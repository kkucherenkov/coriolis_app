import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/shared/queue/mutation_queue.dart';
import 'package:coriolis_companion/shared/queue/mutation_queue_drainer.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockLocalMutationQueue extends Mock implements LocalMutationQueue {}

class MockDio extends Mock implements Dio {}

class MockConnectivity extends Mock implements Connectivity {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PendingMutation _entry({
  String id = 'id1',
  String method = 'PATCH',
  String path = '/characters/abc',
  String? body,
  Map<String, String> headers = const {},
}) =>
    PendingMutation(
      id: id,
      method: method,
      path: path,
      body: body,
      headers: headers,
      createdAt: DateTime.utc(2026, 5, 16),
    );

Response<dynamic> _response(int statusCode) => Response<dynamic>(
      requestOptions: RequestOptions(path: ''),
      statusCode: statusCode,
    );

/// Matcher that asserts `Options.extra['skipMutationQueue'] == true`.
final _hasSkipFlag = predicate<Options>(
  (o) => o.extra?['skipMutationQueue'] == true,
  'Options with skipMutationQueue=true',
);

void main() {
  late MockLocalMutationQueue queue;
  late MockDio dio;
  late MockConnectivity connectivity;
  late StreamController<List<ConnectivityResult>> connectivityCtrl;

  setUp(() {
    queue = MockLocalMutationQueue();
    dio = MockDio();
    connectivity = MockConnectivity();
    connectivityCtrl = StreamController<List<ConnectivityResult>>.broadcast();

    when(() => connectivity.onConnectivityChanged)
        .thenAnswer((_) => connectivityCtrl.stream);

    // Register fallback for Options so captureAny works.
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  tearDown(() async {
    await connectivityCtrl.close();
  });

  MutationQueueDrainer makeDrainer({Duration fade = const Duration(seconds: 2)}) =>
      MutationQueueDrainer(
        queue: queue,
        dio: dio,
        connectivity: connectivity,
        syncedFadeDuration: fade,
      );

  // ── 1. start() is idempotent ─────────────────────────────────────────────

  test('1: start() is idempotent — second call does not re-subscribe', () async {
    when(() => queue.count()).thenAnswer((_) async => 0);

    final drainer = makeDrainer();
    await drainer.start();
    await drainer.start(); // second call should be a no-op

    // onConnectivityChanged is accessed exactly once (first start() call).
    verify(() => connectivity.onConnectivityChanged).called(1);

    await drainer.dispose();
  });

  // ── 2. start() hydrates pending ──────────────────────────────────────────

  test('2: start() hydrates pending from queue.count()', () async {
    when(() => queue.count()).thenAnswer((_) async => 5);

    final drainer = makeDrainer();
    await drainer.start();

    expect(drainer.pending.value, 5);

    await drainer.dispose();
  });

  // ── 3. Online + empty queue → idle, no Dio calls ─────────────────────────

  test('3: wifi with empty queue → status stays idle, no Dio calls', () async {
    when(() => queue.count()).thenAnswer((_) async => 0);
    when(() => queue.list()).thenAnswer((_) async => []);

    final drainer = makeDrainer();
    await drainer.start();

    connectivityCtrl.add([ConnectivityResult.wifi]);
    await Future<void>.delayed(Duration.zero);

    expect(drainer.status.value, MutationQueueStatus.idle);
    verifyNever(() => dio.request<dynamic>(any(), options: any(named: 'options')));

    await drainer.dispose();
  });

  // ── 4. All-success drain → syncing → synced → idle after 2 s ────────────

  test(
      '4: wifi with 3 entries all 200 → syncing→synced, all removed, '
      'pending=0, fades to idle after 2s', () {
    fakeAsync((async) {
      when(() => queue.count()).thenAnswer((_) async => 3);
      final entries = [
        _entry(id: 'a', path: '/a'),
        _entry(id: 'b', path: '/b'),
        _entry(id: 'c', path: '/c'),
      ];
      when(() => queue.list()).thenAnswer((_) async => entries);
      when(() => queue.remove(any())).thenAnswer((_) async {});
      // After removal, count drops to 0.
      var removeCount = 0;
      when(() => queue.remove(any())).thenAnswer((_) async {
        removeCount++;
      });
      when(() => queue.count()).thenAnswer((_) async => 3 - removeCount);

      when(
        () => dio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => _response(200));

      final statuses = <MutationQueueStatus>[];
      final drainer = makeDrainer();
      drainer.status.addListener(() => statuses.add(drainer.status.value));

      async.flushMicrotasks();
      // start
      drainer.start();
      async.flushMicrotasks();

      connectivityCtrl.add([ConnectivityResult.wifi]);
      async.flushMicrotasks();

      expect(statuses, contains(MutationQueueStatus.syncing));
      expect(statuses.last, MutationQueueStatus.synced);
      expect(drainer.pending.value, 0);

      // Verify all three removed.
      verify(() => queue.remove('a')).called(1);
      verify(() => queue.remove('b')).called(1);
      verify(() => queue.remove('c')).called(1);

      // Fast-forward past the 2 s fade.
      async.elapse(const Duration(seconds: 3));

      expect(drainer.status.value, MutationQueueStatus.idle);

      drainer.dispose();
      async.flushMicrotasks();
    });
  });

  // ── 5. Offline connectivity event → no drain ────────────────────────────

  test('5: ConnectivityResult.none → no drain triggered', () async {
    when(() => queue.count()).thenAnswer((_) async => 2);

    final drainer = makeDrainer();
    await drainer.start();

    connectivityCtrl.add([ConnectivityResult.none]);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => queue.list());
    verifyNever(() => dio.request<dynamic>(any(), options: any(named: 'options')));
    expect(drainer.status.value, MutationQueueStatus.idle);

    await drainer.dispose();
  });

  // ── 6. none then mobile → drain runs ────────────────────────────────────

  test('6: none then mobile → drain runs', () async {
    when(() => queue.count()).thenAnswer((_) async => 1);
    when(() => queue.list()).thenAnswer((_) async => [_entry()]);
    when(() => queue.remove(any())).thenAnswer((_) async {});
    when(
      () => dio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => _response(200));

    final drainer = makeDrainer();
    await drainer.start();

    connectivityCtrl.add([ConnectivityResult.none]);
    await Future<void>.delayed(Duration.zero);
    verifyNever(() => queue.list());

    connectivityCtrl.add([ConnectivityResult.mobile]);
    await Future<void>.delayed(Duration.zero);

    verify(() => queue.list()).called(1);

    await drainer.dispose();
  });

  // ── 7. Server returns 500 → error, entry stays ──────────────────────────

  test('7: replay returns 500 → status=error, entry not removed', () async {
    when(() => queue.count()).thenAnswer((_) async => 1);
    when(() => queue.list()).thenAnswer((_) async => [_entry()]);
    when(
      () => dio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => _response(500));

    final drainer = makeDrainer();
    await drainer.start();

    connectivityCtrl.add([ConnectivityResult.wifi]);
    await Future<void>.delayed(Duration.zero);

    expect(drainer.status.value, MutationQueueStatus.error);
    verifyNever(() => queue.remove(any()));

    await drainer.dispose();
  });

  // ── 8. DioException on one of three entries → error, failed stays ────────

  test(
      '8: DioException on entry[0], others succeed → '
      'status=error, failed entry stays, others removed', () async {
    when(() => queue.count()).thenAnswer((_) async => 3);
    final entries = [
      _entry(id: 'fail', path: '/fail'),
      _entry(id: 'ok1', path: '/ok1'),
      _entry(id: 'ok2', path: '/ok2'),
    ];
    when(() => queue.list()).thenAnswer((_) async => entries);
    when(() => queue.remove(any())).thenAnswer((_) async {});

    when(
      () => dio.request<dynamic>(
        '/fail',
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/fail'),
        type: DioExceptionType.connectionError,
      ),
    );
    when(
      () => dio.request<dynamic>(
        '/ok1',
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => _response(200));
    when(
      () => dio.request<dynamic>(
        '/ok2',
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => _response(200));

    final drainer = makeDrainer();
    await drainer.start();

    connectivityCtrl.add([ConnectivityResult.wifi]);
    await Future<void>.delayed(Duration.zero);

    expect(drainer.status.value, MutationQueueStatus.error);
    verifyNever(() => queue.remove('fail'));
    verify(() => queue.remove('ok1')).called(1);
    verify(() => queue.remove('ok2')).called(1);

    await drainer.dispose();
  });

  // ── 9. Re-entrancy guard prevents parallel drain ─────────────────────────

  test('9: mid-flight connectivity flip → _draining guard prevents parallel call',
      () async {
    when(() => queue.count()).thenAnswer((_) async => 1);
    when(() => queue.list()).thenAnswer((_) async => [_entry()]);
    when(() => queue.remove(any())).thenAnswer((_) async {});

    // Slow reply so first drain is still in progress when second event arrives.
    final completer = Completer<Response<dynamic>>();
    when(
      () => dio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) => completer.future);

    final drainer = makeDrainer();
    await drainer.start();

    // First connectivity event starts a drain.
    connectivityCtrl.add([ConnectivityResult.wifi]);
    await Future<void>.delayed(Duration.zero);

    // Second event while first is in flight.
    connectivityCtrl.add([ConnectivityResult.wifi]);
    await Future<void>.delayed(Duration.zero);

    // Unblock the first drain.
    completer.complete(_response(200));
    await Future<void>.delayed(Duration.zero);

    // Dio.request called exactly once for the single queued entry.
    verify(
      () => dio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).called(1);

    await drainer.dispose();
  });

  // ── 10. drainNow() works offline (manual retry) ──────────────────────────

  test('10: drainNow() succeeds even when connectivity is offline', () async {
    when(() => queue.count()).thenAnswer((_) async => 1);
    when(() => queue.list()).thenAnswer((_) async => [_entry()]);
    when(() => queue.remove(any())).thenAnswer((_) async {});
    when(
      () => dio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => _response(200));

    final drainer = makeDrainer();
    await drainer.start();

    // Explicitly no connectivity event; user calls drainNow directly.
    await drainer.drainNow();

    verify(() => queue.remove('id1')).called(1);
    expect(drainer.status.value, MutationQueueStatus.synced);

    await drainer.dispose();
  });

  // ── 11. Every replay carries skipMutationQueue=true ──────────────────────

  test('11: every replay request carries skipMutationQueue=true in Options.extra',
      () async {
    when(() => queue.count()).thenAnswer((_) async => 2);
    final entries = [
      _entry(id: 'a', path: '/a'),
      _entry(id: 'b', path: '/b'),
    ];
    when(() => queue.list()).thenAnswer((_) async => entries);
    when(() => queue.remove(any())).thenAnswer((_) async {});

    final capturedOptions = <Options>[];
    when(
      () => dio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((inv) {
      capturedOptions.add(inv.namedArguments[#options] as Options);
      return Future.value(_response(200));
    });

    final drainer = makeDrainer();
    await drainer.start();
    await drainer.drainNow();

    expect(capturedOptions, hasLength(2));
    for (final opts in capturedOptions) {
      expect(opts, _hasSkipFlag);
    }

    await drainer.dispose();
  });

  // ── 12. Body decoding ────────────────────────────────────────────────────

  test('12a: JSON content-type → body is decoded to a Map', () async {
    const headers = {'content-type': 'application/json'};
    const body = '{"name":"Saga"}';
    when(() => queue.count()).thenAnswer((_) async => 1);
    when(() => queue.list())
        .thenAnswer((_) async => [_entry(body: body, headers: headers)]);
    when(() => queue.remove(any())).thenAnswer((_) async {});

    dynamic capturedData;
    when(
      () => dio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((inv) {
      capturedData = inv.namedArguments[#data];
      return Future.value(_response(200));
    });

    final drainer = makeDrainer();
    await drainer.start();
    await drainer.drainNow();

    expect(capturedData, {'name': 'Saga'});

    await drainer.dispose();
  });

  test('12b: null body → data is null', () async {
    when(() => queue.count()).thenAnswer((_) async => 1);
    when(() => queue.list())
        .thenAnswer((_) async => [_entry(body: null, headers: {})]);
    when(() => queue.remove(any())).thenAnswer((_) async {});

    dynamic capturedData = 'not-null';
    when(
      () => dio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((inv) {
      capturedData = inv.namedArguments[#data];
      return Future.value(_response(200));
    });

    final drainer = makeDrainer();
    await drainer.start();
    await drainer.drainNow();

    expect(capturedData, isNull);

    await drainer.dispose();
  });
}

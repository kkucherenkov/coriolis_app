import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/shared/queue/mutation_queue.dart';
import 'package:coriolis_companion/shared/queue/mutation_queue_interceptor.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockQueue extends Mock implements LocalMutationQueue {}

class _MockConnectivity extends Mock implements Connectivity {}

// ---------------------------------------------------------------------------
// Capturing handlers
// ---------------------------------------------------------------------------

class _CapturingRequestHandler extends RequestInterceptorHandler {
  RequestOptions? capturedNext;
  Response<dynamic>? capturedResolve;

  @override
  void next(RequestOptions options) {
    capturedNext = options;
    // Do NOT call super — avoids "no handler" errors in unit tests.
  }

  @override
  void resolve(Response<dynamic> response, [bool callFollowingResponseInterceptor = false]) {
    capturedResolve = response;
  }
}

class _CapturingErrorHandler extends ErrorInterceptorHandler {
  DioException? capturedNext;
  Response<dynamic>? capturedResolve;

  @override
  void next(DioException err) {
    capturedNext = err;
  }

  @override
  void resolve(Response<dynamic> response) {
    capturedResolve = response;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

RequestOptions _opts({
  String method = 'PATCH',
  String path = '/characters/c1',
  dynamic data,
  Map<String, dynamic>? headers,
  Map<String, dynamic>? extra,
}) {
  final opts = RequestOptions(
    path: path,
    method: method,
    data: data,
    headers: headers ?? {},
    extra: extra ?? {},
  );
  return opts;
}

DioException _netError(
  DioExceptionType type, {
  String method = 'PATCH',
  String path = '/characters/c1',
  Map<String, dynamic>? extra,
}) {
  final req = _opts(method: method, path: path, extra: extra);
  return DioException(requestOptions: req, type: type);
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void main() {
  late _MockQueue queue;
  late _MockConnectivity connectivity;
  late MutationQueueInterceptor sut;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(DioException(
      requestOptions: RequestOptions(path: '/'),
    ));
  });

  setUp(() {
    queue = _MockQueue();
    connectivity = _MockConnectivity();
    sut = MutationQueueInterceptor(queue: queue, connectivity: connectivity);

    // Default stub: online (wifi).
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);

    // Default stub for enqueue.
    when(() => queue.enqueue(
          method: any(named: 'method'),
          path: any(named: 'path'),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        )).thenAnswer((_) async => _fakeMutation());
  });

  // -------------------------------------------------------------------------
  // onRequest — pass-through cases
  // -------------------------------------------------------------------------

  test('1. GET request — next called, no enqueue', () async {
    final handler = _CapturingRequestHandler();
    await sut.onRequest(_opts(method: 'GET'), handler);

    expect(handler.capturedNext, isNotNull);
    expect(handler.capturedResolve, isNull);
    verifyNever(() => queue.enqueue(
          method: any(named: 'method'),
          path: any(named: 'path'),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        ));
  });

  test('2. POST request — next called, no enqueue', () async {
    final handler = _CapturingRequestHandler();
    await sut.onRequest(_opts(method: 'POST'), handler);

    expect(handler.capturedNext, isNotNull);
    expect(handler.capturedResolve, isNull);
    verifyNever(() => queue.enqueue(
          method: any(named: 'method'),
          path: any(named: 'path'),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        ));
  });

  // -------------------------------------------------------------------------
  // onRequest — offline enqueue cases
  // -------------------------------------------------------------------------

  test('3. PATCH offline — enqueued with method/path/body, Authorization stripped, resolve 200 {}',
      () async {
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.none]);

    final handler = _CapturingRequestHandler();
    final opts = _opts(
      method: 'PATCH',
      path: '/characters/c1',
      data: {'name': 'Tael'},
      headers: {'Authorization': 'Bearer old-token', 'Content-Type': 'application/json'},
    );

    await sut.onRequest(opts, handler);

    // Capture all four named args.
    // Empirically, mocktail appends them in call-site declaration order from
    // the verify() closure: method[0], path[1], body[2], headers[3] — but
    // the runtime order turned out to be [method, path, headers, body].
    // We avoid relying on magic indices and instead look up by type/value.
    final v = verify(() => queue.enqueue(
          method: captureAny(named: 'method'),
          path: captureAny(named: 'path'),
          body: captureAny(named: 'body'),
          headers: captureAny(named: 'headers'),
        ));
    v.called(1);
    final captured = v.captured;

    final capturedMethod = captured[0] as String;
    final capturedPath = captured[1] as String;
    // mocktail actual order: [method, path, headers, body]
    final capturedHeaders = captured[2] as Map<String, String>;
    final capturedBody = captured[3] as String?;

    expect(capturedMethod, 'PATCH');
    expect(capturedPath, '/characters/c1');
    expect(capturedBody, '{"name":"Tael"}');
    expect(capturedHeaders.keys.map((k) => k.toLowerCase()), isNot(contains('authorization')));

    expect(handler.capturedResolve?.statusCode, 200);
    expect(handler.capturedResolve?.data, <String, dynamic>{});
    expect(handler.capturedNext, isNull);
  });

  test('4. PUT offline — enqueued', () async {
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.none]);

    final handler = _CapturingRequestHandler();
    await sut.onRequest(_opts(method: 'PUT', data: {'hp': 3}), handler);

    final captured = verify(() => queue.enqueue(
          method: captureAny(named: 'method'),
          path: any(named: 'path'),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        )).captured;

    expect(captured[0], 'PUT');
    expect(handler.capturedResolve?.statusCode, 200);
  });

  test('5. DELETE offline — body is null', () async {
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.none]);

    final handler = _CapturingRequestHandler();
    await sut.onRequest(_opts(method: 'DELETE', data: null), handler);

    final captured = verify(() => queue.enqueue(
          method: any(named: 'method'),
          path: any(named: 'path'),
          body: captureAny(named: 'body'),
          headers: any(named: 'headers'),
        )).captured;

    expect(captured[0], isNull);
    expect(handler.capturedResolve?.statusCode, 200);
  });

  test('6. PATCH online (wifi) — next called, no enqueue', () async {
    // connectivity already stubbed to wifi in setUp.
    final handler = _CapturingRequestHandler();
    await sut.onRequest(_opts(method: 'PATCH'), handler);

    expect(handler.capturedNext, isNotNull);
    expect(handler.capturedResolve, isNull);
    verifyNever(() => queue.enqueue(
          method: any(named: 'method'),
          path: any(named: 'path'),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        ));
  });

  // -------------------------------------------------------------------------
  // onError — network error enqueue cases
  // -------------------------------------------------------------------------

  test('7. onError connectionError on PATCH — enqueue + resolve 200', () async {
    final handler = _CapturingErrorHandler();
    await sut.onError(
      _netError(DioExceptionType.connectionError),
      handler,
    );

    verify(() => queue.enqueue(
          method: any(named: 'method'),
          path: any(named: 'path'),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        )).called(1);
    expect(handler.capturedResolve?.statusCode, 200);
    expect(handler.capturedNext, isNull);
  });

  test('8. onError connectionTimeout on PATCH — enqueue + resolve 200', () async {
    final handler = _CapturingErrorHandler();
    await sut.onError(
      _netError(DioExceptionType.connectionTimeout),
      handler,
    );

    verify(() => queue.enqueue(
          method: any(named: 'method'),
          path: any(named: 'path'),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        )).called(1);
    expect(handler.capturedResolve?.statusCode, 200);
  });

  test('9. onError sendTimeout on PATCH — enqueue + resolve 200', () async {
    final handler = _CapturingErrorHandler();
    await sut.onError(
      _netError(DioExceptionType.sendTimeout),
      handler,
    );

    verify(() => queue.enqueue(
          method: any(named: 'method'),
          path: any(named: 'path'),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        )).called(1);
    expect(handler.capturedResolve?.statusCode, 200);
  });

  test('10. onError receiveTimeout on PATCH — enqueue + resolve 200', () async {
    final handler = _CapturingErrorHandler();
    await sut.onError(
      _netError(DioExceptionType.receiveTimeout),
      handler,
    );

    verify(() => queue.enqueue(
          method: any(named: 'method'),
          path: any(named: 'path'),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        )).called(1);
    expect(handler.capturedResolve?.statusCode, 200);
  });

  test('11. onError badResponse (4xx/5xx) on PATCH — next called, no enqueue', () async {
    final handler = _CapturingErrorHandler();
    await sut.onError(
      _netError(DioExceptionType.badResponse),
      handler,
    );

    verifyNever(() => queue.enqueue(
          method: any(named: 'method'),
          path: any(named: 'path'),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        ));
    expect(handler.capturedNext, isNotNull);
    expect(handler.capturedResolve, isNull);
  });

  test('12. onError network error on POST — next called, no enqueue', () async {
    final handler = _CapturingErrorHandler();
    await sut.onError(
      _netError(DioExceptionType.connectionError, method: 'POST'),
      handler,
    );

    verifyNever(() => queue.enqueue(
          method: any(named: 'method'),
          path: any(named: 'path'),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        ));
    expect(handler.capturedNext, isNotNull);
  });

  // -------------------------------------------------------------------------
  // skipMutationQueue bypass
  // -------------------------------------------------------------------------

  test('13. skipMutationQueue=true offline — next called, no enqueue', () async {
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.none]);

    final handler = _CapturingRequestHandler();
    await sut.onRequest(
      _opts(method: 'PATCH', extra: {'skipMutationQueue': true}),
      handler,
    );

    verifyNever(() => queue.enqueue(
          method: any(named: 'method'),
          path: any(named: 'path'),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        ));
    expect(handler.capturedNext, isNotNull);
    expect(handler.capturedResolve, isNull);
  });

  // -------------------------------------------------------------------------
  // Authorization stripping
  // -------------------------------------------------------------------------

  test('14. Authorization header stripped on enqueue', () async {
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.none]);

    final handler = _CapturingRequestHandler();
    await sut.onRequest(
      _opts(
        method: 'PATCH',
        headers: {
          'Authorization': 'Bearer xyz',
          'Content-Type': 'application/json',
          'X-Custom': 'kept',
        },
      ),
      handler,
    );

    final captured = verify(() => queue.enqueue(
          method: any(named: 'method'),
          path: any(named: 'path'),
          body: any(named: 'body'),
          headers: captureAny(named: 'headers'),
        )).captured;

    final capturedHeaders = captured[0] as Map<String, String>;
    final lowerKeys = capturedHeaders.keys.map((k) => k.toLowerCase()).toList();
    expect(lowerKeys, isNot(contains('authorization')));
    expect(capturedHeaders['X-Custom'], 'kept');
  });

  // -------------------------------------------------------------------------
  // Multi-result connectivity
  // -------------------------------------------------------------------------

  test('15. Connectivity [wifi, none] — treated as online, next called, no enqueue', () async {
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi, ConnectivityResult.none]);

    final handler = _CapturingRequestHandler();
    await sut.onRequest(_opts(method: 'PATCH'), handler);

    verifyNever(() => queue.enqueue(
          method: any(named: 'method'),
          path: any(named: 'path'),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        ));
    expect(handler.capturedNext, isNotNull);
    expect(handler.capturedResolve, isNull);
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PendingMutation _fakeMutation() => PendingMutation(
      id: 'test-id',
      method: 'PATCH',
      path: '/characters/c1',
      body: null,
      headers: const {},
      createdAt: DateTime.utc(2026, 5, 16),
    );

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/i18n/strings.g.dart';
import 'package:coriolis_companion/shared/queue/mutation_queue.dart';
import 'package:coriolis_companion/shared/queue/mutation_queue_drainer.dart';
import 'package:coriolis_companion/shared/queue/offline_queue_banner.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockLocalMutationQueue extends Mock implements LocalMutationQueue {}

class _MockDio extends Mock implements Dio {}

class _MockConnectivity extends Mock implements Connectivity {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps [banner] in a minimal [MaterialApp] + [TranslationProvider] set to
/// [localeRaw] (defaults to 'en').
Widget _wrap(Widget banner, {String localeRaw = 'en'}) {
  LocaleSettings.setLocaleRaw(localeRaw);
  return TranslationProvider(
    child: Builder(
      builder: (ctx) => MaterialApp(
        locale: TranslationProvider.of(ctx).flutterLocale,
        home: Scaffold(body: Column(children: [banner])),
      ),
    ),
  );
}

MutationQueueDrainer _makeDrainer(
  _MockLocalMutationQueue queue,
  _MockDio dio,
  _MockConnectivity connectivity,
) {
  when(() => connectivity.onConnectivityChanged)
      .thenAnswer((_) => const Stream.empty());
  return MutationQueueDrainer(
    queue: queue,
    dio: dio,
    connectivity: connectivity,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockLocalMutationQueue queue;
  late _MockDio dio;
  late _MockConnectivity connectivity;

  setUp(() {
    queue = _MockLocalMutationQueue();
    dio = _MockDio();
    connectivity = _MockConnectivity();
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  // ── 1. idle + pending==0 → no banner ──────────────────────────────────────

  testWidgets('1: idle status with 0 pending renders SizedBox.shrink',
      (tester) async {
    final drainer = _makeDrainer(queue, dio, connectivity);
    drainer.status.value = MutationQueueStatus.idle;
    drainer.pending.value = 0;

    await tester.pumpWidget(_wrap(OfflineQueueBanner(drainer: drainer)));
    await tester.pump();

    // AnimatedSize collapses to zero height when tone is null; a SizedBox.shrink is present.
    expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
    expect(find.textContaining('Offline'), findsNothing);
    expect(find.textContaining('Syncing'), findsNothing);
    expect(find.textContaining('saved'), findsNothing);
  });

  // ── 2. idle + pending>0 → warning copy ────────────────────────────────────

  testWidgets('2: idle status with 3 pending shows warning copy (en)',
      (tester) async {
    final drainer = _makeDrainer(queue, dio, connectivity);
    drainer.status.value = MutationQueueStatus.idle;
    drainer.pending.value = 3;

    await tester.pumpWidget(_wrap(OfflineQueueBanner(drainer: drainer)));
    await tester.pump();

    expect(find.text('Offline — 3 edits waiting to sync'), findsOneWidget);
  });

  // ── 3. syncing → info copy ────────────────────────────────────────────────

  testWidgets('3: syncing status shows syncing copy', (tester) async {
    final drainer = _makeDrainer(queue, dio, connectivity);
    drainer.status.value = MutationQueueStatus.syncing;
    drainer.pending.value = 2;

    await tester.pumpWidget(_wrap(OfflineQueueBanner(drainer: drainer)));
    await tester.pump();

    expect(find.text('Syncing your changes…'), findsOneWidget);
  });

  // ── 4. synced → success copy ──────────────────────────────────────────────

  testWidgets('4: synced status shows success copy', (tester) async {
    final drainer = _makeDrainer(queue, dio, connectivity);
    drainer.status.value = MutationQueueStatus.synced;
    drainer.pending.value = 0;

    await tester.pumpWidget(_wrap(OfflineQueueBanner(drainer: drainer)));
    await tester.pump();

    expect(find.text('All changes saved'), findsOneWidget);
  });

  // ── 5. error + pending>0 → error copy + retry button ─────────────────────

  testWidgets('5: error status shows error copy and Retry button', (tester) async {
    final drainer = _makeDrainer(queue, dio, connectivity);
    drainer.status.value = MutationQueueStatus.error;
    drainer.pending.value = 2;

    await tester.pumpWidget(_wrap(OfflineQueueBanner(drainer: drainer)));
    await tester.pump();

    expect(find.text("Couldn't sync 2 changes"), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Retry'), findsOneWidget);
  });

  // ── 6. tapping Retry calls drainer.drainNow() ─────────────────────────────

  testWidgets('6: tapping Retry invokes drainNow (queue.list is called)',
      (tester) async {
    final drainer = _makeDrainer(queue, dio, connectivity);
    drainer.status.value = MutationQueueStatus.error;
    drainer.pending.value = 1;

    // drainNow() calls queue.list() first — stub it to return an empty list so
    // the drain completes cleanly without attempting real Dio requests.
    when(() => queue.list()).thenAnswer((_) async => []);
    when(() => queue.count()).thenAnswer((_) async => 0);

    await tester.pumpWidget(_wrap(OfflineQueueBanner(drainer: drainer)));
    await tester.pump();

    await tester.tap(find.widgetWithText(TextButton, 'Retry'));
    await tester.pumpAndSettle();

    verify(() => queue.list()).called(1);
  });

  // ── 7. ru locale — pending copy renders in Russian ────────────────────────

  testWidgets('7: ru locale renders Russian pending copy', (tester) async {
    addTearDown(() => LocaleSettings.setLocaleRaw('en'));

    final drainer = _makeDrainer(queue, dio, connectivity);
    drainer.status.value = MutationQueueStatus.idle;
    drainer.pending.value = 5;

    await tester.pumpWidget(
      _wrap(OfflineQueueBanner(drainer: drainer), localeRaw: 'ru'),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Офлайн — 5 изменений ждут отправки'),
      findsOneWidget,
    );
  });
}

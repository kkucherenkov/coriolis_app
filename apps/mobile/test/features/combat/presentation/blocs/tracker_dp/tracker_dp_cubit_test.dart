import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/combat/presentation/blocs/tracker_dp/tracker_dp_cubit.dart';
import 'package:coriolis_companion/features/sessions/domain/game_session.dart';
import 'package:coriolis_companion/features/sessions/domain/session_repository.dart';

class _MockSessionRepository extends Mock implements SessionRepository {}

GameSession _session({int dpCount = 3}) => GameSession(
      id: 'sess-1',
      ownerId: 'u1',
      name: 'Bridge',
      status: 'active',
      dpCount: dpCount,
      characterIds: const [],
      createdAt: DateTime(2026, 5, 15),
      updatedAt: DateTime(2026, 5, 15),
    );

void main() {
  late _MockSessionRepository repo;

  setUp(() {
    repo = _MockSessionRepository();
  });

  TrackerDpCubit makeCubit({int initialCount = 3}) => TrackerDpCubit(
        repository: repo,
        sessionId: 'sess-1',
        initialCount: initialCount,
      );

  test('seeds count from initialCount, idle, no error', () {
    final c = makeCubit(initialCount: 7);
    expect(c.state.count, 7);
    expect(c.state.busy, isFalse);
    expect(c.state.errorMessage, isNull);
  });

  blocTest<TrackerDpCubit, TrackerDpState>(
    'adjustDp +1 emits busy then updated count from server',
    build: () {
      when(() => repo.adjustDp(any(), delta: any(named: 'delta')))
          .thenAnswer((_) async => _session(dpCount: 4));
      return makeCubit();
    },
    act: (c) async {
      final ok = await c.adjustDp(1);
      expect(ok, isTrue);
    },
    expect: () => [
      isA<TrackerDpState>().having((s) => s.busy, 'busy', isTrue),
      isA<TrackerDpState>()
          .having((s) => s.busy, 'busy', isFalse)
          .having((s) => s.count, 'count', 4),
    ],
    verify: (_) {
      verify(() => repo.adjustDp('sess-1', delta: 1)).called(1);
    },
  );

  blocTest<TrackerDpCubit, TrackerDpState>(
    'adjustDp -1 surfaces server error via errorMessage',
    build: () {
      when(() => repo.adjustDp(any(), delta: any(named: 'delta')))
          .thenThrow(StateError('422 DP_BELOW_ZERO'));
      return makeCubit(initialCount: 0);
    },
    act: (c) async {
      final ok = await c.adjustDp(-1);
      expect(ok, isFalse);
    },
    expect: () => [
      isA<TrackerDpState>().having((s) => s.busy, 'busy', isTrue),
      isA<TrackerDpState>()
          .having((s) => s.busy, 'busy', isFalse)
          .having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('DP_BELOW_ZERO'),
          ),
    ],
  );

  blocTest<TrackerDpCubit, TrackerDpState>(
    'applyDpChanged patches count without a round-trip',
    build: makeCubit,
    act: (c) => c.applyDpChanged(9),
    expect: () => [
      isA<TrackerDpState>().having((s) => s.count, 'count', 9),
    ],
    verify: (_) {
      verifyNever(() => repo.adjustDp(any(), delta: any(named: 'delta')));
    },
  );

  blocTest<TrackerDpCubit, TrackerDpState>(
    'applyDpChanged is a no-op when the count is unchanged',
    build: makeCubit,
    act: (c) => c.applyDpChanged(3),
    expect: () => const <TrackerDpState>[],
  );

  blocTest<TrackerDpCubit, TrackerDpState>(
    'adjustDp is a no-op while busy',
    build: () {
      when(() => repo.adjustDp(any(), delta: any(named: 'delta')))
          .thenAnswer((_) async => _session(dpCount: 4));
      return makeCubit()..emit(const TrackerDpState(count: 3, busy: true));
    },
    act: (c) async {
      final ok = await c.adjustDp(1);
      expect(ok, isFalse);
    },
    expect: () => const <TrackerDpState>[],
    verify: (_) {
      verifyNever(() => repo.adjustDp(any(), delta: any(named: 'delta')));
    },
  );
}

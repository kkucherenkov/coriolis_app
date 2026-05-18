import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/game_sessions/domain/game_session.dart';
import 'package:coriolis_companion/features/game_sessions/domain/invite.dart';
import 'package:coriolis_companion/features/game_sessions/domain/session_repository.dart';
import 'package:coriolis_companion/features/game_sessions/presentation/blocs/session_detail/session_detail_cubit.dart';
import 'package:coriolis_companion/features/game_sessions/presentation/blocs/session_detail/session_detail_state.dart';
import 'package:coriolis_companion/shared/realtime/session_realtime.dart';

class _MockSessionRepository extends Mock implements SessionRepository {}

/// Stub realtime — `SessionRealtime` is a concrete class, but the kick path
/// never touches it (no `load()`, no `_startRealtime`), so the stub never
/// runs anything beyond construction.
class _StubSessionRealtime extends Mock implements SessionRealtime {}

void main() {
  group('SessionDetailCubit.kickMember', () {
    late _MockSessionRepository repo;
    late _StubSessionRealtime realtime;

    final gm = GameSessionMember(
      id: 'mem-gm',
      userId: 'user-gm',
      role: 'gm',
      displayName: 'Sara the Maestro',
      joinedAt: DateTime(2026, 5, 16),
    );
    final player = GameSessionMember(
      id: 'mem-player',
      userId: 'user-player',
      role: 'player',
      displayName: 'Adric',
      joinedAt: DateTime(2026, 5, 17),
    );
    final session = GameSession(
      id: 'gs-1',
      ownerId: 'user-gm',
      name: 'The Long Night',
      status: 'active',
      dpCount: 3,
      members: [gm, player],
      createdAt: DateTime(2026, 5, 16),
      updatedAt: DateTime(2026, 5, 17),
    );

    setUp(() {
      repo = _MockSessionRepository();
      realtime = _StubSessionRealtime();
      // The cubit's `close()` awaits `realtime.dispose()`; the auto-stub
      // returns `null` which can't satisfy `Future<void>`.
      when(() => realtime.dispose()).thenAnswer((_) async {});
    });

    blocTest<SessionDetailCubit, SessionDetailState>(
      'happy path: marks the row busy, then refetches without the kicked member',
      build: () {
        when(() => repo.removeMember('gs-1', 'mem-player'))
            .thenAnswer((_) async {});
        when(() => repo.get('gs-1')).thenAnswer(
          (_) async => session.copyWith(members: [gm]),
        );
        return SessionDetailCubit(repository: repo, realtime: realtime);
      },
      seed: () => SessionDetailState(
        status: SessionDetailStatus.loaded,
        session: session,
      ),
      act: (cubit) => cubit.kickMember('mem-player'),
      expect: () => [
        // Busy spinner armed on the per-row id.
        SessionDetailState(
          status: SessionDetailStatus.loaded,
          session: session,
          kickBusyMembershipId: 'mem-player',
        ),
        // Server-side roster after re-fetch — only the GM remains.
        SessionDetailState(
          status: SessionDetailStatus.loaded,
          session: session.copyWith(members: [gm]),
        ),
      ],
      verify: (_) {
        verify(() => repo.removeMember('gs-1', 'mem-player')).called(1);
        verify(() => repo.get('gs-1')).called(1);
      },
    );

    blocTest<SessionDetailCubit, SessionDetailState>(
      'error path: surfaces the exception in kickError and clears the busy flag',
      build: () {
        when(() => repo.removeMember('gs-1', 'mem-player'))
            .thenThrow(Exception('403 Forbidden'));
        return SessionDetailCubit(repository: repo, realtime: realtime);
      },
      seed: () => SessionDetailState(
        status: SessionDetailStatus.loaded,
        session: session,
      ),
      act: (cubit) => cubit.kickMember('mem-player'),
      expect: () => [
        SessionDetailState(
          status: SessionDetailStatus.loaded,
          session: session,
          kickBusyMembershipId: 'mem-player',
        ),
        isA<SessionDetailState>()
            .having((s) => s.kickBusyMembershipId, 'kickBusyMembershipId', isNull)
            .having((s) => s.kickError, 'kickError', contains('403 Forbidden'))
            .having((s) => s.session, 'session', session),
      ],
      verify: (_) {
        verify(() => repo.removeMember('gs-1', 'mem-player')).called(1);
        verifyNever(() => repo.get(any()));
      },
    );

    blocTest<SessionDetailCubit, SessionDetailState>(
      'noop when state.session is null (no session loaded yet)',
      build: () =>
          SessionDetailCubit(repository: repo, realtime: realtime),
      act: (cubit) => cubit.kickMember('mem-player'),
      expect: () => const <SessionDetailState>[],
      verify: (_) {
        verifyNever(() => repo.removeMember(any(), any()));
        verifyNever(() => repo.get(any()));
      },
    );
  });
}

// `Invite*` is imported so the mocktail-generated null fallback for the
// invite-related repository methods doesn't pull in a transitive package.
// ignore: unused_element
typedef _KeepInvitesImported = InviteMetadata;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/sessions/domain/player_session_repository.dart';
import 'package:coriolis_companion/features/sessions/domain/player_membership.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/player_sessions_list/player_sessions_list_cubit.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/player_sessions_list/player_sessions_list_state.dart';

class _MockPlayerSessionRepository extends Mock
    implements PlayerSessionRepository {}

void main() {
  group('PlayerSessionsListCubit', () {
    late _MockPlayerSessionRepository repo;

    setUp(() {
      repo = _MockPlayerSessionRepository();
    });

    final membership = PlayerMembership(
      membershipId: 'm-1',
      gameSessionId: 'gs-1',
      sessionName: 'The Mercy of Kua',
      role: 'player',
      joinedAt: DateTime(2026, 5, 16),
    );

    test('initial state', () {
      final cubit = PlayerSessionsListCubit(repository: repo);
      expect(cubit.state.status, PlayerSessionsStatus.initial);
      expect(cubit.state.memberships, isEmpty);
    });

    blocTest<PlayerSessionsListCubit, PlayerSessionsListState>(
      'emits loading then success with memberships',
      build: () {
        when(() => repo.getMyMemberships())
            .thenAnswer((_) async => [membership]);
        return PlayerSessionsListCubit(repository: repo);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const PlayerSessionsListState(status: PlayerSessionsStatus.loading),
        PlayerSessionsListState(
          status: PlayerSessionsStatus.success,
          memberships: [membership],
        ),
      ],
      verify: (_) =>
          verify(() => repo.getMyMemberships()).called(1),
    );

    blocTest<PlayerSessionsListCubit, PlayerSessionsListState>(
      'emits loading then success with empty list',
      build: () {
        when(() => repo.getMyMemberships()).thenAnswer((_) async => []);
        return PlayerSessionsListCubit(repository: repo);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const PlayerSessionsListState(status: PlayerSessionsStatus.loading),
        const PlayerSessionsListState(
          status: PlayerSessionsStatus.success,
          memberships: [],
        ),
      ],
    );

    blocTest<PlayerSessionsListCubit, PlayerSessionsListState>(
      'emits loading then failure on exception',
      build: () {
        when(() => repo.getMyMemberships())
            .thenThrow(Exception('network error'));
        return PlayerSessionsListCubit(repository: repo);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const PlayerSessionsListState(status: PlayerSessionsStatus.loading),
        isA<PlayerSessionsListState>().having(
          (s) => s.status,
          'status',
          PlayerSessionsStatus.failure,
        ),
      ],
    );

    blocTest<PlayerSessionsListCubit, PlayerSessionsListState>(
      'leaveSession calls repository and reloads on success',
      build: () {
        when(() => repo.leaveSession(any(), any()))
            .thenAnswer((_) async {});
        when(() => repo.getMyMemberships()).thenAnswer((_) async => []);
        return PlayerSessionsListCubit(repository: repo);
      },
      act: (cubit) => cubit.leaveSession(
        membershipId: 'm-1',
        gameSessionId: 'gs-1',
      ),
      expect: () => [
        const PlayerSessionsListState(status: PlayerSessionsStatus.loading),
        const PlayerSessionsListState(
          status: PlayerSessionsStatus.success,
          memberships: [],
        ),
      ],
      verify: (_) {
        verify(() => repo.leaveSession('m-1', 'gs-1')).called(1);
        verify(() => repo.getMyMemberships()).called(1);
      },
    );

    blocTest<PlayerSessionsListCubit, PlayerSessionsListState>(
      'leaveSession emits errorMessage on failure',
      build: () {
        when(() => repo.leaveSession(any(), any()))
            .thenThrow(Exception('leave failed'));
        return PlayerSessionsListCubit(repository: repo);
      },
      seed: () => PlayerSessionsListState(
        status: PlayerSessionsStatus.success,
        memberships: [membership],
      ),
      act: (cubit) => cubit.leaveSession(
        membershipId: 'm-1',
        gameSessionId: 'gs-1',
      ),
      expect: () => [
        isA<PlayerSessionsListState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          isNotNull,
        ),
      ],
    );
  });
}

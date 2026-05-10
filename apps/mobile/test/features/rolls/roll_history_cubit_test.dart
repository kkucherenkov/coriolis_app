import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/rolls/domain/roll.dart';
import 'package:coriolis_companion/features/rolls/domain/roll_repository.dart';
import 'package:coriolis_companion/features/rolls/presentation/blocs/roll_history/roll_history_cubit.dart';
import 'package:coriolis_companion/features/rolls/presentation/blocs/roll_history/roll_history_state.dart';

class _MockRollRepository extends Mock implements RollRepository {}

Roll _roll(String id, {bool pushed = false, int hits = 1}) => Roll(
      id: id,
      characterId: 'char-1',
      label: 'Roll $id',
      pool: 5,
      dice: const [6, 5, 3, 1, 6],
      hits: hits,
      pushed: pushed,
      createdAt: DateTime.utc(2026, 5, 10),
    );

void main() {
  late _MockRollRepository repo;

  setUp(() {
    repo = _MockRollRepository();
  });

  group('RollHistoryCubit', () {
    blocTest<RollHistoryCubit, RollHistoryState>(
      'load: emits loading → loaded with the repository result',
      build: () {
        when(() => repo.listRolls('char-1', limit: 50))
            .thenAnswer((_) async => [_roll('a'), _roll('b')]);
        return RollHistoryCubit(repository: repo);
      },
      act: (cubit) => cubit.load('char-1'),
      expect: () => [
        const RollHistoryState(status: RollHistoryStatus.loading),
        RollHistoryState(
          status: RollHistoryStatus.loaded,
          rolls: [_roll('a'), _roll('b')],
        ),
      ],
    );

    blocTest<RollHistoryCubit, RollHistoryState>(
      'load: emits loading → error when listRolls throws',
      build: () {
        when(() => repo.listRolls(any(), limit: any(named: 'limit')))
            .thenThrow(StateError('Network down'));
        return RollHistoryCubit(repository: repo);
      },
      act: (cubit) => cubit.load('char-1'),
      skip: 1,
      expect: () => [
        isA<RollHistoryState>()
            .having((s) => s.status, 'status', RollHistoryStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', contains('Network down')),
      ],
    );

    blocTest<RollHistoryCubit, RollHistoryState>(
      'prependRoll: places the new roll at the head and dedups by id',
      build: () => RollHistoryCubit(repository: repo),
      seed: () => RollHistoryState(
        status: RollHistoryStatus.loaded,
        rolls: [_roll('a'), _roll('b')],
      ),
      act: (cubit) => cubit
        ..prependRoll(_roll('c'))
        ..prependRoll(_roll('a', hits: 9)), // duplicate id, latest wins
      expect: () => [
        RollHistoryState(
          status: RollHistoryStatus.loaded,
          rolls: [_roll('c'), _roll('a'), _roll('b')],
        ),
        RollHistoryState(
          status: RollHistoryStatus.loaded,
          rolls: [_roll('a', hits: 9), _roll('c'), _roll('b')],
        ),
      ],
    );

    blocTest<RollHistoryCubit, RollHistoryState>(
      'prependRoll: caps the visible list at 50 entries',
      build: () => RollHistoryCubit(repository: repo),
      seed: () => RollHistoryState(
        status: RollHistoryStatus.loaded,
        rolls: List.generate(50, (i) => _roll('row-$i')),
      ),
      act: (cubit) => cubit.prependRoll(_roll('fresh')),
      verify: (cubit) {
        expect(cubit.state.rolls.length, 50);
        expect(cubit.state.rolls.first.id, 'fresh');
        expect(cubit.state.rolls.last.id, 'row-48');
      },
    );

    blocTest<RollHistoryCubit, RollHistoryState>(
      'updateRoll: replaces the matching row in place',
      build: () => RollHistoryCubit(repository: repo),
      seed: () => RollHistoryState(
        status: RollHistoryStatus.loaded,
        rolls: [_roll('a'), _roll('b'), _roll('c')],
      ),
      act: (cubit) => cubit.updateRoll(_roll('b', pushed: true, hits: 4)),
      expect: () => [
        RollHistoryState(
          status: RollHistoryStatus.loaded,
          rolls: [_roll('a'), _roll('b', pushed: true, hits: 4), _roll('c')],
        ),
      ],
    );

    blocTest<RollHistoryCubit, RollHistoryState>(
      'updateRoll: prepends when the id is unknown (covers Centrifugo-before-load)',
      build: () => RollHistoryCubit(repository: repo),
      seed: () => RollHistoryState(
        status: RollHistoryStatus.loaded,
        rolls: [_roll('a')],
      ),
      act: (cubit) => cubit.updateRoll(_roll('z', pushed: true)),
      expect: () => [
        RollHistoryState(
          status: RollHistoryStatus.loaded,
          rolls: [_roll('z', pushed: true), _roll('a')],
        ),
      ],
    );
  });
}

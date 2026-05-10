import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/rolls/domain/roll.dart';
import 'package:coriolis_companion/features/rolls/domain/roll_repository.dart';
import 'package:coriolis_companion/features/rolls/presentation/blocs/dice_roller/dice_roller_cubit.dart';
import 'package:coriolis_companion/features/rolls/presentation/blocs/dice_roller/dice_roller_state.dart';

class _MockRollRepository extends Mock implements RollRepository {}

final _rolledFreshly = Roll(
  id: 'roll-1',
  characterId: 'char-1',
  label: 'Pilot · Evade',
  pool: 5,
  dice: const [6, 5, 3, 1, 6],
  hits: 2,
  pushed: false,
  createdAt: DateTime.utc(2026, 5, 10),
);

final _rolledPushed = Roll(
  id: 'roll-1',
  characterId: 'char-1',
  label: 'Pilot · Evade',
  pool: 5,
  dice: const [6, 6, 3, 4, 6],
  hits: 3,
  pushed: true,
  createdAt: DateTime.utc(2026, 5, 10),
);

void main() {
  late _MockRollRepository repo;

  setUp(() {
    repo = _MockRollRepository();
  });

  group('DiceRollerCubit', () {
    group('pool stepper', () {
      blocTest<DiceRollerCubit, DiceRollerState>(
        'increment / decrement clamp to [1, 10]',
        build: () => DiceRollerCubit(repository: repo),
        seed: () => const DiceRollerState(pool: 9),
        act: (cubit) => cubit
          ..incrementPool()
          ..incrementPool() // attempts 11 — clamped to 10
          ..setPool(0)
          ..decrementPool(), // already at 1 — no-op
        expect: () => const [
          DiceRollerState(pool: 10),
          // Second incrementPool stays at 10 — no emit; bloc_test would
          // skip an identical state, so we don't list it again.
          DiceRollerState(pool: 1),
        ],
      );
    });

    group('roll', () {
      blocTest<DiceRollerCubit, DiceRollerState>(
        'rejects empty label without hitting the repository',
        build: () => DiceRollerCubit(repository: repo),
        act: (cubit) => cubit.roll(characterId: 'char-1'),
        expect: () => [
          const DiceRollerState(
            status: DiceRollerStatus.error,
            errorMessage: 'Label is required',
          ),
        ],
        verify: (_) => verifyNever(() => repo.createRoll(
              characterId: any(named: 'characterId'),
              label: any(named: 'label'),
              pool: any(named: 'pool'),
              gameSessionId: any(named: 'gameSessionId'),
            )),
      );

      blocTest<DiceRollerCubit, DiceRollerState>(
        'happy path: idle → rolling → idle with lastRoll',
        build: () {
          when(
            () => repo.createRoll(
              characterId: 'char-1',
              label: 'Pilot · Evade',
              pool: 5,
              gameSessionId: null,
            ),
          ).thenAnswer((_) async => _rolledFreshly);
          return DiceRollerCubit(repository: repo);
        },
        seed: () => const DiceRollerState(label: 'Pilot · Evade'),
        act: (cubit) => cubit.roll(characterId: 'char-1'),
        expect: () => [
          const DiceRollerState(
            status: DiceRollerStatus.rolling,
            label: 'Pilot · Evade',
          ),
          DiceRollerState(
            label: 'Pilot · Evade',
            lastRoll: _rolledFreshly,
          ),
        ],
      );

      blocTest<DiceRollerCubit, DiceRollerState>(
        'repository failure surfaces via errorMessage',
        build: () {
          when(
            () => repo.createRoll(
              characterId: any(named: 'characterId'),
              label: any(named: 'label'),
              pool: any(named: 'pool'),
              gameSessionId: any(named: 'gameSessionId'),
            ),
          ).thenThrow(StateError('Network down'));
          return DiceRollerCubit(repository: repo);
        },
        seed: () => const DiceRollerState(label: 'Pilot · Evade'),
        act: (cubit) => cubit.roll(characterId: 'char-1'),
        skip: 1, // skip the rolling state
        expect: () => [
          isA<DiceRollerState>()
              .having((s) => s.status, 'status', DiceRollerStatus.error)
              .having((s) => s.errorMessage, 'errorMessage', contains('Network down')),
        ],
      );
    });

    group('push', () {
      blocTest<DiceRollerCubit, DiceRollerState>(
        'replaces lastRoll with the pushed result',
        build: () {
          when(() => repo.pushRoll('roll-1'))
              .thenAnswer((_) async => _rolledPushed);
          return DiceRollerCubit(repository: repo);
        },
        seed: () => DiceRollerState(lastRoll: _rolledFreshly),
        act: (cubit) => cubit.push(),
        expect: () => [
          DiceRollerState(
            status: DiceRollerStatus.pushing,
            lastRoll: _rolledFreshly,
          ),
          DiceRollerState(lastRoll: _rolledPushed),
        ],
      );

      blocTest<DiceRollerCubit, DiceRollerState>(
        'is a no-op when lastRoll is null',
        build: () => DiceRollerCubit(repository: repo),
        act: (cubit) => cubit.push(),
        expect: () => <DiceRollerState>[],
        verify: (_) => verifyNever(() => repo.pushRoll(any())),
      );

      blocTest<DiceRollerCubit, DiceRollerState>(
        'is a no-op when the roll has already been pushed',
        build: () => DiceRollerCubit(repository: repo),
        seed: () => DiceRollerState(lastRoll: _rolledPushed),
        act: (cubit) => cubit.push(),
        expect: () => <DiceRollerState>[],
        verify: (_) => verifyNever(() => repo.pushRoll(any())),
      );
    });
  });
}

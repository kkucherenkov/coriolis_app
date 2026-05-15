import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/ships/domain/ship.dart';
import 'package:coriolis_companion/features/ships/domain/ship_repository.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ships_list/ships_list_cubit.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ships_list/ships_list_state.dart';

class _MockShipRepository extends Mock implements ShipRepository {}

const _summaries = [
  ShipSummary(
    id: 's1',
    name: 'Tannhauser Gate',
    shipClass: 'light-freighter',
    model: 'Helebian Class III',
    registry: 'KUA-7741-M',
  ),
  ShipSummary(
    id: 's2',
    name: 'Veiled Sun',
    shipClass: 'courier-yacht',
  ),
];

void main() {
  late _MockShipRepository repo;

  setUp(() {
    repo = _MockShipRepository();
  });

  group('ShipsListCubit', () {
    blocTest<ShipsListCubit, ShipsListState>(
      'emits loading → loaded when repository returns items',
      build: () {
        when(() => repo.list(limit: 20))
            .thenAnswer((_) async => _summaries);
        return ShipsListCubit(repo);
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        const ShipsListState(status: ShipsListStatus.loading),
        const ShipsListState(
          status: ShipsListStatus.loaded,
          ships: _summaries,
        ),
      ],
    );

    blocTest<ShipsListCubit, ShipsListState>(
      'emits loading → empty when repository returns []',
      build: () {
        when(() => repo.list(limit: 20)).thenAnswer((_) async => []);
        return ShipsListCubit(repo);
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        const ShipsListState(status: ShipsListStatus.loading),
        const ShipsListState(
          status: ShipsListStatus.empty,
          ships: [],
        ),
      ],
    );

    blocTest<ShipsListCubit, ShipsListState>(
      'emits loading → error when repository throws',
      build: () {
        when(() => repo.list(limit: 20)).thenThrow(Exception('network'));
        return ShipsListCubit(repo);
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        const ShipsListState(status: ShipsListStatus.loading),
        isA<ShipsListState>()
            .having((s) => s.status, 'status', ShipsListStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<ShipsListCubit, ShipsListState>(
      'refresh re-loads the list',
      build: () {
        when(() => repo.list(limit: 20))
            .thenAnswer((_) async => _summaries);
        return ShipsListCubit(repo);
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [
        const ShipsListState(status: ShipsListStatus.loading),
        const ShipsListState(
          status: ShipsListStatus.loaded,
          ships: _summaries,
        ),
      ],
    );
  });
}

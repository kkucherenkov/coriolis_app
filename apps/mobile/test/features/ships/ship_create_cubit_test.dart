import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/ships/domain/ship.dart';
import 'package:coriolis_companion/features/ships/domain/ship_repository.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ship_create/ship_create_cubit.dart';

class _MockShipRepository extends Mock implements ShipRepository {}

final _now = DateTime(2026, 5, 15);

Ship _shipFixture({String id = 'ship-new'}) => Ship(
      id: id,
      ownerId: 'u1',
      name: 'Tannhauser Gate',
      shipClass: 'light-freighter',
      model: null,
      registry: null,
      hull: const ShipPoints(current: 8, max: 8),
      energy: const ShipPoints(current: 6, max: 6),
      armor: 4,
      maneuverability: 0,
      signature: -1,
      speed: 3,
      cargoCapacity: 50,
      modules: const [],
      crew: const [],
      problems: const [],
      history: null,
      notes: null,
      createdAt: _now,
      updatedAt: _now,
    );

void main() {
  late _MockShipRepository repo;

  setUp(() {
    repo = _MockShipRepository();
  });

  ShipCreateCubit makeCubit() => ShipCreateCubit(repository: repo);

  group('ShipCreateCubit', () {
    test('initial state is idle with default fields', () {
      final cubit = makeCubit();
      expect(cubit.state.status, ShipCreateStatus.idle);
      expect(cubit.state.name, '');
      expect(cubit.state.shipClass, 'light-freighter');
      expect(cubit.state.canSubmit, isFalse, reason: 'empty name → cannot submit');
    });

    blocTest<ShipCreateCubit, ShipCreateState>(
      'setName flips canSubmit once name is non-empty',
      build: makeCubit,
      act: (cubit) {
        cubit.setName('Iron Lotus');
      },
      verify: (cubit) {
        expect(cubit.state.canSubmit, isTrue);
      },
    );

    blocTest<ShipCreateCubit, ShipCreateState>(
      'submit emits submitting → success and exposes createdShipId',
      build: makeCubit,
      act: (cubit) async {
        when(() => repo.create(
              name: any(named: 'name'),
              shipClass: any(named: 'shipClass'),
              model: any(named: 'model'),
              registry: any(named: 'registry'),
            )).thenAnswer((_) async => _shipFixture(id: 'cuid-fresh'));
        cubit.setName('  Iron Lotus  ');
        cubit.setModel('Helebian III');
        await cubit.submit();
      },
      expect: () => [
        // setName
        isA<ShipCreateState>().having((s) => s.name, 'name', '  Iron Lotus  '),
        // setModel
        isA<ShipCreateState>().having((s) => s.model, 'model', 'Helebian III'),
        // submit → submitting
        isA<ShipCreateState>().having(
          (s) => s.status,
          'status',
          ShipCreateStatus.submitting,
        ),
        // success
        isA<ShipCreateState>()
            .having((s) => s.status, 'status', ShipCreateStatus.success)
            .having((s) => s.createdShipId, 'createdShipId', 'cuid-fresh'),
      ],
      verify: (_) {
        // Trimmed name + non-empty model land on the wire; empty registry is
        // dropped to null.
        verify(() => repo.create(
              name: 'Iron Lotus',
              shipClass: 'light-freighter',
              model: 'Helebian III',
              registry: null,
            )).called(1);
      },
    );

    blocTest<ShipCreateCubit, ShipCreateState>(
      'submit failure surfaces an errorMessage and keeps form fields',
      build: makeCubit,
      act: (cubit) async {
        when(() => repo.create(
              name: any(named: 'name'),
              shipClass: any(named: 'shipClass'),
              model: any(named: 'model'),
              registry: any(named: 'registry'),
            )).thenThrow(StateError('422 invalid class'));
        cubit.setName('Iron Lotus');
        await cubit.submit();
      },
      expect: () => [
        isA<ShipCreateState>().having((s) => s.name, 'name', 'Iron Lotus'),
        isA<ShipCreateState>()
            .having((s) => s.status, 'status', ShipCreateStatus.submitting),
        isA<ShipCreateState>()
            .having((s) => s.status, 'status', ShipCreateStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('422 invalid class'),
            ),
      ],
    );

    blocTest<ShipCreateCubit, ShipCreateState>(
      'submit with empty name is a no-op',
      build: makeCubit,
      act: (cubit) async {
        await cubit.submit();
      },
      expect: () => const <ShipCreateState>[],
      verify: (_) {
        verifyNever(() => repo.create(
              name: any(named: 'name'),
              shipClass: any(named: 'shipClass'),
              model: any(named: 'model'),
              registry: any(named: 'registry'),
            ));
      },
    );

    blocTest<ShipCreateCubit, ShipCreateState>(
      'setShipClass updates only the class field',
      build: makeCubit,
      act: (cubit) => cubit.setShipClass('gunboat'),
      verify: (cubit) {
        expect(cubit.state.shipClass, 'gunboat');
        expect(cubit.state.name, isEmpty);
      },
    );
  });
}

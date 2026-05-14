import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/ships/domain/ship.dart';
import 'package:coriolis_companion/features/ships/domain/ship_repository.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ship_sheet/ship_sheet_cubit.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ship_sheet/ship_sheet_state.dart';

class _MockShipRepository extends Mock implements ShipRepository {}

final _now = DateTime(2026, 5, 15);

Ship _shipFixture({
  String name = 'Tannhauser Gate',
  ShipPoints hull = const ShipPoints(current: 5, max: 8),
  ShipPoints energy = const ShipPoints(current: 4, max: 6),
  int armor = 4,
  String? notes,
  List<String> problems = const [],
}) {
  return Ship(
    id: 's1',
    ownerId: 'u1',
    name: name,
    shipClass: 'light-freighter',
    model: 'Helebian Class III',
    registry: 'KUA-7741-M',
    hull: hull,
    energy: energy,
    armor: armor,
    maneuverability: 0,
    signature: -1,
    speed: 4,
    cargoCapacity: 50,
    modules: const [],
    crew: const [],
    problems: problems,
    history: null,
    notes: notes,
    createdAt: _now,
    updatedAt: _now,
  );
}

ShipSheetCubit _buildCubit(_MockShipRepository repo) => ShipSheetCubit(
      repository: repo,
      debounceDuration: const Duration(milliseconds: 1),
      savedResetDuration: const Duration(milliseconds: 1),
    );

void main() {
  late _MockShipRepository repo;

  setUpAll(() {
    registerFallbackValue(const ShipPoints(current: 0, max: 0));
  });

  setUp(() {
    repo = _MockShipRepository();
  });

  group('ShipSheetCubit', () {
    group('load', () {
      blocTest<ShipSheetCubit, ShipSheetState>(
        'emits isLoading=true → loaded ship on success',
        build: () {
          when(() => repo.get('s1')).thenAnswer((_) async => _shipFixture());
          return _buildCubit(repo);
        },
        act: (cubit) => cubit.load('s1'),
        expect: () => [
          const ShipSheetState(isLoading: true),
          ShipSheetState(isLoading: false, ship: _shipFixture()),
        ],
      );

      blocTest<ShipSheetCubit, ShipSheetState>(
        'maps Dio 404 to notFound state',
        build: () {
          when(() => repo.get('missing')).thenThrow(DioException(
            requestOptions: RequestOptions(path: '/ships/missing'),
            response: Response(
              requestOptions: RequestOptions(path: '/ships/missing'),
              statusCode: 404,
            ),
          ));
          return _buildCubit(repo);
        },
        act: (cubit) => cubit.load('missing'),
        expect: () => [
          const ShipSheetState(isLoading: true),
          const ShipSheetState(isLoading: false, notFound: true),
        ],
      );

      blocTest<ShipSheetCubit, ShipSheetState>(
        'emits error state when repository throws non-404',
        build: () {
          when(() => repo.get('s1')).thenThrow(Exception('boom'));
          return _buildCubit(repo);
        },
        act: (cubit) => cubit.load('s1'),
        expect: () => [
          const ShipSheetState(isLoading: true),
          isA<ShipSheetState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );
    });

    group('updateName (debounced)', () {
      blocTest<ShipSheetCubit, ShipSheetState>(
        'sends only the name field on the PATCH',
        build: () {
          when(() => repo.get('s1')).thenAnswer((_) async => _shipFixture());
          when(() => repo.update(
                's1',
                name: 'Renamed',
                model: null,
                registry: null,
                hull: null,
                energy: null,
                armor: null,
                maneuverability: null,
                signature: null,
                speed: null,
                problems: null,
                history: null,
                notes: null,
              )).thenAnswer((_) async => _shipFixture(name: 'Renamed'));
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('s1');
          cubit.updateName('Renamed');
          await Future<void>.delayed(const Duration(milliseconds: 50));
        },
        verify: (cubit) {
          expect(cubit.state.ship?.name, 'Renamed');
          expect(cubit.state.saveStatus,
              anyOf(ShipSheetSaveStatus.saved, ShipSheetSaveStatus.idle));
        },
      );
    });

    group('adjustHullCurrent', () {
      blocTest<ShipSheetCubit, ShipSheetState>(
        'clamps current to [0, max] and patches the hull pair',
        build: () {
          when(() => repo.get('s1')).thenAnswer((_) async => _shipFixture());
          when(() => repo.update(
                's1',
                name: null,
                model: null,
                registry: null,
                hull: const ShipPoints(current: 6, max: 8),
                energy: null,
                armor: null,
                maneuverability: null,
                signature: null,
                speed: null,
                problems: null,
                history: null,
                notes: null,
              )).thenAnswer((_) async =>
              _shipFixture(hull: const ShipPoints(current: 6, max: 8)));
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('s1');
          cubit.adjustHullCurrent(1);
          await Future<void>.delayed(const Duration(milliseconds: 50));
        },
        verify: (cubit) {
          expect(cubit.state.ship?.hull.current, 6);
          expect(cubit.state.ship?.hull.max, 8);
        },
      );

      blocTest<ShipSheetCubit, ShipSheetState>(
        'never sets current below 0',
        build: () {
          when(() => repo.get('s1')).thenAnswer(
              (_) async => _shipFixture(hull: const ShipPoints(current: 0, max: 8)));
          when(() => repo.update(
                's1',
                name: null,
                model: null,
                registry: null,
                hull: any(named: 'hull'),
                energy: null,
                armor: null,
                maneuverability: null,
                signature: null,
                speed: null,
                problems: null,
                history: null,
                notes: null,
              )).thenAnswer((invocation) async =>
              _shipFixture(hull: invocation.namedArguments[#hull] as ShipPoints));
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('s1');
          cubit.adjustHullCurrent(-3);
          await Future<void>.delayed(const Duration(milliseconds: 50));
        },
        verify: (cubit) {
          expect(cubit.state.ship?.hull.current, 0);
        },
      );
    });

    group('setHullMax', () {
      blocTest<ShipSheetCubit, ShipSheetState>(
        'caps current at the new max',
        build: () {
          when(() => repo.get('s1')).thenAnswer((_) async => _shipFixture());
          when(() => repo.update(
                's1',
                name: null,
                model: null,
                registry: null,
                hull: const ShipPoints(current: 3, max: 3),
                energy: null,
                armor: null,
                maneuverability: null,
                signature: null,
                speed: null,
                problems: null,
                history: null,
                notes: null,
              )).thenAnswer((_) async =>
              _shipFixture(hull: const ShipPoints(current: 3, max: 3)));
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('s1');
          cubit.setHullMax(3);
          await Future<void>.delayed(const Duration(milliseconds: 50));
        },
        verify: (cubit) {
          expect(cubit.state.ship?.hull.max, 3);
          expect(cubit.state.ship?.hull.current, 3);
        },
      );
    });

    group('updateProblemsFromText', () {
      blocTest<ShipSheetCubit, ShipSheetState>(
        'splits, trims, and drops empty segments',
        build: () {
          when(() => repo.get('s1')).thenAnswer((_) async => _shipFixture());
          when(() => repo.update(
                's1',
                name: null,
                model: null,
                registry: null,
                hull: null,
                energy: null,
                armor: null,
                maneuverability: null,
                signature: null,
                speed: null,
                problems: const ['leaky valve', 'misaligned sensor'],
                history: null,
                notes: null,
              )).thenAnswer((_) async => _shipFixture(
              problems: const ['leaky valve', 'misaligned sensor']));
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('s1');
          cubit.updateProblemsFromText('  leaky valve ,, misaligned sensor ,');
          await Future<void>.delayed(const Duration(milliseconds: 50));
        },
        verify: (cubit) {
          expect(cubit.state.ship?.problems,
              ['leaky valve', 'misaligned sensor']);
        },
      );
    });

    group('deleteShip', () {
      blocTest<ShipSheetCubit, ShipSheetState>(
        'emits saving while deleting',
        build: () {
          when(() => repo.get('s1')).thenAnswer((_) async => _shipFixture());
          when(() => repo.delete('s1')).thenAnswer((_) async {});
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('s1');
          await cubit.deleteShip();
        },
        verify: (cubit) {
          expect(cubit.state.saveStatus, isNot(ShipSheetSaveStatus.error));
        },
      );

      blocTest<ShipSheetCubit, ShipSheetState>(
        'records error message on delete failure',
        build: () {
          when(() => repo.get('s1')).thenAnswer((_) async => _shipFixture());
          when(() => repo.delete('s1')).thenThrow(Exception('boom'));
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('s1');
          await cubit.deleteShip();
        },
        verify: (cubit) {
          expect(cubit.state.saveStatus, ShipSheetSaveStatus.error);
          expect(cubit.state.saveErrorMessage, isNotNull);
        },
      );
    });

    group('duplicate', () {
      blocTest<ShipSheetCubit, ShipSheetState>(
        'returns new ship id and emits saved status',
        build: () {
          when(() => repo.get('s1')).thenAnswer((_) async => _shipFixture());
          when(() => repo.duplicate('s1')).thenAnswer((_) async {
            return Ship(
              id: 's2-copy',
              ownerId: 'u1',
              name: 'Tannhauser Gate (Copy)',
              shipClass: 'light-freighter',
              model: 'Helebian Class III',
              registry: null,
              hull: const ShipPoints(current: 8, max: 8),
              energy: const ShipPoints(current: 6, max: 6),
              armor: 4,
              maneuverability: 0,
              signature: -1,
              speed: 4,
              cargoCapacity: 50,
              modules: const [],
              crew: const [],
              problems: const [],
              history: null,
              notes: null,
              createdAt: _now,
              updatedAt: _now,
            );
          });
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('s1');
          final newId = await cubit.duplicate();
          expect(newId, 's2-copy');
        },
        verify: (cubit) {
          // Saved status either still saved or already reset to idle (timer);
          // it must NOT be in an error state.
          expect(cubit.state.saveStatus, isNot(ShipSheetSaveStatus.error));
        },
      );

      blocTest<ShipSheetCubit, ShipSheetState>(
        'returns null and records saveErrorMessage on failure',
        build: () {
          when(() => repo.get('s1')).thenAnswer((_) async => _shipFixture());
          when(() => repo.duplicate('s1'))
              .thenThrow(StateError('422 cannot duplicate'));
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('s1');
          final newId = await cubit.duplicate();
          expect(newId, isNull);
        },
        verify: (cubit) {
          expect(cubit.state.saveStatus, ShipSheetSaveStatus.error);
          expect(
            cubit.state.saveErrorMessage,
            contains('422 cannot duplicate'),
          );
        },
      );

      blocTest<ShipSheetCubit, ShipSheetState>(
        'is a no-op when no ship is loaded yet',
        build: () => _buildCubit(repo),
        act: (cubit) async {
          final newId = await cubit.duplicate();
          expect(newId, isNull);
        },
        verify: (_) {
          verifyNever(() => repo.duplicate(any<String>()));
        },
      );
    });

    group('assignCrew', () {
      blocTest<ShipSheetCubit, ShipSheetState>(
        'returns true and refetches ship on success',
        build: () {
          when(() => repo.get('s1')).thenAnswer((_) async => _shipFixture());
          when(() => repo.assignCrew(
                shipId: any(named: 'shipId'),
                position: any(named: 'position'),
                characterId: any(named: 'characterId'),
              )).thenAnswer((_) async {});
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('s1');
          final ok = await cubit.assignCrew(
            position: 'captain',
            characterId: 'char-7',
          );
          expect(ok, isTrue);
        },
        verify: (cubit) {
          verify(() => repo.assignCrew(
                shipId: 's1',
                position: 'captain',
                characterId: 'char-7',
              )).called(1);
          // get called twice — once on load, once on the refetch.
          verify(() => repo.get('s1')).called(2);
          expect(cubit.state.saveStatus, isNot(ShipSheetSaveStatus.error));
        },
      );

      blocTest<ShipSheetCubit, ShipSheetState>(
        'returns false and surfaces saveErrorMessage on failure',
        build: () {
          when(() => repo.get('s1')).thenAnswer((_) async => _shipFixture());
          when(() => repo.assignCrew(
                shipId: any(named: 'shipId'),
                position: any(named: 'position'),
                characterId: any(named: 'characterId'),
              )).thenThrow(StateError('409 already assigned'));
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('s1');
          final ok = await cubit.assignCrew(
            position: 'pilot',
            characterId: 'char-99',
          );
          expect(ok, isFalse);
        },
        verify: (cubit) {
          expect(cubit.state.saveStatus, ShipSheetSaveStatus.error);
          expect(
            cubit.state.saveErrorMessage,
            contains('409 already assigned'),
          );
        },
      );
    });

    group('unassignCrew', () {
      blocTest<ShipSheetCubit, ShipSheetState>(
        'returns true and refetches ship on success',
        build: () {
          when(() => repo.get('s1')).thenAnswer((_) async => _shipFixture());
          when(() => repo.unassignCrew(
                shipId: any(named: 'shipId'),
                characterId: any(named: 'characterId'),
              )).thenAnswer((_) async {});
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('s1');
          final ok = await cubit.unassignCrew(characterId: 'char-7');
          expect(ok, isTrue);
        },
        verify: (_) {
          verify(() => repo.unassignCrew(
                shipId: 's1',
                characterId: 'char-7',
              )).called(1);
        },
      );

      blocTest<ShipSheetCubit, ShipSheetState>(
        'no-op when no ship is loaded',
        build: () => _buildCubit(repo),
        act: (cubit) async {
          final ok = await cubit.unassignCrew(characterId: 'char-7');
          expect(ok, isFalse);
        },
        verify: (_) {
          verifyNever(() => repo.unassignCrew(
                shipId: any(named: 'shipId'),
                characterId: any(named: 'characterId'),
              ));
        },
      );
    });

    group('exportSnapshot', () {
      blocTest<ShipSheetCubit, ShipSheetState>(
        'returns the export Ship on success',
        build: () {
          when(() => repo.get('s1')).thenAnswer((_) async => _shipFixture());
          when(() => repo.exportSnapshot('s1'))
              .thenAnswer((_) async => _shipFixture());
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('s1');
          final snapshot = await cubit.exportSnapshot();
          expect(snapshot, isNotNull);
          expect(snapshot!.id, 's1');
        },
        verify: (cubit) {
          expect(cubit.state.saveStatus, isNot(ShipSheetSaveStatus.error));
        },
      );

      blocTest<ShipSheetCubit, ShipSheetState>(
        'returns null and records 501 errors gracefully',
        build: () {
          when(() => repo.get('s1')).thenAnswer((_) async => _shipFixture());
          when(() => repo.exportSnapshot('s1'))
              .thenThrow(StateError('501 not implemented'));
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('s1');
          final snapshot = await cubit.exportSnapshot();
          expect(snapshot, isNull);
        },
        verify: (cubit) {
          expect(cubit.state.saveStatus, ShipSheetSaveStatus.error);
          expect(
            cubit.state.saveErrorMessage,
            contains('501 not implemented'),
          );
        },
      );
    });
  });
}

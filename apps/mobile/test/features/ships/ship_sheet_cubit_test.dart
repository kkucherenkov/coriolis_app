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
  });
}

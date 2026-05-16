import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/ships/data/cached_ship_repository.dart';
import 'package:coriolis_companion/features/ships/data/ship_api_mapper.dart';
import 'package:coriolis_companion/features/ships/data/ship_cache.dart';
import 'package:coriolis_companion/features/ships/domain/ship.dart';
import 'package:coriolis_companion/features/ships/domain/ship_repository.dart';

class _MockRemote extends Mock implements ShipRepository {}

class _MockCache extends Mock implements LocalShipCache {}

api_client.Ship _wire({
  String id = 'ship-1',
  String name = 'Tannhauser Gate',
}) =>
    api_client.Ship((b) => b
      ..id = id
      ..ownerId = 'user-1'
      ..name = name
      ..class_ = api_client.ShipClass.lightFreighter
      ..armor = 0
      ..maneuverability = 0
      ..signature = 0
      ..speed = 3
      ..cargoCapacity = 50
      ..hull.replace(api_client.ShipHull((h) => h
        ..current = 8
        ..max = 8))
      ..energy.replace(api_client.ShipEnergy((e) => e
        ..current = 6
        ..max = 6))
      ..modules.replace(BuiltList<api_client.ShipModule>())
      ..crew.replace(BuiltList<api_client.CrewSlot>())
      ..problems.replace(BuiltList<String>())
      ..createdAt = DateTime.utc(2026, 5, 17)
      ..updatedAt = DateTime.utc(2026, 5, 17));

DioException _networkErr(String path) => DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.connectionError,
    );

DioException _badResponseErr(String path, int code) => DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: path),
        statusCode: code,
      ),
    );

void main() {
  late _MockRemote remote;
  late _MockCache cache;
  late CachedShipRepository sut;

  setUp(() {
    remote = _MockRemote();
    cache = _MockCache();
    sut = CachedShipRepository(remote: remote, cache: cache);
    registerFallbackValue(_wire());
  });

  // ── get ───────────────────────────────────────────────────────────────────

  group('get', () {
    test('happy path returns remote result without touching cache', () async {
      final domain = ShipApiMapper.toDomain(_wire());
      when(() => remote.get('ship-1')).thenAnswer((_) async => domain);

      final got = await sut.get('ship-1');

      expect(got.id, 'ship-1');
      verifyNever(() => cache.read(any()));
      verifyNever(() => cache.write(any()));
    });

    test('falls back to cache on network DioException', () async {
      when(() => remote.get('ship-1')).thenThrow(_networkErr('/ships/ship-1'));
      when(() => cache.read('ship-1')).thenAnswer((_) async => _wire());

      final got = await sut.get('ship-1');

      expect(got.id, 'ship-1');
      verify(() => cache.read('ship-1')).called(1);
    });

    test('rethrows non-network DioException (4xx) without touching cache',
        () async {
      final err = _badResponseErr('/ships/ship-1', 404);
      when(() => remote.get('ship-1')).thenThrow(err);

      expect(() => sut.get('ship-1'), throwsA(same(err)));
      verifyNever(() => cache.read(any()));
    });

    test('rethrows original DioException when network fails and cache misses',
        () async {
      final err = _networkErr('/ships/ship-1');
      when(() => remote.get('ship-1')).thenThrow(err);
      when(() => cache.read('ship-1')).thenAnswer((_) async => null);

      expect(() => sut.get('ship-1'), throwsA(same(err)));
    });
  });

  // ── list ──────────────────────────────────────────────────────────────────

  group('list', () {
    test('happy path returns remote summaries without touching cache',
        () async {
      when(() => remote.list(limit: 20)).thenAnswer(
        (_) async => [
          const ShipSummary(
            id: 'ship-1',
            name: 'Tannhauser Gate',
            shipClass: 'lightFreighter',
          ),
        ],
      );

      final summaries = await sut.list();

      expect(summaries.single.id, 'ship-1');
      verifyNever(() => cache.readAll());
    });

    test('falls back to cache.readAll on network DioException', () async {
      when(() => remote.list(limit: 20))
          .thenThrow(_networkErr('/ships'));
      when(() => cache.readAll()).thenAnswer((_) async => [_wire()]);

      final summaries = await sut.list();

      expect(summaries.single.id, 'ship-1');
      expect(summaries.single.name, 'Tannhauser Gate');
    });
  });

  // ── mutations invalidate cache ────────────────────────────────────────────

  group('mutations', () {
    test('update on success calls cache.delete once', () async {
      final domain = ShipApiMapper.toDomain(_wire(name: 'X'));
      when(() => remote.update('ship-1', name: 'X'))
          .thenAnswer((_) async => domain);
      when(() => cache.delete('ship-1')).thenAnswer((_) async {});

      final updated = await sut.update('ship-1', name: 'X');

      expect(updated.name, 'X');
      verify(() => cache.delete('ship-1')).called(1);
    });

    test('delete on success calls cache.delete once', () async {
      when(() => remote.delete('ship-1')).thenAnswer((_) async {});
      when(() => cache.delete('ship-1')).thenAnswer((_) async {});

      await sut.delete('ship-1');

      verify(() => remote.delete('ship-1')).called(1);
      verify(() => cache.delete('ship-1')).called(1);
    });

    test('update on remote failure does NOT call cache.delete', () async {
      final err = _networkErr('/ships/ship-1');
      when(() => remote.update('ship-1', name: 'X')).thenThrow(err);

      expect(
        () => sut.update('ship-1', name: 'X'),
        throwsA(same(err)),
      );
      verifyNever(() => cache.delete(any()));
    });

    test('addWeaponModule on success calls cache.delete for parent ship',
        () async {
      const mod = DomainShipModule(
        id: 'mod-1',
        slot: 'WEAPON',
        name: 'Laser Cannon',
        energyUse: 2,
      );
      when(
        () => remote.addWeaponModule(
          shipId: 'ship-1',
          name: 'Laser Cannon',
        ),
      ).thenAnswer((_) async => mod);
      when(() => cache.delete('ship-1')).thenAnswer((_) async {});

      await sut.addWeaponModule(shipId: 'ship-1', name: 'Laser Cannon');

      verify(() => cache.delete('ship-1')).called(1);
    });
  });
}

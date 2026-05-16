import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:built_collection/built_collection.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/features/ships/data/drift_ship_cache.dart';
import 'package:coriolis_companion/shared/cache/app_database.dart';

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
      ..createdAt = DateTime.utc(2026, 5, 16)
      ..updatedAt = DateTime.utc(2026, 5, 16));

void main() {
  late AppDatabase db;
  late DriftShipCache cache;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cache = DriftShipCache(db);
  });

  tearDown(() async => db.close());

  test('read returns null when nothing cached', () async {
    expect(await cache.read('missing'), isNull);
  });

  test('write then read round-trips the wire payload', () async {
    final wire = _wire(name: 'Veiled Sun');
    await cache.write(wire);
    final got = await cache.read('ship-1');
    expect(got, isNotNull);
    expect(got!.name, 'Veiled Sun');
  });

  test('readAll returns all written rows', () async {
    await cache.write(_wire(id: 'ship-1', name: 'Tannhauser Gate'));
    await cache.write(_wire(id: 'ship-2', name: 'Veiled Sun'));
    final all = await cache.readAll();
    expect(all.length, 2);
    expect(all.map((s) => s.id), containsAll(['ship-1', 'ship-2']));
  });

  test('delete removes the row', () async {
    await cache.write(_wire());
    await cache.delete('ship-1');
    expect(await cache.read('ship-1'), isNull);
  });
}

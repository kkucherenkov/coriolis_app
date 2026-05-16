import 'dart:convert';

import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:app_api_client/app_api_client.dart' show standardSerializers;

import 'package:coriolis_companion/features/ships/data/ship_cache.dart';
import 'package:coriolis_companion/shared/cache/app_database.dart';

/// Drift-backed [LocalShipCache].
class DriftShipCache implements LocalShipCache {
  DriftShipCache(this._db);

  final AppDatabase _db;

  @override
  Future<List<api_client.Ship>> readAll() async {
    final rows = await _db.select(_db.shipsCache).get();
    return rows.map(_deserialize).toList(growable: false);
  }

  @override
  Future<api_client.Ship?> read(String id) async {
    final row = await (_db.select(_db.shipsCache)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _deserialize(row);
  }

  @override
  Future<void> write(api_client.Ship wire) async {
    final payload = json.encode(
      standardSerializers.serializeWith(api_client.Ship.serializer, wire),
    );
    await _db.into(_db.shipsCache).insertOnConflictUpdate(
          ShipsCacheCompanion.insert(
            id: wire.id,
            payloadJson: payload,
            wireUpdatedAt: wire.updatedAt,
            cachedAt: DateTime.now().toUtc(),
          ),
        );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.shipsCache)..where((t) => t.id.equals(id))).go();
  }

  api_client.Ship _deserialize(ShipsCacheData row) {
    return standardSerializers.deserializeWith(
      api_client.Ship.serializer,
      json.decode(row.payloadJson),
    )!;
  }
}

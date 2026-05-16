import 'dart:convert';

import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:app_api_client/app_api_client.dart' show standardSerializers;

import 'package:coriolis_companion/features/npcs/data/npc_cache.dart';
import 'package:coriolis_companion/shared/cache/app_database.dart';

/// Drift-backed [LocalNpcCache].
class DriftNpcCache implements LocalNpcCache {
  DriftNpcCache(this._db);

  final AppDatabase _db;

  @override
  Future<List<api_client.Npc>> readAll() async {
    final rows = await _db.select(_db.npcsCache).get();
    return rows.map(_deserialize).toList(growable: false);
  }

  @override
  Future<api_client.Npc?> read(String id) async {
    final row = await (_db.select(_db.npcsCache)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _deserialize(row);
  }

  @override
  Future<void> write(api_client.Npc wire) async {
    final payload = json.encode(
      standardSerializers.serializeWith(api_client.Npc.serializer, wire),
    );
    await _db.into(_db.npcsCache).insertOnConflictUpdate(
          NpcsCacheCompanion.insert(
            id: wire.id,
            payloadJson: payload,
            wireUpdatedAt: wire.updatedAt,
            cachedAt: DateTime.now().toUtc(),
          ),
        );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.npcsCache)..where((t) => t.id.equals(id))).go();
  }

  api_client.Npc _deserialize(NpcsCacheData row) {
    return standardSerializers.deserializeWith(
      api_client.Npc.serializer,
      json.decode(row.payloadJson),
    )!;
  }
}

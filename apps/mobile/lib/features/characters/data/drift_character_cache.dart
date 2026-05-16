import 'dart:convert';

import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:app_api_client/app_api_client.dart' show standardSerializers;

import 'package:coriolis_companion/features/characters/data/character_cache.dart';
import 'package:coriolis_companion/shared/cache/app_database.dart';

/// Drift-backed [LocalCharacterCache].
class DriftCharacterCache implements LocalCharacterCache {
  DriftCharacterCache(this._db);

  final AppDatabase _db;

  @override
  Future<List<api_client.Character>> readAll() async {
    final rows = await _db.select(_db.charactersCache).get();
    return rows.map(_deserialize).toList(growable: false);
  }

  @override
  Future<api_client.Character?> read(String id) async {
    final row = await (_db.select(_db.charactersCache)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _deserialize(row);
  }

  @override
  Future<void> write(api_client.Character wire) async {
    final payload = json.encode(
      standardSerializers.serializeWith(api_client.Character.serializer, wire),
    );
    await _db.into(_db.charactersCache).insertOnConflictUpdate(
          CharactersCacheCompanion.insert(
            id: wire.id,
            payloadJson: payload,
            wireUpdatedAt: wire.updatedAt,
            cachedAt: DateTime.now().toUtc(),
          ),
        );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.charactersCache)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  api_client.Character _deserialize(CharactersCacheData row) {
    return standardSerializers.deserializeWith(
      api_client.Character.serializer,
      json.decode(row.payloadJson),
    )!;
  }
}

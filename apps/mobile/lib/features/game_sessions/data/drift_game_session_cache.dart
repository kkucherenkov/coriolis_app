import 'dart:convert';

import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:app_api_client/app_api_client.dart' show standardSerializers;

import 'package:coriolis_companion/features/game_sessions/data/game_session_cache.dart';
import 'package:coriolis_companion/shared/cache/app_database.dart';

/// Drift-backed [LocalGameSessionCache].
class DriftGameSessionCache implements LocalGameSessionCache {
  DriftGameSessionCache(this._db);

  final AppDatabase _db;

  @override
  Future<List<api_client.GameSession>> readAll() async {
    final rows = await _db.select(_db.gameSessionsCache).get();
    return rows.map(_deserialize).toList(growable: false);
  }

  @override
  Future<api_client.GameSession?> read(String id) async {
    final row = await (_db.select(_db.gameSessionsCache)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _deserialize(row);
  }

  @override
  Future<void> write(api_client.GameSession wire) async {
    final payload = json.encode(
      standardSerializers.serializeWith(
          api_client.GameSession.serializer, wire),
    );
    await _db.into(_db.gameSessionsCache).insertOnConflictUpdate(
          GameSessionsCacheCompanion.insert(
            id: wire.id,
            payloadJson: payload,
            wireUpdatedAt: wire.updatedAt,
            cachedAt: DateTime.now().toUtc(),
          ),
        );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.gameSessionsCache)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  api_client.GameSession _deserialize(GameSessionsCacheData row) {
    return standardSerializers.deserializeWith(
      api_client.GameSession.serializer,
      json.decode(row.payloadJson),
    )!;
  }
}

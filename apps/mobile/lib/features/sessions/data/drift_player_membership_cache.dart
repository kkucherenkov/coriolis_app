import 'dart:convert';

import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:app_api_client/app_api_client.dart' show standardSerializers;

import 'package:coriolis_companion/features/sessions/data/player_membership_cache.dart';
import 'package:coriolis_companion/shared/cache/app_database.dart';

/// Drift-backed [LocalPlayerMembershipCache].
class DriftPlayerMembershipCache implements LocalPlayerMembershipCache {
  DriftPlayerMembershipCache(this._db);

  final AppDatabase _db;

  @override
  Future<List<api_client.MyMembershipSummary>> readAll() async {
    final rows = await _db.select(_db.playerMembershipsCache).get();
    return rows.map(_deserialize).toList(growable: false);
  }

  @override
  Future<api_client.MyMembershipSummary?> read(String membershipId) async {
    final row = await (_db.select(_db.playerMembershipsCache)
          ..where((t) => t.id.equals(membershipId)))
        .getSingleOrNull();
    if (row == null) return null;
    return _deserialize(row);
  }

  @override
  Future<void> write(api_client.MyMembershipSummary wire) async {
    final payload = json.encode(
      standardSerializers.serializeWith(
          api_client.MyMembershipSummary.serializer, wire),
    );
    // MyMembershipSummary has no updatedAt; both timestamps use local clock.
    final now = DateTime.now().toUtc();
    await _db.into(_db.playerMembershipsCache).insertOnConflictUpdate(
          PlayerMembershipsCacheCompanion.insert(
            id: wire.membershipId,
            payloadJson: payload,
            wireUpdatedAt: now,
            cachedAt: now,
          ),
        );
  }

  @override
  Future<void> delete(String membershipId) async {
    await (_db.delete(_db.playerMembershipsCache)
          ..where((t) => t.id.equals(membershipId)))
        .go();
  }

  api_client.MyMembershipSummary _deserialize(PlayerMembershipsCacheData row) {
    return standardSerializers.deserializeWith(
      api_client.MyMembershipSummary.serializer,
      json.decode(row.payloadJson),
    )!;
  }
}

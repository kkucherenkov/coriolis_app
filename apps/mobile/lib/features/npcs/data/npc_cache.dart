import 'package:app_api_client/app_api_client.dart' as api_client;

/// Local read-cache for NPC wire payloads.
///
/// Implementations must be safe to call from any isolate that owns the
/// underlying database handle; in this app there is one [AppDatabase]
/// instance per process (registered as a singleton in `injector.dart`).
abstract class LocalNpcCache {
  /// Returns every cached NPC (used for offline list view).
  Future<List<api_client.Npc>> readAll();

  /// Returns the cached NPC matching [id], or `null` if not cached.
  Future<api_client.Npc?> read(String id);

  /// Inserts or replaces the cached payload for `wire.id`.
  ///
  /// `wireUpdatedAt` is stamped with `wire.updatedAt` (real field on [api_client.Npc]);
  /// `cachedAt` is stamped with `DateTime.now().toUtc()` at write time.
  Future<void> write(api_client.Npc wire);

  /// Removes the row for [id]. No-op if absent.
  Future<void> delete(String id);
}

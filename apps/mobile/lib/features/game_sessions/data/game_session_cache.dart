import 'package:app_api_client/app_api_client.dart' as api_client;

/// Local read-cache for game-session wire payloads.
///
/// Implementations must be safe to call from any isolate that owns the
/// underlying database handle; in this app there is one `AppDatabase`
/// instance per process (registered as a singleton in `injector.dart`).
abstract class LocalGameSessionCache {
  /// Returns every cached game session (used for offline list view).
  Future<List<api_client.GameSession>> readAll();

  /// Returns the cached session matching [id], or `null` if not cached.
  Future<api_client.GameSession?> read(String id);

  /// Inserts or replaces the cached payload for `wire.id`.
  ///
  /// The implementation serialises `wire` via `standardSerializers` and
  /// stamps both `wireUpdatedAt` (from `wire.updatedAt`) and `cachedAt`
  /// (`DateTime.now().toUtc()`).
  Future<void> write(api_client.GameSession wire);

  /// Removes the row for [id]. No-op if absent.
  Future<void> delete(String id);
}

import 'package:app_api_client/app_api_client.dart' as api_client;

/// Local read-cache for player membership wire payloads.
///
/// Implementations must be safe to call from any isolate that owns the
/// underlying database handle; in this app there is one `AppDatabase`
/// instance per process (registered as a singleton in `injector.dart`).
abstract class LocalPlayerMembershipCache {
  /// Returns every cached membership (used for offline list view).
  Future<List<api_client.MyMembershipSummary>> readAll();

  /// Returns the cached membership matching [membershipId], or `null` if not cached.
  Future<api_client.MyMembershipSummary?> read(String membershipId);

  /// Inserts or replaces the cached payload for `wire.membershipId`.
  ///
  /// `MyMembershipSummary` has no `updatedAt` field; both `wireUpdatedAt` and
  /// `cachedAt` are stamped with `DateTime.now().toUtc()` at write time.
  Future<void> write(api_client.MyMembershipSummary wire);

  /// Removes the row for [membershipId]. No-op if absent.
  Future<void> delete(String membershipId);
}

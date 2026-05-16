import 'package:drift/drift.dart';

import 'package:coriolis_companion/shared/cache/connection/native.dart'
    as conn;

part 'app_database.g.dart';

/// Cached wire payload for a single character.
///
/// `payloadJson` is the JSON-encoded form of `app_api_client.Character`
/// (the wire DTO) — the decorator round-trips it through
/// `standardSerializers` to stay agnostic of domain shape changes.
///
/// `wireUpdatedAt` stores the server-side `updatedAt` for staleness checks;
/// `cachedAt` is local clock at write time for diagnostics / TTL.
class CharactersCache extends Table {
  TextColumn get id => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get wireUpdatedAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// FIFO queue of mutations that failed to reach the server while offline.
///
/// Each row represents one PATCH / PUT / DELETE request that the
/// `MutationQueueInterceptor` (Block 2) could not deliver. Rows are
/// consumed and removed by the `MutationQueueDrainer` (Block 3) once
/// connectivity is restored.
///
/// `headersJson` holds a JSON-encoded `Map<String, String>` of the original
/// request headers. The Authorization header is stripped by the interceptor
/// before the entry is written here — it is re-injected at replay time so a
/// stale token is never replayed verbatim.
///
/// `createdAt` drives FIFO ordering; consumers sort ascending on this column
/// so earlier mutations are replayed first (preserving causal order).
class PendingMutations extends Table {
  TextColumn get id => text()();
  TextColumn get method => text()();
  TextColumn get path => text()();
  TextColumn get body => text().nullable()();
  TextColumn get headersJson => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [CharactersCache, PendingMutations])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(conn.openConnection());

  /// Test-only constructor — accepts a pre-built executor (e.g.
  /// `NativeDatabase.memory()`).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(pendingMutations);
          }
        },
      );
}

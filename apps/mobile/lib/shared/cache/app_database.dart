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

@DriftDatabase(tables: [CharactersCache])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(conn.openConnection());

  /// Test-only constructor — accepts a pre-built executor (e.g.
  /// `NativeDatabase.memory()`).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

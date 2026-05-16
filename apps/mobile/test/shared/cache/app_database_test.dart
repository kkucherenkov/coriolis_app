import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/shared/cache/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  test('schema migration creates characters_cache table', () async {
    final all = await db.select(db.charactersCache).get();
    expect(all, isEmpty);
  });

  test('insertOrReplace persists then returns one row per id', () async {
    final now = DateTime.utc(2026, 5, 16, 12);
    await db.into(db.charactersCache).insertOnConflictUpdate(
          CharactersCacheCompanion.insert(
            id: 'char-1',
            payloadJson: '{"id":"char-1"}',
            wireUpdatedAt: now,
            cachedAt: now,
          ),
        );
    await db.into(db.charactersCache).insertOnConflictUpdate(
          CharactersCacheCompanion.insert(
            id: 'char-1',
            payloadJson: '{"id":"char-1","name":"Tael"}',
            wireUpdatedAt: now.add(const Duration(minutes: 1)),
            cachedAt: now.add(const Duration(minutes: 1)),
          ),
        );

    final rows = await db.select(db.charactersCache).get();
    expect(rows.length, 1);
    expect(rows.first.payloadJson, contains('Tael'));
  });

  test('wireUpdatedAt round-trips to second precision', () async {
    // Drift's default DateTimeColumn maps to Unix integer seconds — sub-second
    // resolution is silently truncated. Lock the contract in a test so a future
    // wire format that needs millisecond precision can't regress silently.
    final ts = DateTime.utc(2026, 5, 16, 12);
    await db.into(db.charactersCache).insertOnConflictUpdate(
          CharactersCacheCompanion.insert(
            id: 'char-ts',
            payloadJson: '{}',
            wireUpdatedAt: ts,
            cachedAt: ts,
          ),
        );
    final row = await (db.select(db.charactersCache)
          ..where((t) => t.id.equals('char-ts')))
        .getSingle();
    expect(row.wireUpdatedAt.toUtc(), ts);
  });

  // ── Schema smoke: all five tables present at current version ─────────────

  test('current schema exposes every cache table at v3', () async {
    // Smoke-test the post-migration shape: a fresh in-memory database (which
    // runs `onCreate` → `createAll()` for the latest `schemaVersion`) must
    // expose `characters_cache`, `pending_mutations`, `ships_cache`,
    // `game_sessions_cache`, and `player_memberships_cache`.
    //
    // Real downgrade-and-upgrade testing (v1 → v2 → v3) requires Drift's
    // `SchemaVerifier` from `drift_dev`, which is a separate dev dep — filed
    // as a follow-up. For now `onCreate(createAll)` guarantees the table set
    // matches the `@DriftDatabase(tables: [...])` annotation.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final freshDb = AppDatabase.forTesting(NativeDatabase.memory());

    await freshDb.into(freshDb.charactersCache).insertOnConflictUpdate(
          CharactersCacheCompanion.insert(
            id: 'char-1',
            payloadJson: '{}',
            wireUpdatedAt: DateTime.utc(2026, 5, 16),
            cachedAt: DateTime.utc(2026, 5, 16),
          ),
        );

    final charRows = await freshDb.select(freshDb.charactersCache).get();
    expect(charRows.length, 1);

    expect(await freshDb.select(freshDb.shipsCache).get(), isEmpty);
    expect(await freshDb.select(freshDb.gameSessionsCache).get(), isEmpty);
    expect(
      await freshDb.select(freshDb.playerMembershipsCache).get(),
      isEmpty,
    );
    expect(await freshDb.select(freshDb.pendingMutations).get(), isEmpty);

    await freshDb.close();
  });
}

import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/shared/cache/app_database.dart';
import 'generated/schema.dart';

void main() {
  // Suppress the "multiple databases opened" warning — each test opens its own
  // independent in-memory database via SchemaVerifier.schemaAt().
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late SchemaVerifier verifier;

  setUp(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('AppDatabase migration', () {
    // ── v1 → v4 ─────────────────────────────────────────────────────────────
    //
    // Simulates a user who installed the app at its very first release
    // (characters_cache only) and upgrades all the way to v4 in one shot.
    // The v1 character row must survive; all tables added in v2/v3/v4 must
    // appear empty after migration.
    test('v1 → v4 (fresh user upgrading through every arm)', () async {
      final schema = await verifier.schemaAt(1);

      // Seed a v1 character row via the raw sqlite3 database.
      // We use raw SQL here because schema generate ran without --companions,
      // so there are no generated insert helpers for old versions.
      schema.rawDatabase.execute(
        'INSERT INTO characters_cache '
        '(id, payload_json, wire_updated_at, cached_at) '
        "VALUES ('char-1', '{\"id\":\"char-1\"}', 1716000000, 1716000000)",
      );

      final db = AppDatabase.forTesting(schema.newConnection());
      await verifier.migrateAndValidate(db, 4);

      // The v1 row must survive.
      final chars = await db.select(db.charactersCache).get();
      expect(chars.length, 1);
      expect(chars.first.id, 'char-1');

      // All tables added in v2 / v3 / v4 must exist and be empty.
      expect(await db.select(db.pendingMutations).get(), isEmpty);
      expect(await db.select(db.shipsCache).get(), isEmpty);
      expect(await db.select(db.gameSessionsCache).get(), isEmpty);
      expect(await db.select(db.playerMembershipsCache).get(), isEmpty);
      expect(await db.select(db.npcsCache).get(), isEmpty);

      await db.close();
      schema.close();
    });

    // ── v2 → v4 ─────────────────────────────────────────────────────────────
    //
    // User already had v2 (characters_cache + pending_mutations).
    // Both a character row and a pending-mutation row must survive.
    test('v2 → v4 preserves CharactersCache and PendingMutations rows',
        () async {
      final schema = await verifier.schemaAt(2);

      schema.rawDatabase.execute(
        'INSERT INTO characters_cache '
        '(id, payload_json, wire_updated_at, cached_at) '
        "VALUES ('char-2', '{\"id\":\"char-2\"}', 1716000000, 1716000000)",
      );
      schema.rawDatabase.execute(
        'INSERT INTO pending_mutations '
        '(id, method, path, body, headers_json, created_at) '
        "VALUES ('mut-1', 'PATCH', '/api/v1/characters/char-2', "
        "NULL, '{}', 1716000001)",
      );

      final db = AppDatabase.forTesting(schema.newConnection());
      await verifier.migrateAndValidate(db, 4);

      final chars = await db.select(db.charactersCache).get();
      expect(chars.length, 1);
      expect(chars.first.id, 'char-2');

      final muts = await db.select(db.pendingMutations).get();
      expect(muts.length, 1);
      expect(muts.first.id, 'mut-1');
      expect(muts.first.method, 'PATCH');

      // Tables added in v3 + v4 must exist and be empty.
      expect(await db.select(db.shipsCache).get(), isEmpty);
      expect(await db.select(db.gameSessionsCache).get(), isEmpty);
      expect(await db.select(db.playerMembershipsCache).get(), isEmpty);
      expect(await db.select(db.npcsCache).get(), isEmpty);

      await db.close();
      schema.close();
    });

    // ── v3 → v4 ─────────────────────────────────────────────────────────────
    //
    // User had v3 (all tables except npcs_cache). The four pre-existing tables
    // must survive; npcs_cache must appear and be empty.
    test(
        'v3 → v4 preserves ShipsCache + GameSessionsCache + PlayerMembershipsCache',
        () async {
      final schema = await verifier.schemaAt(3);

      schema.rawDatabase.execute(
        'INSERT INTO ships_cache '
        '(id, payload_json, wire_updated_at, cached_at) '
        "VALUES ('ship-1', '{\"id\":\"ship-1\"}', 1716000000, 1716000000)",
      );
      schema.rawDatabase.execute(
        'INSERT INTO game_sessions_cache '
        '(id, payload_json, wire_updated_at, cached_at) '
        "VALUES ('gs-1', '{\"id\":\"gs-1\"}', 1716000000, 1716000000)",
      );
      schema.rawDatabase.execute(
        'INSERT INTO player_memberships_cache '
        '(id, payload_json, wire_updated_at, cached_at) '
        "VALUES ('pm-1', '{\"id\":\"pm-1\"}', 1716000000, 1716000000)",
      );

      final db = AppDatabase.forTesting(schema.newConnection());
      await verifier.migrateAndValidate(db, 4);

      final ships = await db.select(db.shipsCache).get();
      expect(ships.length, 1);
      expect(ships.first.id, 'ship-1');

      final sessions = await db.select(db.gameSessionsCache).get();
      expect(sessions.length, 1);
      expect(sessions.first.id, 'gs-1');

      final memberships = await db.select(db.playerMembershipsCache).get();
      expect(memberships.length, 1);
      expect(memberships.first.id, 'pm-1');

      // npcs_cache was added in v4 — must exist and be empty.
      expect(await db.select(db.npcsCache).get(), isEmpty);

      await db.close();
      schema.close();
    });

    // ── v3 → v4 mixed data ──────────────────────────────────────────────────
    //
    // v3 database with both a character row and a pending-mutation row.
    // Both must survive the v3→v4 migration unchanged.
    test(
        'v3 → v4 with mixed data — character row + pending mutation survive',
        () async {
      final schema = await verifier.schemaAt(3);

      schema.rawDatabase.execute(
        'INSERT INTO characters_cache '
        '(id, payload_json, wire_updated_at, cached_at) '
        "VALUES ('char-3', '{\"id\":\"char-3\",\"name\":\"Zephyr\"}', "
        '1716001000, 1716001000)',
      );
      schema.rawDatabase.execute(
        'INSERT INTO pending_mutations '
        '(id, method, path, body, headers_json, created_at) '
        "VALUES ('mut-2', 'PUT', '/api/v1/characters/char-3', "
        "'{\"name\":\"Zephyr\"}', "
        "'{\"Content-Type\":\"application/json\"}', 1716001001)",
      );

      final db = AppDatabase.forTesting(schema.newConnection());
      await verifier.migrateAndValidate(db, 4);

      final chars = await db.select(db.charactersCache).get();
      expect(chars.length, 1);
      expect(chars.first.id, 'char-3');
      expect(chars.first.payloadJson, contains('Zephyr'));

      final muts = await db.select(db.pendingMutations).get();
      expect(muts.length, 1);
      expect(muts.first.id, 'mut-2');
      expect(muts.first.body, contains('Zephyr'));

      // npcs_cache added in v4 — empty.
      expect(await db.select(db.npcsCache).get(), isEmpty);

      await db.close();
      schema.close();
    });
  });
}

import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:built_collection/built_collection.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/features/game_sessions/data/drift_game_session_cache.dart';
import 'package:coriolis_companion/shared/cache/app_database.dart';

api_client.GameSession _wire({
  String id = 'session-1',
  String name = 'The Dying Ship',
}) =>
    api_client.$GameSession((b) => b
      ..id = id
      ..ownerId = 'user-1'
      ..name = name
      ..status = api_client.GameSessionStatus.active
      ..dpCount = 0
      ..characterIds.replace(BuiltList<String>())
      ..memberships.replace(BuiltList<api_client.GameSessionMembership>())
      ..createdAt = DateTime.utc(2026, 5, 16)
      ..updatedAt = DateTime.utc(2026, 5, 16));

void main() {
  late AppDatabase db;
  late DriftGameSessionCache cache;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cache = DriftGameSessionCache(db);
  });

  tearDown(() async => db.close());

  test('read returns null when nothing cached', () async {
    expect(await cache.read('missing'), isNull);
  });

  test('write then read round-trips the wire payload', () async {
    final wire = _wire(name: 'Mercy of Ikons');
    await cache.write(wire);
    final got = await cache.read('session-1');
    expect(got, isNotNull);
    expect(got!.name, 'Mercy of Ikons');
  });

  test('readAll returns all written rows', () async {
    await cache.write(_wire(id: 'session-1', name: 'The Dying Ship'));
    await cache.write(_wire(id: 'session-2', name: 'Mercy of Ikons'));
    final all = await cache.readAll();
    expect(all.length, 2);
    expect(all.map((s) => s.id), containsAll(['session-1', 'session-2']));
  });

  test('delete removes the row', () async {
    await cache.write(_wire());
    await cache.delete('session-1');
    expect(await cache.read('session-1'), isNull);
  });
}

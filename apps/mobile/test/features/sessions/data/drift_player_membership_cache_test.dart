import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/features/sessions/data/drift_player_membership_cache.dart';
import 'package:coriolis_companion/shared/cache/app_database.dart';

api_client.MyMembershipSummary _wire({
  String membershipId = 'mem-1',
  String sessionName = 'The Dying Ship',
}) =>
    api_client.MyMembershipSummary((b) => b
      ..membershipId = membershipId
      ..gameSessionId = 'session-1'
      ..sessionName = sessionName
      ..role = api_client.GameSessionMemberRole.player
      ..joinedAt = DateTime.utc(2026, 5, 16));

void main() {
  late AppDatabase db;
  late DriftPlayerMembershipCache cache;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cache = DriftPlayerMembershipCache(db);
  });

  tearDown(() async => db.close());

  test('read returns null when nothing cached', () async {
    expect(await cache.read('missing'), isNull);
  });

  test('write then read round-trips the wire payload', () async {
    final wire = _wire(sessionName: 'Mercy of Ikons');
    await cache.write(wire);
    final got = await cache.read('mem-1');
    expect(got, isNotNull);
    expect(got!.sessionName, 'Mercy of Ikons');
  });

  test('readAll returns all written rows', () async {
    await cache.write(_wire(membershipId: 'mem-1', sessionName: 'The Dying Ship'));
    await cache.write(_wire(membershipId: 'mem-2', sessionName: 'Mercy of Ikons'));
    final all = await cache.readAll();
    expect(all.length, 2);
    expect(all.map((m) => m.membershipId), containsAll(['mem-1', 'mem-2']));
  });

  test('delete removes the row', () async {
    await cache.write(_wire());
    await cache.delete('mem-1');
    expect(await cache.read('mem-1'), isNull);
  });
}

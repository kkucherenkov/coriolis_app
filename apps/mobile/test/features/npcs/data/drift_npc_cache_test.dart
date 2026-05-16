import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:built_collection/built_collection.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/features/npcs/data/drift_npc_cache.dart';
import 'package:coriolis_companion/shared/cache/app_database.dart';

/// Minimal fixture for [api_client.Npc].
///
/// [api_client.Npc] requires deeply-nested BuiltValue objects: [Attributes],
/// [Skills], [NpcHp], [NpcMp], plus [BuiltList] fields for armor, weapons,
/// and tags. All numeric fields default to 0 via BuiltValueHook; empty lists
/// are supplied explicitly because BuiltList fields have no default hook.
api_client.Npc _wire({
  String id = 'npc-1',
  String name = 'Syndicate Guard',
}) =>
    api_client.Npc((b) => b
      ..id = id
      ..ownerId = 'user-1'
      ..name = name
      ..updatedAt = DateTime.utc(2026, 5, 17)
      ..createdAt = DateTime.utc(2026, 5, 17)
      ..attributes.update((ab) => ab
        ..strength = 3
        ..agility = 3
        ..wits = 2
        ..empathy = 2)
      ..skills.update((sb) => sb
        ..dexterity = 0
        ..force = 1
        ..infiltration = 0
        ..manipulation = 0
        ..meleeCombat = 1
        ..observation = 0
        ..rangedCombat = 2
        ..survival = 0
        ..command = 0
        ..culture = 0
        ..dataDjinn = 0
        ..medicurgy = 0
        ..mysticPowers = 0
        ..pilot = 0
        ..science = 0
        ..technology = 0)
      ..hp.update((hb) => hb
        ..current = 6
        ..max = 6)
      ..mp.update((mb) => mb
        ..current = 4
        ..max = 4)
      ..armor.replace(BuiltList<api_client.ItemArmor>())
      ..weapons.replace(BuiltList<api_client.ItemWeapon>())
      ..tags.replace(BuiltList<String>()));

void main() {
  late AppDatabase db;
  late DriftNpcCache cache;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cache = DriftNpcCache(db);
  });

  tearDown(() async => db.close());

  test('read returns null when nothing cached', () async {
    expect(await cache.read('missing'), isNull);
  });

  test('write then read round-trips the wire payload', () async {
    final wire = _wire(name: 'Legionary Commander');
    await cache.write(wire);
    final got = await cache.read('npc-1');
    expect(got, isNotNull);
    expect(got!.name, 'Legionary Commander');
  });

  test('readAll returns all written rows', () async {
    await cache.write(_wire(id: 'npc-1', name: 'Syndicate Guard'));
    await cache.write(_wire(id: 'npc-2', name: 'Drone Pilot'));
    final all = await cache.readAll();
    expect(all.length, 2);
    expect(all.map((n) => n.id), containsAll(['npc-1', 'npc-2']));
  });

  test('delete removes the row', () async {
    await cache.write(_wire());
    await cache.delete('npc-1');
    expect(await cache.read('npc-1'), isNull);
  });
}

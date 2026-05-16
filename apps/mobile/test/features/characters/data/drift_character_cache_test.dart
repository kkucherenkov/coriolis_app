import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:built_collection/built_collection.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/features/characters/data/drift_character_cache.dart';
import 'package:coriolis_companion/shared/cache/app_database.dart';

api_client.Character _wire({
  String id = 'char-1',
  String name = 'Tael',
  api_client.CharacterStatusEnum status = api_client.CharacterStatusEnum.draft,
}) =>
    api_client.Character((b) => b
      ..id = id
      ..ownerId = 'user-1'
      ..name = name
      ..upbringing = api_client.Upbringing.plebeian
      ..reputation = 0
      ..startingWealth = 0
      ..birr = 0
      ..mutant = false
      ..status = status
      ..attributes.replace(api_client.Attributes((a) => a
        ..strength = 3
        ..agility = 3
        ..wits = 3
        ..empathy = 3))
      ..skills.replace(api_client.Skills((s) => s
        ..dexterity = 0
        ..force = 0
        ..infiltration = 0
        ..manipulation = 0
        ..meleeCombat = 0
        ..observation = 0
        ..rangedCombat = 0
        ..survival = 0
        ..command = 0
        ..culture = 0
        ..dataDjinn = 0
        ..medicurgy = 0
        ..mysticPowers = 0
        ..pilot = 0
        ..science = 0
        ..technology = 0))
      ..hp.replace(api_client.CharacterHp((h) => h
        ..current = 5
        ..max = 5))
      ..mp.replace(api_client.CharacterMp((m) => m
        ..current = 5
        ..max = 5))
      ..encumbrance.replace(api_client.CharacterEncumbrance((e) => e
        ..current = 0
        ..max = 10))
      ..experience = 0
      ..conditions.replace(api_client.ConditionFlags((c) => c
        ..exhausted = false
        ..sleepless = false
        ..thirsty = false
        ..hungry = false))
      ..criticalInjuries.replace(BuiltList<api_client.CriticalInjury>())
      ..talents.replace(BuiltList<api_client.Talent>())
      ..relationships.replace(BuiltList<api_client.Relationship>())
      ..inventory.replace(BuiltList<api_client.Item>())
      ..updatedAt = DateTime.utc(2026, 5, 16)
      ..createdAt = DateTime.utc(2026, 5, 16));

void main() {
  late AppDatabase db;
  late DriftCharacterCache cache;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cache = DriftCharacterCache(db);
  });

  tearDown(() async => db.close());

  test('read returns null when nothing cached', () async {
    expect(await cache.read('missing'), isNull);
  });

  test('write then read round-trips the wire payload', () async {
    final wire = _wire(name: 'Adira');
    await cache.write(wire);
    final got = await cache.read('char-1');
    expect(got, isNotNull);
    expect(got!.name, 'Adira');
  });

  test('write twice for same id replaces in place', () async {
    await cache.write(_wire(name: 'Adira'));
    await cache.write(_wire(name: 'Adira II'));
    final all = await cache.readAll();
    expect(all.length, 1);
    expect(all.single.name, 'Adira II');
  });

  test('delete removes the row', () async {
    await cache.write(_wire());
    await cache.delete('char-1');
    expect(await cache.read('char-1'), isNull);
  });
}

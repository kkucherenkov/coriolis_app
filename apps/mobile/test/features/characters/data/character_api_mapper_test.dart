import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/features/characters/data/character_api_mapper.dart';
import 'package:coriolis_companion/features/characters/domain/character.dart';

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
  test('toDomain maps id + name + status', () {
    final Character domain = CharacterApiMapper.toDomain(_wire(name: 'Adira'));
    expect(domain.id, 'char-1');
    expect(domain.name, 'Adira');
    expect(domain.status, 'draft');
  });

  test('toSummary extracts id + name + concept', () {
    final summary = CharacterApiMapper.toSummary(_wire());
    expect(summary.id, 'char-1');
    expect(summary.name, 'Tael');
    expect(summary.concept, isNull);
  });
}

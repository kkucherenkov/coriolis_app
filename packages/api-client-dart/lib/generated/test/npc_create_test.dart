import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for NpcCreate
void main() {
  final instance = NpcCreateBuilder();
  // TODO add properties to the builder and call build()

  group(NpcCreate, () {
    // NPC name (1–120 characters)
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // Free-form description (Markdown, max 2000 chars)
    // String description
    test('to test the property `description`', () async {
      // TODO
    });

    // Attribute block; missing keys default to 2
    // Attributes attributes
    test('to test the property `attributes`', () async {
      // TODO
    });

    // Skill block; missing keys default to 0
    // Skills skills
    test('to test the property `skills`', () async {
      // TODO
    });

    // NpcCreateHp hp
    test('to test the property `hp`', () async {
      // TODO
    });

    // NpcCreateMp mp
    test('to test the property `mp`', () async {
      // TODO
    });

    // Sensor signature score; defaults to 0
    // int signature (default value: 0)
    test('to test the property `signature`', () async {
      // TODO
    });

    // Key skill modifier for combat tracker; defaults to 0
    // int keySkillModifier (default value: 0)
    test('to test the property `keySkillModifier`', () async {
      // TODO
    });

    // Armor items; defaults to empty array
    // BuiltList<ItemArmor> armor
    test('to test the property `armor`', () async {
      // TODO
    });

    // Weapons; defaults to empty array
    // BuiltList<ItemWeapon> weapons
    test('to test the property `weapons`', () async {
      // TODO
    });

    // Categorisation tags; defaults to empty array
    // BuiltList<String> tags
    test('to test the property `tags`', () async {
      // TODO
    });

  });
}

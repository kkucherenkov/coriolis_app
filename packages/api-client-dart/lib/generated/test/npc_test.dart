import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for Npc
void main() {
  final instance = NpcBuilder();
  // TODO add properties to the builder and call build()

  group(Npc, () {
    // Opaque NPC identifier (cuid2)
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // Identifier of the owning user (cuid2)
    // String ownerId
    test('to test the property `ownerId`', () async {
      // TODO
    });

    // NPC name (1–120 characters)
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // Free-form GM notes or narrative description (Markdown, max 2000 chars)
    // String description
    test('to test the property `description`', () async {
      // TODO
    });

    // Attributes attributes
    test('to test the property `attributes`', () async {
      // TODO
    });

    // Skills skills
    test('to test the property `skills`', () async {
      // TODO
    });

    // NpcHp hp
    test('to test the property `hp`', () async {
      // TODO
    });

    // NpcMp mp
    test('to test the property `mp`', () async {
      // TODO
    });

    // NPC sensor signature for ship-combat sensor checks (ST3001 ГЛАВА 14). Signed integer; 0 is baseline; negative makes the NPC harder to detect; positive makes them easier. 
    // int signature (default value: 0)
    test('to test the property `signature`', () async {
      // TODO
    });

    // Signed integer bonus applied by the combat tracker to the NPC's attack or defence roll pool when resolving opposed key-skill checks (ST3001 ГЛАВА 14). Positive values give the NPC an advantage; negative values impose a penalty. 
    // int keySkillModifier (default value: 0)
    test('to test the property `keySkillModifier`', () async {
      // TODO
    });

    // Armor items carried by the NPC
    // BuiltList<ItemArmor> armor
    test('to test the property `armor`', () async {
      // TODO
    });

    // Weapons carried by the NPC
    // BuiltList<ItemWeapon> weapons
    test('to test the property `weapons`', () async {
      // TODO
    });

    // Free-form GM-side categorisation labels (e.g. \"Pirate\", \"Cyborg\", \"Boss\"). Used for filtering in the NPC list and for encounter-table grouping. Each tag is a 1–40 character string. 
    // BuiltList<String> tags
    test('to test the property `tags`', () async {
      // TODO
    });

    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

    // DateTime updatedAt
    test('to test the property `updatedAt`', () async {
      // TODO
    });

  });
}

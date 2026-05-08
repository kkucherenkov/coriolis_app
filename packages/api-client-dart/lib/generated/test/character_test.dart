import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for Character
void main() {
  final instance = CharacterBuilder();
  // TODO add properties to the builder and call build()

  group(Character, () {
    // Opaque character identifier (cuid2)
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // Identifier of the owning user (cuid2)
    // String ownerId
    test('to test the property `ownerId`', () async {
      // TODO
    });

    // Character name (1–80 characters)
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // Short concept phrase — the role the character plays at the table (1–120 chars when non-null)
    // String concept
    test('to test the property `concept`', () async {
      // TODO
    });

    // IconId iconId
    test('to test the property `iconId`', () async {
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

    // CharacterHp hp
    test('to test the property `hp`', () async {
      // TODO
    });

    // CharacterMp mp
    test('to test the property `mp`', () async {
      // TODO
    });

    // CharacterEncumbrance encumbrance
    test('to test the property `encumbrance`', () async {
      // TODO
    });

    // Total XP earned
    // int experience
    test('to test the property `experience`', () async {
      // TODO
    });

    // ConditionFlags conditions
    test('to test the property `conditions`', () async {
      // TODO
    });

    // BuiltList<CriticalInjury> criticalInjuries
    test('to test the property `criticalInjuries`', () async {
      // TODO
    });

    // BuiltList<Talent> talents
    test('to test the property `talents`', () async {
      // TODO
    });

    // BuiltList<Relationship> relationships
    test('to test the property `relationships`', () async {
      // TODO
    });

    // BuiltList<Item> inventory
    test('to test the property `inventory`', () async {
      // TODO
    });

    // Free-form notes (Markdown; soft cap 4096 characters)
    // String notes
    test('to test the property `notes`', () async {
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

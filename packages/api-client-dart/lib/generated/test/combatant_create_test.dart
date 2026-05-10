import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for CombatantCreate
void main() {
  final instance = CombatantCreateBuilder();
  // TODO add properties to the builder and call build()

  group(CombatantCreate, () {
    // CombatantType combatantType
    test('to test the property `combatantType`', () async {
      // TODO
    });

    // Identifier of the source entity. Must be a `Character.id` when `combatantType` is `pc`, or an `Npc.id` when `combatantType` is `npc`. 
    // String sourceId
    test('to test the property `sourceId`', () async {
      // TODO
    });

    // Optional override for the combatant display name. When omitted the server copies the source entity's `name`. 
    // String displayName
    test('to test the property `displayName`', () async {
      // TODO
    });

    // Optional GM notes in Markdown (max 500 characters).
    // String notes
    test('to test the property `notes`', () async {
      // TODO
    });

  });
}

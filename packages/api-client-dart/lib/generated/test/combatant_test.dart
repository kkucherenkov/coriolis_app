import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for Combatant
void main() {
  final instance = CombatantBuilder();
  // TODO add properties to the builder and call build()

  group(Combatant, () {
    // Opaque combatant identifier (cuid2)
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // Identifier of the parent encounter (cuid2)
    // String encounterId
    test('to test the property `encounterId`', () async {
      // TODO
    });

    // CombatantType combatantType
    test('to test the property `combatantType`', () async {
      // TODO
    });

    // Identifier of the source entity. When `combatantType` is `pc` this is the `Character.id`; when `npc` it is the `Npc.id`. 
    // String sourceId
    test('to test the property `sourceId`', () async {
      // TODO
    });

    // Denormalised name of the combatant, copied from the source entity's `name` at add-time. Can be overridden in `CombatantCreate.displayName` or updated via `PATCH`. 
    // String displayName
    test('to test the property `displayName`', () async {
      // TODO
    });

    // d10 initiative result (1–10 per ST3001). Null until the encounter's initiative is rolled (Block 4 operation). Set server-side only. 
    // int initiative
    test('to test the property `initiative`', () async {
      // TODO
    });

    // 0-based index in the turn sequence after initiative is sorted. Null until initiative is rolled. Combatant at index 0 goes first. Set server-side only. 
    // int turnOrder
    test('to test the property `turnOrder`', () async {
      // TODO
    });

    // Current hit points. May go below 0 (CT3001 does not clamp).
    // int hpCurrent
    test('to test the property `hpCurrent`', () async {
      // TODO
    });

    // Maximum hit points snapshotted from the source at add-time.
    // int hpMax
    test('to test the property `hpMax`', () async {
      // TODO
    });

    // Armor rating (number of armor dice). Snapshotted from the source at add-time.
    // int armor
    test('to test the property `armor`', () async {
      // TODO
    });

    // Mystic Darkness signature value. Defaults to 0 for PC combatants; copied from `Npc.signature` for NPC combatants at add-time. 
    // int signature
    test('to test the property `signature`', () async {
      // TODO
    });

    // Free-form short tags describing combat status conditions. Well-known values: `broken`, `exposed`, `covered`, `prone`. Clients should render known tags with icons; unknown tags are shown as plain text. 
    // BuiltList<String> statusFlags
    test('to test the property `statusFlags`', () async {
      // TODO
    });

    // Optional GM notes for this combatant in Markdown format (max 500 characters).
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

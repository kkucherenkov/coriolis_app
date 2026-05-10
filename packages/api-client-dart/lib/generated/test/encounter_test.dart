import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for Encounter
void main() {
  final instance = EncounterBuilder();
  // TODO add properties to the builder and call build()

  group(Encounter, () {
    // Opaque encounter identifier (cuid2)
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // Identifier of the parent game session (cuid2)
    // String gameSessionId
    test('to test the property `gameSessionId`', () async {
      // TODO
    });

    // Short descriptive name for the encounter (1–80 characters)
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // EncounterStatus status
    test('to test the property `status`', () async {
      // TODO
    });

    // Current combat round. Starts at 0 while in `setup`. Bumped to 1 when the encounter transitions to `active`. Increments by 1 each time the turn order wraps back to the first combatant (Block 4 turn-advance operation). 
    // int round (default value: 0)
    test('to test the property `round`', () async {
      // TODO
    });

    // Identifier of the combatant whose turn it currently is. Null when `status` is `setup` (initiative not yet rolled) or `ended` (combat closed). Set by the server on the `setup → active` transition and updated by the turn-advance operation (Block 4). 
    // String activeCombatantId
    test('to test the property `activeCombatantId`', () async {
      // TODO
    });

    // Optional GM notes for the encounter in Markdown format (max 4096 characters). May be edited at any status. 
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

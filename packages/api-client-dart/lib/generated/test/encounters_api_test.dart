import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';


/// tests for EncountersApi
void main() {
  final instance = AppApiClient().getEncountersApi();

  group(EncountersApi, () {
    // Create an encounter in a game session
    //
    // Creates a new encounter owned by the game session. The encounter is seeded with `status: setup`, `round: 0`, and `activeCombatantId: null`. Combatants can be freely added or removed while the encounter is in `setup` status (Block 3 surface). 
    //
    //Future<Encounter> createEncounter(String sessionId, EncounterCreate encounterCreate) async
    test('test createEncounter', () async {
      // TODO
    });

    // Delete an encounter
    //
    // Permanently deletes an encounter and cascades to all of its combatants (Block 3 schema). The encounter's parent game session must be owned by the authenticated user. 
    //
    //Future deleteEncounter(String id) async
    test('test deleteEncounter', () async {
      // TODO
    });

    // Get an encounter by ID
    //
    // Returns the full encounter DTO. The encounter's parent game session must be owned by the authenticated user — the server checks `encounter.gameSession.ownerId === caller.id`. Returns 404 if the encounter does not exist or 403 if the caller does not own the parent session. 
    //
    //Future<Encounter> getEncounter(String id) async
    test('test getEncounter', () async {
      // TODO
    });

    // List encounters for a game session
    //
    // Returns a cursor-paginated list of encounters belonging to the game session identified by `sessionId`. Optionally filter by `status`. Only the GM who owns the session may call this endpoint. Results are ordered newest-first by `createdAt`. 
    //
    //Future<EncounterList> listEncounters(String sessionId, { String cursor, int limit, EncounterStatus status }) async
    test('test listEncounters', () async {
      // TODO
    });

    // Update an encounter
    //
    // Applies PATCH semantics to an encounter. All fields are optional.  **Allowed status transitions:** - `setup → active` — starts combat. Bumps `round` to 1, sets   `activeCombatantId` to the first combatant in initiative order.   **Requires at least one combatant** on the encounter; if the   encounter has zero combatants the server returns 422   `ENCOUNTER_NO_COMBATANTS` (combatants are added via the Block 3   surface at `POST /api/v1/encounters/{id}/combatants`). - `active → ended` — closes combat. The encounter becomes   read-only history; `activeCombatantId` is set to null.  **Forbidden transitions** (422 `ENCOUNTER_INVALID_TRANSITION`): - Any transition back to `setup` from `active` or `ended`. - `setup → ended` (must go through `active` first). - Any transition out of `ended`.  Renaming and notes editing are permitted regardless of status. 
    //
    //Future<Encounter> updateEncounter(String id, EncounterUpdate encounterUpdate) async
    test('test updateEncounter', () async {
      // TODO
    });

  });
}

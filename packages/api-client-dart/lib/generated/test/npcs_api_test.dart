import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';


/// tests for NpcsApi
void main() {
  final instance = AppApiClient().getNpcsApi();

  group(NpcsApi, () {
    // Create a new NPC
    //
    // Creates an NPC owned by the authenticated user. Only `name` is required; all other fields default to playable stubs so a quick encounter-filler can be created with a single call. Server assigns `id`, `ownerId`, `createdAt`, `updatedAt`.  Default seeds applied by the server when fields are omitted: - `attributes` — all four attributes set to 2 - `skills` — all 16 skills set to 0 - `hp` — `{ current: 4, max: 4 }` - `mp` — `{ current: 4, max: 4 }` - `armor` — empty array - `weapons` — empty array - `tags` — empty array - `signature` — 0 - `keySkillModifier` — 0 
    //
    //Future<Npc> createNpc(NpcCreate npcCreate) async
    test('test createNpc', () async {
      // TODO
    });

    // Delete an NPC
    //
    // Permanently deletes an NPC. This action is irreversible. NPCs referenced by active encounters are rejected with 409 `NPC_IN_USE` — remove the combatant from the encounter first. 
    //
    //Future deleteNpc(String id) async
    test('test deleteNpc', () async {
      // TODO
    });

    // Duplicate an NPC
    //
    // Creates a deep copy of the NPC (attributes, skills, hp, mp, armor, weapons, tags) and assigns it to the authenticated user. The copy receives a new `id` and a name suffix: \"(copy)\" for the first duplicate, \"(copy 2)\" for the second, and so on. The source NPC must be owned by the caller. 
    //
    //Future<Npc> duplicateNpc(String id) async
    test('test duplicateNpc', () async {
      // TODO
    });

    // Get an NPC by ID
    //
    // Returns the full Npc DTO. Returns 404 if the NPC does not exist and 403 if it is owned by a different user. 
    //
    //Future<Npc> getNpc(String id) async
    test('test getNpc', () async {
      // TODO
    });

    // List the authenticated user's NPCs
    //
    // Returns a cursor-paginated list of NPCs owned by the authenticated user. Pass `cursor` from a previous response's `nextCursor` to retrieve the following page. Results are ordered newest-first by `createdAt`. Optionally filter by `tag` (exact match against any element of the NPC's `tags` array). 
    //
    //Future<NpcList> listNpcs({ String cursor, int limit, String tag }) async
    test('test listNpcs', () async {
      // TODO
    });

    // Partially update an NPC
    //
    // Applies PATCH semantics — omitted fields are left unchanged. Read-only fields (`id`, `ownerId`, `createdAt`, `updatedAt`) are rejected with 400 if included. 
    //
    //Future<Npc> updateNpc(String id, NpcUpdate npcUpdate) async
    test('test updateNpc', () async {
      // TODO
    });

  });
}

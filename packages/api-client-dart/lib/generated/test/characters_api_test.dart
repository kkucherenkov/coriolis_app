import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';


/// tests for CharactersApi
void main() {
  final instance = AppApiClient().getCharactersApi();

  group(CharactersApi, () {
    // Add an item to a character's inventory
    //
    // Creates an item of the specified `type` under the character. The discriminator field `type` determines which additional fields are accepted and required. `id` is assigned by the server. 
    //
    //Future<Item> addCharacterItem(String id, ItemCreate itemCreate) async
    test('test addCharacterItem', () async {
      // TODO
    });

    // Add a talent to a character
    //
    // Creates a talent record attached to the character. Talents are free-form (name + description + rank); there is no server-side talent library in v1. 
    //
    //Future<Talent> addCharacterTalent(String id, TalentCreate talentCreate) async
    test('test addCharacterTalent', () async {
      // TODO
    });

    // Create a new character
    //
    // Creates a character owned by the authenticated user. `name` is the only required field; all other fields default to empty arrays, null, or 0. Server-derived fields (`hp.max`, `mp.max`, `encumbrance.max`) are populated from the provided attribute values or defaults.  Attribute defaults are 2 per attribute when not provided. Skills default to 0. 
    //
    //Future<Character> createCharacter(CharacterCreate characterCreate) async
    test('test createCharacter', () async {
      // TODO
    });

    // Delete a character
    //
    // Permanently deletes a character and all its nested items, talents, relationships, and share links. This action is irreversible. 
    //
    //Future deleteCharacter(String id) async
    test('test deleteCharacter', () async {
      // TODO
    });

    // Delete an item
    //
    // Permanently deletes an item from a character's inventory. Authorization: caller must own the parent character. 
    //
    //Future deleteItem(String id) async
    test('test deleteItem', () async {
      // TODO
    });

    // Delete a talent
    //
    // Permanently removes a talent from a character. Authorization: caller must own the parent character. 
    //
    //Future deleteTalent(String id) async
    test('test deleteTalent', () async {
      // TODO
    });

    // Duplicate a character
    //
    // Creates a deep copy of the character (including items, talents, relationships, and conditions) and assigns it to the authenticated user. The copy receives a new `id` and the name has \" (copy)\" appended. Share links are not duplicated. The source character must be owned by the caller. 
    //
    //Future<Character> duplicateCharacter(String id) async
    test('test duplicateCharacter', () async {
      // TODO
    });

    // Export a character as JSON
    //
    // Returns the full canonical Character DTO as a downloadable JSON payload. v1 ships JSON only; PDF and encounter-bundle exports are post-v1. The response carries `Content-Disposition: attachment` so browsers prompt a download. 
    //
    //Future<Character> exportCharacter(String id) async
    test('test exportCharacter', () async {
      // TODO
    });

    // Get a character by ID
    //
    // Returns the full character DTO. Returns 404 if the character does not exist or is not owned by the authenticated user. Owner-scoped: a character owned by another user returns 403 (not 404) when the caller is authenticated, to aid debugging while preserving access boundaries. 
    //
    //Future<Character> getCharacter(String id) async
    test('test getCharacter', () async {
      // TODO
    });

    // List the authenticated user's characters
    //
    // Returns a cursor-paginated list of characters owned by the authenticated user. Pass `cursor` from a previous response's `nextCursor` to retrieve the following page. Results are ordered newest-first by `createdAt`. 
    //
    //Future<CharacterList> listCharacters({ String cursor, int limit }) async
    test('test listCharacters', () async {
      // TODO
    });

    // Partially update a character
    //
    // Applies PATCH semantics — omitted fields are left unchanged. Read-only fields (`id`, `ownerId`, `hp.max`, `mp.max`, `encumbrance.max`, `createdAt`, `updatedAt`) are rejected with 400 if included.  Server-derived fields (`hp.max`, `mp.max`, `encumbrance.max`) are recalculated after each write and reflected in the response. 
    //
    //Future<Character> updateCharacter(String id, CharacterUpdate characterUpdate) async
    test('test updateCharacter', () async {
      // TODO
    });

    // Update an item
    //
    // Applies PATCH semantics to an item. The `type` discriminator may not be changed after creation — attempting to do so returns 400 with code `ITEM_TYPE_MISMATCH`. Authorization: caller must own the parent character. 
    //
    //Future<Item> updateItem(String id, ItemUpdate itemUpdate) async
    test('test updateItem', () async {
      // TODO
    });

    // Update a talent
    //
    // Applies PATCH semantics to a talent. Authorization: caller must own the parent character. 
    //
    //Future<Talent> updateTalent(String id, TalentUpdate talentUpdate) async
    test('test updateTalent', () async {
      // TODO
    });

  });
}

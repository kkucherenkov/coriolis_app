import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';


/// tests for ShipsApi
void main() {
  final instance = AppApiClient().getShipsApi();

  group(ShipsApi, () {
    // Add a module to a ship
    //
    // Installs a new module on the ship. The `slot` discriminator determines which type-specific fields are accepted. Validates that the slot type is appropriate for the requested module. The ship must be owned by the caller. 
    //
    //Future<ShipModule> addShipModule(String id, ShipModuleCreate shipModuleCreate) async
    test('test addShipModule', () async {
      // TODO
    });

    // Assign a character to a crew position
    //
    // Assigns one of the caller's own characters to a crew position on the ship. The ship must be owned by the caller. The character must also be owned by the caller (returns `CHARACTER_NOT_OWNED` otherwise). Returns `CREW_POSITION_TAKEN` if that position is already filled. 
    //
    //Future<CrewSlot> assignCrew(String id, AssignCrewRequest assignCrewRequest) async
    test('test assignCrew', () async {
      // TODO
    });

    // Create a new ship
    //
    // Creates a ship owned by the authenticated user. `name` and `class` are required; all other fields default to class-appropriate values per ST3001 ГЛАВА 7 Table 7.5. Server assigns `id`, `ownerId`, `createdAt`, `updatedAt`. 
    //
    //Future<Ship> createShip(ShipCreate shipCreate) async
    test('test createShip', () async {
      // TODO
    });

    // Delete a ship
    //
    // Permanently deletes a ship and all its modules, crew assignments, and share links. This action is irreversible. 
    //
    //Future deleteShip(String id) async
    test('test deleteShip', () async {
      // TODO
    });

    // Remove a module from a ship
    //
    // Permanently removes an installed module. Authorization: caller must own the parent ship. 
    //
    //Future deleteShipModule(String id) async
    test('test deleteShipModule', () async {
      // TODO
    });

    // Duplicate a ship
    //
    // Creates a deep copy of the ship (including modules and problems) and assigns it to the authenticated user. The copy receives a new `id` and the name has \" (copy)\" appended. Crew assignments and share links are not duplicated. The source ship must be owned by the caller. 
    //
    //Future<Ship> duplicateShip(String id) async
    test('test duplicateShip', () async {
      // TODO
    });

    // Export a ship as JSON
    //
    // Returns the full canonical Ship DTO as a downloadable JSON payload. The response carries `Content-Disposition: attachment` so browsers prompt a download. 
    //
    //Future<Ship> exportShip(String id) async
    test('test exportShip', () async {
      // TODO
    });

    // Get a ship by ID
    //
    // Returns the full Ship DTO. Returns 404 if the ship does not exist or is not owned by the authenticated user. Owner-scoped: a ship owned by another user returns 403. 
    //
    //Future<Ship> getShip(String id) async
    test('test getShip', () async {
      // TODO
    });

    // List the authenticated user's ships
    //
    // Returns a cursor-paginated list of ships owned by the authenticated user. Pass `cursor` from a previous response's `nextCursor` to retrieve the following page. Results are ordered newest-first by `createdAt`. 
    //
    //Future<ShipList> listShips({ String cursor, int limit }) async
    test('test listShips', () async {
      // TODO
    });

    // Remove a character from the crew
    //
    // Removes the crew assignment for the given character ID on the ship. Both the ship and the character must be owned by the caller. 
    //
    //Future unassignCrew(String id, String characterId) async
    test('test unassignCrew', () async {
      // TODO
    });

    // Partially update a ship
    //
    // Applies PATCH semantics — omitted fields are left unchanged. Read-only fields (`id`, `ownerId`, `createdAt`, `updatedAt`) are rejected with 400 if included. 
    //
    //Future<Ship> updateShip(String id, ShipUpdate shipUpdate) async
    test('test updateShip', () async {
      // TODO
    });

    // Update a ship module
    //
    // Applies PATCH semantics to a ship module. The `slot` discriminator may not be changed after installation — attempting to do so returns 400 with code `MODULE_TYPE_MISMATCH`. Authorization: caller must own the parent ship. 
    //
    //Future<ShipModule> updateShipModule(String id, ShipModuleUpdate shipModuleUpdate) async
    test('test updateShipModule', () async {
      // TODO
    });

  });
}

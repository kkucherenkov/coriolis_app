import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';


/// tests for GameSessionsApi
void main() {
  final instance = AppApiClient().getGameSessionsApi();

  group(GameSessionsApi, () {
    // Assign a character to a game session
    //
    // Assigns one of the caller's own characters to the game session. The character must be owned by the same user as the session (GM). Assigning an already-assigned character is idempotent — returns the current session state without creating a duplicate. 
    //
    //Future<GameSession> assignCharacterToSession(String id, AssignCharacterToSession assignCharacterToSession) async
    test('test assignCharacterToSession', () async {
      // TODO
    });

    // Create a new game session
    //
    // Creates a game session owned by the authenticated user (the GM). `name` is the only required field; all other fields are optional. 
    //
    //Future<GameSession> createGameSession(GameSessionCreate gameSessionCreate) async
    test('test createGameSession', () async {
      // TODO
    });

    // Delete a game session
    //
    // Permanently deletes a game session. Cascades to the character assignment join table. The session must be owned by the caller. 
    //
    //Future deleteGameSession(String id) async
    test('test deleteGameSession', () async {
      // TODO
    });

    // Get a game session by ID
    //
    // Returns the full game session DTO. Returns 404 if the session does not exist or is not owned by the authenticated user. 
    //
    //Future<GameSession> getGameSession(String id) async
    test('test getGameSession', () async {
      // TODO
    });

    // List the authenticated GM's game sessions
    //
    // Returns a cursor-paginated list of game sessions owned by the authenticated user. Pass `cursor` from a previous response's `nextCursor` to retrieve the following page. Results are ordered newest-first by `createdAt`. Optionally filter by `status`. 
    //
    //Future<GameSessionList> listGameSessions({ String cursor, int limit, GameSessionStatus status }) async
    test('test listGameSessions', () async {
      // TODO
    });

    // Remove a character from a game session
    //
    // Removes the character from the session's character list. The session must be owned by the caller. Silently succeeds if the character was not assigned. 
    //
    //Future unassignCharacterFromSession(String id, String characterId) async
    test('test unassignCharacterFromSession', () async {
      // TODO
    });

    // Update a game session
    //
    // Applies PATCH semantics to a game session. All fields are optional. Status transitions: `active → archived` and `archived → active` are both permitted. 
    //
    //Future<GameSession> updateGameSession(String id, GameSessionUpdate gameSessionUpdate) async
    test('test updateGameSession', () async {
      // TODO
    });

  });
}

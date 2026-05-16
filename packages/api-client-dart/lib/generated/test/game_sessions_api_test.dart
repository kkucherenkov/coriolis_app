import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';


/// tests for GameSessionsApi
void main() {
  final instance = AppApiClient().getGameSessionsApi();

  group(GameSessionsApi, () {
    // Adjust Darkness Points for a game session
    //
    // Atomically adjusts the Darkness Points counter for the session.  **ACL rules:** - Negative `delta`: only the GM who owns the session may apply. - Positive `delta`: the GM owner may apply; the system applies   automatically via the roll-push pipeline.  **Error codes:** - `DP_INVALID_DELTA` (422) — `delta` is 0. - `DP_BELOW_ZERO` (422) — applying `delta` would take `dpCount` below 0. - `GAME_SESSION_NOT_OWNER` (403) — negative delta from non-owner. 
    //
    //Future<GameSession> adjustDp(String id, DpAdjustment dpAdjustment) async
    test('test adjustDp', () async {
      // TODO
    });

    // Block a session member
    //
    // Adds the target membership to the caller's block list for this session. Idempotent — blocking an already-blocked member is a no-op. Once blocked, the blocked member cannot whisper to the blocker. 
    //
    //Future blockMember(String id, ChatBlockRequest chatBlockRequest) async
    test('test blockMember', () async {
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

    // Read invite metadata (GM only)
    //
    // Returns whether an invite is active for this session and when it was last rotated. Never returns the plaintext URL — that is revealed exactly once by POST /invite/rotate. 
    //
    //Future<InviteMetadata> getInviteMetadata(String id) async
    test('test getInviteMetadata', () async {
      // TODO
    });

    // Link or unlink a character to a membership
    //
    // The owner of the membership (the player or the GM themselves) can change which character is attached. The GM can also operate on any membership for moderation. Pass `characterId: null` to unlink. 
    //
    //Future<GameSessionMembership> linkMembershipCharacter(String id, String membershipId, LinkMembershipCharacterRequest linkMembershipCharacterRequest) async
    test('test linkMembershipCharacter', () async {
      // TODO
    });

    // List the caller's block list for a session
    //
    // Returns all memberships the caller has blocked in this session. 
    //
    //Future<ListBlocks200Response> listBlocks(String id) async
    test('test listBlocks', () async {
      // TODO
    });

    // List chat conversations for a session member
    //
    // Returns a summary of all conversations visible to the caller: the broadcast channel plus any whisper threads they participate in. Includes unread counts relative to the caller's read cursor. 
    //
    //Future<ChatConversationList> listChatConversations(String id) async
    test('test listChatConversations', () async {
      // TODO
    });

    // List chat messages for a session conversation
    //
    // Returns a cursor-paginated list of messages for the specified conversation. Pass `conversation=broadcast` (default) for the session broadcast channel, or pass a `membershipId` to read a whisper thread. Only the two participants of a whisper thread can see its messages. 
    //
    //Future<ChatMessageList> listChatMessages(String id, { String conversation, String cursor, int limit }) async
    test('test listChatMessages', () async {
      // TODO
    });

    // List Darkness Point audit events for a session
    //
    // Returns a cursor-paginated audit log of all DP adjustments made to the session, ordered newest-first. Only accessible by the GM owner. 
    //
    //Future<DpEventList> listDpEvents(String id, { String cursor, int limit }) async
    test('test listDpEvents', () async {
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

    // List session members (GM or member)
    //
    // Returns active memberships for this session. Available to the GM and to any active member. Leaver rows (with non-null leftAt) are excluded. 
    //
    //Future<BuiltList<GameSessionMembership>> listMembers(String id) async
    test('test listMembers', () async {
      // TODO
    });

    // Mark a conversation as read up to a timestamp
    //
    // Upserts the caller's read cursor for the given conversation. The `conversationKey` is URL-encoded; use `broadcast` for the session broadcast or a membershipId for a whisper thread. 
    //
    //Future markChatConversationRead(String id, String conversationKey, MarkReadRequest markReadRequest) async
    test('test markChatConversationRead', () async {
      // TODO
    });

    // Post a chat message to a session
    //
    // Posts a broadcast (`targetMembershipId: null`) or whisper (`targetMembershipId: <membershipId>`) message. Returns 403 when the target has blocked the author. Returns 404 when the target is not an active session member. Rate-limited to 30 msg/min and 5/s burst per user. 
    //
    //Future<ChatMessage> postChatMessage(String id, PostChatMessageRequest postChatMessageRequest) async
    test('test postChatMessage', () async {
      // TODO
    });

    // Kick (GM) or leave (member) — soft delete
    //
    // Stamps `leftAt` on the membership. The GM can kick any non-GM member; a player can self-leave. The GM cannot kick themselves. 
    //
    //Future removeMembership(String id, String membershipId) async
    test('test removeMembership', () async {
      // TODO
    });

    // Revoke the current invite (GM only)
    //
    // Clears the invite hash on the session. Subsequent accept attempts return 410 Gone. Re-issuing requires POST /invite/rotate. 
    //
    //Future revokeInvite(String id) async
    test('test revokeInvite', () async {
      // TODO
    });

    // Rotate (or first-generate) the session's invite link (GM only)
    //
    // Generates a fresh 22-char URL-safe nanoid, stores its SHA-256 hash, and returns the plaintext URL exactly once. Any previously-issued invite immediately becomes invalid. 
    //
    //Future<InviteRotated> rotateInvite(String id) async
    test('test rotateInvite', () async {
      // TODO
    });

    // Unblock a session member
    //
    // Removes the target membership from the caller's block list. Idempotent — unblocking a member who was not blocked is a no-op. 
    //
    //Future unblockMember(String id, String targetMembershipId) async
    test('test unblockMember', () async {
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

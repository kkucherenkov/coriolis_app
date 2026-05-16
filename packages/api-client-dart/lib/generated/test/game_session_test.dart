import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for GameSession
void main() {
  //final instance = GameSessionBuilder();
  // TODO add properties to the builder and call build()

  group(GameSession, () {
    // Opaque session identifier (cuid2)
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // User identifier of the GM who owns this session
    // String ownerId
    test('to test the property `ownerId`', () async {
      // TODO
    });

    // Short name for the session
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // Optional longer description
    // String description
    test('to test the property `description`', () async {
      // TODO
    });

    // GameSessionStatus status
    test('to test the property `status`', () async {
      // TODO
    });

    // Darkness Points counter; mutated by Feature 7.3
    // int dpCount
    test('to test the property `dpCount`', () async {
      // TODO
    });

    // Optional ship linked to the session (Epic 8)
    // String shipId
    test('to test the property `shipId`', () async {
      // TODO
    });

    // Active members of this session. Always includes the GM row. Single source of truth for \"who is at this table\" since Phase 8 Stream E removed the legacy `characterIds` array. Each row optionally carries `characterId` — that's how a player (or GM) links a PC to their seat. 
    // BuiltList<GameSessionMembership> memberships
    test('to test the property `memberships`', () async {
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

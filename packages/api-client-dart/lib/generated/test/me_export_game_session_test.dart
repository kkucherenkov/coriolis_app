import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for MeExportGameSession
void main() {
  final instance = MeExportGameSessionBuilder();
  // TODO add properties to the builder and call build()

  group(MeExportGameSession, () {
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

    // Character ids assigned to this session. Manage via the join endpoint (POST / DELETE on /game-sessions/{id}/characters). 
    // BuiltList<String> characterIds
    test('to test the property `characterIds`', () async {
      // TODO
    });

    // Optional ship linked to the session (Epic 8)
    // String shipId
    test('to test the property `shipId`', () async {
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

    // BuiltList<Npc> npcs
    test('to test the property `npcs`', () async {
      // TODO
    });

    // BuiltList<MeExportEncounter> encounters
    test('to test the property `encounters`', () async {
      // TODO
    });

  });
}

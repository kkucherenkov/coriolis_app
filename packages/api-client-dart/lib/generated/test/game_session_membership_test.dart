import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for GameSessionMembership
void main() {
  final instance = GameSessionMembershipBuilder();
  // TODO add properties to the builder and call build()

  group(GameSessionMembership, () {
    // Stable cuid; used as targetMembershipId in chat whispers.
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // String gameSessionId
    test('to test the property `gameSessionId`', () async {
      // TODO
    });

    // String userId
    test('to test the property `userId`', () async {
      // TODO
    });

    // GameSessionMemberRole role
    test('to test the property `role`', () async {
      // TODO
    });

    // Cached display name of the user (denormalised for UI).
    // String displayName
    test('to test the property `displayName`', () async {
      // TODO
    });

    // String characterId
    test('to test the property `characterId`', () async {
      // TODO
    });

    // String characterName
    test('to test the property `characterName`', () async {
      // TODO
    });

    // DateTime joinedAt
    test('to test the property `joinedAt`', () async {
      // TODO
    });

    // DateTime leftAt
    test('to test the property `leftAt`', () async {
      // TODO
    });

  });
}

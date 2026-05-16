import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for ChatMessage
void main() {
  final instance = ChatMessageBuilder();
  // TODO add properties to the builder and call build()

  group(ChatMessage, () {
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // String gameSessionId
    test('to test the property `gameSessionId`', () async {
      // TODO
    });

    // GameSessionMembership.id; null for system messages
    // String authorMembershipId
    test('to test the property `authorMembershipId`', () async {
      // TODO
    });

    // Denormalised at read time
    // String authorDisplayName
    test('to test the property `authorDisplayName`', () async {
      // TODO
    });

    // null = broadcast; non-null = whisper
    // String targetMembershipId
    test('to test the property `targetMembershipId`', () async {
      // TODO
    });

    // ChatMessageKind kind
    test('to test the property `kind`', () async {
      // TODO
    });

    // null for kind=system; non-empty trimmed text for kind=text
    // String body
    test('to test the property `body`', () async {
      // TODO
    });

    // i18n key for kind=system, e.g. chat.system.member_joined
    // String systemKey
    test('to test the property `systemKey`', () async {
      // TODO
    });

    // BuiltMap<String, JsonObject> systemParams
    test('to test the property `systemParams`', () async {
      // TODO
    });

    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

    // DateTime editedAt
    test('to test the property `editedAt`', () async {
      // TODO
    });

    // DateTime deletedAt
    test('to test the property `deletedAt`', () async {
      // TODO
    });

  });
}

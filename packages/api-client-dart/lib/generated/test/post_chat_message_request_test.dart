import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for PostChatMessageRequest
void main() {
  final instance = PostChatMessageRequestBuilder();
  // TODO add properties to the builder and call build()

  group(PostChatMessageRequest, () {
    // Client-submitted messages must be of kind=text; system messages are server-generated only.
    // String kind
    test('to test the property `kind`', () async {
      // TODO
    });

    // String body
    test('to test the property `body`', () async {
      // TODO
    });

    // null or omitted = broadcast; non-null = whisper to this membership
    // String targetMembershipId
    test('to test the property `targetMembershipId`', () async {
      // TODO
    });

  });
}

import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';


/// tests for ChatApi
void main() {
  final instance = AppApiClient().getChatApi();

  group(ChatApi, () {
    // Delete (soft) a chat message
    //
    // Stamps `deletedAt` on the message. Authors may always delete their own broadcast messages. GMs may delete any broadcast. Whispers may only be deleted by the author — GM has no visibility into whispers and receives 404 rather than 403 (privacy contract). 
    //
    //Future deleteChatMessage(String id) async
    test('test deleteChatMessage', () async {
      // TODO
    });

    // Edit a chat message body
    //
    // Replaces the message body. Only the original author may edit. Returns 422 when the edit window (5 min) has expired. Returns 403 when the caller is not the author. 
    //
    //Future<ChatMessage> editChatMessage(String id, EditChatMessageRequest editChatMessageRequest) async
    test('test editChatMessage', () async {
      // TODO
    });

    // Get a single chat message by ID
    //
    // Returns the message if the caller has visibility. Broadcast messages are visible to any active session member. Whisper messages are visible only to the author and the target — any other caller, including the GM, receives 404 (privacy contract: non-existence over forbidden). 
    //
    //Future<ChatMessage> getChatMessage(String id) async
    test('test getChatMessage', () async {
      // TODO
    });

  });
}

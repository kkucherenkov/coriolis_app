import 'package:app_api_client/app_api_client.dart'
    show ChatMessage, ChatConversationSummary;

/// Port (interface) for loading and mutating chat messages.
///
/// Implementations live in `data/chat_repository_impl.dart`.
abstract interface class ChatRepository {
  /// Hydrate initial data: conversations + first page of messages for
  /// [conversationKey].
  Future<List<ChatConversationSummary>> getConversations(String gameSessionId);

  /// Load messages for a conversation. Pass `broadcast` or a membershipId.
  Future<List<ChatMessage>> getMessages(
    String gameSessionId, {
    required String conversation,
  });

  /// Post a new message. Returns the created message.
  Future<ChatMessage> postMessage(
    String gameSessionId, {
    required String body,
    String? targetMembershipId,
  });

  /// Edit an existing message.
  Future<ChatMessage> editMessage(String messageId, {required String body});

  /// Soft-delete a message.
  Future<void> deleteMessage(String messageId);

  /// Block a member in this session.
  Future<void> blockMember(
    String gameSessionId, {
    required String targetMembershipId,
  });

  /// Unblock a member in this session.
  Future<void> unblockMember(
    String gameSessionId, {
    required String targetMembershipId,
  });

  /// List blocked members for this session (returns membershipIds).
  Future<Set<String>> listBlocks(String gameSessionId);

  /// Advance the read cursor for a conversation.
  Future<void> markRead(
    String gameSessionId, {
    required String conversation,
    required String lastReadMessageId,
  });
}

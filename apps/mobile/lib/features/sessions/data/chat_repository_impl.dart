import 'package:app_api_client/app_api_client.dart'
    show
        ChatApi,
        ChatBlockRequest,
        ChatBlockSummary,
        ChatConversationSummary,
        ChatMessage,
        EditChatMessageRequest,
        GameSessionsApi,
        MarkReadRequest,
        PostChatMessageRequest,
        PostChatMessageRequestKindEnum;

import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_repository.dart';

/// [ChatRepository] implementation backed by the generated Dart API client.
class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl({
    required ChatApi chatApi,
    required GameSessionsApi gameSessionsApi,
  })  : _chatApi = chatApi,
        _gameSessionsApi = gameSessionsApi;

  final ChatApi _chatApi;
  final GameSessionsApi _gameSessionsApi;

  @override
  Future<List<ChatConversationSummary>> getConversations(
    String gameSessionId,
  ) async {
    final res = await _gameSessionsApi.listChatConversations(id: gameSessionId);
    return res.data?.items.toList() ?? const [];
  }

  @override
  Future<List<ChatMessage>> getMessages(
    String gameSessionId, {
    required String conversation,
  }) async {
    final res = await _gameSessionsApi.listChatMessages(
      id: gameSessionId,
      conversation: conversation,
      limit: 50,
    );
    return res.data?.items.toList() ?? const [];
  }

  @override
  Future<ChatMessage> postMessage(
    String gameSessionId, {
    required String body,
    String? targetMembershipId,
  }) async {
    final req = PostChatMessageRequest((b) => b
      ..kind = PostChatMessageRequestKindEnum.text
      ..body = body
      ..targetMembershipId = targetMembershipId);
    final res = await _gameSessionsApi.postChatMessage(
      id: gameSessionId,
      postChatMessageRequest: req,
    );
    if (res.data == null) throw StateError('postChatMessage returned null data');
    return res.data!;
  }

  @override
  Future<ChatMessage> editMessage(
    String messageId, {
    required String body,
  }) async {
    final req = EditChatMessageRequest((b) => b..body = body);
    final res = await _chatApi.editChatMessage(
      id: messageId,
      editChatMessageRequest: req,
    );
    if (res.data == null) throw StateError('editChatMessage returned null data');
    return res.data!;
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _chatApi.deleteChatMessage(id: messageId);
  }

  @override
  Future<void> blockMember(
    String gameSessionId, {
    required String targetMembershipId,
  }) async {
    final req =
        ChatBlockRequest((b) => b..targetMembershipId = targetMembershipId);
    await _gameSessionsApi.blockMember(
      id: gameSessionId,
      chatBlockRequest: req,
    );
  }

  @override
  Future<void> unblockMember(
    String gameSessionId, {
    required String targetMembershipId,
  }) async {
    await _gameSessionsApi.unblockMember(
      id: gameSessionId,
      targetMembershipId: targetMembershipId,
    );
  }

  @override
  Future<Set<String>> listBlocks(String gameSessionId) async {
    final res = await _gameSessionsApi.listBlocks(id: gameSessionId);
    final items = res.data?.items.toList() ?? <ChatBlockSummary>[];
    return items.map((b) => b.targetMembershipId).toSet();
  }

  @override
  Future<void> markRead(
    String gameSessionId, {
    required String conversation,
    required String lastReadMessageId,
    required DateTime lastReadAt,
  }) async {
    final req = MarkReadRequest((b) => b..lastReadAt = lastReadAt.toUtc());
    await _gameSessionsApi.markChatConversationRead(
      id: gameSessionId,
      conversationKey: conversation,
      markReadRequest: req,
    );
  }
}

import 'package:app_api_client/app_api_client.dart'
    show ChatMessage, ChatConversationSummary;
import 'package:equatable/equatable.dart';

/// Connection state mirroring the web store's `connectionStatus`.
enum ChatConnectionStatus { disconnected, connecting, subscribed, unrecoverable }

/// One slot in the per-conversation message store.
class ChatConversationData extends Equatable {
  const ChatConversationData({
    required this.summary,
    required this.messages,
    this.nextCursor,
    this.unreadCount = 0,
  });

  final ChatConversationSummary summary;
  final List<ChatMessage> messages;
  final String? nextCursor;
  final int unreadCount;

  ChatConversationData copyWith({
    ChatConversationSummary? summary,
    List<ChatMessage>? messages,
    String? nextCursor,
    int? unreadCount,
  }) =>
      ChatConversationData(
        summary: summary ?? this.summary,
        messages: messages ?? this.messages,
        nextCursor: nextCursor ?? this.nextCursor,
        unreadCount: unreadCount ?? this.unreadCount,
      );

  @override
  List<Object?> get props => [summary.conversationKey, messages, unreadCount];
}

// ── States ────────────────────────────────────────────────────────────────────

sealed class ChatState extends Equatable {
  const ChatState();
}

final class ChatInitial extends ChatState {
  const ChatInitial();

  @override
  List<Object?> get props => [];
}

final class ChatLoading extends ChatState {
  const ChatLoading();

  @override
  List<Object?> get props => [];
}

final class ChatError extends ChatState {
  const ChatError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class ChatReady extends ChatState {
  const ChatReady({
    required this.gameSessionId,
    required this.myMembershipId,
    required this.activeKey,
    required this.conversations,
    required this.blockedByMe,
    required this.openWhisperKeys,
    required this.connectionStatus,
    required this.composerValue,
    this.atBottom = true,
  });

  final String gameSessionId;
  final String myMembershipId;

  /// The currently active conversation key: 'broadcast' or a membershipId.
  final String activeKey;

  /// Map from conversationKey → data.
  final Map<String, ChatConversationData> conversations;

  /// MembershipIds blocked by the current user in this session.
  final Set<String> blockedByMe;

  /// Whisper conversation keys that have been explicitly opened as tabs.
  final Set<String> openWhisperKeys;

  final ChatConnectionStatus connectionStatus;
  final String composerValue;

  /// True when scroll is at (or within 80px of) the bottom.
  final bool atBottom;

  // ── Derived helpers ────────────────────────────────────────────────────────

  List<ChatConversationData> get conversationsList {
    final list = conversations.values.toList();
    // broadcast first; whispers by lastMessageAt desc.
    list.sort((a, b) {
      if (a.summary.conversationKey == 'broadcast') return -1;
      if (b.summary.conversationKey == 'broadcast') return 1;
      final aT = a.summary.lastMessageAt;
      final bT = b.summary.lastMessageAt;
      if (aT == null && bT == null) return 0;
      if (aT == null) return 1;
      if (bT == null) return -1;
      return bT.compareTo(aT);
    });
    return list;
  }

  int get totalUnreadCount =>
      conversations.values.fold(0, (s, c) => s + c.unreadCount);

  ChatConversationData? get activeConversation => conversations[activeKey];

  ChatReady copyWith({
    String? gameSessionId,
    String? myMembershipId,
    String? activeKey,
    Map<String, ChatConversationData>? conversations,
    Set<String>? blockedByMe,
    Set<String>? openWhisperKeys,
    ChatConnectionStatus? connectionStatus,
    String? composerValue,
    bool? atBottom,
  }) =>
      ChatReady(
        gameSessionId: gameSessionId ?? this.gameSessionId,
        myMembershipId: myMembershipId ?? this.myMembershipId,
        activeKey: activeKey ?? this.activeKey,
        conversations: conversations ?? this.conversations,
        blockedByMe: blockedByMe ?? this.blockedByMe,
        openWhisperKeys: openWhisperKeys ?? this.openWhisperKeys,
        connectionStatus: connectionStatus ?? this.connectionStatus,
        composerValue: composerValue ?? this.composerValue,
        atBottom: atBottom ?? this.atBottom,
      );

  @override
  List<Object?> get props => [
        gameSessionId,
        myMembershipId,
        activeKey,
        conversations,
        blockedByMe,
        openWhisperKeys,
        connectionStatus,
        composerValue,
        atBottom,
      ];
}

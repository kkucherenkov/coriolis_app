import 'dart:async';

import 'package:app_api_client/app_api_client.dart'
    show ChatConversationSummary, ChatConversationSummaryKindEnum;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/sessions/domain/chat_presence_service.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_event.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_realtime_service.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required ChatRepository repository,
    required ChatRealtimeService realtimeService,
    required ChatPresenceService presenceService,
  })  : _repository = repository,
        _realtimeService = realtimeService,
        _presenceService = presenceService,
        super(const ChatInitial()) {
    on<ChatHydrateRequested>(_onHydrate);
    on<ChatRealtimeEventReceived>(_onRealtimeEvent);
    on<ChatPresenceUpdated>(_onPresenceUpdated);
    on<ChatMessageSendRequested>(_onSend);
    on<ChatEditStarted>(_onEditStarted);
    on<ChatEditCancelled>(_onEditCancelled);
    on<ChatMessageEditRequested>(_onEdit);
    on<ChatMessageDeleteRequested>(_onDelete);
    on<ChatConversationSelected>(_onConversationSelected);
    on<ChatWhisperOpened>(_onWhisperOpened);
    on<ChatWhisperClosed>(_onWhisperClosed);
    on<ChatMemberBlockRequested>(_onBlock);
    on<ChatMemberUnblockRequested>(_onUnblock);
    on<ChatMarkRead>(_onMarkRead);
    on<ChatScrolledToBottom>(_onScrolledToBottom);
    on<ChatScrolledAway>(_onScrolledAway);
    on<ChatComposerChanged>(_onComposerChanged);
  }

  final ChatRepository _repository;
  final ChatRealtimeService _realtimeService;
  final ChatPresenceService _presenceService;
  StreamSubscription<ChatRealtimeEvent>? _realtimeSub;
  StreamSubscription<Set<String>>? _presenceSub;

  // ── Hydrate ──────────────────────────────────────────────────────────────

  Future<void> _onHydrate(
    ChatHydrateRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    try {
      // 1. Load conversations
      final convs = await _repository.getConversations(event.gameSessionId);

      // 2. Ensure broadcast is present (server always returns it, but be safe)
      final hasBroadcast =
          convs.any((c) => c.conversationKey == 'broadcast');
      final allConvs = hasBroadcast
          ? convs
          : [
              _syntheticBroadcast(event.gameSessionId),
              ...convs,
            ];

      // 3. Load messages for broadcast by default
      final broadcastMessages = await _repository.getMessages(
        event.gameSessionId,
        conversation: 'broadcast',
      );

      // 4. Blocks
      final blocked = await _repository.listBlocks(event.gameSessionId);

      // 5. Build conversations map
      final convMap = <String, ChatConversationData>{};
      for (final c in allConvs) {
        convMap[c.conversationKey] = ChatConversationData(
          summary: c,
          messages: c.conversationKey == 'broadcast' ? broadcastMessages : [],
          unreadCount: c.unreadCount,
        );
      }

      final openWhisperKeys = convMap.keys
          .where((k) => k != 'broadcast')
          .toSet();

      // 6. Start realtime (chat publications)
      await _realtimeService.start(
        gameSessionId: event.gameSessionId,
        myMembershipId: event.myMembershipId,
      );
      _realtimeSub = _realtimeService.events.listen(
        (e) => add(ChatRealtimeEventReceived(e)),
      );

      // 7. Start presence subscription (join/leave events on session channel)
      await _presenceService.start(
        gameSessionId: event.gameSessionId,
        myMembershipId: event.myMembershipId,
      );
      _presenceSub = _presenceService.onlineIds.listen(
        (ids) => add(ChatPresenceUpdated(ids)),
      );

      emit(ChatReady(
        gameSessionId: event.gameSessionId,
        myMembershipId: event.myMembershipId,
        activeKey: 'broadcast',
        conversations: convMap,
        blockedByMe: blocked,
        openWhisperKeys: openWhisperKeys,
        connectionStatus: ChatConnectionStatus.subscribed,
        composerValue: '',
      ));
    } on Object catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  // ── Realtime ─────────────────────────────────────────────────────────────

  void _onRealtimeEvent(
    ChatRealtimeEventReceived event,
    Emitter<ChatState> emit,
  ) {
    final s = state;
    if (s is! ChatReady) return;

    switch (event.event) {
      case ChatRealtimePosted(message: final m):
        final key = m.targetMembershipId ?? 'broadcast';
        final existing = s.conversations[key];
        if (existing == null) return;
        final updated = existing.copyWith(
          messages: [...existing.messages, m],
          unreadCount: s.activeKey == key ? 0 : existing.unreadCount + 1,
        );
        emit(s.copyWith(
          conversations: {...s.conversations, key: updated},
        ));

      case ChatRealtimeEdited(message: final m):
        final key = m.targetMembershipId ?? 'broadcast';
        final existing = s.conversations[key];
        if (existing == null) return;
        final msgs = existing.messages.map((msg) {
          return msg.id == m.id ? m : msg;
        }).toList();
        emit(s.copyWith(
          conversations: {
            ...s.conversations,
            key: existing.copyWith(messages: msgs),
          },
        ));

      case ChatRealtimeDeleted(
          messageId: final id,
          deletedAt: final at,
        ):
        // Update whichever conversation contains the message.
        final convs = Map<String, ChatConversationData>.from(s.conversations);
        for (final entry in convs.entries) {
          final msgs = entry.value.messages.map((msg) {
            if (msg.id == id) {
              return msg.rebuild((b) => b.deletedAt = at);
            }
            return msg;
          }).toList();
          convs[entry.key] = entry.value.copyWith(messages: msgs);
        }
        emit(s.copyWith(conversations: convs));
    }
  }

  // ── Presence ─────────────────────────────────────────────────────────────

  void _onPresenceUpdated(
    ChatPresenceUpdated event,
    Emitter<ChatState> emit,
  ) {
    final s = state;
    if (s is! ChatReady) return;
    emit(s.copyWith(onlineMembershipIds: event.ids));
  }

  // ── Send ─────────────────────────────────────────────────────────────────

  Future<void> _onSend(
    ChatMessageSendRequested event,
    Emitter<ChatState> emit,
  ) async {
    final s = state;
    if (s is! ChatReady) return;
    if (event.body.trim().isEmpty) return;

    try {
      final msg = await _repository.postMessage(
        s.gameSessionId,
        body: event.body.trim(),
        targetMembershipId: event.targetMembershipId,
      );

      final key = msg.targetMembershipId ?? 'broadcast';
      final existing = s.conversations[key] ??
          ChatConversationData(
            summary: _syntheticBroadcast(s.gameSessionId),
            messages: [],
          );
      final updated = existing.copyWith(
        messages: [...existing.messages, msg],
      );
      emit(s.copyWith(
        conversations: {...s.conversations, key: updated},
        composerValue: '',
      ));
    } on Object {
      // Keep state intact — let UI show a snackbar if needed.
    }
  }

  // ── Edit banner lifecycle ────────────────────────────────────────────────

  void _onEditStarted(
    ChatEditStarted event,
    Emitter<ChatState> emit,
  ) {
    final s = state;
    if (s is! ChatReady) return;
    emit(s.copyWith(
      editingMessageId: event.messageId,
      editingPreview: event.body,
      composerValue: event.body,
    ));
  }

  void _onEditCancelled(
    ChatEditCancelled event,
    Emitter<ChatState> emit,
  ) {
    final s = state;
    if (s is! ChatReady) return;
    emit(s.copyWith(clearEditing: true, composerValue: ''));
  }

  // ── Edit submit ──────────────────────────────────────────────────────────

  Future<void> _onEdit(
    ChatMessageEditRequested event,
    Emitter<ChatState> emit,
  ) async {
    final s = state;
    if (s is! ChatReady) return;

    // Close the banner optimistically — mirrors the web flow where the
    // composer clears + editingMessageId resets before the await
    // (`apps/web/app/pages/app/game-sessions/[id].vue:266-276`). The realtime
    // echo or the awaited response patches the message body in place.
    emit(s.copyWith(clearEditing: true, composerValue: ''));

    try {
      final msg =
          await _repository.editMessage(event.messageId, body: event.body);
      final after = state;
      if (after is! ChatReady) return;
      final key = msg.targetMembershipId ?? 'broadcast';
      final existing = after.conversations[key];
      if (existing == null) return;
      final msgs = existing.messages.map((m) {
        return m.id == msg.id ? msg : m;
      }).toList();
      emit(after.copyWith(
        conversations: {
          ...after.conversations,
          key: existing.copyWith(messages: msgs),
        },
      ));
    } on Object {
      // Swallow — server returns 422 on edit-window expiry; surface via snackbar.
    }
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  Future<void> _onDelete(
    ChatMessageDeleteRequested event,
    Emitter<ChatState> emit,
  ) async {
    final s = state;
    if (s is! ChatReady) return;

    try {
      await _repository.deleteMessage(event.messageId);
      final convs = Map<String, ChatConversationData>.from(s.conversations);
      for (final entry in convs.entries) {
        final msgs = entry.value.messages.map((m) {
          if (m.id == event.messageId) {
            return m.rebuild((b) => b.deletedAt = DateTime.now().toUtc());
          }
          return m;
        }).toList();
        convs[entry.key] = entry.value.copyWith(messages: msgs);
      }
      emit(s.copyWith(conversations: convs));
    } on Object {
      // Swallow.
    }
  }

  // ── Conversation selection ───────────────────────────────────────────────

  Future<void> _onConversationSelected(
    ChatConversationSelected event,
    Emitter<ChatState> emit,
  ) async {
    final s = state;
    if (s is! ChatReady) return;

    // Cancel any in-flight edit before switching — the banner would
    // otherwise lie about which thread it belongs to. Mirrors
    // `apps/web/app/pages/app/game-sessions/[id].vue:310-317`.
    final clearEditing = s.editingMessageId != null;
    final resetComposer = clearEditing;

    // Lazy-load messages if this conversation has none yet.
    if (s.conversations[event.conversationKey]?.messages.isEmpty ?? true) {
      try {
        final msgs = await _repository.getMessages(
          s.gameSessionId,
          conversation: event.conversationKey,
        );
        final existing = s.conversations[event.conversationKey];
        if (existing != null) {
          emit(s.copyWith(
            activeKey: event.conversationKey,
            conversations: {
              ...s.conversations,
              event.conversationKey: existing.copyWith(messages: msgs),
            },
            clearEditing: clearEditing,
            composerValue: resetComposer ? '' : null,
          ));
          return;
        }
      } on Object {
        // Ignore; fall through to just switching key.
      }
    }

    emit(s.copyWith(
      activeKey: event.conversationKey,
      clearEditing: clearEditing,
      composerValue: resetComposer ? '' : null,
    ));
  }

  // ── Whisper open / close ─────────────────────────────────────────────────

  Future<void> _onWhisperOpened(
    ChatWhisperOpened event,
    Emitter<ChatState> emit,
  ) async {
    final s = state;
    if (s is! ChatReady) return;

    final key = event.partnerMembershipId;
    final newKeys = {...s.openWhisperKeys, key};

    // Ensure a conversation slot exists.
    if (!s.conversations.containsKey(key)) {
      emit(s.copyWith(
        activeKey: key,
        openWhisperKeys: newKeys,
        conversations: {
          ...s.conversations,
          key: ChatConversationData(
            summary: _syntheticWhisper(key, s.gameSessionId),
            messages: [],
          ),
        },
      ));
      return;
    }

    emit(s.copyWith(activeKey: key, openWhisperKeys: newKeys));
  }

  void _onWhisperClosed(
    ChatWhisperClosed event,
    Emitter<ChatState> emit,
  ) {
    final s = state;
    if (s is! ChatReady) return;

    final newKeys = Set<String>.from(s.openWhisperKeys)
      ..remove(event.conversationKey);
    final newActive =
        s.activeKey == event.conversationKey ? 'broadcast' : s.activeKey;
    emit(s.copyWith(activeKey: newActive, openWhisperKeys: newKeys));
  }

  // ── Block / Unblock ──────────────────────────────────────────────────────

  Future<void> _onBlock(
    ChatMemberBlockRequested event,
    Emitter<ChatState> emit,
  ) async {
    final s = state;
    if (s is! ChatReady) return;

    try {
      await _repository.blockMember(
        s.gameSessionId,
        targetMembershipId: event.targetMembershipId,
      );
      final newBlocked = {...s.blockedByMe, event.targetMembershipId};
      // Close whisper tab with this member if open.
      final newKeys = Set<String>.from(s.openWhisperKeys)
        ..remove(event.targetMembershipId);
      final newActive = s.activeKey == event.targetMembershipId
          ? 'broadcast'
          : s.activeKey;
      emit(s.copyWith(
        blockedByMe: newBlocked,
        openWhisperKeys: newKeys,
        activeKey: newActive,
      ));
    } on Object {
      // Swallow.
    }
  }

  Future<void> _onUnblock(
    ChatMemberUnblockRequested event,
    Emitter<ChatState> emit,
  ) async {
    final s = state;
    if (s is! ChatReady) return;

    try {
      await _repository.unblockMember(
        s.gameSessionId,
        targetMembershipId: event.targetMembershipId,
      );
      final newBlocked = Set<String>.from(s.blockedByMe)
        ..remove(event.targetMembershipId);
      emit(s.copyWith(blockedByMe: newBlocked));
    } on Object {
      // Swallow.
    }
  }

  // ── Read cursor ──────────────────────────────────────────────────────────

  Future<void> _onMarkRead(
    ChatMarkRead event,
    Emitter<ChatState> emit,
  ) async {
    final s = state;
    if (s is! ChatReady) return;

    try {
      await _repository.markRead(
        s.gameSessionId,
        conversation: s.activeKey,
        lastReadMessageId: event.lastReadMessageId,
      );
      final existing = s.conversations[s.activeKey];
      if (existing != null) {
        emit(s.copyWith(
          conversations: {
            ...s.conversations,
            s.activeKey: existing.copyWith(unreadCount: 0),
          },
        ));
      }
    } on Object {
      // Swallow.
    }
  }

  // ── Scroll state ─────────────────────────────────────────────────────────

  void _onScrolledToBottom(
    ChatScrolledToBottom event,
    Emitter<ChatState> emit,
  ) {
    final s = state;
    if (s is ChatReady) emit(s.copyWith(atBottom: true));
  }

  void _onScrolledAway(
    ChatScrolledAway event,
    Emitter<ChatState> emit,
  ) {
    final s = state;
    if (s is ChatReady) emit(s.copyWith(atBottom: false));
  }

  // ── Composer ─────────────────────────────────────────────────────────────

  void _onComposerChanged(
    ChatComposerChanged event,
    Emitter<ChatState> emit,
  ) {
    final s = state;
    if (s is ChatReady) emit(s.copyWith(composerValue: event.value));
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static ChatConversationSummary _syntheticBroadcast(String _) =>
      ChatConversationSummary((b) => b
        ..conversationKey = 'broadcast'
        ..kind = ChatConversationSummaryKindEnum.broadcast
        ..unreadCount = 0);

  static ChatConversationSummary _syntheticWhisper(
          String partnerMembershipId, String _) =>
      ChatConversationSummary((b) => b
        ..conversationKey = partnerMembershipId
        ..kind = ChatConversationSummaryKindEnum.whisper
        ..partnerMembershipId = partnerMembershipId
        ..unreadCount = 0);

  @override
  Future<void> close() async {
    await _realtimeSub?.cancel();
    await _presenceSub?.cancel();
    await _realtimeService.dispose();
    await _presenceService.dispose();
    return super.close();
  }
}

import 'dart:async';

import 'package:app_api_client/app_api_client.dart'
    show
        ChatConversationSummary,
        ChatConversationSummaryKindEnum,
        ChatMessage,
        ChatMessageKind;
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_bloc.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_event.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_realtime_service.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_state.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

class _MockChatRealtimeService extends Mock implements ChatRealtimeService {}

ChatConversationSummary _broadcastSummary() => ChatConversationSummary((b) => b
  ..conversationKey = 'broadcast'
  ..kind = ChatConversationSummaryKindEnum.broadcast
  ..unreadCount = 0);

ChatConversationSummary _whisperSummary(String id) =>
    ChatConversationSummary((b) => b
      ..conversationKey = id
      ..kind = ChatConversationSummaryKindEnum.whisper
      ..partnerMembershipId = id
      ..partnerDisplayName = 'User $id'
      ..unreadCount = 0);

ChatMessage _msg({
  String id = 'm1',
  String gameSessionId = 'gs-1',
  String? authorMembershipId = 'me',
  String? targetMembershipId,
  String body = 'Hello',
  DateTime? editedAt,
}) =>
    ChatMessage((b) => b
      ..id = id
      ..gameSessionId = gameSessionId
      ..authorMembershipId = authorMembershipId
      ..kind = ChatMessageKind.text
      ..body = body
      ..createdAt = DateTime.utc(2026, 5, 18)
      ..editedAt = editedAt
      ..targetMembershipId = targetMembershipId);

ChatReady _seedReady({
  String? editingMessageId,
  String editingPreview = '',
  String composerValue = '',
  String activeKey = 'broadcast',
  Map<String, ChatConversationData>? conversations,
  Set<String>? openWhisperKeys,
}) =>
    ChatReady(
      gameSessionId: 'gs-1',
      myMembershipId: 'me',
      activeKey: activeKey,
      conversations: conversations ??
          {
            'broadcast': ChatConversationData(
              summary: _broadcastSummary(),
              messages: [_msg(id: 'm1', body: 'Original')],
            ),
          },
      blockedByMe: const {},
      openWhisperKeys: openWhisperKeys ?? const {},
      connectionStatus: ChatConnectionStatus.subscribed,
      composerValue: composerValue,
      editingMessageId: editingMessageId,
      editingPreview: editingPreview,
    );

void main() {
  late _MockChatRepository repo;
  late _MockChatRealtimeService realtime;
  late StreamController<ChatRealtimeEvent> eventsCtrl;

  setUp(() {
    repo = _MockChatRepository();
    realtime = _MockChatRealtimeService();
    eventsCtrl = StreamController<ChatRealtimeEvent>.broadcast();

    when(() => realtime.events).thenAnswer((_) => eventsCtrl.stream);
    when(() => realtime.dispose()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await eventsCtrl.close();
  });

  ChatBloc buildBloc() => ChatBloc(
        repository: repo,
        realtimeService: realtime,
      );

  group('ChatBloc edit-banner flow', () {
    blocTest<ChatBloc, ChatState>(
      'ChatEditStarted populates editingMessageId + preview + composer',
      build: buildBloc,
      seed: _seedReady,
      act: (bloc) => bloc.add(const ChatEditStarted(
        messageId: 'm1',
        body: 'Original',
      )),
      expect: () => [
        isA<ChatReady>()
            .having((s) => s.editingMessageId, 'editingMessageId', 'm1')
            .having((s) => s.editingPreview, 'editingPreview', 'Original')
            .having((s) => s.composerValue, 'composerValue', 'Original'),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'ChatEditCancelled clears editing state and composer',
      build: buildBloc,
      seed: () => _seedReady(
        editingMessageId: 'm1',
        editingPreview: 'Original',
        composerValue: 'Original edited',
      ),
      act: (bloc) => bloc.add(const ChatEditCancelled()),
      expect: () => [
        isA<ChatReady>()
            .having((s) => s.editingMessageId, 'editingMessageId', isNull)
            .having((s) => s.editingPreview, 'editingPreview', '')
            .having((s) => s.composerValue, 'composerValue', ''),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'ChatMessageEditRequested clears banner optimistically then patches body',
      build: () {
        when(() => repo.editMessage('m1', body: 'Updated')).thenAnswer(
          (_) async => _msg(
            id: 'm1',
            body: 'Updated',
            editedAt: DateTime.utc(2026, 5, 18, 1),
          ),
        );
        return buildBloc();
      },
      seed: () => _seedReady(
        editingMessageId: 'm1',
        editingPreview: 'Original',
        composerValue: 'Updated',
      ),
      act: (bloc) => bloc.add(const ChatMessageEditRequested(
        messageId: 'm1',
        body: 'Updated',
      )),
      expect: () => [
        // 1. Optimistic banner close (composer cleared, editing state cleared).
        isA<ChatReady>()
            .having((s) => s.editingMessageId, 'editingMessageId', isNull)
            .having((s) => s.composerValue, 'composerValue', ''),
        // 2. After await: message body patched in place.
        isA<ChatReady>().having(
          (s) =>
              s.conversations['broadcast']?.messages.firstWhere((m) => m.id == 'm1').body,
          'patched body',
          'Updated',
        ),
      ],
      verify: (_) {
        verify(() => repo.editMessage('m1', body: 'Updated')).called(1);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'ChatMessageEditRequested swallows 422 from server but keeps banner closed',
      build: () {
        when(() => repo.editMessage('m1', body: 'Late edit'))
            .thenThrow(StateError('422 edit window expired'));
        return buildBloc();
      },
      seed: () => _seedReady(
        editingMessageId: 'm1',
        editingPreview: 'Original',
        composerValue: 'Late edit',
      ),
      act: (bloc) => bloc.add(const ChatMessageEditRequested(
        messageId: 'm1',
        body: 'Late edit',
      )),
      expect: () => [
        // Only the optimistic close emits; no post-await state since the
        // throw is swallowed in _onEdit.
        isA<ChatReady>()
            .having((s) => s.editingMessageId, 'editingMessageId', isNull)
            .having((s) => s.composerValue, 'composerValue', ''),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'ChatConversationSelected auto-cancels an in-flight edit',
      build: () {
        // The selector also lazy-loads messages for the target conversation;
        // stub it so the existing path stays satisfied.
        when(() => repo.getMessages('gs-1', conversation: 'w1'))
            .thenAnswer((_) async => [_msg(id: 'w-m1', body: 'Whisper hi')]);
        return buildBloc();
      },
      seed: () => _seedReady(
        editingMessageId: 'm1',
        editingPreview: 'Original',
        composerValue: 'Original edited',
        conversations: {
          'broadcast': ChatConversationData(
            summary: _broadcastSummary(),
            messages: [_msg(id: 'm1', body: 'Original')],
          ),
          'w1': ChatConversationData(
            summary: _whisperSummary('w1'),
            messages: const [],
          ),
        },
        openWhisperKeys: const {'w1'},
      ),
      act: (bloc) => bloc.add(const ChatConversationSelected('w1')),
      expect: () => [
        isA<ChatReady>()
            .having((s) => s.activeKey, 'activeKey', 'w1')
            .having((s) => s.editingMessageId, 'editingMessageId', isNull)
            .having((s) => s.editingPreview, 'editingPreview', '')
            .having((s) => s.composerValue, 'composerValue', ''),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'ChatConversationSelected leaves composer alone when not editing',
      build: () {
        when(() => repo.getMessages('gs-1', conversation: 'w1'))
            .thenAnswer((_) async => [_msg(id: 'w-m1', body: 'Whisper hi')]);
        return buildBloc();
      },
      seed: () => _seedReady(
        composerValue: 'half-typed draft',
        conversations: {
          'broadcast': ChatConversationData(
            summary: _broadcastSummary(),
            messages: const [],
          ),
          'w1': ChatConversationData(
            summary: _whisperSummary('w1'),
            messages: const [],
          ),
        },
        openWhisperKeys: const {'w1'},
      ),
      act: (bloc) => bloc.add(const ChatConversationSelected('w1')),
      expect: () => [
        isA<ChatReady>()
            .having((s) => s.activeKey, 'activeKey', 'w1')
            .having((s) => s.composerValue, 'composerValue', 'half-typed draft'),
      ],
    );
  });
}

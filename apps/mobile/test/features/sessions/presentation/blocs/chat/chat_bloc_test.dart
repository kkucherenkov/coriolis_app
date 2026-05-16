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

// ── Mocks ─────────────────────────────────────────────────────────────────────

class _MockChatRepository extends Mock implements ChatRepository {}

class _MockChatRealtimeService extends Mock implements ChatRealtimeService {}

// ── Helpers ───────────────────────────────────────────────────────────────────

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
}) =>
    ChatMessage((b) => b
      ..id = id
      ..gameSessionId = gameSessionId
      ..authorMembershipId = authorMembershipId
      ..kind = ChatMessageKind.text
      ..body = body
      ..createdAt = DateTime.utc(2026, 5, 16)
      ..targetMembershipId = targetMembershipId);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _MockChatRepository repo;
  late _MockChatRealtimeService realtime;
  late StreamController<ChatRealtimeEvent> eventsCtrl;

  setUp(() {
    repo = _MockChatRepository();
    realtime = _MockChatRealtimeService();
    eventsCtrl = StreamController<ChatRealtimeEvent>.broadcast();

    when(() => realtime.events).thenAnswer((_) => eventsCtrl.stream);
    when(() => realtime.start(
          gameSessionId: any(named: 'gameSessionId'),
          myMembershipId: any(named: 'myMembershipId'),
        )).thenAnswer((_) async {});
    when(() => realtime.dispose()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await eventsCtrl.close();
  });

  ChatBloc buildBloc() => ChatBloc(
        repository: repo,
        realtimeService: realtime,
      );

  group('ChatBloc', () {
    // Test 1: Hydrate happy path
    blocTest<ChatBloc, ChatState>(
      'hydrate happy path emits Loading then Ready with broadcast messages',
      build: () {
        when(() => repo.getConversations('gs-1'))
            .thenAnswer((_) async => [_broadcastSummary()]);
        when(() => repo.getMessages('gs-1', conversation: 'broadcast'))
            .thenAnswer((_) async => [_msg()]);
        when(() => repo.listBlocks('gs-1'))
            .thenAnswer((_) async => <String>{});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ChatHydrateRequested(
        gameSessionId: 'gs-1',
        myMembershipId: 'me',
      )),
      expect: () => [
        isA<ChatLoading>(),
        isA<ChatReady>()
            .having((s) => s.gameSessionId, 'gameSessionId', 'gs-1')
            .having(
              (s) => s.conversations['broadcast']?.messages.length,
              'broadcast message count',
              1,
            ),
      ],
    );

    // Test 2: Send message → optimistic insertion
    blocTest<ChatBloc, ChatState>(
      'send message adds to conversation and clears composer',
      build: () {
        when(() => repo.postMessage(
              'gs-1',
              body: 'Hi',
              targetMembershipId: null,
            )).thenAnswer((_) async => _msg(id: 'm2', body: 'Hi'));
        return buildBloc();
      },
      seed: () => ChatReady(
        gameSessionId: 'gs-1',
        myMembershipId: 'me',
        activeKey: 'broadcast',
        conversations: {
          'broadcast': ChatConversationData(
            summary: _broadcastSummary(),
            messages: const [],
          ),
        },
        blockedByMe: const {},
        openWhisperKeys: const {},
        connectionStatus: ChatConnectionStatus.subscribed,
        composerValue: 'Hi',
      ),
      act: (bloc) => bloc.add(const ChatMessageSendRequested(body: 'Hi')),
      expect: () => [
        isA<ChatReady>()
            .having(
              (s) => s.conversations['broadcast']?.messages.length,
              'message count',
              1,
            )
            .having((s) => s.composerValue, 'composerValue', ''),
      ],
    );

    // Test 3: Realtime posted → state has new message
    blocTest<ChatBloc, ChatState>(
      'realtime posted event adds message to conversation',
      build: () => buildBloc(),
      seed: () => ChatReady(
        gameSessionId: 'gs-1',
        myMembershipId: 'me',
        activeKey: 'broadcast',
        conversations: {
          'broadcast': ChatConversationData(
            summary: _broadcastSummary(),
            messages: const [],
          ),
        },
        blockedByMe: const {},
        openWhisperKeys: const {},
        connectionStatus: ChatConnectionStatus.subscribed,
        composerValue: '',
      ),
      act: (bloc) => bloc.add(
        ChatRealtimeEventReceived(
          ChatRealtimePosted(_msg(id: 'rt1', body: 'Realtime!')),
        ),
      ),
      expect: () => [
        isA<ChatReady>().having(
          (s) => s.conversations['broadcast']?.messages.any((m) => m.id == 'rt1'),
          'has rt1',
          isTrue,
        ),
      ],
    );

    // Test 4: Block → blockedByMe updates + whisper tab closed
    blocTest<ChatBloc, ChatState>(
      'block member updates blockedByMe and closes whisper tab',
      build: () {
        when(() => repo.blockMember(
              'gs-1',
              targetMembershipId: 'other',
            )).thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => ChatReady(
        gameSessionId: 'gs-1',
        myMembershipId: 'me',
        activeKey: 'other',
        conversations: {
          'broadcast': ChatConversationData(
            summary: _broadcastSummary(),
            messages: const [],
          ),
          'other': ChatConversationData(
            summary: _whisperSummary('other'),
            messages: const [],
          ),
        },
        blockedByMe: const {},
        openWhisperKeys: const {'other'},
        connectionStatus: ChatConnectionStatus.subscribed,
        composerValue: '',
      ),
      act: (bloc) =>
          bloc.add(const ChatMemberBlockRequested('other')),
      expect: () => [
        isA<ChatReady>()
            .having(
              (s) => s.blockedByMe.contains('other'),
              'blocked',
              isTrue,
            )
            .having(
              (s) => s.openWhisperKeys.contains('other'),
              'whisper tab closed',
              isFalse,
            )
            .having(
              (s) => s.activeKey,
              'activeKey falls back to broadcast',
              'broadcast',
            ),
      ],
    );

    // Test 5: openWhisper → activeKey changes
    blocTest<ChatBloc, ChatState>(
      'ChatWhisperOpened sets activeKey to the new whisper key',
      build: () => buildBloc(),
      seed: () => ChatReady(
        gameSessionId: 'gs-1',
        myMembershipId: 'me',
        activeKey: 'broadcast',
        conversations: {
          'broadcast': ChatConversationData(
            summary: _broadcastSummary(),
            messages: const [],
          ),
        },
        blockedByMe: const {},
        openWhisperKeys: const {},
        connectionStatus: ChatConnectionStatus.subscribed,
        composerValue: '',
      ),
      act: (bloc) => bloc.add(const ChatWhisperOpened('partner1')),
      expect: () => [
        isA<ChatReady>()
            .having((s) => s.activeKey, 'activeKey', 'partner1')
            .having(
              (s) => s.openWhisperKeys.contains('partner1'),
              'openWhisperKeys has partner1',
              isTrue,
            ),
      ],
    );

    // Test 6: closeWhisper → falls back to broadcast
    blocTest<ChatBloc, ChatState>(
      'ChatWhisperClosed removes tab and falls back to broadcast',
      build: () => buildBloc(),
      seed: () => ChatReady(
        gameSessionId: 'gs-1',
        myMembershipId: 'me',
        activeKey: 'w1',
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
        blockedByMe: const {},
        openWhisperKeys: const {'w1'},
        connectionStatus: ChatConnectionStatus.subscribed,
        composerValue: '',
      ),
      act: (bloc) => bloc.add(const ChatWhisperClosed('w1')),
      expect: () => [
        isA<ChatReady>()
            .having((s) => s.activeKey, 'activeKey', 'broadcast')
            .having(
              (s) => s.openWhisperKeys.contains('w1'),
              'w1 removed',
              isFalse,
            ),
      ],
    );
  });
}

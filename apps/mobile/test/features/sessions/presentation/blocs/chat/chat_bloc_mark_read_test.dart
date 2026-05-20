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

import 'package:coriolis_companion/features/sessions/domain/chat_presence_service.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_bloc.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_event.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_realtime_service.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_state.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class _MockChatRepository extends Mock implements ChatRepository {}

class _MockChatRealtimeService extends Mock implements ChatRealtimeService {}

class _MockChatPresenceService extends Mock implements ChatPresenceService {}

// ── Helpers ───────────────────────────────────────────────────────────────────

final _messageCreatedAt = DateTime.utc(2026, 5, 16, 10, 30, 0);

ChatConversationSummary _broadcastSummary() => ChatConversationSummary((b) => b
  ..conversationKey = 'broadcast'
  ..kind = ChatConversationSummaryKindEnum.broadcast
  ..unreadCount = 2);

ChatMessage _msg({
  String id = 'm-last',
  DateTime? createdAt,
}) =>
    ChatMessage((b) => b
      ..id = id
      ..gameSessionId = 'gs-1'
      ..authorMembershipId = 'author-1'
      ..kind = ChatMessageKind.text
      ..body = 'Hello'
      ..createdAt = createdAt ?? _messageCreatedAt);

ChatReady _readyState({List<ChatMessage>? messages}) => ChatReady(
      gameSessionId: 'gs-1',
      myMembershipId: 'me',
      activeKey: 'broadcast',
      conversations: {
        'broadcast': ChatConversationData(
          summary: _broadcastSummary(),
          messages: messages ?? [_msg()],
          unreadCount: 2,
        ),
      },
      blockedByMe: const {},
      openWhisperKeys: const {},
      connectionStatus: ChatConnectionStatus.subscribed,
      composerValue: '',
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _MockChatRepository repo;
  late _MockChatRealtimeService realtime;
  late _MockChatPresenceService presence;
  late StreamController<ChatRealtimeEvent> eventsCtrl;
  late StreamController<Set<String>> presenceCtrl;

  setUp(() {
    repo = _MockChatRepository();
    realtime = _MockChatRealtimeService();
    presence = _MockChatPresenceService();
    eventsCtrl = StreamController<ChatRealtimeEvent>.broadcast();
    presenceCtrl = StreamController<Set<String>>.broadcast();

    when(() => realtime.events).thenAnswer((_) => eventsCtrl.stream);
    when(() => realtime.start(
          gameSessionId: any(named: 'gameSessionId'),
          myMembershipId: any(named: 'myMembershipId'),
        )).thenAnswer((_) async {});
    when(() => realtime.dispose()).thenAnswer((_) async {});

    when(() => presence.onlineIds).thenAnswer((_) => presenceCtrl.stream);
    when(() => presence.start(
          gameSessionId: any(named: 'gameSessionId'),
          myMembershipId: any(named: 'myMembershipId'),
        )).thenAnswer((_) async {});
    when(() => presence.dispose()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await eventsCtrl.close();
    await presenceCtrl.close();
  });

  ChatBloc buildBloc() => ChatBloc(
        repository: repo,
        realtimeService: realtime,
        presenceService: presence,
      );

  group('ChatBloc — ChatMarkRead', () {
    test(
      'passes event.lastReadAt directly to repository.markRead — '
      'i.e. message.createdAt, not DateTime.now()',
      () async {
        final messageCreatedAt = DateTime.utc(2026, 5, 16, 10, 30, 0);
        final msg = _msg(id: 'm-42', createdAt: messageCreatedAt);

        when(
          () => repo.markRead(
            any(),
            conversation: any(named: 'conversation'),
            lastReadMessageId: any(named: 'lastReadMessageId'),
            lastReadAt: any(named: 'lastReadAt'),
          ),
        ).thenAnswer((_) async {});

        final bloc = buildBloc();
        bloc.emit(_readyState(messages: [msg]));

        bloc.add(ChatMarkRead(
          lastReadMessageId: msg.id,
          lastReadAt: msg.createdAt,
        ));

        // Give the async handler time to complete.
        await Future<void>.delayed(Duration.zero);
        await bloc.close();

        final captured = verify(
          () => repo.markRead(
            'gs-1',
            conversation: 'broadcast',
            lastReadMessageId: 'm-42',
            lastReadAt: captureAny(named: 'lastReadAt'),
          ),
        ).captured;

        expect(captured, hasLength(1));
        expect(
          captured.single as DateTime,
          messageCreatedAt,
          reason: 'bloc must forward message.createdAt, not wall-clock now',
        );
      },
    );

    blocTest<ChatBloc, ChatState>(
      'ChatMarkRead resets unreadCount to 0 in the active conversation',
      build: () {
        when(
          () => repo.markRead(
            any(),
            conversation: any(named: 'conversation'),
            lastReadMessageId: any(named: 'lastReadMessageId'),
            lastReadAt: any(named: 'lastReadAt'),
          ),
        ).thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => _readyState(messages: [_msg()]),
      act: (bloc) => bloc.add(ChatMarkRead(
        lastReadMessageId: 'm-last',
        lastReadAt: _messageCreatedAt,
      )),
      expect: () => [
        isA<ChatReady>().having(
          (s) => s.conversations['broadcast']?.unreadCount,
          'unreadCount reset to 0',
          0,
        ),
      ],
    );
  });
}

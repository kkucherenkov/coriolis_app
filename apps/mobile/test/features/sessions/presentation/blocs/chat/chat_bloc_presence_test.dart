import 'dart:async';

import 'package:app_api_client/app_api_client.dart'
    show ChatConversationSummary, ChatConversationSummaryKindEnum;
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

ChatConversationSummary _broadcastSummary() => ChatConversationSummary((b) => b
  ..conversationKey = 'broadcast'
  ..kind = ChatConversationSummaryKindEnum.broadcast
  ..unreadCount = 0);

ChatReady _readyState({Set<String> onlineMembershipIds = const {}}) => ChatReady(
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
      onlineMembershipIds: onlineMembershipIds,
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

  group('ChatBloc — presence', () {
    blocTest<ChatBloc, ChatState>(
      'ChatPresenceUpdated updates onlineMembershipIds in ChatReady state',
      build: buildBloc,
      seed: _readyState,
      act: (bloc) => bloc.add(const ChatPresenceUpdated({'m-alice', 'm-bob'})),
      expect: () => [
        isA<ChatReady>()
            .having(
              (s) => s.onlineMembershipIds,
              'onlineMembershipIds',
              {'m-alice', 'm-bob'},
            ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'ChatPresenceUpdated with empty set clears onlineMembershipIds',
      build: buildBloc,
      seed: () => _readyState(onlineMembershipIds: {'m-alice'}),
      act: (bloc) => bloc.add(const ChatPresenceUpdated({})),
      expect: () => [
        isA<ChatReady>()
            .having(
              (s) => s.onlineMembershipIds,
              'onlineMembershipIds',
              isEmpty,
            ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'ChatPresenceUpdated is ignored when state is not ChatReady',
      build: buildBloc,
      seed: () => const ChatInitial(),
      act: (bloc) => bloc.add(const ChatPresenceUpdated({'m-alice'})),
      expect: () => <ChatState>[],
    );

    blocTest<ChatBloc, ChatState>(
      'close() calls presenceService.dispose()',
      build: buildBloc,
      // No act needed — just close the bloc and verify dispose was called.
      verify: (_) {
        verify(() => presence.dispose()).called(1);
      },
    );
  });
}

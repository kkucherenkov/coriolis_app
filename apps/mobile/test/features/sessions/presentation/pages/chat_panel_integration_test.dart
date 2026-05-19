// Route-level integration test for the player chat surface
// (Phase 8.5 follow-up #8 — mobile half).
//
// What this covers
// ----------------
// Mounts `PlayerSessionDetailPage` end-to-end with `get_it` wired to
// `mocktail` stubs for every dependency the page (and its `ChatBloc`)
// reaches into:
//
//   * `PlayerSessionRepository` — returns one membership for the player
//     view used in this test.
//   * `ChatRepository` — controls conversation list, message pages, post /
//     edit / delete / block plumbing.
//   * `ChatRealtimeService` — exposes a `StreamController<ChatRealtimeEvent>`
//     so tests can dispatch posted / edited / deleted events.
//   * `ChatPresenceService` — exposes a `StreamController<Set<String>>` so
//     tests can flip a partner's online status.
//
// No real Centrifugo socket. No real HTTP. No platform plugins are
// hammered: the deps that `main.dart` reaches into (Firebase, Sentry, Drift,
// Secure Storage, app routes) are never touched because we mount the page
// directly with `MaterialApp` + `BlocProvider`.
//
// Why under `test/` and not `integration_test/`?
// ----------------------------------------------
// Flutter's `integration_test/` runner requires a connected device or a
// supported desktop / web shell — this repo only ships iOS + Android
// targets, so `flutter test integration_test/` aborts in headless CI.
// `WidgetTester` is the same primitive either way; the file lives next to
// its page (`features/sessions/presentation/pages/`) and runs as part of
// the standard `flutter test apps/mobile/` suite alongside the unit specs.
//
// Scenarios
// ---------
//  1. Page boots — ChatPanel mounts, broadcast tab is active, composer ready.
//  2. Sending a broadcast message calls `ChatRepository.postMessage`; the
//     new message renders after the future resolves.
//  3. Switching to a whisper tab swaps `activeKey` and re-fetches messages
//     for the partner conversation.
//  4. Presence update via the stubbed stream flips a partner's online flag
//     and the whisper tab's presence dot reflects it.

import 'dart:async';

import 'package:app_api_client/app_api_client.dart'
    show
        ChatConversationSummary,
        ChatConversationSummaryKindEnum,
        ChatMessage,
        ChatMessageKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_ui/app_ui.dart' show AppChatPresence, AppChatPresenceDot;
import 'package:coriolis_companion/features/sessions/domain/chat_presence_service.dart';
import 'package:coriolis_companion/features/sessions/domain/player_membership.dart';
import 'package:coriolis_companion/features/sessions/domain/player_session_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_realtime_service.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/pages/player_session_detail_page.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

// ── Mocks ───────────────────────────────────────────────────────────────────

class _MockPlayerSessionRepository extends Mock
    implements PlayerSessionRepository {}

class _MockChatRepository extends Mock implements ChatRepository {}

class _MockChatRealtimeService extends Mock implements ChatRealtimeService {}

class _MockChatPresenceService extends Mock implements ChatPresenceService {}

// ── Fixtures ────────────────────────────────────────────────────────────────

const _sessionId = 'session-test';
const _myMembershipId = 'member-self';
const _partnerMembershipId = 'member-partner';

PlayerMembership _membership() => PlayerMembership(
      membershipId: _myMembershipId,
      gameSessionId: _sessionId,
      sessionName: 'Test Session',
      role: 'player',
      joinedAt: DateTime.utc(2026, 5, 19, 10),
    );

ChatConversationSummary _broadcastSummary() =>
    ChatConversationSummary((b) => b
      ..conversationKey = 'broadcast'
      ..kind = ChatConversationSummaryKindEnum.broadcast
      ..unreadCount = 0);

ChatConversationSummary _whisperSummary() =>
    ChatConversationSummary((b) => b
      ..conversationKey = _partnerMembershipId
      ..kind = ChatConversationSummaryKindEnum.whisper
      ..partnerMembershipId = _partnerMembershipId
      ..partnerDisplayName = 'Adira'
      ..unreadCount = 0);

ChatMessage _message({
  String id = 'msg-1',
  String? author = _myMembershipId,
  String? target,
  String body = 'Hello, crew.',
}) =>
    ChatMessage((b) => b
      ..id = id
      ..gameSessionId = _sessionId
      ..authorMembershipId = author
      ..authorDisplayName = 'GM'
      ..kind = ChatMessageKind.text
      ..body = body
      ..createdAt = DateTime.utc(2026, 5, 19, 11)
      ..targetMembershipId = target);

// ── Test harness ────────────────────────────────────────────────────────────

/// Wraps the page in `TranslationProvider` + `MaterialApp` so `t.chat.*`
/// strings resolve. `app_ui` typography lives behind plain Material 3 colours
/// here — design tokens are sourced from `app_ui` at the widget level and do
/// not require a `Theme` override for the test.
Widget _wrap(Widget child) => TranslationProvider(
      child: MaterialApp(home: child),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockPlayerSessionRepository sessionsRepo;
  late _MockChatRepository chatRepo;
  late _MockChatRealtimeService realtime;
  late _MockChatPresenceService presence;
  late StreamController<ChatRealtimeEvent> realtimeCtrl;
  late StreamController<Set<String>> presenceCtrl;

  setUpAll(() {
    // Register a fallback for the conversation key arg because mocktail's
    // strict matchers reject `any()` on positional / named String args
    // without a default registered.
    registerFallbackValue('');
  });

  setUp(() async {
    if (GetIt.I.isRegistered<ChatRepository>()) await GetIt.I.reset();

    sessionsRepo = _MockPlayerSessionRepository();
    chatRepo = _MockChatRepository();
    realtime = _MockChatRealtimeService();
    presence = _MockChatPresenceService();
    realtimeCtrl = StreamController<ChatRealtimeEvent>.broadcast();
    presenceCtrl = StreamController<Set<String>>.broadcast();

    // Default happy-path behaviour — individual tests override below.
    when(() => sessionsRepo.getMyMemberships())
        .thenAnswer((_) async => [_membership()]);

    when(() => chatRepo.getConversations(_sessionId))
        .thenAnswer((_) async => [_broadcastSummary(), _whisperSummary()]);
    when(() => chatRepo.getMessages(_sessionId, conversation: 'broadcast'))
        .thenAnswer((_) async => <ChatMessage>[]);
    when(() => chatRepo.getMessages(_sessionId,
            conversation: _partnerMembershipId))
        .thenAnswer((_) async => <ChatMessage>[]);
    when(() => chatRepo.listBlocks(_sessionId))
        .thenAnswer((_) async => <String>{});

    when(() => realtime.events).thenAnswer((_) => realtimeCtrl.stream);
    when(() => realtime.start(
          gameSessionId: any(named: 'gameSessionId'),
          myMembershipId: any(named: 'myMembershipId'),
        )).thenAnswer((_) async {});
    when(() => realtime.stop()).thenAnswer((_) async {});
    when(() => realtime.dispose()).thenAnswer((_) async {});

    when(() => presence.onlineIds).thenAnswer((_) => presenceCtrl.stream);
    when(() => presence.start(
          gameSessionId: any(named: 'gameSessionId'),
          myMembershipId: any(named: 'myMembershipId'),
        )).thenAnswer((_) async {});
    when(() => presence.stop()).thenAnswer((_) async {});
    when(() => presence.dispose()).thenAnswer((_) async {});

    GetIt.I
      ..registerSingleton<ChatRepository>(chatRepo)
      ..registerSingleton<ChatRealtimeService>(realtime)
      ..registerSingleton<ChatPresenceService>(presence);
  });

  tearDown(() async {
    await realtimeCtrl.close();
    await presenceCtrl.close();
    await GetIt.I.reset();
  });

  Widget buildPage() => PlayerSessionDetailPage(
        gameSessionId: _sessionId,
        repository: sessionsRepo,
      );

  // ── Scenarios ─────────────────────────────────────────────────────────────

  testWidgets(
    '1. boot — page hydrates, broadcast tab active, composer ready',
    (tester) async {
      await tester.pumpWidget(_wrap(buildPage()));
      await tester.pumpAndSettle();

      // ChatBloc has hydrated — broadcast tab is in the strip and active.
      expect(find.byKey(const Key('tab_broadcast')), findsOneWidget);
      // Composer is mounted and accepts taps.
      expect(find.byKey(const Key('send_button')), findsOneWidget);
      // No messages yet.
      expect(find.byKey(const Key('message_list')), findsOneWidget);
      // Repository contract was honoured.
      verify(() => sessionsRepo.getMyMemberships()).called(1);
      verify(() =>
              chatRepo.getMessages(_sessionId, conversation: 'broadcast'))
          .called(1);
    },
  );

  testWidgets(
    '2. send — composer submit calls ChatRepository.postMessage and renders the new message',
    (tester) async {
      final sent = _message(id: 'srv-1', body: 'Beware the Dark.');
      when(() => chatRepo.postMessage(
            _sessionId,
            body: any(named: 'body'),
            targetMembershipId: any(named: 'targetMembershipId'),
          )).thenAnswer((_) async => sent);

      await tester.pumpWidget(_wrap(buildPage()));
      await tester.pumpAndSettle();

      // Type into the composer. enterText fires onChanged → bloc dispatches
      // ChatComposerChanged → state.composerValue updates. A pump lets the
      // composer rebuild with the new prop value so `_canSend` is true when
      // we tap send.
      await tester.enterText(
        find.byType(TextField).first,
        'Beware the Dark.',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('send_button')));
      await tester.pumpAndSettle();

      verify(() => chatRepo.postMessage(
            _sessionId,
            body: 'Beware the Dark.',
            targetMembershipId: null,
          )).called(1);

      // The bloc appends the message to broadcast on success — it now
      // renders in the list.
      expect(find.text('Beware the Dark.'), findsOneWidget);
    },
  );

  testWidgets(
    '3. switch — tapping the whisper tab swaps active conversation and re-fetches whisper messages',
    (tester) async {
      // Whisper conversation comes pre-listed (see _setUp). Stub the page
      // load specifically for that key so we can verify a re-fetch occurs.
      when(() =>
              chatRepo.getMessages(_sessionId,
                  conversation: _partnerMembershipId))
          .thenAnswer(
        (_) async => [
          _message(
            id: 'wsp-1',
            target: _partnerMembershipId,
            body: 'A whisper for the GM.',
          ),
        ],
      );

      await tester.pumpWidget(_wrap(buildPage()));
      await tester.pumpAndSettle();

      // Tab is rendered because the conversation summary lists the whisper.
      final tab = find.byKey(const Key('tab_$_partnerMembershipId'));
      expect(tab, findsOneWidget);

      await tester.tap(tab);
      await tester.pumpAndSettle();

      // Two fetches: broadcast on hydrate + whisper on selection.
      verify(() =>
              chatRepo.getMessages(_sessionId,
                  conversation: _partnerMembershipId))
          .called(1);
      expect(find.text('A whisper for the GM.'), findsOneWidget);
    },
  );

  testWidgets(
    '4. presence — partner appearing in onlineIds flips the whisper tab presence dot to online',
    (tester) async {
      await tester.pumpWidget(_wrap(buildPage()));
      await tester.pumpAndSettle();

      final tabFinder = find.byKey(const Key('tab_$_partnerMembershipId'));
      expect(tabFinder, findsOneWidget);

      // Before the presence event: tab renders an offline dot.
      final dotBefore = tester.widget<AppChatPresenceDot>(
        find.descendant(of: tabFinder, matching: find.byType(AppChatPresenceDot)),
      );
      expect(dotBefore.presence, AppChatPresence.offline);

      // Emit presence update including the partner.
      presenceCtrl.add({_partnerMembershipId});
      await tester.pumpAndSettle();

      final dotAfter = tester.widget<AppChatPresenceDot>(
        find.descendant(of: tabFinder, matching: find.byType(AppChatPresenceDot)),
      );
      expect(dotAfter.presence, AppChatPresence.online);
    },
  );
}

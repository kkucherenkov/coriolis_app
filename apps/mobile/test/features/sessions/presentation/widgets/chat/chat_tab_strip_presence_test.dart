import 'package:app_api_client/app_api_client.dart'
    show ChatConversationSummary, ChatConversationSummaryKindEnum;
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_state.dart';
import 'package:coriolis_companion/features/sessions/presentation/widgets/chat/chat_tab_strip.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

ChatConversationData _broadcast() => ChatConversationData(
      summary: ChatConversationSummary((b) => b
        ..conversationKey = 'broadcast'
        ..kind = ChatConversationSummaryKindEnum.broadcast
        ..unreadCount = 0),
      messages: const [],
    );

ChatConversationData _whisper(String id, String name) => ChatConversationData(
      summary: ChatConversationSummary((b) => b
        ..conversationKey = id
        ..kind = ChatConversationSummaryKindEnum.whisper
        ..partnerMembershipId = id
        ..partnerDisplayName = name
        ..unreadCount = 0),
      messages: const [],
    );

Widget _wrap(Widget child) => TranslationProvider(
      child: MaterialApp(home: Scaffold(body: child)),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('ChatTabStrip — presence dot', () {
    testWidgets(
        'whisper tab with partner in onlineMembershipIds renders dot in online state',
        (tester) async {
      await tester.pumpWidget(_wrap(
        ChatTabStrip(
          conversations: [_broadcast(), _whisper('m-alice', 'Alice')],
          activeKey: 'broadcast',
          openWhisperKeys: const {'m-alice'},
          onlineMembershipIds: const {'m-alice'},
          onSelect: (_) {},
          onAddWhisper: () {},
        ),
      ));

      final dot = tester.widget<AppChatPresenceDot>(
        find.byType(AppChatPresenceDot),
      );
      expect(dot.presence, AppChatPresence.online);
    });

    testWidgets(
        'whisper tab with partner NOT in onlineMembershipIds renders dot in offline state',
        (tester) async {
      // Design decision: always render the dot (varying state, not existence)
      // to match web behaviour and avoid layout shift on join/leave.
      await tester.pumpWidget(_wrap(
        ChatTabStrip(
          conversations: [_broadcast(), _whisper('m-alice', 'Alice')],
          activeKey: 'broadcast',
          openWhisperKeys: const {'m-alice'},
          onlineMembershipIds: const {}, // alice is offline
          onSelect: (_) {},
          onAddWhisper: () {},
        ),
      ));

      final dot = tester.widget<AppChatPresenceDot>(
        find.byType(AppChatPresenceDot),
      );
      expect(dot.presence, AppChatPresence.offline);
    });

    testWidgets('broadcast tab never renders a presence dot', (tester) async {
      await tester.pumpWidget(_wrap(
        ChatTabStrip(
          conversations: [_broadcast()],
          activeKey: 'broadcast',
          openWhisperKeys: const {},
          onlineMembershipIds: const {'m-alice'},
          onSelect: (_) {},
          onAddWhisper: () {},
        ),
      ));

      expect(find.byType(AppChatPresenceDot), findsNothing);
    });

    testWidgets(
        'multiple whisper tabs each render a dot with correct presence state',
        (tester) async {
      await tester.pumpWidget(_wrap(
        ChatTabStrip(
          conversations: [
            _broadcast(),
            _whisper('m-alice', 'Alice'),
            _whisper('m-bob', 'Bob'),
          ],
          activeKey: 'broadcast',
          openWhisperKeys: const {'m-alice', 'm-bob'},
          onlineMembershipIds: const {'m-alice'}, // alice online, bob offline
          onSelect: (_) {},
          onAddWhisper: () {},
        ),
      ));

      final dots = tester
          .widgetList<AppChatPresenceDot>(find.byType(AppChatPresenceDot))
          .toList();
      expect(dots, hasLength(2));
      // Alice's tab dot is online, Bob's is offline.
      // Tabs are rendered in conversation order: alice first, then bob.
      expect(dots[0].presence, AppChatPresence.online);
      expect(dots[1].presence, AppChatPresence.offline);
    });
  });
}

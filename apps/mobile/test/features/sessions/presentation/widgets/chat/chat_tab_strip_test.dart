import 'package:app_api_client/app_api_client.dart'
    show ChatConversationSummary, ChatConversationSummaryKindEnum;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_state.dart';
import 'package:coriolis_companion/features/sessions/presentation/widgets/chat/chat_tab_strip.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

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

void main() {
  group('ChatTabStrip', () {
    testWidgets('5 whispers shows 3 visible + overflow chip', (tester) async {
      final convs = [
        _broadcast(),
        _whisper('w1', 'Alice'),
        _whisper('w2', 'Bob'),
        _whisper('w3', 'Carol'),
        _whisper('w4', 'Dave'),
        _whisper('w5', 'Eve'),
      ];

      await tester.pumpWidget(_wrap(
        ChatTabStrip(
          conversations: convs,
          activeKey: 'broadcast',
          openWhisperKeys: const {'w1', 'w2', 'w3', 'w4', 'w5'},
          onSelect: (_) {},
          onAddWhisper: () {},
        ),
      ));

      // 3 whisper tabs visible + broadcast tab.
      expect(find.byKey(const Key('tab_broadcast')), findsOneWidget);
      expect(find.byKey(const Key('tab_w1')), findsOneWidget);
      expect(find.byKey(const Key('tab_w2')), findsOneWidget);
      expect(find.byKey(const Key('tab_w3')), findsOneWidget);
      // Overflow chip for 2 remaining whispers.
      expect(find.byKey(const Key('overflow_chip')), findsOneWidget);
    });

    testWidgets('tapping a tab fires onSelect with correct key', (tester) async {
      String? selected;
      final convs = [
        _broadcast(),
        _whisper('w1', 'Alice'),
      ];

      await tester.pumpWidget(_wrap(
        ChatTabStrip(
          conversations: convs,
          activeKey: 'broadcast',
          openWhisperKeys: const {'w1'},
          onSelect: (key) => selected = key,
          onAddWhisper: () {},
        ),
      ));

      await tester.tap(find.byKey(const Key('tab_w1')));
      await tester.pump();

      expect(selected, 'w1');
    });

    testWidgets('+ button fires onAddWhisper', (tester) async {
      bool addCalled = false;
      final convs = [_broadcast()];

      await tester.pumpWidget(_wrap(
        ChatTabStrip(
          conversations: convs,
          activeKey: 'broadcast',
          openWhisperKeys: const {},
          onSelect: (_) {},
          onAddWhisper: () => addCalled = true,
        ),
      ));

      await tester.tap(find.byKey(const Key('add_whisper_button')));
      await tester.pump();

      expect(addCalled, isTrue);
    });
  });
}

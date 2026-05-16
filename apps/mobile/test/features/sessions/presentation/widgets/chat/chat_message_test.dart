import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/features/sessions/presentation/widgets/chat/chat_message.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

Widget _wrap(Widget child) => TranslationProvider(
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  group('ChatMessageWidget', () {
    testWidgets('broadcastAuthor variant is right-aligned', (tester) async {
      await tester.pumpWidget(_wrap(
        const ChatMessageWidget(
          messageId: 'm1',
          variant: ChatMessageVariant.broadcastAuthor,
          body: 'Hello from author',
        ),
      ));

      final row = tester.widget<Row>(
        find.byWidgetPredicate(
          (w) =>
              w is Row &&
              (w.mainAxisAlignment == MainAxisAlignment.end),
        ),
      );
      expect(row.mainAxisAlignment, MainAxisAlignment.end);
    });

    testWidgets('broadcastOther variant is left-aligned', (tester) async {
      await tester.pumpWidget(_wrap(
        const ChatMessageWidget(
          messageId: 'm2',
          variant: ChatMessageVariant.broadcastOther,
          body: 'Hello from other',
          authorName: 'Alice',
        ),
      ));

      final rows = tester.widgetList<Row>(
        find.byWidgetPredicate(
          (w) => w is Row,
        ),
      ).toList();

      // At least one row should be start-aligned (the bubble row).
      expect(
        rows.any((r) => r.mainAxisAlignment == MainAxisAlignment.start),
        isTrue,
      );
    });

    testWidgets('whisper variant shows lock icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const ChatMessageWidget(
          messageId: 'm3',
          variant: ChatMessageVariant.whisper,
          body: 'Secret message',
          authorName: 'Bob',
        ),
      ));

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('system variant skips bubble and has no avatar', (tester) async {
      await tester.pumpWidget(_wrap(
        const ChatMessageWidget(
          messageId: 'm4',
          variant: ChatMessageVariant.system,
          body: 'Alice joined the session.',
        ),
      ));

      // System row should render a centered Text, no CircleAvatar.
      expect(find.byType(CircleAvatar), findsNothing);
      expect(find.text('Alice joined the session.'), findsOneWidget);
    });

    testWidgets('system variant centers text', (tester) async {
      await tester.pumpWidget(_wrap(
        const ChatMessageWidget(
          messageId: 'm5',
          variant: ChatMessageVariant.system,
          body: 'Encounter started.',
        ),
      ));

      final center = find.byType(Center);
      expect(center, findsWidgets);
    });

    testWidgets('long-press opens action sheet and tapping Delete calls onDelete',
        (tester) async {
      bool deleteCalled = false;

      await tester.pumpWidget(_wrap(
        ChatMessageWidget(
          messageId: 'm6',
          variant: ChatMessageVariant.broadcastAuthor,
          body: 'Delete me',
          canDelete: true,
          ownByMe: true,
          onDelete: () => deleteCalled = true,
        ),
      ));

      // Long press the message body text to trigger the action sheet.
      await tester.longPress(find.text('Delete me'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('action_delete')), findsOneWidget);

      await tester.tap(find.byKey(const Key('action_delete')));
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
    });
  });
}

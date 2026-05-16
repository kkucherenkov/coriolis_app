import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/features/sessions/presentation/widgets/chat/whisper_picker_sheet.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

Widget _wrap(Widget child) => TranslationProvider(
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  group('WhisperPickerSheet', () {
    testWidgets('blocked members filtered out — only supplied members shown',
        (tester) async {
      // Blocked member "Dave" is excluded by the caller before passing to
      // the widget; the widget only shows what it receives.
      final members = [
        const WhisperPickerMember(membershipId: 'w1', displayName: 'Alice'),
        const WhisperPickerMember(membershipId: 'w2', displayName: 'Bob'),
        // Dave (w3) is blocked and was filtered out by the caller.
      ];

      await tester.pumpWidget(_wrap(
        WhisperPickerSheet(
          members: members,
          onPick: (_) {},
        ),
      ));

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Dave'), findsNothing);
    });

    testWidgets('tapping a member row calls onPick with that member',
        (tester) async {
      WhisperPickerMember? picked;

      final members = [
        const WhisperPickerMember(membershipId: 'w1', displayName: 'Alice'),
        const WhisperPickerMember(membershipId: 'w2', displayName: 'Bob'),
      ];

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    builder: (_) => WhisperPickerSheet(
                      members: members,
                      onPick: (m) => picked = m,
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('member_w1')));
      await tester.pumpAndSettle();

      expect(picked?.membershipId, 'w1');
    });
  });
}

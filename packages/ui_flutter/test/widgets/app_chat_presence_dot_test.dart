// No golden tests: no golden-test infrastructure exists in packages/ui_flutter/test/.

import 'package:app_ui/app_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

void main() {
  group('AppChatPresenceDot', () {
    testWidgets('renders online state with brass fill', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppChatPresenceDot(presence: AppChatPresence.online)),
      );

      // DecoratedBox with brass fill is present.
      final decoratedBoxes = tester.widgetList<DecoratedBox>(
        find.byType(DecoratedBox),
      );
      final decoration = decoratedBoxes.first.decoration as BoxDecoration;
      expect(decoration.color, AppColors.brandBrass);
      expect(decoration.shape, BoxShape.circle);

      // SizedBox widget exists with the correct dimensions in the widget tree.
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(AppChatPresenceDot),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, 8.0);
      expect(sizedBox.height, 8.0);
    });

    testWidgets('renders idle state with textSecondary fill', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppChatPresenceDot(presence: AppChatPresence.idle)),
      );

      final decoratedBoxes = tester.widgetList<DecoratedBox>(
        find.byType(DecoratedBox),
      );
      final decoration = decoratedBoxes.first.decoration as BoxDecoration;
      expect(decoration.color, AppColors.textSecondary);
    });

    testWidgets('offline state has transparent fill and secondary border',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const AppChatPresenceDot(presence: AppChatPresence.offline)),
      );

      final decoratedBoxes = tester.widgetList<DecoratedBox>(
        find.byType(DecoratedBox),
      );
      final decoration = decoratedBoxes.first.decoration as BoxDecoration;
      // Fill must be transparent.
      expect(decoration.color, const Color(0x00000000));
      // Border must be textSecondary.
      final border = decoration.border as Border;
      expect(border.top.color, AppColors.textSecondary);
    });

    testWidgets('semantics label exposes presence name', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppChatPresenceDot(presence: AppChatPresence.online)),
      );

      expect(
        tester.getSemantics(find.byType(AppChatPresenceDot)),
        matchesSemantics(label: 'online'),
      );
    });

    testWidgets('semantics label for offline state', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppChatPresenceDot(presence: AppChatPresence.offline)),
      );

      expect(
        tester.getSemantics(find.byType(AppChatPresenceDot)),
        matchesSemantics(label: 'offline'),
      );
    });
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ui/app_ui.dart';

Widget _wrap(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(child: child),
);

void main() {
  group('AppButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(const AppButton(label: 'Save')));
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('tap target is at least 44×44', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppButton(label: 'X', size: AppButtonSize.sm)),
      );
      final box = tester.getSize(find.byType(AppButton));
      expect(box.width, greaterThanOrEqualTo(44));
      expect(box.height, greaterThanOrEqualTo(44));
    });

    testWidgets('fires onPressed when enabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Go', onPressed: () => tapped = true)),
      );
      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });

    testWidgets('does not fire onPressed when disabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'Go',
            disabled: true,
            onPressed: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(AppButton), warnIfMissed: false);
      expect(tapped, isFalse);
    });

    testWidgets('shows spinner when loading', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppButton(label: 'Wait', loading: true)),
      );
      // Label is replaced by spinner — Text widget should be absent.
      expect(find.text('Wait'), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    for (final variant in AppButtonVariant.values) {
      testWidgets('renders variant $variant', (tester) async {
        await tester.pumpWidget(_wrap(AppButton(label: 'v', variant: variant)));
        expect(find.byType(AppButton), findsOneWidget);
      });
    }

    testWidgets('secondary variant paints the label in brass', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppButton(label: 'Cancel', variant: AppButtonVariant.secondary),
        ),
      );
      final style = tester.widget<Text>(find.text('Cancel')).style!;
      expect(style.color, AppColors.brandBrass);
    });

    testWidgets('mystic variant paints the label in on-brass over teal', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppButton(
            label: 'Push the Roll',
            variant: AppButtonVariant.mystic,
          ),
        ),
      );
      final style = tester.widget<Text>(find.text('Push the Roll')).style!;
      expect(style.color, AppColors.textOnBrass);
    });
  });
}

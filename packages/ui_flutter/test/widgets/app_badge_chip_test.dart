import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ui/app_ui.dart';

Widget _wrap(Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: child),
    );

void main() {
  group('AppBadge', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(_wrap(const AppBadge(label: 'Active')));
      expect(find.text('Active'), findsOneWidget);
    });

    for (final tone in AppBadgeTone.values) {
      testWidgets('renders tone $tone', (tester) async {
        await tester.pumpWidget(_wrap(AppBadge(label: 'x', tone: tone)));
        expect(find.byType(AppBadge), findsOneWidget);
      });
    }

    for (final size in AppBadgeSize.values) {
      testWidgets('renders size $size', (tester) async {
        await tester.pumpWidget(_wrap(AppBadge(label: 'x', size: size)));
        expect(find.byType(AppBadge), findsOneWidget);
      });
    }
  });

  group('AppChip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(_wrap(const AppChip(label: 'Tag')));
      expect(find.text('Tag'), findsOneWidget);
    });

    testWidgets('fires onToggle on tap', (tester) async {
      var toggled = false;
      await tester.pumpWidget(_wrap(
        AppChip(label: 'T', onToggle: () => toggled = true),
      ));
      await tester.tap(find.byType(AppChip));
      expect(toggled, isTrue);
    });

    testWidgets('does not fire onToggle when disabled', (tester) async {
      var toggled = false;
      await tester.pumpWidget(_wrap(
        AppChip(label: 'T', disabled: true, onToggle: () => toggled = true),
      ));
      await tester.tap(find.byType(AppChip), warnIfMissed: false);
      expect(toggled, isFalse);
    });

    testWidgets('shows × when removable', (tester) async {
      await tester.pumpWidget(_wrap(const AppChip(label: 'T', removable: true)));
      expect(find.text('×'), findsOneWidget);
    });

    testWidgets('fires onRemove when × tapped', (tester) async {
      var removed = false;
      await tester.pumpWidget(_wrap(
        AppChip(label: 'T', removable: true, onRemove: () => removed = true),
      ));
      await tester.tap(find.text('×'));
      expect(removed, isTrue);
    });

    testWidgets('tap target >= 44x44', (tester) async {
      await tester.pumpWidget(_wrap(const AppChip(label: 'X')));
      final box = tester.getSize(find.byType(AppChip));
      expect(box.width, greaterThanOrEqualTo(44));
      expect(box.height, greaterThanOrEqualTo(44));
    });
  });
}

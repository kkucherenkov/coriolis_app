import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ui/app_ui.dart';

Widget _wrap(Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(width: 200, child: child),
    );

void main() {
  group('AppDivider', () {
    for (final tone in AppDividerTone.values) {
      testWidgets('renders tone $tone', (tester) async {
        await tester.pumpWidget(_wrap(AppDivider(tone: tone)));
        expect(find.byType(AppDivider), findsOneWidget);
      });
    }

    for (final weight in AppDividerWeight.values) {
      testWidgets('renders weight $weight', (tester) async {
        await tester.pumpWidget(_wrap(AppDivider(weight: weight)));
        expect(find.byType(AppDivider), findsOneWidget);
      });
    }

    testWidgets('renders with inset', (tester) async {
      await tester.pumpWidget(_wrap(const AppDivider(inset: true)));
      expect(find.byType(Padding), findsWidgets);
    });
  });

  group('AppDots', () {
    testWidgets('renders correct number of dots', (tester) async {
      await tester.pumpWidget(_wrap(const AppDots(value: 3, max: 5)));
      // 5 AnimatedContainers are the dot shapes
      expect(find.byType(AnimatedContainer), findsNWidgets(5));
    });

    testWidgets('renders value 0', (tester) async {
      await tester.pumpWidget(_wrap(const AppDots(value: 0, max: 5)));
      expect(find.byType(AppDots), findsOneWidget);
    });

    testWidgets('renders value == max', (tester) async {
      await tester.pumpWidget(_wrap(const AppDots(value: 5, max: 5)));
      expect(find.byType(AppDots), findsOneWidget);
    });

    for (final tone in AppBadgeTone.values) {
      testWidgets('renders tone $tone', (tester) async {
        await tester.pumpWidget(_wrap(AppDots(value: 2, tone: tone)));
        expect(find.byType(AppDots), findsOneWidget);
      });
    }

    for (final size in AppDotsSize.values) {
      testWidgets('renders size $size', (tester) async {
        await tester.pumpWidget(_wrap(AppDots(value: 2, size: size)));
        expect(find.byType(AppDots), findsOneWidget);
      });
    }
  });
}

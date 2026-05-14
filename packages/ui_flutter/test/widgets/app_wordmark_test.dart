import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ui/app_ui.dart';

/// Wrap the widget under test with loose constraints so size-fixed children
/// (SizedBox) are not stretched by the test view's tight 800×600 surface.
Widget _wrap(Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    );

void main() {
  group('AppWordmark', () {
    testWidgets('renders the brand text uppercased', (tester) async {
      await tester.pumpWidget(_wrap(const AppWordmark()));
      expect(find.text('CORIOLIS'), findsOneWidget);
    });

    testWidgets('renders the eyebrow text uppercased', (tester) async {
      await tester.pumpWidget(_wrap(const AppWordmark()));
      expect(find.text('COMPANION'), findsOneWidget);
    });

    testWidgets('respects custom brand + eyebrow overrides', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppWordmark(brand: 'Coriolis', eyebrow: 'Спутник'),
      ));
      expect(find.text('CORIOLIS'), findsOneWidget);
      expect(find.text('СПУТНИК'), findsOneWidget);
    });

    testWidgets('pairs the brand with an AppSwash', (tester) async {
      await tester.pumpWidget(_wrap(const AppWordmark()));
      expect(find.byType(AppSwash), findsOneWidget);
    });

    testWidgets('defaults the brand font-size to 48 logical pixels', (tester) async {
      await tester.pumpWidget(_wrap(const AppWordmark()));
      final style = tester.widget<Text>(find.text('CORIOLIS')).style!;
      expect(style.fontSize, 48.0);
      expect(style.fontFamily, AppFontFamily.display);
      expect(style.color, AppColors.brandBrassLight);
      expect(style.fontWeight, AppFontWeight.regular);
    });

    testWidgets('uses Inter body family with brass colour for the eyebrow',
        (tester) async {
      await tester.pumpWidget(_wrap(const AppWordmark()));
      final style = tester.widget<Text>(find.text('COMPANION')).style!;
      expect(style.fontFamily, AppFontFamily.body);
      expect(style.color, AppColors.brandBrass);
    });

    testWidgets('auto-scales the eyebrow at size × 0.18', (tester) async {
      // size 100 → eyebrow 18
      await tester.pumpWidget(_wrap(const AppWordmark(size: 100)));
      final style = tester.widget<Text>(find.text('COMPANION')).style!;
      expect(style.fontSize, closeTo(18.0, 0.001));
    });

    testWidgets('floors the eyebrow at 10 logical pixels for tiny lockups',
        (tester) async {
      // size 24 → 24 × 0.18 = 4.32 → clamped to 10
      await tester.pumpWidget(_wrap(const AppWordmark(size: 24)));
      final style = tester.widget<Text>(find.text('COMPANION')).style!;
      expect(style.fontSize, 10.0);
    });

    testWidgets('sizes the swash at size × 2.4', (tester) async {
      // size 50 → swash width 120
      await tester.pumpWidget(_wrap(const AppWordmark(size: 50)));
      expect(tester.getSize(find.byType(AppSwash)).width, 120.0);
    });

    testWidgets(
        'exposes the lockup as a single header with combined accessible name',
        (tester) async {
      await tester.pumpWidget(_wrap(const AppWordmark()));
      final semantics = tester.getSemantics(find.byType(AppWordmark));
      expect(semantics.flagsCollection.isHeader, isTrue);
      expect(semantics.label, 'Coriolis Companion');
    });

    testWidgets('forwards localized brand + eyebrow into the accessible name',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const AppWordmark(brand: 'Coriolis', eyebrow: 'Спутник'),
      ));
      final semantics = tester.getSemantics(find.byType(AppWordmark));
      expect(semantics.label, 'Coriolis Спутник');
    });
  });
}

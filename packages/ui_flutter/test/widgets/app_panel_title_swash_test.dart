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
  group('AppSwash', () {
    testWidgets('renders at the default width and aspect ratio (120:10)',
        (tester) async {
      await tester.pumpWidget(_wrap(const AppSwash()));
      final size = tester.getSize(find.byType(AppSwash));
      expect(size.width, 80.0);
      expect(size.height, closeTo(80.0 * (10.0 / 120.0), 0.001));
    });

    testWidgets('forwards a custom width and preserves the aspect ratio',
        (tester) async {
      await tester.pumpWidget(_wrap(const AppSwash(width: 240)));
      final size = tester.getSize(find.byType(AppSwash));
      expect(size.width, 240.0);
      expect(size.height, closeTo(240.0 * (10.0 / 120.0), 0.001));
    });

    for (final color in AppSwashColor.values) {
      testWidgets('renders colour $color without errors', (tester) async {
        await tester.pumpWidget(_wrap(AppSwash(color: color)));
        expect(find.byType(AppSwash), findsOneWidget);
      });
    }

    testWidgets('is hidden from semantics (decorative)', (tester) async {
      await tester.pumpWidget(_wrap(const AppSwash()));
      // ExcludeSemantics wraps the painter — find it on the widget tree.
      expect(find.byType(ExcludeSemantics), findsWidgets);
    });
  });

  group('AppPanelTitle', () {
    testWidgets('renders the supplied text', (tester) async {
      await tester.pumpWidget(_wrap(const AppPanelTitle(text: 'Crew Status')));
      expect(find.text('Crew Status'), findsOneWidget);
    });

    testWidgets('pairs the text with an AppSwash', (tester) async {
      await tester.pumpWidget(_wrap(const AppPanelTitle(text: 'Crew Status')));
      expect(find.byType(AppSwash), findsOneWidget);
    });

    testWidgets('defaults to size=md (font 22, swash width 70)', (tester) async {
      await tester.pumpWidget(_wrap(const AppPanelTitle(text: 'Crew')));
      final textStyle = tester.widget<Text>(find.text('Crew')).style!;
      expect(textStyle.fontSize, 22.0);
      final swashSize = tester.getSize(find.byType(AppSwash));
      expect(swashSize.width, 70.0);
    });

    testWidgets('size=sm renders font 16 and swash width 70', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppPanelTitle(text: 'Talents', size: AppPanelTitleSize.sm),
      ));
      final textStyle = tester.widget<Text>(find.text('Talents')).style!;
      expect(textStyle.fontSize, 16.0);
      expect(tester.getSize(find.byType(AppSwash)).width, 70.0);
    });

    testWidgets('size=lg renders font 28 and swash width 110', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppPanelTitle(text: 'Library', size: AppPanelTitleSize.lg),
      ));
      final textStyle = tester.widget<Text>(find.text('Library')).style!;
      expect(textStyle.fontSize, 28.0);
      expect(tester.getSize(find.byType(AppSwash)).width, 110.0);
    });

    testWidgets('marks the heading with header semantics', (tester) async {
      await tester.pumpWidget(_wrap(const AppPanelTitle(text: 'Crew')));
      final semantics = tester.getSemantics(find.byType(AppPanelTitle));
      expect(semantics.flagsCollection.isHeader, isTrue);
    });

    testWidgets('uses a Forum display family with brass-light colour',
        (tester) async {
      await tester.pumpWidget(_wrap(const AppPanelTitle(text: 'Crew')));
      final style = tester.widget<Text>(find.text('Crew')).style!;
      expect(style.fontFamily, AppFontFamily.display);
      expect(style.color, AppColors.brandBrassLight);
      expect(style.fontWeight, AppFontWeight.regular);
    });
  });
}

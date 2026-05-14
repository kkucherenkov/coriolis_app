import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ui/app_ui.dart';

Widget _wrap(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: MediaQuery(
    data: const MediaQueryData(),
    child: Align(alignment: Alignment.topLeft, child: child),
  ),
);

void main() {
  group('AppPortrait', () {
    testWidgets('derives initials from name (first letters of up to 2 words)', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppPortrait(name: 'Aelyn Skarn')));
      expect(find.text('AS'), findsOneWidget);
    });

    testWidgets('uses only the first two words when more are present', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppPortrait(name: 'Captain Aelyn Skarn of Algol')),
      );
      expect(find.text('CA'), findsOneWidget);
    });

    testWidgets('uppercases derived initials', (tester) async {
      await tester.pumpWidget(_wrap(const AppPortrait(name: 'aelyn skarn')));
      expect(find.text('AS'), findsOneWidget);
    });

    testWidgets('preserves Cyrillic via code-point iteration', (tester) async {
      await tester.pumpWidget(_wrap(const AppPortrait(name: 'Айлин Скарн')));
      expect(find.text('АС'), findsOneWidget);
    });

    testWidgets('falls back to "NA" when no name or initials are provided', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppPortrait()));
      expect(find.text('NA'), findsOneWidget);
    });

    testWidgets('honours an explicit initials override over name', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppPortrait(name: 'Aelyn Skarn', initials: 'XY')),
      );
      expect(find.text('XY'), findsOneWidget);
      expect(find.text('AS'), findsNothing);
    });

    testWidgets('trims an initials override longer than 2 characters', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppPortrait(initials: 'ABCDE')));
      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('defaults the medallion to 96 logical pixels square', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppPortrait(name: 'A B')));
      final size = tester.getSize(find.byType(AppPortrait));
      expect(size.width, 96.0);
      expect(size.height, 96.0);
    });

    testWidgets('scales the initials font-size at size × 0.36', (tester) async {
      // size 100 → 36.0
      await tester.pumpWidget(_wrap(const AppPortrait(name: 'A B', size: 100)));
      final style = tester.widget<Text>(find.text('AB')).style!;
      expect(style.fontSize, closeTo(36.0, 0.001));
      expect(style.fontFamily, AppFontFamily.display);
      expect(style.color, AppColors.brandBrassLight);
    });

    testWidgets('exposes the portrait as an image semantic with the name', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppPortrait(name: 'Aelyn Skarn')));
      final semantics = tester.getSemantics(find.byType(AppPortrait));
      expect(semantics.flagsCollection.isImage, isTrue);
      expect(semantics.label, 'Aelyn Skarn');
    });

    testWidgets('uses the explicit semantics label override when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppPortrait(
            name: 'Aelyn Skarn',
            semanticsLabel: 'Player character — Aelyn Skarn',
          ),
        ),
      );
      final semantics = tester.getSemantics(find.byType(AppPortrait));
      expect(semantics.label, 'Player character — Aelyn Skarn');
    });

    testWidgets('falls back to the initials when no name / label given', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppPortrait(initials: 'NA')));
      final semantics = tester.getSemantics(find.byType(AppPortrait));
      expect(semantics.label, 'NA');
    });
  });
}

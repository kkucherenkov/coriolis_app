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
  group('AppIconMedallion', () {
    testWidgets('renders the monogram letter as text', (tester) async {
      await tester.pumpWidget(_wrap(const AppIconMedallion(letter: 'T')));
      expect(find.text('T'), findsOneWidget);
    });

    testWidgets('defaults the medallion to 64 logical pixels square', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppIconMedallion(letter: 'T')));
      final size = tester.getSize(find.byType(AppIconMedallion));
      expect(size.width, 64.0);
      expect(size.height, 64.0);
    });

    testWidgets('reflects a custom size into the painted square', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppIconMedallion(letter: 'F', size: 48)),
      );
      final size = tester.getSize(find.byType(AppIconMedallion));
      expect(size.width, 48.0);
      expect(size.height, 48.0);
    });

    testWidgets('scales the letter font-size at size × 0.5', (tester) async {
      // size 64 → letter 32
      await tester.pumpWidget(
        _wrap(const AppIconMedallion(letter: 'T', size: 64)),
      );
      final style = tester.widget<Text>(find.text('T')).style!;
      expect(style.fontSize, 32.0);
      expect(style.fontFamily, AppFontFamily.display);
      expect(style.color, AppColors.surfaceVoid);
    });

    testWidgets('does not paint the halo by default', (tester) async {
      await tester.pumpWidget(_wrap(const AppIconMedallion(letter: 'T')));
      // The halo is a DecoratedBox layered inside the Stack; with `glow=false`
      // it is omitted entirely.
      final decoratedBoxes = find.descendant(
        of: find.byType(AppIconMedallion),
        matching: find.byType(DecoratedBox),
      );
      expect(decoratedBoxes, findsNothing);
    });

    testWidgets('paints the mystic halo when glow=true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppIconMedallion(
            letter: 'F',
            glow: true,
            semanticsLabel: 'The Faceless One',
          ),
        ),
      );
      final decoratedBoxes = find.descendant(
        of: find.byType(AppIconMedallion),
        matching: find.byType(DecoratedBox),
      );
      expect(decoratedBoxes, findsOneWidget);
    });

    testWidgets(
      'exposes the medallion as an image semantic when label is provided',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const AppIconMedallion(letter: 'T', semanticsLabel: 'The Traveler'),
          ),
        );
        final semantics = tester.getSemantics(find.byType(AppIconMedallion));
        expect(semantics.flagsCollection.isImage, isTrue);
        expect(semantics.label, 'The Traveler');
      },
    );

    testWidgets('is decorative (no semantics) when no label is given', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppIconMedallion(letter: 'T')));
      final semantics = tester.getSemantics(find.byType(AppIconMedallion));
      expect(semantics.label, '');
      expect(semantics.flagsCollection.isImage, isFalse);
    });
  });
}

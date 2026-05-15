import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ui/app_ui.dart';

/// Wrap the widget under test with a sizing parent so the grid lays out
/// against a known width.
Widget _wrap(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: MediaQuery(
    data: const MediaQueryData(),
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 360, child: child),
    ),
  ),
);

void main() {
  group('AppSkillRow', () {
    testWidgets('renders name, attr (uppercase), and rank', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppSkillRow(name: 'Pilot', attr: 'Agility', rank: 3)),
      );
      expect(find.text('Pilot'), findsOneWidget);
      // Attr is uppercased on render to mirror the handoff eyebrow.
      expect(find.text('AGILITY'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders the dot meter via AppDots', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppSkillRow(name: 'Pilot', attr: 'Agility', rank: 3)),
      );
      expect(find.byType(AppDots), findsOneWidget);
    });

    testWidgets('clamps a negative rank to 0', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppSkillRow(name: 'Pilot', attr: 'Agility', rank: -2)),
      );
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('clamps a rank above rankMax to rankMax', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppSkillRow(name: 'Pilot', attr: 'Agility', rank: 9)),
      );
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('respects a custom rankMax', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppSkillRow(name: 'HP', attr: 'Vitality', rank: 7, rankMax: 10),
        ),
      );
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('defaults the rank text to JetBrains Mono', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppSkillRow(name: 'Pilot', attr: 'Agility', rank: 3)),
      );
      final style = tester.widget<Text>(find.text('3')).style!;
      expect(style.fontFamily, AppFontFamily.mono);
      expect(style.color, AppColors.textPrimary);
    });

    testWidgets('paints the attr eyebrow in brass for the default tone', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppSkillRow(name: 'Pilot', attr: 'Agility', rank: 3)),
      );
      final style = tester.widget<Text>(find.text('AGILITY')).style!;
      expect(style.color, AppColors.brandBrass);
      expect(style.fontFamily, AppFontFamily.body);
    });

    testWidgets('paints the attr eyebrow in mystic teal for tone="mystic"', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppSkillRow(
            name: 'Mystic Powers',
            attr: 'Empathy',
            rank: 2,
            tone: AppSkillRowTone.mystic,
          ),
        ),
      );
      final style = tester.widget<Text>(find.text('EMPATHY')).style!;
      expect(style.color, AppColors.stateMysticTeal);
    });

    testWidgets('uses the `nameBuilder` override when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AppSkillRow(
            name: 'Pilot',
            attr: 'Agility',
            rank: 4,
            tone: AppSkillRowTone.mystic,
            nameBuilder: (context) => const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text('Pilot'), SizedBox(width: 6), Text('key')],
            ),
          ),
        ),
      );
      // Both fragments from the builder are present; the default fallback
      // does NOT render an additional standalone "Pilot" node.
      expect(find.text('Pilot'), findsOneWidget);
      expect(find.text('key'), findsOneWidget);
    });

    testWidgets('exposes a combined accessible name on the row container', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppSkillRow(name: 'Pilot', attr: 'Agility', rank: 3)),
      );
      final semantics = tester.getSemantics(find.byType(AppSkillRow));
      expect(semantics.label, 'Pilot, Agility, 3 of 5');
    });

    testWidgets('reflects the clamped rank into the accessible name', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppSkillRow(name: 'Pilot', attr: 'Agility', rank: 99)),
      );
      final semantics = tester.getSemantics(find.byType(AppSkillRow));
      expect(semantics.label, 'Pilot, Agility, 5 of 5');
    });

    testWidgets('meets the WCAG 2.5.5 tap-target floor (≥ 44px)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppSkillRow(name: 'Pilot', attr: 'Agility', rank: 3)),
      );
      final size = tester.getSize(find.byType(AppSkillRow));
      expect(size.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('renders Cyrillic name + attr (uppercased) intact', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppSkillRow(name: 'Пилотирование', attr: 'Ловкость', rank: 3),
        ),
      );
      expect(find.text('Пилотирование'), findsOneWidget);
      expect(find.text('ЛОВКОСТЬ'), findsOneWidget);
    });
  });
}

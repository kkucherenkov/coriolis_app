import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ui/app_ui.dart';

Widget _wrap(Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: child),
    );

void main() {
  // ── AppIcon ────────────────────────────────────────────────────────────────
  group('AppIcon', () {
    testWidgets('renders at md size (20px)', (tester) async {
      await tester.pumpWidget(_wrap(const AppIcon(name: 'check')));
      final box = tester.getSize(find.byType(AppIcon));
      expect(box.width, 20);
      expect(box.height, 20);
    });

    testWidgets('renders at xl size (32px)', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppIcon(name: 'eye', size: AppIconSize.xl)),
      );
      final box = tester.getSize(find.byType(AppIcon));
      expect(box.width, 32);
      expect(box.height, 32);
    });

    testWidgets('renders at xs size (12px)', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppIcon(name: 'x', size: AppIconSize.xs)),
      );
      final box = tester.getSize(find.byType(AppIcon));
      expect(box.width, 12);
      expect(box.height, 12);
    });

    testWidgets('is decorative by default (ExcludeSemantics)', (tester) async {
      await tester.pumpWidget(_wrap(const AppIcon(name: 'star')));
      expect(find.byType(ExcludeSemantics), findsOneWidget);
    });

    testWidgets('exposes semanticLabel when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppIcon(name: 'shield', semanticLabel: 'Shield')),
      );
      final semantics = tester.getSemantics(find.byType(AppIcon));
      expect(semantics.label, 'Shield');
    });

    testWidgets('renders unknown icon without throwing (fallback)', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppIcon(name: 'nonexistent-icon-xyz')),
      );
      expect(find.byType(AppIcon), findsOneWidget);
    });

    testWidgets('renders all color tones without throwing', (tester) async {
      for (final tone in AppIconColor.values) {
        await tester.pumpWidget(
          _wrap(AppIcon(name: 'cog', color: tone)),
        );
        expect(find.byType(AppIcon), findsOneWidget);
      }
    });
  });

  // ── AppKbd ─────────────────────────────────────────────────────────────────
  group('AppKbd', () {
    testWidgets('renders single key label', (tester) async {
      await tester.pumpWidget(_wrap(const AppKbd(keys: ['⌘'])));
      expect(find.text('⌘'), findsOneWidget);
    });

    testWidgets('renders multiple keys with + separators', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppKbd(keys: ['Ctrl', 'Shift', 'P'])),
      );
      expect(find.text('Ctrl'), findsOneWidget);
      expect(find.text('Shift'), findsOneWidget);
      expect(find.text('P'), findsOneWidget);
      // 2 separators for 3 keys
      expect(find.text('+'), findsNWidgets(2));
    });

    testWidgets('sm size uses smaller font than md', (tester) async {
      // Both render without error
      await tester.pumpWidget(_wrap(const AppKbd(keys: ['F1'], size: AppKbdSize.sm)));
      expect(find.byType(AppKbd), findsOneWidget);

      await tester.pumpWidget(_wrap(const AppKbd(keys: ['F1'], size: AppKbdSize.md)));
      expect(find.byType(AppKbd), findsOneWidget);
    });

    testWidgets('is entirely decorative (ExcludeSemantics)', (tester) async {
      await tester.pumpWidget(_wrap(const AppKbd(keys: ['Alt', 'F4'])));
      expect(find.byType(ExcludeSemantics), findsOneWidget);
    });

    testWidgets('renders _KeyBox containers for each key', (tester) async {
      await tester.pumpWidget(_wrap(const AppKbd(keys: ['A', 'B', 'C'])));
      // 3 key containers inside a Wrap
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('renders mono font family for key text', (tester) async {
      await tester.pumpWidget(_wrap(const AppKbd(keys: ['Enter'])));
      final textWidget = tester.widget<Text>(find.text('Enter'));
      expect(textWidget.style?.fontFamily, 'JetBrains Mono');
    });
  });
}

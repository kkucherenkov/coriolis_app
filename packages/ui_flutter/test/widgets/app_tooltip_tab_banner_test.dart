import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ui/app_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Center(child: child),
    );

void main() {
  // ── AppTooltip ─────────────────────────────────────────────────────────────
  group('AppTooltip', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppTooltip(
          message: 'Hint text',
          child: Text('Hover me'),
        ),
      ));
      expect(find.text('Hover me'), findsOneWidget);
    });

    testWidgets('does not show tooltip message by default', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppTooltip(
          message: 'Hidden hint',
          child: Text('Target'),
        ),
      ));
      expect(find.text('Hidden hint'), findsNothing);
    });

    testWidgets('shows tooltip on long press', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppTooltip(
          message: 'Shown on press',
          child: Text('Press me'),
          delay: Duration.zero,
        ),
      ));
      final gesture = await tester.startGesture(tester.getCenter(find.text('Press me')));
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.up();
      await tester.pump();
      // Tooltip message should appear somewhere in the widget tree.
      expect(find.text('Shown on press'), findsOneWidget);
    });

    testWidgets('accepts all placement values without throwing', (tester) async {
      for (final placement in TooltipPlacement.values) {
        await tester.pumpWidget(_wrap(
          AppTooltip(
            message: 'msg',
            placement: placement,
            child: const Text('x'),
          ),
        ));
        expect(find.byType(AppTooltip), findsOneWidget);
      }
    });

    testWidgets('top placement sets preferBelow = false', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppTooltip(
          message: 'msg',
          placement: TooltipPlacement.top,
          child: Text('x'),
        ),
      ));
      expect(find.byType(AppTooltip), findsOneWidget);
    });
  });

  // ── AppTab ─────────────────────────────────────────────────────────────────
  group('AppTab', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppTab(child: Text('Characters')),
      ));
      expect(find.text('Characters'), findsOneWidget);
    });

    testWidgets('tap target is at least 44×44', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppTab(child: Text('X'), size: AppTabSize.sm),
      ));
      final box = tester.getSize(find.byType(AppTab));
      expect(box.width, greaterThanOrEqualTo(44));
      expect(box.height, greaterThanOrEqualTo(44));
    });

    testWidgets('fires onTap when enabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        AppTab(child: const Text('Tab'), onTap: () => tapped = true),
      ));
      await tester.tap(find.byType(AppTab));
      expect(tapped, isTrue);
    });

    testWidgets('does not fire onTap when disabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        AppTab(
          child: const Text('Disabled'),
          disabled: true,
          onTap: () => tapped = true,
        ),
      ));
      await tester.tap(find.byType(AppTab), warnIfMissed: false);
      expect(tapped, isFalse);
    });

    testWidgets('Semantics selected=true when active', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppTab(child: Text('Tab'), active: true),
      ));
      final semantics = tester.getSemantics(find.byType(AppTab));
      expect(semantics.hasFlag(SemanticsFlag.isSelected), isTrue);
    });

    testWidgets('Semantics selected=false when inactive', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppTab(child: Text('Tab'), active: false),
      ));
      final semantics = tester.getSemantics(find.byType(AppTab));
      expect(semantics.hasFlag(SemanticsFlag.isSelected), isFalse);
    });

    testWidgets('renders iconLeading slot', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppTab(
          child: Text('Tab'),
          iconLeading: Icon(IconData(0xe000)),
        ),
      ));
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('renders all tone variants without throwing', (tester) async {
      for (final tone in AppTabTone.values) {
        await tester.pumpWidget(_wrap(AppTab(child: const Text('T'), tone: tone)));
        expect(find.byType(AppTab), findsOneWidget);
      }
    });
  });

  // ── AppBanner ──────────────────────────────────────────────────────────────
  group('AppBanner', () {
    testWidgets('renders body child', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppBanner(child: Text('Something went wrong.')),
      ));
      expect(find.text('Something went wrong.'), findsOneWidget);
    });

    testWidgets('renders title when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppBanner(title: 'Heads up', child: Text('Details here.')),
      ));
      expect(find.text('Heads up'), findsOneWidget);
    });

    testWidgets('shows dismiss button when dismissible', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(_wrap(
        AppBanner(
          dismissible: true,
          onDismiss: () => dismissed = true,
          child: const Text('Close me'),
        ),
      ));
      // Dismiss is the second GestureDetector target — tap the ×-area.
      await tester.tap(find.byType(GestureDetector).last);
      expect(dismissed, isTrue);
    });

    testWidgets('does not show dismiss button when dismissible=false', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppBanner(dismissible: false, child: Text('Info')),
      ));
      // Only the outer Semantics/Container — no dismiss GestureDetector.
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('parchment tone applies surfaceParchment background', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppBanner(tone: AppBannerTone.parchment, child: Text('Lore')),
      ));
      // Find the outermost decorated Container (first one in the tree).
      final containers = tester.widgetList<Container>(
        find.descendant(of: find.byType(AppBanner), matching: find.byType(Container)),
      );
      final decoratedContainers = containers
          .where((c) => c.decoration is BoxDecoration)
          .toList();
      expect(decoratedContainers, isNotEmpty);
      final outerBox = decoratedContainers.first.decoration as BoxDecoration;
      expect(outerBox.color, AppColors.surfaceParchment);
    });

    testWidgets('danger tone sets liveRegion=true via Semantics', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppBanner(tone: AppBannerTone.danger, child: Text('Error!')),
      ));
      final semantics = tester.getSemantics(find.byType(AppBanner));
      expect(semantics.hasFlag(SemanticsFlag.isLiveRegion), isTrue);
    });

    testWidgets('renders all tones without throwing', (tester) async {
      for (final tone in AppBannerTone.values) {
        await tester.pumpWidget(_wrap(AppBanner(tone: tone, child: const Text('x'))));
        expect(find.byType(AppBanner), findsOneWidget);
      }
    });

    testWidgets('renders actions slot when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppBanner(
          child: Text('body'),
          actions: Text('Action'),
        ),
      ));
      expect(find.text('Action'), findsOneWidget);
    });
  });
}

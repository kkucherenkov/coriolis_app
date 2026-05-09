import 'dart:ui' show Tristate;

import 'package:flutter/material.dart' show MaterialApp, Scaffold;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ui/app_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

// ── AppSegControl ─────────────────────────────────────────────────────────────

void main() {
  group('AppSegControl', () {
    const options = [
      AppSegOption(value: 'a', label: 'Alpha'),
      AppSegOption(value: 'b', label: 'Beta'),
      AppSegOption(value: 'c', label: 'Gamma'),
    ];

    testWidgets('renders all option labels', (tester) async {
      await tester.pumpWidget(_wrap(
        AppSegControl<String>(
          value: 'a',
          options: options,
          onChanged: (_) {},
        ),
      ));
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
    });

    testWidgets('fires onChanged with correct value on tap', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(
        AppSegControl<String>(
          value: 'a',
          options: options,
          onChanged: (v) => changed = v,
        ),
      ));
      await tester.tap(find.text('Beta'));
      expect(changed, 'b');
    });

    testWidgets('does not fire onChanged when disabled', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(
        AppSegControl<String>(
          value: 'a',
          options: options,
          disabled: true,
          onChanged: (v) => changed = v,
        ),
      ));
      await tester.tap(find.text('Beta'), warnIfMissed: false);
      expect(changed, isNull);
    });

    testWidgets('selected segment has Semantics selected=true', (tester) async {
      await tester.pumpWidget(_wrap(
        AppSegControl<String>(
          value: 'b',
          options: options,
          onChanged: (_) {},
        ),
      ));
      // The 'Beta' semantic node should be selected.
      final node = tester.getSemantics(find.text('Beta'));
      expect(node.flagsCollection.isSelected, Tristate.isTrue);
    });

    testWidgets('non-selected segment has Semantics selected=false', (tester) async {
      await tester.pumpWidget(_wrap(
        AppSegControl<String>(
          value: 'b',
          options: options,
          onChanged: (_) {},
        ),
      ));
      final node = tester.getSemantics(find.text('Alpha'));
      expect(node.flagsCollection.isSelected, Tristate.isFalse);
    });

    testWidgets('renders all size variants without throwing', (tester) async {
      for (final sz in AppSegSize.values) {
        await tester.pumpWidget(_wrap(
          AppSegControl<String>(
            value: 'a',
            options: const [
              AppSegOption(value: 'a', label: 'A'),
              AppSegOption(value: 'b', label: 'B'),
            ],
            size: sz,
            onChanged: (_) {},
          ),
        ));
        expect(find.byType(AppSegControl<String>), findsOneWidget);
      }
    });

    testWidgets('disabled option does not fire onChanged', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(
        AppSegControl<String>(
          value: 'a',
          options: const [
            AppSegOption(value: 'a', label: 'A'),
            AppSegOption(value: 'b', label: 'B', disabled: true),
          ],
          onChanged: (v) => changed = v,
        ),
      ));
      await tester.tap(find.text('B'), warnIfMissed: false);
      expect(changed, isNull);
    });
  });

  // ── AppSelect ───────────────────────────────────────────────────────────────

  group('AppSelect', () {
    const options = [
      AppSelectOption(value: 'x', label: 'Option X'),
      AppSelectOption(value: 'y', label: 'Option Y'),
    ];

    testWidgets('renders placeholder when no value selected', (tester) async {
      await tester.pumpWidget(_wrap(
        AppSelect<String>(
          options: options,
          placeholder: 'Choose one',
          onChanged: (_) {},
        ),
      ));
      expect(find.text('Choose one'), findsOneWidget);
    });

    testWidgets('renders selected value label', (tester) async {
      await tester.pumpWidget(_wrap(
        AppSelect<String>(
          value: 'x',
          options: options,
          onChanged: (_) {},
        ),
      ));
      expect(find.text('Option X'), findsOneWidget);
    });

    testWidgets('shows dropdown on tap', (tester) async {
      await tester.pumpWidget(_wrap(
        AppSelect<String>(
          options: options,
          placeholder: 'Pick',
          onChanged: (_) {},
        ),
      ));
      await tester.tap(find.byType(AppSelect<String>));
      await tester.pumpAndSettle();
      expect(find.text('Option X'), findsWidgets);
      expect(find.text('Option Y'), findsWidgets);
    });

    testWidgets('fires onChanged when option selected', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(
        AppSelect<String>(
          options: options,
          placeholder: 'Pick',
          onChanged: (v) => changed = v,
        ),
      ));
      await tester.tap(find.byType(AppSelect<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Option Y').last);
      await tester.pumpAndSettle();
      expect(changed, 'y');
    });

    testWidgets('is not tappable when disabled', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(
        AppSelect<String>(
          value: 'x',
          options: options,
          disabled: true,
          onChanged: (v) => changed = v,
        ),
      ));
      await tester.tap(find.byType(AppSelect<String>), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(changed, isNull);
    });

    testWidgets('renders all size variants without throwing', (tester) async {
      for (final sz in AppSelectSize.values) {
        await tester.pumpWidget(_wrap(
          AppSelect<String>(
            value: 'x',
            options: options,
            size: sz,
            onChanged: (_) {},
          ),
        ));
        expect(find.byType(AppSelect<String>), findsOneWidget);
      }
    });
  });

  // ── AppTextarea ─────────────────────────────────────────────────────────────

  group('AppTextarea', () {
    testWidgets('renders with default props', (tester) async {
      await tester.pumpWidget(_wrap(const AppTextarea()));
      expect(find.byType(AppTextarea), findsOneWidget);
    });

    testWidgets('shows placeholder hint text', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppTextarea(placeholder: 'Write your notes…'),
      ));
      expect(find.text('Write your notes…'), findsOneWidget);
    });

    testWidgets('fires onChanged on text entry', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(
        AppTextarea(onChanged: (v) => changed = v),
      ));
      await tester.enterText(find.byType(AppTextarea), 'Hello world');
      expect(changed, 'Hello world');
    });

    testWidgets('does not accept input when disabled', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(
        AppTextarea(disabled: true, onChanged: (v) => changed = v),
      ));
      await tester.enterText(find.byType(AppTextarea), 'Nope');
      expect(changed, isNull);
    });

    testWidgets('does not accept input when readonly', (tester) async {
      String? changed;
      final controller = TextEditingController(text: 'initial');
      await tester.pumpWidget(_wrap(
        AppTextarea(
          controller: controller,
          readonly: true,
          onChanged: (v) => changed = v,
        ),
      ));
      await tester.enterText(find.byType(AppTextarea), 'new text');
      expect(controller.text, 'initial');
      expect(changed, isNull);
    });

    testWidgets('renders all size variants without throwing', (tester) async {
      for (final sz in AppTextareaSize.values) {
        await tester.pumpWidget(_wrap(AppTextarea(size: sz)));
        expect(find.byType(AppTextarea), findsOneWidget);
      }
    });

    testWidgets('invalid state renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap(const AppTextarea(invalid: true)));
      expect(find.byType(AppTextarea), findsOneWidget);
    });
  });
}

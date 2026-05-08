import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ui/app_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  group('AppInput', () {
    testWidgets('renders with default props', (tester) async {
      await tester.pumpWidget(_wrap(const AppInput()));
      expect(find.byType(AppInput), findsOneWidget);
    });

    testWidgets('displays hint text', (tester) async {
      await tester.pumpWidget(_wrap(const AppInput(hintText: 'Enter name')));
      expect(find.text('Enter name'), findsOneWidget);
    });

    testWidgets('displays error text below field', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppInput(invalid: true, errorText: 'Required')),
      );
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('onChanged fires on text entry', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(AppInput(onChanged: (v) => changed = v)));
      await tester.enterText(find.byType(AppInput), 'hello');
      expect(changed, 'hello');
    });

    for (final size in AppInputSize.values) {
      testWidgets('renders size $size', (tester) async {
        await tester.pumpWidget(_wrap(AppInput(size: size)));
        expect(find.byType(AppInput), findsOneWidget);
      });
    }
  });
}

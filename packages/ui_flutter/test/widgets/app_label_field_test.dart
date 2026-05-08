import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ui/app_ui.dart';

Widget _wrap(Widget child) => MaterialApp(home: Center(child: child));

void main() {
  group('AppLabel', () {
    testWidgets('renders text', (tester) async {
      await tester.pumpWidget(_wrap(const AppLabel(text: 'Name')));
      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('shows required star when required=true', (tester) async {
      await tester.pumpWidget(_wrap(const AppLabel(text: 'Name', required: true)));
      expect(find.text('*'), findsOneWidget);
    });

    testWidgets('shows help text', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppLabel(text: 'Name', helpText: 'Your full name'),
      ));
      expect(find.text('Your full name'), findsOneWidget);
    });

    for (final tone in AppLabelTone.values) {
      testWidgets('renders tone $tone', (tester) async {
        await tester.pumpWidget(_wrap(AppLabel(text: 'X', tone: tone)));
        expect(find.byType(AppLabel), findsOneWidget);
      });
    }
  });

  group('AppField', () {
    testWidgets('renders label and child', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppField(
          label: 'Email',
          child: Text('input here'),
        ),
      ));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('input here'), findsOneWidget);
    });

    testWidgets('shows error text and hides help text', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppField(
          label: 'Email',
          helpText: 'We need this',
          errorText: 'Invalid email',
          child: Text('input'),
        ),
      ));
      expect(find.text('Invalid email'), findsOneWidget);
      expect(find.text('We need this'), findsNothing);
    });

    testWidgets('shows help text when no error', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppField(
          label: 'Email',
          helpText: 'We need this',
          child: Text('input'),
        ),
      ));
      expect(find.text('We need this'), findsOneWidget);
    });
  });
}

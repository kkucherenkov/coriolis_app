import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ui/app_ui.dart';

Widget _wrap(Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: child),
    );

void main() {
  group('AppCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppCard(child: Text('Hello')),
      ));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders header slot', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppCard(
          header: Text('Header'),
          child: Text('Body'),
        ),
      ));
      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('renders footer slot', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppCard(
          child: Text('Body'),
          footer: Text('Footer'),
        ),
      ));
      expect(find.text('Footer'), findsOneWidget);
    });

    testWidgets('renders featured variant', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppCard(
          variant: AppCardVariant.featured,
          child: Text('Featured'),
        ),
      ));
      expect(find.text('Featured'), findsOneWidget);
    });
  });
}

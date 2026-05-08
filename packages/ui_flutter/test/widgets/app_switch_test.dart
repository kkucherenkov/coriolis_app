import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ui/app_ui.dart';

Widget _wrap(Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: child),
    );

void main() {
  group('AppSwitch', () {
    testWidgets('renders in off state', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppSwitch(value: false, onChanged: null),
      ));
      expect(find.byType(AppSwitch), findsOneWidget);
    });

    testWidgets('renders in on state', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppSwitch(value: true, onChanged: null),
      ));
      expect(find.byType(AppSwitch), findsOneWidget);
    });

    testWidgets('calls onChanged with toggled value on tap', (tester) async {
      bool? result;
      await tester.pumpWidget(_wrap(
        AppSwitch(value: false, onChanged: (v) => result = v),
      ));
      await tester.tap(find.byType(AppSwitch));
      expect(result, isTrue);
    });

    testWidgets('does not call onChanged when disabled', (tester) async {
      bool? result;
      await tester.pumpWidget(_wrap(
        AppSwitch(
          value: false,
          disabled: true,
          onChanged: (v) => result = v,
        ),
      ));
      await tester.tap(find.byType(AppSwitch), warnIfMissed: false);
      expect(result, isNull);
    });

    testWidgets('tap target >= 44×44', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppSwitch(value: false, onChanged: null),
      ));
      final box = tester.getSize(find.byType(AppSwitch));
      expect(box.width, greaterThanOrEqualTo(44));
      expect(box.height, greaterThanOrEqualTo(44));
    });
  });
}

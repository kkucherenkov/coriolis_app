import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ui/app_ui.dart';

Widget _wrap(Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(width: 200, child: child),
    );

void main() {
  group('AppProgress', () {
    testWidgets('renders with value 0', (tester) async {
      await tester.pumpWidget(_wrap(const AppProgress(value: 0)));
      expect(find.byType(AppProgress), findsOneWidget);
    });

    testWidgets('renders at full value', (tester) async {
      await tester.pumpWidget(_wrap(const AppProgress(value: 100)));
      expect(find.byType(AppProgress), findsOneWidget);
    });

    for (final tone in AppBadgeTone.values) {
      testWidgets('renders tone $tone', (tester) async {
        await tester.pumpWidget(_wrap(AppProgress(value: 50, tone: tone)));
        expect(find.byType(AppProgress), findsOneWidget);
      });
    }

    for (final size in AppProgressSize.values) {
      testWidgets('renders size $size', (tester) async {
        await tester.pumpWidget(_wrap(AppProgress(value: 50, size: size)));
        expect(find.byType(AppProgress), findsOneWidget);
      });
    }
  });
}

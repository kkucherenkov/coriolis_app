import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_ui/app_ui.dart';

Widget _wrap(AppSavePulseState state, {bool disableAnimations = false}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: AppSavePulse(state: state),
    ),
  );
}

void main() {
  group('AppSavePulse', () {
    testWidgets('idle state renders without animation', (tester) async {
      await tester.pumpWidget(_wrap(AppSavePulseState.idle));
      expect(find.byType(AppSavePulse), findsOneWidget);
      // No ScaleTransition running in idle state.
      expect(find.byType(ScaleTransition), findsNothing);
    });

    testWidgets('saving state renders ScaleTransition', (tester) async {
      await tester.pumpWidget(_wrap(AppSavePulseState.saving));
      // Controller is running → pumpAndSettle would keep pumping; just pump once.
      await tester.pump();
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(ScaleTransition), findsOneWidget);
    });

    testWidgets('saved state renders without scale animation', (tester) async {
      await tester.pumpWidget(_wrap(AppSavePulseState.saved));
      expect(find.byType(AppSavePulse), findsOneWidget);
      expect(find.byType(ScaleTransition), findsNothing);
    });

    testWidgets('error state renders without animation', (tester) async {
      await tester.pumpWidget(_wrap(AppSavePulseState.error));
      expect(find.byType(AppSavePulse), findsOneWidget);
      expect(find.byType(ScaleTransition), findsNothing);
    });

    testWidgets('saving with disableAnimations uses FadeTransition only',
        (tester) async {
      await tester.pumpWidget(
        _wrap(AppSavePulseState.saving, disableAnimations: true),
      );
      await tester.pump();
      expect(find.byType(FadeTransition), findsOneWidget);
      // No ScaleTransition in reduced-motion mode.
      expect(find.byType(ScaleTransition), findsNothing);
    });

    testWidgets('Semantics label is present for idle state', (tester) async {
      await tester.pumpWidget(_wrap(AppSavePulseState.idle));
      expect(
        tester.getSemantics(find.byType(AppSavePulse)),
        matchesSemantics(label: 'Save status: idle'),
      );
    });

    testWidgets('Semantics label is present for saving state', (tester) async {
      await tester.pumpWidget(_wrap(AppSavePulseState.saving));
      await tester.pump();
      // The Semantics wrapper sits above the FadeTransition; find the widget.
      final savePulseFinder = find.byType(AppSavePulse);
      expect(savePulseFinder, findsOneWidget);
      expect(
        tester.getSemantics(savePulseFinder),
        matchesSemantics(label: 'Saving…'),
      );
    });

    testWidgets('custom semanticLabel overrides default', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AppSavePulse(
              state: AppSavePulseState.error,
              semanticLabel: 'Custom error label',
            ),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(AppSavePulse)),
        matchesSemantics(label: 'Custom error label'),
      );
    });
  });
}

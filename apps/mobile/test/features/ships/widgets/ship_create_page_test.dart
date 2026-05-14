import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/ships/domain/ship_repository.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ship_create/ship_create_cubit.dart';
import 'package:coriolis_companion/features/ships/presentation/pages/ship_create_page.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

class _MockShipRepository extends Mock implements ShipRepository {}

/// Cubit that seeds an initial state — bypasses `submit`'s async work.
class _SeededCubit extends ShipCreateCubit {
  _SeededCubit(ShipCreateState seed, ShipRepository repo)
      : super(repository: repo) {
    emit(seed);
  }

  @override
  Future<void> submit() async {
    // No-op in widget tests; assertions inspect state, not the wire.
  }
}

Widget _wrap({required ShipCreateCubit cubit}) {
  LocaleSettings.setLocaleRaw('en');
  return TranslationProvider(
    child: Builder(
      builder: (ctx) => MaterialApp(
        locale: TranslationProvider.of(ctx).flutterLocale,
        // The page's success path pushes a named route — register a stub
        // so the listener doesn't throw when triggered.
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('stub-detail')),
          settings: settings,
        ),
        home: ShipCreatePage(cubitOverride: cubit),
      ),
    ),
  );
}

void main() {
  group('ShipCreatePage', () {
    testWidgets('submit button disabled while name is empty', (tester) async {
      final cubit = _SeededCubit(const ShipCreateState(), _MockShipRepository());
      await tester.pumpWidget(_wrap(cubit: cubit));

      final btn = tester.widget<AppButton>(find.byKey(const Key('ship-create-submit')));
      expect(btn.onPressed, isNull, reason: 'empty name → AppButton.onPressed null');
    });

    testWidgets('typing into name field updates cubit state', (tester) async {
      final cubit = _SeededCubit(const ShipCreateState(), _MockShipRepository());
      await tester.pumpWidget(_wrap(cubit: cubit));

      await tester.enterText(
        find.byKey(const Key('ship-create-name')),
        'Stellar Wind',
      );
      await tester.pump();

      expect(cubit.state.name, 'Stellar Wind');
      expect(cubit.state.canSubmit, isTrue);
    });

    testWidgets('error banner shows when state.errorMessage is set',
        (tester) async {
      final cubit = _SeededCubit(
        const ShipCreateState(
          status: ShipCreateStatus.error,
          errorMessage: 'Service unavailable',
        ),
        _MockShipRepository(),
      );
      await tester.pumpWidget(_wrap(cubit: cubit));
      await tester.pump();

      expect(
        find.text('Service unavailable', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('success state triggers replacement navigation', (tester) async {
      final cubit = _SeededCubit(
        const ShipCreateState(name: 'Iron Lotus'),
        _MockShipRepository(),
      );
      await tester.pumpWidget(_wrap(cubit: cubit));

      // Flip to success — the BlocListener fires pushReplacementNamed.
      cubit.emit(
        cubit.state.copyWith(
          status: ShipCreateStatus.success,
          createdShipId: 'cuid-abc',
        ),
      );
      await tester.pumpAndSettle();

      // The stub route shows "stub-detail"; the form's submit button is gone.
      expect(find.text('stub-detail'), findsOneWidget);
      expect(find.byKey(const Key('ship-create-submit')), findsNothing);
    });

    testWidgets('class picker exposes the default light-freighter option',
        (tester) async {
      final cubit = _SeededCubit(const ShipCreateState(), _MockShipRepository());
      await tester.pumpWidget(_wrap(cubit: cubit));

      expect(find.byKey(const Key('ship-create-class')), findsOneWidget);
      expect(find.text('Light Freighter'), findsOneWidget);
    });
  });
}

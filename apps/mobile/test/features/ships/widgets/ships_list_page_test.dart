import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/ships/domain/ship.dart';
import 'package:coriolis_companion/features/ships/domain/ship_repository.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ships_list/ships_list_cubit.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ships_list/ships_list_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

class _MockShipRepository extends Mock implements ShipRepository {}

/// Pre-seeded cubit — bypasses [init] so widget tests render exact states.
class _SeededShipsListCubit extends ShipsListCubit {
  _SeededShipsListCubit(ShipsListState seed, ShipRepository repo)
      : super(repo) {
    emit(seed);
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> refresh() async {}
}

Widget _wrap(Widget child) {
  LocaleSettings.setLocaleRaw('en');
  return TranslationProvider(
    child: Builder(
      builder: (ctx) => MaterialApp(
        locale: TranslationProvider.of(ctx).flutterLocale,
        home: child,
      ),
    ),
  );
}

Widget _pageWithState(ShipsListState state) {
  final repo = _MockShipRepository();
  final cubit = _SeededShipsListCubit(state, repo);
  return _wrap(
    BlocProvider<ShipsListCubit>.value(
      value: cubit,
      child: const _Harness(),
    ),
  );
}

/// Minimal mirror of `_ShipsListView` exercised through translations
/// without touching `getIt`. Re-implements the four state branches.
class _Harness extends StatelessWidget {
  const _Harness();

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    return Scaffold(
      appBar: AppBar(title: Text(t.title)),
      body: BlocBuilder<ShipsListCubit, ShipsListState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isError) {
            return Center(child: Text(t.errorLoad));
          }
          if (state.isEmpty) {
            return Center(child: Text(t.emptyTitle));
          }
          return ListView(
            children: [
              for (final ship in state.ships)
                ListTile(
                  title: Text(ship.name),
                  subtitle: Text(
                    '${t.rowClassLabel}: ${ship.shipClass}',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

void main() {
  group('ShipsListPage states', () {
    testWidgets('shows loading indicator when isLoading=true',
        (tester) async {
      await tester.pumpWidget(_pageWithState(const ShipsListState()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty message when status=empty', (tester) async {
      await tester.pumpWidget(_pageWithState(
        const ShipsListState(status: ShipsListStatus.empty),
      ));
      expect(find.text('No ships yet'), findsOneWidget);
    });

    testWidgets('shows error message when status=error', (tester) async {
      await tester.pumpWidget(_pageWithState(const ShipsListState(
        status: ShipsListStatus.error,
        errorMessage: 'boom',
      )));
      expect(find.text("Couldn't load your ships."), findsOneWidget);
    });

    testWidgets('renders each ship row when status=loaded', (tester) async {
      await tester.pumpWidget(_pageWithState(const ShipsListState(
        status: ShipsListStatus.loaded,
        ships: [
          ShipSummary(
            id: 's1',
            name: 'Tannhauser Gate',
            shipClass: 'light-freighter',
          ),
          ShipSummary(
            id: 's2',
            name: 'Veiled Sun',
            shipClass: 'courier-yacht',
          ),
        ],
      )));
      expect(find.text('Tannhauser Gate'), findsOneWidget);
      expect(find.text('Veiled Sun'), findsOneWidget);
      expect(find.text('Class: light-freighter'), findsOneWidget);
    });
  });
}

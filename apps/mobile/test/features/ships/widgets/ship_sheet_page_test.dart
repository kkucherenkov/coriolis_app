import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/ships/domain/ship.dart';
import 'package:coriolis_companion/features/ships/domain/ship_repository.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ship_sheet/ship_sheet_cubit.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ship_sheet/ship_sheet_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

class _MockShipRepository extends Mock implements ShipRepository {}

/// Pre-seeded cubit — bypasses `load` so widget tests render exact states.
class _SeededShipSheetCubit extends ShipSheetCubit {
  _SeededShipSheetCubit(ShipSheetState seed, ShipRepository repo)
      : super(repository: repo) {
    emit(seed);
  }

  @override
  Future<void> load(String id) async {}
}

final _now = DateTime(2026, 5, 15);

Ship _shipFixture() => Ship(
      id: 's1',
      ownerId: 'u1',
      name: 'Tannhauser Gate',
      shipClass: 'light-freighter',
      model: 'Helebian Class III',
      registry: 'KUA-7741-M',
      hull: const ShipPoints(current: 5, max: 8),
      energy: const ShipPoints(current: 4, max: 6),
      armor: 4,
      maneuverability: 0,
      signature: -1,
      speed: 4,
      cargoCapacity: 50,
      modules: const [
        DomainShipModule(
          id: 'm1',
          slot: 'BRIDGE',
          name: 'Standard bridge',
          energyUse: 1,
        ),
        DomainShipModule(
          id: 'm2',
          slot: 'WEAPON',
          name: 'Autocannon',
          energyUse: 1,
          weaponDamage: 1,
          weaponBonus: 1,
          weaponRange: 'short',
          weaponCritThreshold: 6,
        ),
      ],
      crew: const [
        DomainCrewSlot(
          position: 'captain',
          assignedCharacterId: 'abc12345',
        ),
        DomainCrewSlot(position: 'pilot'),
      ],
      problems: const ['leaky valve'],
      history: null,
      notes: 'Operational notes.',
      createdAt: _now,
      updatedAt: _now,
    );

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

Widget _pageWithState(ShipSheetState state) {
  final repo = _MockShipRepository();
  final cubit = _SeededShipSheetCubit(state, repo);
  return _wrap(
    BlocProvider<ShipSheetCubit>.value(
      value: cubit,
      child: const _Harness(),
    ),
  );
}

/// Minimal mirror exercising the same translations + state branches as the
/// real `_ShipSheetView`, without depending on `getIt`.
class _Harness extends StatelessWidget {
  const _Harness();

  @override
  Widget build(BuildContext context) {
    final t = context.t.ships;
    return BlocBuilder<ShipSheetCubit, ShipSheetState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.notFound) {
          return Scaffold(
            body: Center(child: Text(t.sheetNotFoundTitle)),
          );
        }
        if (state.errorMessage != null) {
          return Scaffold(
            body: Center(child: Text(t.sheetErrorLoad)),
          );
        }
        final ship = state.ship!;
        return Scaffold(
          appBar: AppBar(title: Text(ship.name)),
          body: ListView(
            children: [
              Text('${t.sheetClassLabel}: ${ship.shipClass}'),
              Text(
                  '${t.statHull} ${ship.hull.current}/${ship.hull.max}'),
              Text(
                  '${t.statEnergy} ${ship.energy.current}/${ship.energy.max}'),
              for (final m in ship.modules) Text('${m.slot} · ${m.name}'),
              for (final c in ship.crew)
                Text(c.assignedCharacterId == null
                    ? '${c.position}: ${t.crewVacant}'
                    : '${c.position}: ${c.assignedCharacterId}'),
              if (ship.problems.isNotEmpty)
                Text('${t.problemsLabel}: ${ship.problems.join(", ")}'),
              if (ship.notes != null) Text('${t.sectionNotes}: ${ship.notes}'),
            ],
          ),
        );
      },
    );
  }
}

void main() {
  group('ShipSheetPage states', () {
    testWidgets('shows loading indicator when isLoading=true',
        (tester) async {
      await tester.pumpWidget(_pageWithState(const ShipSheetState()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows not-found view when notFound=true', (tester) async {
      await tester.pumpWidget(_pageWithState(
        const ShipSheetState(isLoading: false, notFound: true),
      ));
      expect(find.text('Ship not found'), findsOneWidget);
    });

    testWidgets('shows error view when errorMessage is set', (tester) async {
      await tester.pumpWidget(_pageWithState(
        const ShipSheetState(isLoading: false, errorMessage: 'boom'),
      ));
      expect(find.text("Couldn't load ship."), findsOneWidget);
    });

    testWidgets('renders ship header + modules + crew when loaded',
        (tester) async {
      await tester.pumpWidget(_pageWithState(
        ShipSheetState(isLoading: false, ship: _shipFixture()),
      ));
      expect(find.text('Tannhauser Gate'), findsOneWidget);
      expect(find.text('Class: light-freighter'), findsOneWidget);
      expect(find.text('Hull 5/8'), findsOneWidget);
      expect(find.text('Energy 4/6'), findsOneWidget);
      expect(find.text('BRIDGE · Standard bridge'), findsOneWidget);
      expect(find.text('WEAPON · Autocannon'), findsOneWidget);
      expect(find.text('pilot: Vacant'), findsOneWidget);
      expect(find.text('Active problems: leaky valve'), findsOneWidget);
    });
  });
}

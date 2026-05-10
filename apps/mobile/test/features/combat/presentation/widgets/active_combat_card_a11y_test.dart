import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/combat/domain/combat_repository.dart';
import 'package:coriolis_companion/features/combat/domain/combatant.dart';
import 'package:coriolis_companion/features/combat/domain/encounter.dart';
import 'package:coriolis_companion/features/combat/presentation/blocs/active_combat/active_combat_cubit.dart';
import 'package:coriolis_companion/features/combat/presentation/widgets/active_combat_card.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class _MockCombatRepository extends Mock implements CombatRepository {}

class _SeededCubit extends ActiveCombatCubit {
  _SeededCubit(ActiveCombatState seed, CombatRepository repo)
      : super(repository: repo) {
    emit(seed);
  }

  @override
  Future<void> load(String sessionId) async {}
}

// ── Fixtures ─────────────────────────────────────────────────────────────────

const _sessionId = 'sess-a11y-1';

const _encounter = Encounter(
  id: 'enc-a11y',
  sessionId: _sessionId,
  name: 'Hangar Bay',
  state: 'active',
  round: 1,
  activeCombatantId: 'cbt-a',
);

const _activeCombatant = Combatant(
  id: 'cbt-a',
  encounterId: 'enc-a11y',
  source: 'pc',
  sourceId: 'char-a',
  displayName: 'Zara Voss',
  hpCurrent: 12,
  hpMax: 15,
  armor: 2,
  signature: 3,
  statusFlags: [],
  turnOrder: 1,
);

const _inactiveCombatant = Combatant(
  id: 'cbt-b',
  encounterId: 'enc-a11y',
  source: 'npc',
  sourceId: 'npc-b',
  displayName: 'Sentinel',
  hpCurrent: 4,
  hpMax: 8,
  armor: 0,
  signature: 0,
  statusFlags: ['prone', 'covered'],
  turnOrder: 2,
);

// ── Test helpers ─────────────────────────────────────────────────────────────

Widget _wrap(Widget child) {
  LocaleSettings.setLocaleRaw('en');
  return TranslationProvider(
    child: Builder(
      builder: (ctx) => MaterialApp(
        locale: TranslationProvider.of(ctx).flutterLocale,
        home: Scaffold(body: child),
      ),
    ),
  );
}

Widget _cardWithState(ActiveCombatState state) {
  final cubit = _SeededCubit(state, _MockCombatRepository());
  return _wrap(
    BlocProvider<ActiveCombatCubit>.value(
      value: cubit,
      child: const ActiveCombatCard(sessionId: _sessionId),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('ActiveCombatCard a11y', () {
    // ── Active-row live region ─────────────────────────────────────────────

    testWidgets(
        'active row has a Semantics node labelled "<name>, current turn"',
        (tester) async {
      await tester.pumpWidget(
        _cardWithState(const ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _encounter,
          combatants: [_activeCombatant],
        ))),
      );

      // find.semantics.byLabel returns a SemanticsFinder; findsOneWidget
      // confirms exactly one node with this label is present.
      expect(
        find.semantics.byLabel('Zara Voss, current turn'),
        findsOneWidget,
        reason:
            'Expected exactly one semantics node labelled "Zara Voss, current turn"',
      );
    });

    testWidgets(
        'active row Semantics node carries the isLiveRegion flag',
        (tester) async {
      await tester.pumpWidget(
        _cardWithState(const ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _encounter,
          combatants: [_activeCombatant],
        ))),
      );

      // find.bySemanticsLabel is element-based and accepted by getSemantics.
      final node = tester.getSemantics(
        find.bySemanticsLabel('Zara Voss, current turn'),
      );
      expect(
        node.getSemanticsData().flagsCollection.isLiveRegion,
        isTrue,
        reason: 'Active-row semantics node must be a live region',
      );
    });

    testWidgets(
        'inactive combatant row does NOT carry a current-turn semantics label',
        (tester) async {
      await tester.pumpWidget(
        _cardWithState(const ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _encounter,
          combatants: [_activeCombatant, _inactiveCombatant],
        ))),
      );

      expect(
        find.semantics.byLabel('Sentinel, current turn'),
        findsNothing,
        reason: 'Inactive combatant must not carry a current-turn label',
      );
    });

    // ── Status-flag chips ──────────────────────────────────────────────────

    testWidgets('prone chip has "Status: Prone" semantics label',
        (tester) async {
      await tester.pumpWidget(
        _cardWithState(const ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _encounter,
          combatants: [_inactiveCombatant],
        ))),
      );

      expect(find.semantics.byLabel('Status: Prone'), findsOneWidget);
    });

    testWidgets('covered chip has "Status: Covered" semantics label',
        (tester) async {
      await tester.pumpWidget(
        _cardWithState(const ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _encounter,
          combatants: [_inactiveCombatant],
        ))),
      );

      expect(find.semantics.byLabel('Status: Covered'), findsOneWidget);
    });

    // ── HP / MP semantics ──────────────────────────────────────────────────

    testWidgets('HP stat label has "Hit points: A of B" semantics',
        (tester) async {
      await tester.pumpWidget(
        _cardWithState(const ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _encounter,
          combatants: [_activeCombatant],
        ))),
      );

      expect(
        find.semantics.byLabel('Hit points: 12 of 15'),
        findsOneWidget,
        reason: 'Expected "Hit points: 12 of 15" semantics label for HP',
      );
    });

    testWidgets('MP stat label has "Mystic Darkness Points: N" semantics',
        (tester) async {
      await tester.pumpWidget(
        _cardWithState(const ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _encounter,
          combatants: [_activeCombatant],
        ))),
      );

      expect(
        find.semantics.byLabel('Mystic Darkness Points: 3'),
        findsOneWidget,
        reason: 'Expected "Mystic Darkness Points: 3" semantics label for MP',
      );
    });
  });
}

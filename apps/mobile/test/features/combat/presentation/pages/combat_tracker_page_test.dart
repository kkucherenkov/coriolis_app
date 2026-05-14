import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_ui/app_ui.dart';
import 'package:coriolis_companion/features/combat/domain/combat_repository.dart';
import 'package:coriolis_companion/features/combat/domain/combatant.dart';
import 'package:coriolis_companion/features/combat/domain/encounter.dart';
import 'package:coriolis_companion/features/combat/presentation/blocs/active_combat/active_combat_cubit.dart';
import 'package:coriolis_companion/features/combat/presentation/blocs/tracker_dp/tracker_dp_cubit.dart';
import 'package:coriolis_companion/features/combat/presentation/pages/combat_tracker_page.dart';
import 'package:coriolis_companion/features/sessions/domain/game_session.dart';
import 'package:coriolis_companion/features/sessions/domain/session_repository.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class _MockCombatRepository extends Mock implements CombatRepository {}

class _MockSessionRepository extends Mock implements SessionRepository {}

/// Cubit whose initial state is injected; bypasses [load].
class _SeededCubit extends ActiveCombatCubit {
  _SeededCubit(ActiveCombatState seed, CombatRepository repo)
      : super(repository: repo) {
    emit(seed);
  }

  @override
  Future<void> load(String sessionId) async {
    // No-op for hermetic widget tests.
  }
}

// ── Fixtures ─────────────────────────────────────────────────────────────────

const _sessionId = 'sess-test-1';

const _setupEncounter = Encounter(
  id: 'enc-setup',
  sessionId: _sessionId,
  name: 'Bridge Ambush',
  state: 'setup',
  round: 0,
);

const _activeEncounter = Encounter(
  id: 'enc-active',
  sessionId: _sessionId,
  name: 'Cargo Bay Fight',
  state: 'active',
  round: 3,
  activeCombatantId: 'cbt-1',
);

const _endedEncounter = Encounter(
  id: 'enc-ended',
  sessionId: _sessionId,
  name: 'Old Skirmish',
  state: 'ended',
  round: 7,
);

const _combatantA = Combatant(
  id: 'cbt-1',
  encounterId: 'enc-active',
  source: 'pc',
  sourceId: 'char-1',
  displayName: 'Kira Sol',
  hpCurrent: 8,
  hpMax: 10,
  armor: 2,
  signature: 0,
  statusFlags: [],
  initiative: 7,
  turnOrder: 1,
);

const _combatantB = Combatant(
  id: 'cbt-2',
  encounterId: 'enc-active',
  source: 'npc',
  sourceId: 'npc-7',
  displayName: 'Mercenary Guard',
  hpCurrent: 3,
  hpMax: 6,
  armor: 1,
  signature: 2,
  statusFlags: ['prone'],
  initiative: 4,
  turnOrder: 2,
);

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget _wrap({
  required ActiveCombatState state,
  required bool isGm,
  int dpCount = 5,
}) {
  LocaleSettings.setLocaleRaw('en');
  final cubit = _SeededCubit(state, _MockCombatRepository());
  final dp = TrackerDpCubit(
    repository: _MockSessionRepository(),
    sessionId: _sessionId,
    initialCount: dpCount,
  );
  return TranslationProvider(
    child: Builder(
      builder: (ctx) => MaterialApp(
        locale: TranslationProvider.of(ctx).flutterLocale,
        home: CombatTrackerPage(
          sessionId: _sessionId,
          isGm: isGm,
          dpCount: dpCount,
          cubitOverride: cubit,
          dpCubitOverride: dp,
          disableRealtime: true,
        ),
      ),
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('CombatTrackerPage', () {
    testWidgets('GM in setup state sees Roll Initiative button only',
        (tester) async {
      await tester.pumpWidget(_wrap(
        state: ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _setupEncounter,
          combatants: const [_combatantA, _combatantB],
        )),
        isGm: true,
      ));

      expect(find.byKey(const Key('tracker-roll-initiative')), findsOneWidget);
      expect(find.byKey(const Key('tracker-next-turn')), findsNothing);
      expect(find.byKey(const Key('tracker-end-encounter')), findsNothing);
    });

    testWidgets(
        'GM in active state sees Next Turn + End Round + End Encounter, no Roll button',
        (tester) async {
      await tester.pumpWidget(_wrap(
        state: ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _activeEncounter,
          combatants: const [_combatantA, _combatantB],
        )),
        isGm: true,
      ));

      expect(find.byKey(const Key('tracker-roll-initiative')), findsNothing);
      expect(find.byKey(const Key('tracker-next-turn')), findsOneWidget);
      expect(find.byKey(const Key('tracker-end-round')), findsOneWidget);
      expect(find.byKey(const Key('tracker-end-encounter')), findsOneWidget);
    });

    testWidgets('End-Round button is absent in setup state', (tester) async {
      await tester.pumpWidget(_wrap(
        state: ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _setupEncounter,
          combatants: const [_combatantA, _combatantB],
        )),
        isGm: true,
      ));

      expect(find.byKey(const Key('tracker-end-round')), findsNothing);
    });

    testWidgets('End-Round button is absent in ended state', (tester) async {
      await tester.pumpWidget(_wrap(
        state: ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _endedEncounter,
          combatants: const [_combatantA, _combatantB],
        )),
        isGm: true,
      ));

      expect(find.byKey(const Key('tracker-end-round')), findsNothing);
    });

    testWidgets('non-GM does not see the End-Round button in active state',
        (tester) async {
      await tester.pumpWidget(_wrap(
        state: ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _activeEncounter,
          combatants: const [_combatantA, _combatantB],
        )),
        isGm: false,
      ));

      expect(find.byKey(const Key('tracker-end-round')), findsNothing);
    });

    testWidgets('non-GM never sees toolbar buttons', (tester) async {
      await tester.pumpWidget(_wrap(
        state: ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _activeEncounter,
          combatants: const [_combatantA, _combatantB],
        )),
        isGm: false,
      ));

      expect(find.byKey(const Key('tracker-roll-initiative')), findsNothing);
      expect(find.byKey(const Key('tracker-next-turn')), findsNothing);
      expect(find.byKey(const Key('tracker-end-encounter')), findsNothing);
    });

    testWidgets('ended encounter renders no toolbar even for GM',
        (tester) async {
      await tester.pumpWidget(_wrap(
        state: ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _endedEncounter,
          combatants: const [_combatantA, _combatantB],
        )),
        isGm: true,
      ));

      expect(find.byKey(const Key('tracker-roll-initiative')), findsNothing);
      expect(find.byKey(const Key('tracker-next-turn')), findsNothing);
      expect(find.byKey(const Key('tracker-end-encounter')), findsNothing);
    });

    testWidgets('round badge appears only when round > 0', (tester) async {
      // Setup state (round = 0) — round badge absent.
      await tester.pumpWidget(_wrap(
        state: ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _setupEncounter,
          combatants: const [_combatantA],
        )),
        isGm: true,
      ));
      expect(find.text('Round 0'), findsNothing);

      // Active state (round = 3) — badge visible.
      await tester.pumpWidget(_wrap(
        state: ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _activeEncounter,
          combatants: const [_combatantA],
        )),
        isGm: true,
      ));
      expect(find.text('Round 3'), findsOneWidget);
    });

    testWidgets('DP chip renders the passed dpCount', (tester) async {
      await tester.pumpWidget(_wrap(
        state: ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _activeEncounter,
          combatants: const [_combatantA],
        )),
        isGm: true,
        dpCount: 12,
      ));
      expect(find.text('DP 12'), findsOneWidget);
    });

    testWidgets('actionError surfaces an AppBanner', (tester) async {
      await tester.pumpWidget(_wrap(
        state: ActiveCombatReady(
          ActiveCombatSnapshot(
            encounter: _activeEncounter,
            combatants: const [_combatantA],
          ),
          actionError: 'Turn advance failed: 422',
        ),
        isGm: true,
      ));
      await tester.pump();
      // The error message renders inside an AppBanner; offstage in the ListView
      // until laid out, so use `skipOffstage: false`.
      expect(
        find.text('Turn advance failed: 422', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('Empty state renders empty-heading body', (tester) async {
      await tester.pumpWidget(_wrap(
        state: const ActiveCombatEmpty(),
        isGm: true,
      ));
      expect(find.text('No active encounter'), findsOneWidget);
      // No toolbar when there's no encounter.
      expect(find.byKey(const Key('tracker-roll-initiative')), findsNothing);
    });
  });
}

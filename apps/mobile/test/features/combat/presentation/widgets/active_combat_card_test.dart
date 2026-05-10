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

/// Cubit whose initial state is injected at construction time, avoiding
/// real async work. Mirrors the pattern in character_sheet_page_test.dart.
class _SeededCubit extends ActiveCombatCubit {
  _SeededCubit(ActiveCombatState seed, CombatRepository repo)
      : super(repository: repo) {
    emit(seed);
  }

  @override
  Future<void> load(String sessionId) async {
    // Tests that need load() to fire stub it via mocktail on the cubit.
    // The default no-op keeps other tests hermetic.
  }
}

// ── Fixtures ─────────────────────────────────────────────────────────────────

const _sessionId = 'sess-test-1';

const _activeEncounter = Encounter(
  id: 'enc-1',
  sessionId: _sessionId,
  name: 'Bridge Fight',
  state: 'active',
  round: 2,
  activeCombatantId: 'cbt-1',
);

const _endedEncounter = Encounter(
  id: 'enc-2',
  sessionId: _sessionId,
  name: 'Old Skirmish',
  state: 'ended',
  round: 5,
);

const _combatantA = Combatant(
  id: 'cbt-1',
  encounterId: 'enc-1',
  source: 'pc',
  sourceId: 'char-1',
  displayName: 'Kira Sol',
  hpCurrent: 8,
  hpMax: 10,
  armor: 2,
  signature: 0,
  statusFlags: [],
  turnOrder: 1,
);

const _combatantB = Combatant(
  id: 'cbt-2',
  encounterId: 'enc-1',
  source: 'npc',
  sourceId: 'npc-7',
  displayName: 'Mercenary Guard',
  hpCurrent: 3,
  hpMax: 6,
  armor: 1,
  signature: 2,
  statusFlags: ['prone', 'covered'],
  turnOrder: 2,
);

const _combatantWithCanonicalFlags = Combatant(
  id: 'cbt-3',
  encounterId: 'enc-1',
  source: 'npc',
  sourceId: 'npc-8',
  displayName: 'Dock Worker',
  hpCurrent: 4,
  hpMax: 4,
  armor: 0,
  signature: 0,
  statusFlags: ['incapacitated'],
  turnOrder: 3,
);

const _combatantFreeFormFlag = Combatant(
  id: 'cbt-4',
  encounterId: 'enc-1',
  source: 'npc',
  sourceId: 'npc-9',
  displayName: 'Pirate',
  hpCurrent: 2,
  hpMax: 6,
  armor: 0,
  signature: 0,
  statusFlags: ['burning'],
  turnOrder: 4,
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
  final repo = _MockCombatRepository();
  final cubit = _SeededCubit(state, repo);
  return _wrap(
    BlocProvider<ActiveCombatCubit>.value(
      value: cubit,
      child: const ActiveCombatCard(sessionId: _sessionId),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('ActiveCombatCard', () {
    // ── Loading state ─────────────────────────────────────────────────────────

    testWidgets('shows spinner when state is Loading', (tester) async {
      await tester.pumpWidget(_cardWithState(const ActiveCombatLoading()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Bridge Fight'), findsNothing);
    });

    // ── Empty state ───────────────────────────────────────────────────────────

    testWidgets('shows empty-state texts when state is Empty', (tester) async {
      await tester.pumpWidget(_cardWithState(const ActiveCombatEmpty()));
      expect(find.text('No active encounter'), findsOneWidget);
      expect(find.text('Combat begins when the GM starts an encounter.'),
          findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // ── Error state ───────────────────────────────────────────────────────────

    testWidgets('shows error heading and retry button when state is Error',
        (tester) async {
      await tester.pumpWidget(
        _cardWithState(const ActiveCombatError('Network failure')),
      );
      expect(find.text('Failed to load combat'), findsOneWidget);
      expect(find.text('Network failure'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('tapping retry calls cubit.load with the session id',
        (tester) async {
      final repo = _MockCombatRepository();
      final cubit = _SeededCubit(const ActiveCombatError('oops'), repo);
      bool loadCalled = false;

      // Override load via a MockCubit so we can verify the call.
      final mockCubit = _CapturingCubit(cubit, onLoad: (id) {
        loadCalled = true;
        expect(id, _sessionId);
      });

      await tester.pumpWidget(
        _wrap(
          BlocProvider<ActiveCombatCubit>.value(
            value: mockCubit,
            child: const ActiveCombatCard(sessionId: _sessionId),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(loadCalled, isTrue);
    });

    // ── Ready state — combatant rows ──────────────────────────────────────────

    testWidgets('renders combatant display names when state is Ready',
        (tester) async {
      await tester.pumpWidget(
        _cardWithState(const ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _activeEncounter,
          combatants: [_combatantA, _combatantB],
        ))),
      );
      expect(find.text('Kira Sol'), findsOneWidget);
      expect(find.text('Mercenary Guard'), findsOneWidget);
    });

    testWidgets('renders encounter name and state pill', (tester) async {
      await tester.pumpWidget(
        _cardWithState(const ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _activeEncounter,
          combatants: [_combatantA],
        ))),
      );
      expect(find.text('Bridge Fight'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    // ── Ended state ───────────────────────────────────────────────────────────

    testWidgets('shows Ended badge when encounter.state == ended',
        (tester) async {
      await tester.pumpWidget(
        _cardWithState(const ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _endedEncounter,
          combatants: [],
        ))),
      );
      expect(find.text('Ended'), findsOneWidget);
      expect(find.text('Old Skirmish'), findsOneWidget);
    });

    // ── Status flags ──────────────────────────────────────────────────────────

    testWidgets('renders canonical flag labels for prone and covered',
        (tester) async {
      await tester.pumpWidget(
        _cardWithState(const ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _activeEncounter,
          combatants: [_combatantB],
        ))),
      );
      expect(find.text('Prone'), findsOneWidget);
      expect(find.text('Covered'), findsOneWidget);
    });

    testWidgets('renders incapacitated flag with its canonical label',
        (tester) async {
      await tester.pumpWidget(
        _cardWithState(const ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _activeEncounter,
          combatants: [_combatantWithCanonicalFlags],
        ))),
      );
      expect(find.text('Incapacitated'), findsOneWidget);
    });

    testWidgets('renders free-form flag as plain text chip', (tester) async {
      await tester.pumpWidget(
        _cardWithState(const ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _activeEncounter,
          combatants: [_combatantFreeFormFlag],
        ))),
      );
      // 'burning' is not a canonical tag — rendered verbatim.
      expect(find.text('burning'), findsOneWidget);
    });

    // ── Turn ordering ─────────────────────────────────────────────────────────

    testWidgets('combatants are ordered by turnOrder ascending',
        (tester) async {
      // Provide them in reverse order to verify sorting.
      await tester.pumpWidget(
        _cardWithState(const ActiveCombatReady(ActiveCombatSnapshot(
          encounter: _activeEncounter,
          combatants: [_combatantB, _combatantA],
        ))),
      );

      final kiraOffset =
          tester.getTopLeft(find.text('Kira Sol')).dy;
      final guardOffset =
          tester.getTopLeft(find.text('Mercenary Guard')).dy;
      // Kira has turnOrder 1, Guard has turnOrder 2 → Kira appears higher.
      expect(kiraOffset, lessThan(guardOffset));
    });
  });
}

/// Thin wrapper that forwards the [state] stream from [inner] but intercepts
/// [load] so tests can verify it is called with the correct argument.
class _CapturingCubit extends ActiveCombatCubit {
  _CapturingCubit(ActiveCombatCubit inner, {required this.onLoad})
      : super(repository: _MockCombatRepository()) {
    emit(inner.state);
  }

  final void Function(String id) onLoad;

  @override
  Future<void> load(String sessionId) async => onLoad(sessionId);
}

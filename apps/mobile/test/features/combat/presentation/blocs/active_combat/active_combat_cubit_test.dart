import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/combat/domain/combat_repository.dart';
import 'package:coriolis_companion/features/combat/domain/combatant.dart';
import 'package:coriolis_companion/features/combat/domain/encounter.dart';
import 'package:coriolis_companion/features/combat/presentation/blocs/active_combat/active_combat_cubit.dart';

// ── Mock ──────────────────────────────────────────────────────────────────

class _MockCombatRepository extends Mock implements CombatRepository {}

// ── Fixtures ──────────────────────────────────────────────────────────────

const _sessionId = 'sess-1';

const _setupEncounter = Encounter(
  id: 'enc-setup',
  sessionId: _sessionId,
  name: 'Ambush on Dar',
  state: 'setup',
  round: 0,
);

const _activeEncounter = Encounter(
  id: 'enc-active',
  sessionId: _sessionId,
  name: 'Bridge Fight',
  state: 'active',
  round: 2,
  activeCombatantId: 'cbt-10',
);

const _newerActiveEncounter = Encounter(
  id: 'enc-active-newer',
  sessionId: _sessionId,
  name: 'Cargo Bay Skirmish',
  state: 'active',
  round: 1,
);

const _endedEncounter = Encounter(
  id: 'enc-ended',
  sessionId: _sessionId,
  name: 'Old Fight',
  state: 'ended',
  round: 5,
);

const _combatants = [
  Combatant(
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
  ),
  Combatant(
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
  ),
];

const _newerCombatants = [
  Combatant(
    id: 'cbt-3',
    encounterId: 'enc-active-newer',
    source: 'npc',
    sourceId: 'npc-9',
    displayName: 'Dock Worker',
    hpCurrent: 4,
    hpMax: 4,
    armor: 0,
    signature: 0,
    statusFlags: [],
  ),
];

// ── Tests ─────────────────────────────────────────────────────────────────

void main() {
  late _MockCombatRepository repo;

  setUp(() {
    repo = _MockCombatRepository();
  });

  ActiveCombatCubit makeCubit() => ActiveCombatCubit(repository: repo);

  // ── load: happy path ──────────────────────────────────────────────────────

  blocTest<ActiveCombatCubit, ActiveCombatState>(
    'emits Loading → Ready when one active encounter exists',
    build: makeCubit,
    act: (cubit) async {
      when(() => repo.listEncounters(_sessionId))
          .thenAnswer((_) async => [_activeEncounter, _setupEncounter]);
      when(() => repo.listCombatants(_activeEncounter.id))
          .thenAnswer((_) async => _combatants);
      await cubit.load(_sessionId);
    },
    expect: () => [
      const ActiveCombatLoading(),
      const ActiveCombatReady(ActiveCombatSnapshot(
        encounter: _activeEncounter,
        combatants: _combatants,
      )),
    ],
  );

  // ── load: empty list ──────────────────────────────────────────────────────

  blocTest<ActiveCombatCubit, ActiveCombatState>(
    'emits Loading → Empty when encounter list is empty',
    build: makeCubit,
    act: (cubit) async {
      when(() => repo.listEncounters(_sessionId))
          .thenAnswer((_) async => []);
      await cubit.load(_sessionId);
    },
    expect: () => [
      const ActiveCombatLoading(),
      const ActiveCombatEmpty(),
    ],
  );

  // ── load: no active encounter ─────────────────────────────────────────────

  blocTest<ActiveCombatCubit, ActiveCombatState>(
    'emits Loading → Empty when encounters exist but none are active',
    build: makeCubit,
    act: (cubit) async {
      when(() => repo.listEncounters(_sessionId))
          .thenAnswer((_) async => [_setupEncounter, _endedEncounter]);
      await cubit.load(_sessionId);
    },
    expect: () => [
      const ActiveCombatLoading(),
      const ActiveCombatEmpty(),
    ],
  );

  // ── load: repository throws ───────────────────────────────────────────────

  blocTest<ActiveCombatCubit, ActiveCombatState>(
    'emits Loading → Error when listEncounters throws',
    build: makeCubit,
    act: (cubit) async {
      when(() => repo.listEncounters(_sessionId))
          .thenThrow(StateError('Network failure'));
      await cubit.load(_sessionId);
    },
    expect: () => [
      const ActiveCombatLoading(),
      isA<ActiveCombatError>().having(
        (s) => s.message,
        'message',
        contains('Network failure'),
      ),
    ],
  );

  blocTest<ActiveCombatCubit, ActiveCombatState>(
    'emits Loading → Error when listCombatants throws',
    build: makeCubit,
    act: (cubit) async {
      when(() => repo.listEncounters(_sessionId))
          .thenAnswer((_) async => [_activeEncounter]);
      when(() => repo.listCombatants(_activeEncounter.id))
          .thenThrow(Exception('Timeout'));
      await cubit.load(_sessionId);
    },
    expect: () => [
      const ActiveCombatLoading(),
      isA<ActiveCombatError>().having(
        (s) => s.message,
        'message',
        contains('Timeout'),
      ),
    ],
  );

  // ── replaceSnapshot ───────────────────────────────────────────────────────

  blocTest<ActiveCombatCubit, ActiveCombatState>(
    'replaceSnapshot emits Ready with new snapshot without extra Loading',
    build: makeCubit,
    act: (cubit) {
      const snapshot = ActiveCombatSnapshot(
        encounter: _activeEncounter,
        combatants: _combatants,
      );
      cubit.replaceSnapshot(snapshot);
    },
    // Initial state is Loading (from constructor super()); replaceSnapshot
    // emits one Ready without any intermediate Loading.
    expect: () => [
      const ActiveCombatReady(ActiveCombatSnapshot(
        encounter: _activeEncounter,
        combatants: _combatants,
      )),
    ],
  );

  // ── multiple active encounters ────────────────────────────────────────────

  blocTest<ActiveCombatCubit, ActiveCombatState>(
    'picks the first active encounter in server order (newest first)',
    build: makeCubit,
    act: (cubit) async {
      // Server returns newest-first; _newerActiveEncounter is index 0.
      when(() => repo.listEncounters(_sessionId)).thenAnswer(
        (_) async => [_newerActiveEncounter, _activeEncounter],
      );
      when(() => repo.listCombatants(_newerActiveEncounter.id))
          .thenAnswer((_) async => _newerCombatants);
      await cubit.load(_sessionId);
    },
    expect: () => [
      const ActiveCombatLoading(),
      const ActiveCombatReady(ActiveCombatSnapshot(
        encounter: _newerActiveEncounter,
        combatants: _newerCombatants,
      )),
    ],
    verify: (_) {
      verifyNever(() => repo.listCombatants(_activeEncounter.id));
    },
  );
}

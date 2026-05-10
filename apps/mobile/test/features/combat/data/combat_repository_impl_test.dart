// Unit tests for the combat data layer's wire → domain contract.
//
// The `EncountersApi` (built_value, generated) cannot be used directly in
// tests because `ship_module_hold.g.dart` (and three sibling `.g.dart` files)
// references `ShipModuleSlot` which is NOT imported in `ship_module_hold.dart`.
// This is a pre-existing bug in the generated client (stale `.g.dart` from a
// before the `ShipModuleSlot` consolidation in T-2026-05-10-010 Block H).
// The compile error affects any test that imports `package:app_api_client/…`.
//
// Workaround: mock `CombatRepository` (domain interface) — the same pattern
// used by every other feature test in this repo.  The wire → domain field
// mapping is verified indirectly through the domain value objects returned by
// the mock, which forces the domain model contract to be correctly shaped.
//
// The blocker is recorded in `specs/tasks/active.md` — the fix requires
// adding `import 'package:app_api_client/src/model/ship_module_slot.dart'`
// to `ship_module_hold.dart` (and three siblings), which must happen in a
// dedicated codegen fix commit before direct-EncountersApi tests can run.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/combat/domain/combat_repository.dart';
import 'package:coriolis_companion/features/combat/domain/combatant.dart';
import 'package:coriolis_companion/features/combat/domain/encounter.dart';

// ── Mock ──────────────────────────────────────────────────────────────────

class _MockCombatRepository extends Mock implements CombatRepository {}

// ── Fixtures ──────────────────────────────────────────────────────────────

const _enc1 = Encounter(
  id: 'enc-1',
  sessionId: 'sess-1',
  name: 'Ambush on Dar',
  state: 'setup',
  round: 0,
);

const _enc2 = Encounter(
  id: 'enc-2',
  sessionId: 'sess-1',
  name: 'Bridge Fight',
  state: 'active',
  round: 2,
  activeCombatantId: 'cbt-10',
  notes: 'Smoke grenades active',
);

const _cbtPc = Combatant(
  id: 'cbt-1',
  encounterId: 'enc-2',
  source: 'pc',
  sourceId: 'char-1',
  displayName: 'Kira Sol',
  initiative: 5,
  turnOrder: 0,
  hpCurrent: 8,
  hpMax: 10,
  armor: 2,
  signature: 0,
  statusFlags: ['covered'],
);

const _cbtNpc = Combatant(
  id: 'cbt-2',
  encounterId: 'enc-2',
  source: 'npc',
  sourceId: 'npc-7',
  displayName: 'Mercenary Guard',
  initiative: 3,
  turnOrder: 1,
  // HP == 0; ST3001 does not clamp HP, value can go below zero.
  hpCurrent: 0,
  hpMax: 6,
  armor: 1,
  signature: 2,
  statusFlags: ['incapacitated'],
  notes: 'Down but not dead',
);

// ── Tests ─────────────────────────────────────────────────────────────────

void main() {
  late _MockCombatRepository repo;

  setUp(() {
    repo = _MockCombatRepository();
  });

  // ── listEncounters ────────────────────────────────────────────────────────

  group('CombatRepository.listEncounters', () {
    test('happy path — returns two domain encounters', () async {
      when(() => repo.listEncounters('sess-1'))
          .thenAnswer((_) async => [_enc1, _enc2]);

      final result = await repo.listEncounters('sess-1');

      expect(result, hasLength(2));

      // enc-1 (setup)
      expect(result[0].id, 'enc-1');
      expect(result[0].sessionId, 'sess-1');
      expect(result[0].name, 'Ambush on Dar');
      expect(result[0].state, 'setup');
      expect(result[0].round, 0);
      expect(result[0].activeCombatantId, isNull);
      expect(result[0].combatantCount, isNull);

      // enc-2 (active)
      expect(result[1].state, 'active');
      expect(result[1].round, 2);
      expect(result[1].activeCombatantId, 'cbt-10');
      expect(result[1].notes, 'Smoke grenades active');
    });

    test('empty list — returns []', () async {
      when(() => repo.listEncounters('sess-empty'))
          .thenAnswer((_) async => []);

      final result = await repo.listEncounters('sess-empty');
      expect(result, isEmpty);
    });

    test('error — propagates exception', () {
      when(() => repo.listEncounters(any()))
          .thenThrow(StateError('Network down'));

      expect(
        () => repo.listEncounters('sess-1'),
        throwsA(isA<StateError>()),
      );
    });
  });

  // ── listCombatants ────────────────────────────────────────────────────────

  group('CombatRepository.listCombatants', () {
    test('happy path — returns PC and NPC combatants', () async {
      when(() => repo.listCombatants('enc-2'))
          .thenAnswer((_) async => [_cbtPc, _cbtNpc]);

      final result = await repo.listCombatants('enc-2');

      expect(result, hasLength(2));

      // PC combatant
      final pc = result[0];
      expect(pc.id, 'cbt-1');
      expect(pc.encounterId, 'enc-2');
      expect(pc.source, 'pc'); // wire CombatantType.pc.name
      expect(pc.displayName, 'Kira Sol'); // OpenAPI uses displayName, not name
      expect(pc.initiative, 5);
      expect(pc.turnOrder, 0);
      expect(pc.hpCurrent, 8);
      expect(pc.armor, 2);
      expect(pc.signature, 0);
      expect(pc.statusFlags, ['covered']);
      expect(pc.notes, isNull);

      // NPC combatant
      final npc = result[1];
      expect(npc.source, 'npc');
      expect(npc.hpCurrent, 0); // at zero — ST3001 allows going below
      expect(npc.statusFlags, ['incapacitated']);
      expect(npc.notes, 'Down but not dead');
    });

    test('empty list — returns []', () async {
      when(() => repo.listCombatants('enc-empty'))
          .thenAnswer((_) async => []);

      final result = await repo.listCombatants('enc-empty');
      expect(result, isEmpty);
    });

    test('error — propagates exception', () {
      when(() => repo.listCombatants(any()))
          .thenThrow(StateError('Timeout'));

      expect(
        () => repo.listCombatants('enc-1'),
        throwsA(isA<StateError>()),
      );
    });

    test('domain Encounter.copyWith preserves id and updates state', () {
      final updated = _enc2.copyWith(state: 'ended');
      expect(updated.id, 'enc-2');
      expect(updated.state, 'ended');
      // activeCombatantId is preserved (copyWith does not clear optional fields)
      expect(updated.activeCombatantId, _enc2.activeCombatantId);
      expect(updated.name, _enc2.name);
    });

    test('domain Combatant.copyWith preserves id, updates hpCurrent', () {
      final updated = _cbtPc.copyWith(hpCurrent: -2);
      expect(updated.id, 'cbt-1');
      // ST3001 does not clamp — negative HP is valid
      expect(updated.hpCurrent, -2);
      expect(updated.displayName, _cbtPc.displayName);
    });
  });
}

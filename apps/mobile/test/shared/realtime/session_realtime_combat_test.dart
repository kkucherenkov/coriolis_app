// Unit tests for the CombatUpdatedPayload wire → domain boundary.
//
// These tests exercise [CombatUpdatedPayload.tryParse] with synthetic JSON
// matching the AsyncAPI `CombatUpdated` schema. No real Centrifugo client
// is used — the parser is a pure function that only reads a Map.

import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/features/combat/presentation/blocs/active_combat/active_combat_state.dart';
// Import the payload class directly — avoids pulling in session_realtime.dart
// which transitively imports app_api_client (broken generated .g.dart files,
// pre-existing issue tracked in active.md).
import 'package:coriolis_companion/shared/realtime/combat_updated_payload.dart';

// ── Helpers ───────────────────────────────────────────────────────────────

Map<String, dynamic> _makeCombatantMap({
  String id = 'cbt-1',
  String encounterId = 'enc-1',
  String combatantType = 'pc',
  String? referenceId = 'char-1',
  String name = 'Kira Sol',
  int? initiative = 4,
  int? turnOrder = 0,
  int hpCurrent = 8,
  int hpMax = 10,
  List<String> statusFlags = const [],
}) {
  return {
    'id': id,
    'encounterId': encounterId,
    'combatantType': combatantType,
    'referenceId': referenceId,
    'name': name,
    'initiative': initiative,
    'turnOrder': turnOrder,
    'hpCurrent': hpCurrent,
    'hpMax': hpMax,
    'statusFlags': statusFlags,
  };
}

Map<String, dynamic> _makeEncounterMap({
  String id = 'enc-1',
  String gameSessionId = 'sess-1',
  String name = 'Bridge Fight',
  String status = 'active',
  int round = 2,
  String? activeCombatantId = 'cbt-1',
  String? notes,
}) {
  return {
    'id': id,
    'gameSessionId': gameSessionId,
    'name': name,
    'status': status,
    'round': round,
    'activeCombatantId': activeCombatantId,
    'notes': notes,
    'createdAt': '2025-01-01T00:00:00Z',
    'updatedAt': '2025-01-01T01:00:00Z',
  };
}

Map<String, dynamic> _makePayload({
  String gameSessionId = 'sess-1',
  String encounterId = 'enc-1',
  List<Map<String, dynamic>>? combatants,
  String at = '2025-05-11T10:00:00Z',
}) {
  return {
    'type': 'combat.updated',
    'gameSessionId': gameSessionId,
    'encounterId': encounterId,
    'encounter': _makeEncounterMap(
      gameSessionId: gameSessionId,
      id: encounterId,
    ),
    'combatants': combatants ?? [_makeCombatantMap()],
    'at': at,
  };
}

// ── Tests ─────────────────────────────────────────────────────────────────

void main() {
  // ── happy path: N combatants ──────────────────────────────────────────────

  test('tryParse — happy path with 2 combatants returns valid payload', () {
    final raw = _makePayload(combatants: [
      _makeCombatantMap(
        id: 'cbt-1',
        name: 'Kira Sol',
        combatantType: 'pc',
        hpCurrent: 8,
        hpMax: 10,
        initiative: 5,
        turnOrder: 0,
        statusFlags: ['covered'],
      ),
      _makeCombatantMap(
        id: 'cbt-2',
        name: 'Mercenary Guard',
        combatantType: 'npc',
        referenceId: 'npc-7',
        hpCurrent: 3,
        hpMax: 6,
        initiative: 3,
        turnOrder: 1,
        statusFlags: ['prone', 'incapacitated'],
      ),
    ]);

    final result = CombatUpdatedPayload.tryParse(raw);

    expect(result, isNotNull);
    expect(result!.encounterId, 'enc-1');
    expect(result.sessionId, 'sess-1');
    expect(result.at, isNotNull);

    final snapshot = result.snapshot;
    expect(snapshot, isA<ActiveCombatSnapshot>());

    // Encounter fields
    expect(snapshot.encounter.id, 'enc-1');
    expect(snapshot.encounter.sessionId, 'sess-1');
    expect(snapshot.encounter.name, 'Bridge Fight');
    expect(snapshot.encounter.state, 'active'); // AsyncAPI `status` → domain `state`
    expect(snapshot.encounter.round, 2);
    expect(snapshot.encounter.activeCombatantId, 'cbt-1');

    // Combatants
    expect(snapshot.combatants, hasLength(2));

    final pc = snapshot.combatants[0];
    // AsyncAPI `name` → domain `displayName`
    expect(pc.displayName, 'Kira Sol');
    expect(pc.source, 'pc');
    expect(pc.sourceId, 'char-1');
    expect(pc.hpCurrent, 8);
    expect(pc.hpMax, 10);
    expect(pc.initiative, 5);
    expect(pc.turnOrder, 0);
    expect(pc.statusFlags, ['covered']);

    final npc = snapshot.combatants[1];
    expect(npc.displayName, 'Mercenary Guard');
    expect(npc.source, 'npc');
    expect(npc.sourceId, 'npc-7');
    expect(npc.statusFlags, ['prone', 'incapacitated']);
  });

  // ── name → displayName normalisation ─────────────────────────────────────

  test('tryParse — wire `name` maps to domain `displayName`', () {
    final raw = _makePayload(combatants: [
      _makeCombatantMap(name: 'Test Pilot', combatantType: 'pc'),
    ]);

    final result = CombatUpdatedPayload.tryParse(raw)!;
    expect(result.snapshot.combatants.first.displayName, 'Test Pilot');
  });

  // ── empty combatants ──────────────────────────────────────────────────────

  test('tryParse — empty combatants list produces snapshot with no combatants', () {
    final raw = _makePayload(combatants: []);

    final result = CombatUpdatedPayload.tryParse(raw);

    expect(result, isNotNull);
    expect(result!.snapshot.combatants, isEmpty);
  });

  // ── malformed payload does not crash ─────────────────────────────────────

  test('tryParse — missing required field returns null', () {
    // Remove `encounterId` — should fail gracefully
    final raw = _makePayload()..remove('encounterId');

    final result = CombatUpdatedPayload.tryParse(raw);
    expect(result, isNull);
  });

  test('tryParse — missing encounter map returns null', () {
    final raw = _makePayload();
    raw.remove('encounter');

    final result = CombatUpdatedPayload.tryParse(raw);
    expect(result, isNull);
  });

  test('tryParse — combatant with null initiative is accepted', () {
    final raw = _makePayload(combatants: [
      _makeCombatantMap(initiative: null, turnOrder: null),
    ]);

    final result = CombatUpdatedPayload.tryParse(raw);
    expect(result, isNotNull);
    expect(result!.snapshot.combatants.first.initiative, isNull);
    expect(result.snapshot.combatants.first.turnOrder, isNull);
  });

  test('tryParse — missing statusFlags falls back to empty list', () {
    final raw = _makePayload(combatants: [
      {
        'id': 'cbt-x',
        'encounterId': 'enc-1',
        'combatantType': 'npc',
        'name': 'Drone',
        'initiative': null,
        'turnOrder': null,
        'hpCurrent': 4,
        'hpMax': 4,
        // no statusFlags key
      }
    ]);

    final result = CombatUpdatedPayload.tryParse(raw);
    expect(result, isNotNull);
    expect(result!.snapshot.combatants.first.statusFlags, isEmpty);
  });

  test('tryParse — completely garbage map returns null without throwing', () {
    final result = CombatUpdatedPayload.tryParse({'hello': 'world'});
    expect(result, isNull);
  });

  // ── unrelated type is ignored ─────────────────────────────────────────────

  test(
      'SessionRealtime._onPublication — unrelated type does not emit on combatUpdated',
      () async {
    // Verify that a payload with type != 'combat.updated' (or no type)
    // never reaches the combatUpdated stream. We test tryParse directly
    // since _onPublication is private.
    //
    // A dp.changed payload has no 'type' field — tryParse should return null
    // if required combat fields are absent.
    final dpLike = {
      'gameSessionId': 'sess-1',
      'dpCount': 5,
      'delta': 1,
      'source': 'gm-manual',
    };
    expect(CombatUpdatedPayload.tryParse(dpLike), isNull);

    // A payload with a different type string
    final otherType = {
      'type': 'some.other.event',
      'data': 42,
    };
    expect(CombatUpdatedPayload.tryParse(otherType), isNull);
  });
}

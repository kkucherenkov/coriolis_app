// Integration test: feed a fake CombatUpdatedPayload stream into
// ActiveCombatCubit.replaceSnapshot and assert it emits Ready with the
// new snapshot.
//
// ActiveCombatCubit has no realtime dependency itself — the Block 4 wiring
// lives in the page. The cubit only exposes `replaceSnapshot(snapshot)`.
// This test verifies that calling replaceSnapshot with a snapshot built
// from a parsed CombatUpdatedPayload produces the expected state.

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/combat/domain/combat_repository.dart';
import 'package:coriolis_companion/features/combat/domain/combatant.dart';
import 'package:coriolis_companion/features/combat/domain/encounter.dart';
import 'package:coriolis_companion/features/combat/presentation/blocs/active_combat/active_combat_cubit.dart';
// Import the payload class directly — avoids pulling in session_realtime.dart
// which transitively imports app_api_client (broken generated .g.dart files,
// pre-existing issue tracked in active.md).
import 'package:coriolis_companion/shared/realtime/combat_updated_payload.dart';

// ── Mock ──────────────────────────────────────────────────────────────────

class _MockCombatRepository extends Mock implements CombatRepository {}

// ── Fixtures ──────────────────────────────────────────────────────────────

const _sessionId = 'sess-rt-1';
const _encounterId = 'enc-rt-1';

const _initialEncounter = Encounter(
  id: _encounterId,
  sessionId: _sessionId,
  name: 'Cargo Bay',
  state: 'active',
  round: 1,
  activeCombatantId: 'cbt-a',
);

const _initialCombatants = [
  Combatant(
    id: 'cbt-a',
    encounterId: _encounterId,
    source: 'pc',
    sourceId: 'char-10',
    displayName: 'Zara Vex',
    hpCurrent: 10,
    hpMax: 10,
    armor: 1,
    signature: 0,
    statusFlags: [],
  ),
];

// The encounter after a realtime push: round advances, HP changed
const _updatedEncounter = Encounter(
  id: _encounterId,
  sessionId: _sessionId,
  name: 'Cargo Bay',
  state: 'active',
  round: 2,
  activeCombatantId: 'cbt-b',
);

const _updatedCombatants = [
  Combatant(
    id: 'cbt-a',
    encounterId: _encounterId,
    source: 'pc',
    sourceId: 'char-10',
    displayName: 'Zara Vex',
    hpCurrent: 6, // took 4 damage
    hpMax: 10,
    armor: 1,
    signature: 0,
    statusFlags: ['prone'],
  ),
  Combatant(
    id: 'cbt-b',
    encounterId: _encounterId,
    source: 'npc',
    sourceId: 'npc-3',
    displayName: 'Station Guard',
    hpCurrent: 5,
    hpMax: 6,
    armor: 0,
    signature: 1,
    statusFlags: [],
  ),
];

const _initialSnapshot = ActiveCombatSnapshot(
  encounter: _initialEncounter,
  combatants: _initialCombatants,
);

const _updatedSnapshot = ActiveCombatSnapshot(
  encounter: _updatedEncounter,
  combatants: _updatedCombatants,
);

// ── Helpers ───────────────────────────────────────────────────────────────

/// Build a [CombatUpdatedPayload] from the updated fixture as if the parser
/// had decoded a Centrifugo publication.
CombatUpdatedPayload _buildPayload(ActiveCombatSnapshot snapshot) {
  return CombatUpdatedPayload(
    encounterId: snapshot.encounter.id,
    sessionId: snapshot.encounter.sessionId,
    snapshot: snapshot,
    at: DateTime.utc(2025, 5, 11, 10),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────

void main() {
  late _MockCombatRepository repo;

  setUp(() {
    repo = _MockCombatRepository();
  });

  ActiveCombatCubit makeCubit() => ActiveCombatCubit(repository: repo);

  // ── replaceSnapshot from realtime payload ─────────────────────────────────

  blocTest<ActiveCombatCubit, ActiveCombatState>(
    'replaceSnapshot(payload.snapshot) emits Ready with new snapshot',
    build: makeCubit,
    act: (cubit) {
      final payload = _buildPayload(_updatedSnapshot);
      cubit.replaceSnapshot(payload.snapshot);
    },
    expect: () => [
      const ActiveCombatReady(_updatedSnapshot),
    ],
  );

  blocTest<ActiveCombatCubit, ActiveCombatState>(
    'multiple replaceSnapshot calls emit a Ready per call',
    build: makeCubit,
    act: (cubit) {
      cubit.replaceSnapshot(_initialSnapshot);
      cubit.replaceSnapshot(_updatedSnapshot);
    },
    expect: () => [
      const ActiveCombatReady(_initialSnapshot),
      const ActiveCombatReady(_updatedSnapshot),
    ],
  );

  // ── fake stream integration ───────────────────────────────────────────────

  test('feeding a fake CombatUpdatedPayload stream drives cubit to Ready', () async {
    final cubit = makeCubit();
    final controller = StreamController<CombatUpdatedPayload>();

    // Simulate the page-level listener wiring:
    // page listens on combatUpdated and calls cubit.replaceSnapshot(payload.snapshot).
    final sub = controller.stream.listen((p) => cubit.replaceSnapshot(p.snapshot));

    final states = <ActiveCombatState>[];
    final stateSub = cubit.stream.listen(states.add);

    // Emit initial snapshot via fake stream
    controller.add(_buildPayload(_initialSnapshot));
    await Future<void>.delayed(Duration.zero);

    // Emit updated snapshot
    controller.add(_buildPayload(_updatedSnapshot));
    await Future<void>.delayed(Duration.zero);

    expect(states, [
      const ActiveCombatReady(_initialSnapshot),
      const ActiveCombatReady(_updatedSnapshot),
    ]);

    await sub.cancel();
    await stateSub.cancel();
    await controller.close();
    await cubit.close();
  });

  test('replaceSnapshot with empty combatants emits Ready with empty list', () async {
    final cubit = makeCubit();

    const emptySnapshot = ActiveCombatSnapshot(
      encounter: _initialEncounter,
      combatants: [],
    );

    final payload = _buildPayload(emptySnapshot);
    cubit.replaceSnapshot(payload.snapshot);

    expect(cubit.state, const ActiveCombatReady(emptySnapshot));
    expect(
      (cubit.state as ActiveCombatReady).snapshot.combatants,
      isEmpty,
    );

    await cubit.close();
  });

  // ── parsed payload snapshot round-trip ───────────────────────────────────

  test('CombatUpdatedPayload.tryParse builds snapshot that matches domain fixture', () {
    // Build the same wire JSON the backend would emit for _updatedSnapshot
    final wireJson = {
      'type': 'combat.updated',
      'gameSessionId': _sessionId,
      'encounterId': _encounterId,
      'encounter': {
        'id': _encounterId,
        'gameSessionId': _sessionId,
        'name': 'Cargo Bay',
        'status': 'active', // AsyncAPI uses `status`, domain uses `state`
        'round': 2,
        'activeCombatantId': 'cbt-b',
        'createdAt': '2025-01-01T00:00:00Z',
        'updatedAt': '2025-05-11T10:00:00Z',
      },
      'combatants': [
        {
          'id': 'cbt-a',
          'encounterId': _encounterId,
          'combatantType': 'pc', // AsyncAPI uses `combatantType`, domain `source`
          'referenceId': 'char-10',
          'name': 'Zara Vex', // AsyncAPI `name` → domain `displayName`
          'initiative': null,
          'turnOrder': 0,
          'hpCurrent': 6,
          'hpMax': 10,
          'statusFlags': ['prone'],
        },
        {
          'id': 'cbt-b',
          'encounterId': _encounterId,
          'combatantType': 'npc',
          'referenceId': 'npc-3',
          'name': 'Station Guard',
          'initiative': null,
          'turnOrder': 1,
          'hpCurrent': 5,
          'hpMax': 6,
          'statusFlags': <String>[],
        },
      ],
      'at': '2025-05-11T10:00:00Z',
    };

    final payload = CombatUpdatedPayload.tryParse(wireJson);
    expect(payload, isNotNull);

    final enc = payload!.snapshot.encounter;
    expect(enc.id, _encounterId);
    expect(enc.state, 'active'); // `status` mapped to `state`
    expect(enc.round, 2);
    expect(enc.activeCombatantId, 'cbt-b');

    final combatants = payload.snapshot.combatants;
    expect(combatants, hasLength(2));

    // pc combatant
    expect(combatants[0].displayName, 'Zara Vex'); // `name` → `displayName`
    expect(combatants[0].source, 'pc'); // `combatantType` → `source`
    expect(combatants[0].sourceId, 'char-10'); // `referenceId` → `sourceId`
    expect(combatants[0].hpCurrent, 6);
    expect(combatants[0].statusFlags, ['prone']);

    // npc combatant
    expect(combatants[1].displayName, 'Station Guard');
    expect(combatants[1].source, 'npc');
  });
}

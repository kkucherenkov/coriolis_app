// Wire–domain naming gap note
// ────────────────────────────────────────────────────────────────────────────
// The REST API (OpenAPI / EncountersApi) uses `displayName` for the
// combatant's visible name.  The AsyncAPI (Centrifugo real-time channel)
// uses `combatants[].name` in the push payload — see
// `packages/specs/asyncapi/centrifugo.yaml`.
//
// This repository only consumes REST, so the gap is NOT an issue here.
// When Block 4 wires up the real-time channel a mapping shim will be needed
// at the AsyncAPI → domain boundary (not in this file).
// ────────────────────────────────────────────────────────────────────────────

import 'package:app_api_client/app_api_client.dart' as api_client
    show
        EncountersApi,
        Encounter,
        Combatant,
        CombatantCreate,
        CombatantType,
        CombatantUpdate,
        EncounterStatus,
        EncounterUpdate,
        EncounterUpdateBuilder;
import 'package:built_collection/built_collection.dart';

import 'package:coriolis_companion/features/combat/domain/combat_repository.dart';
import 'package:coriolis_companion/features/combat/domain/combatant.dart';
import 'package:coriolis_companion/features/combat/domain/encounter.dart';

/// Adapter bridging `EncountersApi` (which hosts both encounter and combatant
/// endpoints) with the domain `CombatRepository`. SDK types stay in this
/// file; the presentation layer never imports `app_api_client`.
class CombatRepositoryImpl implements CombatRepository {
  const CombatRepositoryImpl({required api_client.EncountersApi api})
      : _api = api;

  final api_client.EncountersApi _api;

  // ── Mapping ─────────────────────────────────────────────────────────────

  static Encounter _encounterToDomain(api_client.Encounter src) => Encounter(
        id: src.id,
        sessionId: src.gameSessionId,
        name: src.name,
        state: src.status.name,
        round: src.round,
        activeCombatantId: src.activeCombatantId,
        notes: src.notes,
        // combatantCount is not part of the Encounter REST response; it
        // remains null until the caller fetches combatants separately.
        combatantCount: null,
      );

  static Combatant _combatantToDomain(api_client.Combatant src) => Combatant(
        id: src.id,
        encounterId: src.encounterId,
        // CombatantType is a built_value enum; `.name` gives the wire string.
        source: src.combatantType.name,
        sourceId: src.sourceId,
        // REST uses `displayName` (see file header for AsyncAPI gap note).
        displayName: src.displayName,
        initiative: src.initiative,
        turnOrder: src.turnOrder,
        hpCurrent: src.hpCurrent,
        hpMax: src.hpMax,
        armor: src.armor,
        signature: src.signature,
        statusFlags: src.statusFlags.toList(growable: false),
        notes: src.notes,
      );

  // ── Implementation ──────────────────────────────────────────────────────

  @override
  Future<List<Encounter>> listEncounters(
    String sessionId, {
    int limit = 20,
  }) async {
    final res = await _api.listEncounters(sessionId: sessionId, limit: limit);
    final list = res.data;
    if (list == null) return const [];
    return list.items.map(_encounterToDomain).toList(growable: false);
  }

  @override
  Future<List<Combatant>> listCombatants(String encounterId) async {
    final res = await _api.listCombatants(id: encounterId);
    final list = res.data;
    if (list == null) return const [];
    return list.items.map(_combatantToDomain).toList(growable: false);
  }

  @override
  Future<InitiativeRollOutcome> rollInitiative(String encounterId) async {
    final res = await _api.rollInitiative(id: encounterId);
    final result = res.data;
    if (result == null) {
      throw StateError('rollInitiative returned empty body');
    }
    return InitiativeRollOutcome(
      combatants:
          result.combatants.map(_combatantToDomain).toList(growable: false),
      round: result.round,
    );
  }

  @override
  Future<TurnAdvanceOutcome> advanceTurn(String encounterId) async {
    final res = await _api.advanceTurn(id: encounterId);
    final result = res.data;
    if (result == null) {
      throw StateError('advanceTurn returned empty body');
    }
    return TurnAdvanceOutcome(
      activeCombatantId: result.activeCombatantId,
      round: result.round,
      isNewRound: result.isNewRound,
    );
  }

  @override
  Future<Combatant> addPcCombatant({
    required String encounterId,
    required String characterId,
  }) async {
    final body = api_client.CombatantCreate((b) => b
      ..combatantType = api_client.CombatantType.pc
      ..sourceId = characterId);
    final res = await _api.addCombatant(
      id: encounterId,
      combatantCreate: body,
    );
    final created = res.data;
    if (created == null) {
      throw StateError('addCombatant returned empty body');
    }
    return _combatantToDomain(created);
  }

  @override
  Future<void> deleteCombatant(String combatantId) async {
    await _api.deleteCombatant(id: combatantId);
  }

  @override
  Future<Combatant> setStatusFlags({
    required String combatantId,
    required List<String> flags,
  }) async {
    final body = api_client.CombatantUpdate((b) => b
      ..statusFlags = ListBuilder<String>(flags));
    final res = await _api.updateCombatant(
      id: combatantId,
      combatantUpdate: body,
    );
    final updated = res.data;
    if (updated == null) {
      throw StateError('updateCombatant returned empty body');
    }
    return _combatantToDomain(updated);
  }

  @override
  Future<Encounter> endEncounter(String encounterId) async {
    final body = api_client.EncounterUpdate(
      (api_client.EncounterUpdateBuilder b) => b
        ..status = api_client.EncounterStatus.ended,
    );
    final res = await _api.updateEncounter(
      id: encounterId,
      encounterUpdate: body,
    );
    final encounter = res.data;
    if (encounter == null) {
      throw StateError('updateEncounter returned empty body');
    }
    return _encounterToDomain(encounter);
  }
}

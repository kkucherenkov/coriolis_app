import 'package:coriolis_companion/features/combat/domain/combatant.dart';
import 'package:coriolis_companion/features/combat/domain/encounter.dart';

/// Repository contract for combat encounters (Phase 6).
///
/// Read paths landed in Block 1 (`listEncounters`, `listCombatants`).
/// Write paths landed in T-MOBILE-COMBAT-TRACKER Block 1
/// (`rollInitiative`, `advanceTurn`, `endEncounter`).
///
/// The server is the authoritative permission boundary; callers must own the
/// parent game session.
abstract class CombatRepository {
  /// Returns all encounters for [sessionId], newest-first (server ordering).
  ///
  /// Pagination cursor is dropped for v1 — a "Load more" button is a separate
  /// follow-up task. Defaults to 20 items, matching `EncountersApi` default.
  Future<List<Encounter>> listEncounters(String sessionId, {int limit = 20});

  /// Returns all combatants for [encounterId], sorted by `turnOrder` ascending
  /// once initiative is rolled; otherwise in insertion order.
  Future<List<Combatant>> listCombatants(String encounterId);

  /// Rolls initiative for every combatant; transitions encounter
  /// `setup → active`. Returns the post-roll combatants (server-ordered by
  /// `turnOrder` ascending) and the starting round (always `1`).
  ///
  /// Server-side errors (422 `ENCOUNTER_INVALID_STATUS`,
  /// `ENCOUNTER_NO_COMBATANTS`, etc.) surface as a thrown `Object` whose
  /// `toString()` is the RFC 9457 detail.
  Future<InitiativeRollOutcome> rollInitiative(String encounterId);

  /// Advances to the next combatant. Returns the new `activeCombatantId`,
  /// the post-advance round, and whether a new round just started.
  ///
  /// Allowed only while `status` is `active`. 422 errors surface as throws.
  Future<TurnAdvanceOutcome> advanceTurn(String encounterId);

  /// Closes the current round and advances all combatants to the start of the
  /// next round. Returns the updated turn state (`isNewRound` is always `true`
  /// on success).
  ///
  /// Allowed only while `status` is `active`. 422 errors surface as throws.
  Future<TurnAdvanceOutcome> advanceRound(String encounterId);

  /// Closes the encounter (`status → ended`). Returns the updated encounter.
  Future<Encounter> endEncounter(String encounterId);

  /// Adds a player-character combatant to [encounterId] from
  /// [characterId] (must be one of the caller's own characters).
  Future<Combatant> addPcCombatant({
    required String encounterId,
    required String characterId,
  });

  /// Removes [combatantId] from its encounter.
  Future<void> deleteCombatant(String combatantId);

  /// Replaces the full status-flag set on [combatantId]. Empty list clears
  /// all flags.
  Future<Combatant> setStatusFlags({
    required String combatantId,
    required List<String> flags,
  });
}

/// Domain projection of `InitiativeRollResult`. Keeps the presentation layer
/// free of the generated SDK type.
class InitiativeRollOutcome {
  const InitiativeRollOutcome({
    required this.combatants,
    required this.round,
  });

  final List<Combatant> combatants;
  final int round;
}

/// Domain projection of `TurnAdvanceResult`.
class TurnAdvanceOutcome {
  const TurnAdvanceOutcome({
    required this.activeCombatantId,
    required this.round,
    required this.isNewRound,
  });

  final String? activeCombatantId;
  final int round;
  final bool isNewRound;
}

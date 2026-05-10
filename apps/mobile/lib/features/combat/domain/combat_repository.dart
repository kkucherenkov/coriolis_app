import 'package:coriolis_companion/features/combat/domain/combatant.dart';
import 'package:coriolis_companion/features/combat/domain/encounter.dart';

/// Repository contract for combat encounters (Phase 6).
///
/// Mobile leans GM-first for Block 1: read operations only. Write paths
/// (add/remove combatants, roll initiative, advance turn) are Block 3+.
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
}

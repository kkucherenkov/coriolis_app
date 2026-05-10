import 'package:coriolis_companion/features/combat/domain/combatant.dart';
import 'package:coriolis_companion/features/combat/domain/encounter.dart';
import 'package:coriolis_companion/features/combat/presentation/blocs/active_combat/active_combat_state.dart';

/// Payload of a `combat.updated` Centrifugo publication.
///
/// Carries a full encounter snapshot together with its combatant list.
/// Wire-to-domain boundary: the AsyncAPI spec names the combatant field
/// `name`; this class maps it to [Combatant.displayName] so the rest of
/// the app always works with the canonical domain field.
///
/// Fields without a domain counterpart (e.g. combatant `referenceId` when
/// the domain has no `sourceId` to fill) default gracefully. Unknown extra
/// fields are silently ignored.
class CombatUpdatedPayload {
  const CombatUpdatedPayload({
    required this.encounterId,
    required this.sessionId,
    required this.snapshot,
    this.at,
  });

  final String encounterId;
  final String sessionId;

  /// Pre-built domain snapshot ready for [ActiveCombatCubit.replaceSnapshot].
  final ActiveCombatSnapshot snapshot;

  final DateTime? at;

  /// Parse a raw JSON map from a `combat.updated` publication.
  ///
  /// Returns `null` on any shape mismatch rather than throwing, so a
  /// malformed publication is silently discarded (consistent with the
  /// existing non-JSON guard in [SessionRealtime._onPublication]).
  static CombatUpdatedPayload? tryParse(Map<String, dynamic> data) {
    try {
      final encounterId = data['encounterId'] as String;
      final sessionId = data['gameSessionId'] as String;

      final encMap = data['encounter'] as Map<String, dynamic>;
      final encounter = Encounter(
        id: encMap['id'] as String,
        sessionId: encMap['gameSessionId'] as String,
        name: encMap['name'] as String,
        // AsyncAPI uses `status`; domain entity uses `state`
        state: encMap['status'] as String,
        round: encMap['round'] as int,
        activeCombatantId: encMap['activeCombatantId'] as String?,
        notes: encMap['notes'] as String?,
      );

      final rawCombatants = data['combatants'] as List<dynamic>;
      final combatants = rawCombatants.map((e) {
        final c = e as Map<String, dynamic>;
        final flags = (c['statusFlags'] as List<dynamic>?)
                ?.map((f) => f as String)
                .toList() ??
            <String>[];
        return Combatant(
          id: c['id'] as String,
          encounterId: c['encounterId'] as String,
          // AsyncAPI: `combatantType` ("pc" | "npc") → domain `source`
          source: c['combatantType'] as String,
          // `referenceId` is nullable; domain `sourceId` falls back to ''
          sourceId: c['referenceId'] as String? ?? '',
          // AsyncAPI uses `name`; domain entity uses `displayName` — map here
          displayName: c['name'] as String,
          initiative: c['initiative'] as int?,
          turnOrder: c['turnOrder'] as int?,
          hpCurrent: c['hpCurrent'] as int,
          hpMax: c['hpMax'] as int,
          // `armor` and `signature` are not in the AsyncAPI payload; default 0
          armor: 0,
          signature: 0,
          statusFlags: flags,
        );
      }).toList();

      return CombatUpdatedPayload(
        encounterId: encounterId,
        sessionId: sessionId,
        snapshot: ActiveCombatSnapshot(
          encounter: encounter,
          combatants: combatants,
        ),
        at: data['at'] is String ? _parseAt(data['at'] as String) : null,
      );
    } on Object {
      return null;
    }
  }

  static DateTime? _parseAt(String value) {
    try {
      return DateTime.parse(value);
    } on FormatException {
      return null;
    }
  }
}

import 'package:equatable/equatable.dart';

/// Shell of a combat encounter as the mobile UI sees it.
///
/// Domain model — `data/combat_repository_impl.dart` translates between this
/// and the SDK's `Encounter`. The combatant list is a separate sub-resource
/// (fetched via `CombatRepository.listCombatants`).
///
/// `state` is the wire string (`"setup"` | `"active"` | `"ended"`), kept
/// as a string so the UI tolerates a future fourth value gracefully.
///
/// `combatantCount` is NOT part of the REST response; it is derived by the
/// `listCombatants` call and cached on the domain object when needed. Set to
/// null when unknown (i.e. when the encounter was fetched without fetching
/// its combatants).
class Encounter extends Equatable {
  const Encounter({
    required this.id,
    required this.sessionId,
    required this.name,
    required this.state,
    required this.round,
    this.activeCombatantId,
    this.combatantCount,
    this.notes,
  });

  final String id;
  final String sessionId;
  final String name;

  /// Wire enum: "setup" | "active" | "ended".
  final String state;

  /// Current combat round. 0 while in setup; ≥1 during active combat.
  final int round;

  /// ID of the combatant whose turn is currently active.
  /// Null while in setup or after the encounter ends.
  final String? activeCombatantId;

  /// Number of combatants. Null when not yet fetched.
  final int? combatantCount;

  /// GM notes in Markdown format.
  final String? notes;

  Encounter copyWith({
    String? name,
    String? state,
    int? round,
    String? activeCombatantId,
    int? combatantCount,
    String? notes,
  }) {
    return Encounter(
      id: id,
      sessionId: sessionId,
      name: name ?? this.name,
      state: state ?? this.state,
      round: round ?? this.round,
      activeCombatantId: activeCombatantId ?? this.activeCombatantId,
      combatantCount: combatantCount ?? this.combatantCount,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        name,
        state,
        round,
        activeCombatantId,
        combatantCount,
        notes,
      ];
}

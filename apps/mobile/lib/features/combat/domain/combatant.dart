import 'package:equatable/equatable.dart';

/// A single participant in a combat encounter as the mobile UI sees it.
///
/// Domain model — `data/combat_repository_impl.dart` translates between this
/// and the SDK's `Combatant`. Fields are a 1-to-1 projection of the REST
/// response; HP can go below 0 (ST3001 does not clamp).
///
/// `source` is the wire string `"pc"` or `"npc"`, kept as a string so the
/// UI tolerates future combatant types without a forced upgrade.
///
/// `statusFlags` preserves the free-form server list verbatim. Canonical
/// ST3001 values are `"incapacitated"`, `"prone"`, and `"covered"`. Unknown
/// tags MUST be shown as plain text and preserved on round-trips (Block 2+).
class Combatant extends Equatable {
  const Combatant({
    required this.id,
    required this.encounterId,
    required this.source,
    required this.sourceId,
    required this.displayName,
    required this.hpCurrent,
    required this.hpMax,
    required this.armor,
    required this.signature,
    required this.statusFlags,
    this.initiative,
    this.turnOrder,
    this.notes,
  });

  final String id;
  final String encounterId;

  /// Wire enum: "pc" | "npc". Kept as a string for forward-compatibility.
  final String source;

  final String sourceId;
  final String displayName;

  /// d6 initiative result (1–6). Null until initiative is rolled (Block 4).
  final int? initiative;

  /// 0-based index in the turn sequence. Null until initiative is rolled.
  final int? turnOrder;

  final int hpCurrent;
  final int hpMax;

  /// Number of armor dice snapshotted from the source at add-time.
  final int armor;

  /// Mystic Darkness signature value.
  final int signature;

  final List<String> statusFlags;
  final String? notes;

  Combatant copyWith({
    int? hpCurrent,
    List<String>? statusFlags,
    String? displayName,
    String? notes,
  }) {
    return Combatant(
      id: id,
      encounterId: encounterId,
      source: source,
      sourceId: sourceId,
      displayName: displayName ?? this.displayName,
      initiative: initiative,
      turnOrder: turnOrder,
      hpCurrent: hpCurrent ?? this.hpCurrent,
      hpMax: hpMax,
      armor: armor,
      signature: signature,
      statusFlags: statusFlags ?? this.statusFlags,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        encounterId,
        source,
        sourceId,
        displayName,
        initiative,
        turnOrder,
        hpCurrent,
        hpMax,
        armor,
        signature,
        statusFlags,
        notes,
      ];
}

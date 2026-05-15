import 'package:equatable/equatable.dart';

import 'package:coriolis_companion/features/rolls/domain/roll.dart';

enum DiceRollerStatus { idle, rolling, pushing, error }

/// State for the in-sheet dice roller (Phase 4 Block 1).
///
/// `lastRoll` is null until the player makes their first roll. After Roll
/// it carries the server-side result; after Push it carries the rerolled
/// result with `pushed: true`. `status` is non-`idle` only while a request
/// is in flight; `errorMessage` outlives the transient status until the
/// player triggers another action.
class DiceRollerState extends Equatable {
  const DiceRollerState({
    this.status = DiceRollerStatus.idle,
    this.label = '',
    this.pool = 5,
    this.lastRoll,
    this.errorMessage,
    this.pushDelta,
  });

  final DiceRollerStatus status;
  final String label;
  final int pool;
  final Roll? lastRoll;
  final String? errorMessage;

  /// SURFACES.md §9 — push can fail (no new 6s). [pushDelta] tracks the
  /// in-session outcome: count of hits gained by the most recent push.
  /// Null until a push fires in this session. A fresh roll resets it to
  /// null; a reloaded already-pushed roll never replays the outcome line.
  final int? pushDelta;

  DiceRollerState copyWith({
    DiceRollerStatus? status,
    String? label,
    int? pool,
    Roll? lastRoll,
    String? errorMessage,
    int? pushDelta,
    // Sentinels so the caller can explicitly clear nullable fields.
    bool clearError = false,
    bool clearLastRoll = false,
    bool clearPushDelta = false,
  }) {
    return DiceRollerState(
      status: status ?? this.status,
      label: label ?? this.label,
      pool: pool ?? this.pool,
      lastRoll: clearLastRoll ? null : (lastRoll ?? this.lastRoll),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pushDelta: clearPushDelta ? null : (pushDelta ?? this.pushDelta),
    );
  }

  @override
  List<Object?> get props =>
      [status, label, pool, lastRoll, errorMessage, pushDelta];
}

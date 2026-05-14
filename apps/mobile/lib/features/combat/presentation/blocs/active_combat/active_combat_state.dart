import 'package:equatable/equatable.dart';

import 'package:coriolis_companion/features/combat/domain/combatant.dart';
import 'package:coriolis_companion/features/combat/domain/encounter.dart';

/// Snapshot of one active encounter together with its combatant list.
///
/// Used in [ActiveCombatState.ready] and as the payload for
/// [ActiveCombatCubit.replaceSnapshot] (Block 4 realtime wiring).
class ActiveCombatSnapshot extends Equatable {
  const ActiveCombatSnapshot({
    required this.encounter,
    required this.combatants,
  });

  final Encounter encounter;
  final List<Combatant> combatants;

  @override
  List<Object?> get props => [encounter, combatants];
}

/// Union state for [ActiveCombatCubit].
sealed class ActiveCombatState extends Equatable {
  const ActiveCombatState();
}

/// Initial fetch in progress.
final class ActiveCombatLoading extends ActiveCombatState {
  const ActiveCombatLoading();

  @override
  List<Object?> get props => [];
}

/// No encounters exist for the session, or none have state == 'active'.
final class ActiveCombatEmpty extends ActiveCombatState {
  const ActiveCombatEmpty();

  @override
  List<Object?> get props => [];
}

/// Active encounter found and combatants loaded.
///
/// [actionInFlight] is true while a tracker write (rollInitiative,
/// advanceTurn, endEncounter) is being awaited. The toolbar disables itself
/// during this window.
///
/// [actionError] carries the most recent action failure message — when
/// non-null, the tracker shows a dismissible banner. Reset to null on the
/// next successful action.
final class ActiveCombatReady extends ActiveCombatState {
  const ActiveCombatReady(
    this.snapshot, {
    this.actionInFlight = false,
    this.actionError,
  });

  final ActiveCombatSnapshot snapshot;
  final bool actionInFlight;
  final String? actionError;

  ActiveCombatReady copyWith({
    ActiveCombatSnapshot? snapshot,
    bool? actionInFlight,
    Object? actionError = _sentinel,
  }) {
    return ActiveCombatReady(
      snapshot ?? this.snapshot,
      actionInFlight: actionInFlight ?? this.actionInFlight,
      actionError: identical(actionError, _sentinel)
          ? this.actionError
          : actionError as String?,
    );
  }

  static const Object _sentinel = Object();

  @override
  List<Object?> get props => [snapshot, actionInFlight, actionError];
}

/// Repository threw; [message] is the stringified exception.
final class ActiveCombatError extends ActiveCombatState {
  const ActiveCombatError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

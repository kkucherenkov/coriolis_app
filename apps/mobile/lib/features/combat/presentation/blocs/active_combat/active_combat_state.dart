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
final class ActiveCombatReady extends ActiveCombatState {
  const ActiveCombatReady(this.snapshot);

  final ActiveCombatSnapshot snapshot;

  @override
  List<Object?> get props => [snapshot];
}

/// Repository threw; [message] is the stringified exception.
final class ActiveCombatError extends ActiveCombatState {
  const ActiveCombatError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

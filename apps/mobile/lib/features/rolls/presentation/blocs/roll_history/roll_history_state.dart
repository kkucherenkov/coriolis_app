import 'package:equatable/equatable.dart';

import 'package:coriolis_companion/features/rolls/domain/roll.dart';

enum RollHistoryStatus { loading, loaded, error }

/// State for the roll-history list (Phase 4 Block 2).
///
/// `rolls` is always the canonical list — capped to 50 server-side and
/// kept that size client-side via `prependRoll`. `prependRoll` /
/// `updateRoll` from the cubit mutate this list directly so the dice
/// roller's events land at the top of the strip without a network
/// round-trip.
class RollHistoryState extends Equatable {
  const RollHistoryState({
    this.status = RollHistoryStatus.loading,
    this.rolls = const [],
    this.errorMessage,
  });

  final RollHistoryStatus status;
  final List<Roll> rolls;
  final String? errorMessage;

  RollHistoryState copyWith({
    RollHistoryStatus? status,
    List<Roll>? rolls,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RollHistoryState(
      status: status ?? this.status,
      rolls: rolls ?? this.rolls,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, rolls, errorMessage];
}

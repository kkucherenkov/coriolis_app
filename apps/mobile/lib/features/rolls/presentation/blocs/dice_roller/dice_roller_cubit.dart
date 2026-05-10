import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/rolls/domain/roll_repository.dart';
import 'package:coriolis_companion/features/rolls/presentation/blocs/dice_roller/dice_roller_state.dart';

/// Manages the dice-roller widget state on the character sheet.
///
/// One cubit per dice-roller instance — registered as a factory in DI so
/// each `BlocProvider` gets a fresh state. The cubit is intentionally
/// thin: it does not own roll history (that's `RollHistoryCubit` in
/// Block 2). Both cubits share the same repository singleton, and the
/// parent page bridges them by listening to `rollCreated` /
/// `rollPushed` and forwarding into the history cubit.
class DiceRollerCubit extends Cubit<DiceRollerState> {
  DiceRollerCubit({required RollRepository repository})
      : _repository = repository,
        super(const DiceRollerState());

  final RollRepository _repository;

  static const int poolMin = 1;
  static const int poolMax = 10;

  void setLabel(String value) {
    emit(state.copyWith(label: value, clearError: true));
  }

  void setPool(int value) {
    final clamped = value < poolMin
        ? poolMin
        : value > poolMax
            ? poolMax
            : value;
    emit(state.copyWith(pool: clamped, clearError: true));
  }

  void incrementPool() => setPool(state.pool + 1);
  void decrementPool() => setPool(state.pool - 1);

  /// Server holds the RNG. We just describe the roll and render whatever
  /// comes back. `errorMessage` carries the RFC 9457 `detail` when the
  /// request fails (validation, network, etc).
  Future<void> roll({
    required String characterId,
    String? gameSessionId,
  }) async {
    final trimmed = state.label.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(
        status: DiceRollerStatus.error,
        errorMessage: 'Label is required',
      ));
      return;
    }
    if (state.pool < poolMin || state.pool > poolMax) return;

    emit(state.copyWith(
      status: DiceRollerStatus.rolling,
      clearError: true,
    ));
    try {
      final roll = await _repository.createRoll(
        characterId: characterId,
        label: trimmed,
        pool: state.pool,
        gameSessionId: gameSessionId,
      );
      emit(state.copyWith(
        status: DiceRollerStatus.idle,
        lastRoll: roll,
      ));
    } on Object catch (e) {
      emit(state.copyWith(
        status: DiceRollerStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Push the most recent roll. Server returns 422 ROLL_NOT_PUSHABLE
  /// when the character is exhausted or the roll has already been
  /// pushed; the error surfaces via `errorMessage` and the visible
  /// roll stays unchanged.
  Future<void> push() async {
    final last = state.lastRoll;
    if (last == null || last.pushed) return;

    emit(state.copyWith(
      status: DiceRollerStatus.pushing,
      clearError: true,
    ));
    try {
      final pushed = await _repository.pushRoll(last.id);
      emit(state.copyWith(
        status: DiceRollerStatus.idle,
        lastRoll: pushed,
      ));
    } on Object catch (e) {
      emit(state.copyWith(
        status: DiceRollerStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Resets the form (called when the bottom sheet closes).
  void reset() {
    emit(const DiceRollerState());
  }
}

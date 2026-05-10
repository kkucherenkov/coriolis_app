import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/rolls/domain/roll.dart';
import 'package:coriolis_companion/features/rolls/domain/roll_repository.dart';
import 'package:coriolis_companion/features/rolls/presentation/blocs/roll_history/roll_history_state.dart';

/// Manages the reverse-chrono roll history for a character.
///
/// The cubit owns the visible list. Fresh rolls from the dice roller
/// arrive via `prependRoll` (parent watches the roller's events and
/// forwards). Pushes arrive via `updateRoll` and replace the matching
/// row in-place. We deliberately do not refetch on every event —
/// listRolls would race against the still-being-persisted INSERT and
/// could legitimately drop the just-rolled row.
class RollHistoryCubit extends Cubit<RollHistoryState> {
  RollHistoryCubit({required RollRepository repository})
      : _repository = repository,
        super(const RollHistoryState());

  final RollRepository _repository;

  static const int _pageSize = 50;

  /// Fetch the first page. Call once on widget mount.
  Future<void> load(String characterId) async {
    emit(state.copyWith(status: RollHistoryStatus.loading, clearError: true));
    try {
      final items = await _repository.listRolls(characterId, limit: _pageSize);
      emit(state.copyWith(status: RollHistoryStatus.loaded, rolls: items));
    } on Object catch (e) {
      emit(state.copyWith(
        status: RollHistoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Prepend a fresh roll. Dedup against the same id (a server-side
  /// retry could legitimately surface twice) and cap at the page size
  /// so the visible list never grows past what listRolls returns.
  void prependRoll(Roll roll) {
    final filtered = state.rolls.where((r) => r.id != roll.id);
    final next = <Roll>[roll, ...filtered].take(_pageSize).toList(growable: false);
    emit(state.copyWith(status: RollHistoryStatus.loaded, rolls: next));
  }

  /// Replace the row matching `roll.id` (used after a push). If the
  /// roll isn't in the list we still prepend — covers the case of a
  /// push arriving via a future Centrifugo subscription before the
  /// initial listRolls completed.
  void updateRoll(Roll roll) {
    final found = state.rolls.any((r) => r.id == roll.id);
    if (!found) {
      prependRoll(roll);
      return;
    }
    final next = state.rolls.map((r) => r.id == roll.id ? roll : r).toList(growable: false);
    emit(state.copyWith(rolls: next));
  }
}

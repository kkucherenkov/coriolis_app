import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/sessions/domain/session_repository.dart';

/// DP-pool sub-state on the combat tracker.
///
/// Owns just the GM's DP +/- affordance — read+write. The initial count is
/// seeded from the route args (so the tracker doesn't have to re-fetch the
/// session); subsequent mutations call `adjustDp` and update locally on
/// success. Errors surface in [errorMessage] so the page can show a
/// SnackBar.
class TrackerDpState extends Equatable {
  const TrackerDpState({
    required this.count,
    this.busy = false,
    this.errorMessage,
  });

  final int count;
  final bool busy;
  final String? errorMessage;

  TrackerDpState copyWith({
    int? count,
    bool? busy,
    Object? errorMessage = _sentinel,
  }) {
    return TrackerDpState(
      count: count ?? this.count,
      busy: busy ?? this.busy,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const Object _sentinel = Object();

  @override
  List<Object?> get props => [count, busy, errorMessage];
}

class TrackerDpCubit extends Cubit<TrackerDpState> {
  TrackerDpCubit({
    required SessionRepository repository,
    required this.sessionId,
    required int initialCount,
  })  : _repository = repository,
        super(TrackerDpState(count: initialCount));

  final SessionRepository _repository;
  final String sessionId;

  /// Posts a DP adjustment. Returns `true` on success.
  ///
  /// Server enforces `DP_BELOW_ZERO` for under-flowing deltas; on failure
  /// the repo throws and we surface the message via `errorMessage`.
  Future<bool> adjustDp(int delta) async {
    if (state.busy) return false;
    emit(state.copyWith(busy: true, errorMessage: null));
    try {
      final updated = await _repository.adjustDp(sessionId, delta: delta);
      emit(state.copyWith(count: updated.dpCount, busy: false));
      return true;
    } on Object catch (e) {
      emit(state.copyWith(busy: false, errorMessage: e.toString()));
      return false;
    }
  }
}

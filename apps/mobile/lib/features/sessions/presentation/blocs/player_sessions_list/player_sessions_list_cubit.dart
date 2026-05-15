import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/sessions/domain/player_session_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/player_sessions_list/player_sessions_list_state.dart';

class PlayerSessionsListCubit extends Cubit<PlayerSessionsListState> {
  PlayerSessionsListCubit({required PlayerSessionRepository repository})
      : _repository = repository,
        super(const PlayerSessionsListState());

  final PlayerSessionRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: PlayerSessionsStatus.loading));
    try {
      final memberships = await _repository.getMyMemberships();
      emit(state.copyWith(
        status: PlayerSessionsStatus.success,
        memberships: memberships,
      ));
    } on Object catch (e) {
      emit(state.copyWith(
        status: PlayerSessionsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> leaveSession({
    required String membershipId,
    required String gameSessionId,
  }) async {
    try {
      await _repository.leaveSession(membershipId, gameSessionId);
      await load();
    } on Object catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/sessions/domain/player_session_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/join_session/join_session_state.dart';

class JoinSessionCubit extends Cubit<JoinSessionState> {
  JoinSessionCubit({required PlayerSessionRepository repository})
      : _repository = repository,
        super(const JoinSessionState());

  final PlayerSessionRepository _repository;

  /// Loads the invite preview for [token].
  ///
  /// - 404 / 410 from the server → emits [JoinSessionStatus.revoked].
  /// - Preview with `alreadyJoined == true` → emits [JoinSessionStatus.alreadyMember].
  Future<void> load(String token) async {
    emit(state.copyWith(status: JoinSessionStatus.loading));
    try {
      final preview = await _repository.getInvitePreview(token);
      if (preview.alreadyJoined) {
        emit(state.copyWith(
          status: JoinSessionStatus.alreadyMember,
          preview: preview,
        ));
        return;
      }
      emit(state.copyWith(
        status: JoinSessionStatus.previewLoaded,
        preview: preview,
      ));
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 404 || code == 410) {
        emit(state.copyWith(status: JoinSessionStatus.revoked));
      } else {
        emit(state.copyWith(
          status: JoinSessionStatus.failure,
          errorMessage: e.toString(),
        ));
      }
    } on Object catch (e) {
      emit(state.copyWith(
        status: JoinSessionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Accepts the invite for [token], optionally linking [characterId].
  Future<void> accept(String token, {String? characterId}) async {
    emit(state.copyWith(status: JoinSessionStatus.loading));
    try {
      final membership =
          await _repository.acceptInvite(token, characterId: characterId);
      emit(state.copyWith(
        status: JoinSessionStatus.success,
        joinedMembership: membership,
      ));
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 404 || code == 410) {
        emit(state.copyWith(status: JoinSessionStatus.revoked));
      } else {
        emit(state.copyWith(
          status: JoinSessionStatus.failure,
          errorMessage: e.toString(),
        ));
      }
    } on Object catch (e) {
      emit(state.copyWith(
        status: JoinSessionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/sessions/domain/session_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/sessions_list/sessions_list_state.dart';

/// Drives the sessions index screen (Phase 4 Block 3 mobile).
///
/// `setFilter` flips between `active` and `archived` and reloads.
/// `archive` / `unarchive` patches a single row through PATCH and
/// refetches — mobile is too small a list to bother with optimistic
/// list mutation for the toggle.
class SessionsListCubit extends Cubit<SessionsListState> {
  SessionsListCubit({required SessionRepository repository})
      : _repository = repository,
        super(const SessionsListState());

  final SessionRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: SessionsListStatus.loading, clearError: true));
    try {
      final items = await _repository.list(status: state.statusFilter, limit: 20);
      emit(state.copyWith(
        status: items.isEmpty ? SessionsListStatus.empty : SessionsListStatus.loaded,
        sessions: items,
      ));
    } on Object catch (e) {
      emit(state.copyWith(
        status: SessionsListStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> setFilter(String status) async {
    if (state.statusFilter == status) return;
    emit(state.copyWith(statusFilter: status));
    await load();
  }

  Future<void> archive(String sessionId) async {
    try {
      await _repository.setStatus(sessionId, 'archived');
      await load();
    } on Object catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> unarchive(String sessionId) async {
    try {
      await _repository.setStatus(sessionId, 'active');
      await load();
    } on Object catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}

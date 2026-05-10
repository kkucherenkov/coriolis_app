import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/sessions/domain/session_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/session_detail/session_detail_state.dart';

/// Drives the session detail page (Phase 4 Block 3 mobile).
///
/// `load` resolves the session by id; the GM-vs-player branch is
/// detected by the page comparing `state.session.ownerId` against the
/// already-resolved `me.id` (cached in the auth feature). `adjustDp`
/// posts a delta and patches `state.session` from the response — the
/// audit log refreshes after every adjust to keep the trail in sync.
/// Block 4 will replace that refresh with a Centrifugo subscription
/// patching the counter live.
class SessionDetailCubit extends Cubit<SessionDetailState> {
  SessionDetailCubit({required SessionRepository repository})
      : _repository = repository,
        super(const SessionDetailState());

  final SessionRepository _repository;

  Future<void> load(String sessionId) async {
    emit(state.copyWith(status: SessionDetailStatus.loading, clearError: true));
    try {
      final session = await _repository.get(sessionId);
      emit(state.copyWith(status: SessionDetailStatus.loaded, session: session));
    } on Object catch (e) {
      // The shared HTTP error type is just a `String` until the global
      // ApiProblemError refactor — best-effort detect 404 by message.
      final message = e.toString();
      if (message.contains('404') || message.toLowerCase().contains('not found')) {
        emit(state.copyWith(status: SessionDetailStatus.notFound));
      } else {
        emit(state.copyWith(
          status: SessionDetailStatus.error,
          errorMessage: message,
        ));
      }
    }
  }

  Future<void> loadDpEvents() async {
    final session = state.session;
    if (session == null) return;
    try {
      final events = await _repository.listDpEvents(session.id, limit: 20);
      emit(state.copyWith(dpEvents: events));
    } on Object catch (e) {
      // Audit-log failure shouldn't sink the rest of the page; surface
      // through `dpError` so the DP card can render an inline note.
      emit(state.copyWith(dpError: e.toString()));
    }
  }

  Future<void> adjustDp({required int delta, String? reason}) async {
    final session = state.session;
    if (session == null || delta == 0) return;
    emit(state.copyWith(dpSubmitting: true, clearDpError: true));
    try {
      final updated = await _repository.adjustDp(
        session.id,
        delta: delta,
        reason: reason,
      );
      emit(state.copyWith(session: updated, dpSubmitting: false));
      await loadDpEvents();
    } on Object catch (e) {
      emit(state.copyWith(
        dpSubmitting: false,
        dpError: e.toString(),
      ));
    }
  }

  /// Centrifugo subscription handler (wired in Block 4). Patches the
  /// visible counter without going through the repository.
  void applyDpChanged({required int dpCount, required int delta, required String source}) {
    final session = state.session;
    if (session == null) return;
    emit(state.copyWith(session: session.copyWith(dpCount: dpCount)));
  }
}

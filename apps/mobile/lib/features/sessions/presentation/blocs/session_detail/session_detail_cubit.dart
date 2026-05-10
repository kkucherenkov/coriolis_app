import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/sessions/domain/session_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/session_detail/session_detail_state.dart';
import 'package:coriolis_companion/shared/realtime/session_realtime.dart';

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
  SessionDetailCubit({
    required SessionRepository repository,
    required SessionRealtime realtime,
  })  : _repository = repository,
        _realtime = realtime,
        super(const SessionDetailState());

  final SessionRepository _repository;
  final SessionRealtime _realtime;

  StreamSubscription<DpChangedPayload>? _dpSub;
  StreamSubscription<RollPushedPayload>? _rollSub;
  StreamSubscription<CombatUpdatedPayload>? _combatSub;
  final _rollPushedController = StreamController<RollPushedPayload>.broadcast();
  final _combatUpdatedController =
      StreamController<CombatUpdatedPayload>.broadcast();

  /// Stream of `roll.pushed` events the page subscribes to for the
  /// SnackBar. Cubit forwards from the realtime adapter so the page
  /// doesn't have to reach into infra.
  Stream<RollPushedPayload> get rollPushed => _rollPushedController.stream;

  /// Stream of `combat.updated` snapshots forwarded from the realtime adapter.
  /// The page wires this into [ActiveCombatCubit.replaceSnapshot].
  Stream<CombatUpdatedPayload> get combatUpdated =>
      _combatUpdatedController.stream;

  Future<void> load(String sessionId) async {
    emit(state.copyWith(status: SessionDetailStatus.loading, clearError: true));
    try {
      final session = await _repository.get(sessionId);
      emit(state.copyWith(status: SessionDetailStatus.loaded, session: session));
      // Open the websocket only after the session resolved — pointing
      // at a deleted/inaccessible session would have its subscribe
      // rejected server-side.
      await _startRealtime(sessionId);
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

  /// Centrifugo subscription handler. Patches the visible counter
  /// directly — the audit list refetches on the next adjust to pick
  /// up the canonical row (the websocket payload doesn't carry the
  /// DpEvent id).
  void applyDpChanged({required int dpCount, required int delta, required String source}) {
    final session = state.session;
    if (session == null) return;
    emit(state.copyWith(session: session.copyWith(dpCount: dpCount)));
  }

  Future<void> _startRealtime(String sessionId) async {
    try {
      await _realtime.start(sessionId);
      _dpSub = _realtime.dpChanged.listen((payload) {
        applyDpChanged(
          dpCount: payload.dpCount,
          delta: payload.delta,
          source: payload.source,
        );
      });
      _rollSub = _realtime.rollPushed.listen(_rollPushedController.add);
      _combatSub = _realtime.combatUpdated.listen(_combatUpdatedController.add);
    } on Object catch (e) {
      // A websocket failure shouldn't sink the rest of the page; keep
      // the state in `loaded` and surface the error via dpError so the
      // UI can render an inline note. The audit log fallback (refetch
      // after every adjust) is still in place.
      emit(state.copyWith(dpError: 'Live updates unavailable: $e'));
    }
  }

  @override
  Future<void> close() async {
    await _dpSub?.cancel();
    await _rollSub?.cancel();
    await _combatSub?.cancel();
    await _realtime.dispose();
    await _rollPushedController.close();
    await _combatUpdatedController.close();
    await super.close();
  }
}

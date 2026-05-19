import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/me/domain/me_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat_dock/chat_dock_state.dart';

/// Manages the chat-dock collapse state for a player session screen.
///
/// - On [hydrate]: calls `GET /me` and seeds [ChatDockState.collapsed] from
///   `Me.chatDockedCollapsed`. Null / missing defaults to `false`.
/// - On [toggle]: flips the in-memory state immediately (optimistic UI),
///   then schedules a debounced `PATCH /me { chatDockedCollapsed }`.
/// - PATCH failures are silent — user-facing state stays where the user
///   set it; the error is logged via [debugPrint].
///
/// Debounce interval is injected for testability (default 600 ms).
class ChatDockCubit extends Cubit<ChatDockState> {
  ChatDockCubit({
    required MeRepository repository,
    Duration debounceDuration = const Duration(milliseconds: 600),
  })  : _repository = repository,
        _debounceDuration = debounceDuration,
        super(const ChatDockState());

  final MeRepository _repository;
  final Duration _debounceDuration;

  Timer? _debounceTimer;

  // ── Hydrate ────────────────────────────────────────────────────────────────

  /// Loads `Me.chatDockedCollapsed` from the server.
  ///
  /// On failure the state remains `isLoading: false, collapsed: false` so the
  /// panel opens by default — a safe degraded experience.
  Future<void> hydrate() async {
    emit(const ChatDockState(isLoading: true));
    try {
      final profile = await _repository.getMe();
      emit(ChatDockState(
        isLoading: false,
        collapsed: profile.chatDockedCollapsed,
      ));
    } on Object catch (e, st) {
      debugPrint('[ChatDockCubit] hydrate failed: $e\n$st');
      emit(const ChatDockState(isLoading: false, collapsed: false));
    }
  }

  // ── Toggle ─────────────────────────────────────────────────────────────────

  /// Flips the dock state and schedules a debounced server write.
  void toggle() {
    final newValue = !state.collapsed;
    emit(state.copyWith(collapsed: newValue));
    _scheduleDebounce(newValue);
  }

  void _scheduleDebounce(bool value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () async {
      try {
        await _repository.patchMe(chatDockedCollapsed: value);
      } on Object catch (e, st) {
        // Silent best-effort persistence — user-facing state is already set.
        debugPrint('[ChatDockCubit] patchMe failed: $e\n$st');
      }
    });
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}

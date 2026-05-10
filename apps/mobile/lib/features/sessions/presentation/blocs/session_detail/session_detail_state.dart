import 'package:equatable/equatable.dart';

import 'package:coriolis_companion/features/sessions/domain/game_session.dart';

enum SessionDetailStatus { loading, loaded, error, notFound }

/// State for the session-detail page (Phase 4 Block 3 mobile).
///
/// `me` is the authenticated user's id; the page sets `isGm` from the
/// repository payload's `ownerId` so the GM-only controls are gated
/// before the user even taps. `dpEvents` is the audit-log tail —
/// fetched only when `isGm` is true (server-side gate too).
class SessionDetailState extends Equatable {
  const SessionDetailState({
    this.status = SessionDetailStatus.loading,
    this.session,
    this.dpEvents = const [],
    this.errorMessage,
    this.dpError,
    this.dpSubmitting = false,
  });

  final SessionDetailStatus status;
  final GameSession? session;
  final List<DpEvent> dpEvents;
  final String? errorMessage;
  final String? dpError;
  final bool dpSubmitting;

  SessionDetailState copyWith({
    SessionDetailStatus? status,
    GameSession? session,
    List<DpEvent>? dpEvents,
    String? errorMessage,
    String? dpError,
    bool? dpSubmitting,
    bool clearError = false,
    bool clearDpError = false,
  }) {
    return SessionDetailState(
      status: status ?? this.status,
      session: session ?? this.session,
      dpEvents: dpEvents ?? this.dpEvents,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      dpError: clearDpError ? null : (dpError ?? this.dpError),
      dpSubmitting: dpSubmitting ?? this.dpSubmitting,
    );
  }

  @override
  List<Object?> get props =>
      [status, session, dpEvents, errorMessage, dpError, dpSubmitting];
}

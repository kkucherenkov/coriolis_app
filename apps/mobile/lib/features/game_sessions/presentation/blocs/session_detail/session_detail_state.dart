import 'package:equatable/equatable.dart';

import 'package:coriolis_companion/features/game_sessions/domain/game_session.dart';

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
    this.kickBusyMembershipId,
    this.kickError,
  });

  final SessionDetailStatus status;
  final GameSession? session;
  final List<DpEvent> dpEvents;
  final String? errorMessage;
  final String? dpError;
  final bool dpSubmitting;

  /// The membership id currently being kicked (drives the per-row spinner).
  /// `null` when no kick is in flight.
  final String? kickBusyMembershipId;

  /// Last kick failure, surfaced as an inline error under the Crew card.
  final String? kickError;

  SessionDetailState copyWith({
    SessionDetailStatus? status,
    GameSession? session,
    List<DpEvent>? dpEvents,
    String? errorMessage,
    String? dpError,
    bool? dpSubmitting,
    String? kickBusyMembershipId,
    String? kickError,
    bool clearError = false,
    bool clearDpError = false,
    bool clearKickBusy = false,
    bool clearKickError = false,
  }) {
    return SessionDetailState(
      status: status ?? this.status,
      session: session ?? this.session,
      dpEvents: dpEvents ?? this.dpEvents,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      dpError: clearDpError ? null : (dpError ?? this.dpError),
      dpSubmitting: dpSubmitting ?? this.dpSubmitting,
      kickBusyMembershipId: clearKickBusy
          ? null
          : (kickBusyMembershipId ?? this.kickBusyMembershipId),
      kickError: clearKickError ? null : (kickError ?? this.kickError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        session,
        dpEvents,
        errorMessage,
        dpError,
        dpSubmitting,
        kickBusyMembershipId,
        kickError,
      ];
}

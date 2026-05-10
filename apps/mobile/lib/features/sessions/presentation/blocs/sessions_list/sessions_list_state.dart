import 'package:equatable/equatable.dart';

import 'package:coriolis_companion/features/sessions/domain/game_session.dart';

enum SessionsListStatus { loading, loaded, empty, error }

class SessionsListState extends Equatable {
  const SessionsListState({
    this.status = SessionsListStatus.loading,
    this.statusFilter = 'active',
    this.sessions = const [],
    this.errorMessage,
  });

  final SessionsListStatus status;
  final String statusFilter;
  final List<GameSession> sessions;
  final String? errorMessage;

  SessionsListState copyWith({
    SessionsListStatus? status,
    String? statusFilter,
    List<GameSession>? sessions,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SessionsListState(
      status: status ?? this.status,
      statusFilter: statusFilter ?? this.statusFilter,
      sessions: sessions ?? this.sessions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, statusFilter, sessions, errorMessage];
}

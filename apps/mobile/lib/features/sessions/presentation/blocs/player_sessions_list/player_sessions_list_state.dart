import 'package:equatable/equatable.dart';

import 'package:coriolis_companion/features/sessions/domain/player_membership.dart';

enum PlayerSessionsStatus { initial, loading, success, failure }

class PlayerSessionsListState extends Equatable {
  const PlayerSessionsListState({
    this.status = PlayerSessionsStatus.initial,
    this.memberships = const [],
    this.errorMessage,
  });

  final PlayerSessionsStatus status;
  final List<PlayerMembership> memberships;
  final String? errorMessage;

  PlayerSessionsListState copyWith({
    PlayerSessionsStatus? status,
    List<PlayerMembership>? memberships,
    String? errorMessage,
  }) =>
      PlayerSessionsListState(
        status: status ?? this.status,
        memberships: memberships ?? this.memberships,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, memberships, errorMessage];
}

import 'package:equatable/equatable.dart';

import 'package:coriolis_companion/features/sessions/domain/invite_preview.dart';
import 'package:coriolis_companion/features/sessions/domain/player_membership.dart';

enum JoinSessionStatus {
  /// No request in flight yet.
  initial,

  /// Preview or accept request in progress.
  loading,

  /// Preview loaded successfully — user can tap Join.
  previewLoaded,

  /// Accept completed successfully.
  success,

  /// Invite token is revoked (server returned 404/410).
  revoked,

  /// Caller is already an active member.
  alreadyMember,

  /// Unrecoverable error (network, unexpected status, etc.).
  failure,
}

class JoinSessionState extends Equatable {
  const JoinSessionState({
    this.status = JoinSessionStatus.initial,
    this.preview,
    this.joinedMembership,
    this.errorMessage,
  });

  final JoinSessionStatus status;

  /// Populated after a successful preview fetch.
  final InvitePreview? preview;

  /// Populated after a successful accept.
  final PlayerMembership? joinedMembership;

  final String? errorMessage;

  JoinSessionState copyWith({
    JoinSessionStatus? status,
    InvitePreview? preview,
    PlayerMembership? joinedMembership,
    String? errorMessage,
  }) =>
      JoinSessionState(
        status: status ?? this.status,
        preview: preview ?? this.preview,
        joinedMembership: joinedMembership ?? this.joinedMembership,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, preview, joinedMembership, errorMessage];
}

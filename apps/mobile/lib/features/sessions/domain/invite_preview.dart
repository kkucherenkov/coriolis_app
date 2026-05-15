import 'package:equatable/equatable.dart';

/// Public preview returned before accepting an invite.
/// Mirrors the server `InvitePreview` schema — no session ID is exposed.
class InvitePreview extends Equatable {
  const InvitePreview({
    required this.sessionName,
    required this.gmDisplayName,
    required this.alreadyJoined,
  });

  final String sessionName;
  final String gmDisplayName;

  /// True when the authenticated caller already has an active membership.
  final bool alreadyJoined;

  @override
  List<Object?> get props => [sessionName, gmDisplayName, alreadyJoined];
}

import 'package:equatable/equatable.dart';

/// Whether an invite link is active and when it was last rotated.
/// The plaintext URL is never included; it is returned once by [InviteRotated].
class InviteMetadata extends Equatable {
  const InviteMetadata({required this.active, this.rotatedAt});

  final bool active;
  final DateTime? rotatedAt;

  @override
  List<Object?> get props => [active, rotatedAt];
}

/// Response to a rotate request — contains the plaintext URL exactly once.
class InviteRotated extends Equatable {
  const InviteRotated({
    required this.url,
    required this.token,
    required this.rotatedAt,
  });

  final String url;
  final String token;
  final DateTime rotatedAt;

  @override
  List<Object?> get props => [url, token, rotatedAt];
}

import 'package:equatable/equatable.dart';

/// Domain entity representing a player's membership in a game session.
///
/// Covers both `gm` and `player` roles. Presentation layer uses [role]
/// to decide which UI to render; the server is the authoritative permission
/// boundary.
class PlayerMembership extends Equatable {
  const PlayerMembership({
    required this.membershipId,
    required this.gameSessionId,
    required this.sessionName,
    required this.role,
    this.characterId,
    this.characterName,
    required this.joinedAt,
  });

  final String membershipId;
  final String gameSessionId;
  final String sessionName;

  /// `'gm'` or `'player'` — mirrors the server enum wire name.
  final String role;

  final String? characterId;
  final String? characterName;
  final DateTime joinedAt;

  @override
  List<Object?> get props => [membershipId, gameSessionId, role];
}

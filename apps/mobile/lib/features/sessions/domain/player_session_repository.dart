import 'package:coriolis_companion/features/sessions/domain/invite_preview.dart';
import 'package:coriolis_companion/features/sessions/domain/player_membership.dart';

/// Repository contract for the player-facing session flow.
///
/// Implemented in `data/` by [PlayerSessionRepositoryImpl]; the presentation
/// layer only ever imports this interface.
abstract class PlayerSessionRepository {
  /// Returns all active (non-left) memberships for the authenticated user.
  Future<List<PlayerMembership>> getMyMemberships();

  /// Fetches public preview for an invite token.
  /// Throws [StateError] when the server returns an empty body.
  Future<InvitePreview> getInvitePreview(String token);

  /// Validates the token and creates (or returns existing) membership.
  /// Optionally links [characterId] at join time.
  Future<PlayerMembership> acceptInvite(String token, {String? characterId});

  /// Stamps `leftAt` on the membership.
  /// A player may only leave their own membership; a GM may kick others.
  Future<void> leaveSession(String membershipId, String gameSessionId);
}

import 'package:coriolis_companion/features/game_sessions/domain/game_session.dart';
import 'package:coriolis_companion/features/game_sessions/domain/invite.dart';

/// Repository contract for game sessions (Phase 4 Features 7.2 + 7.3).
///
/// Mobile leans player-first: the GM-only ops (`adjustDp`, invite rotate
/// / revoke) are exposed but the UI gates them on
/// `me.id == session.ownerId`. The server is the authoritative
/// permission boundary; the client gating is just to spare the user
/// a 403 round-trip.
///
/// Character linking is membership-driven (Phase 8 Stream E): players
/// link a PC during invite-accept; the GM's own membership.characterId
/// is set via `PATCH /game-sessions/:id/members/:membershipId`. The
/// legacy GM-only assign/unassign endpoints are gone.
abstract class SessionRepository {
  /// Returns up to [limit] sessions filtered by [status]. Cursor
  /// pagination from the SDK is dropped on the floor for v1 — the
  /// corpus is small and a "Load more" button is its own follow-up.
  Future<List<GameSession>> list({String? status, int limit = 20});

  Future<GameSession> get(String id);

  Future<GameSession> create({required String name, String? description});

  /// Soft-archive (PATCH status). The server keeps the row.
  Future<GameSession> setStatus(String id, String status);

  Future<void> delete(String id);

  /// Adjusts DP by [delta]. Positive: GM owner OR system (roll push).
  /// Negative: GM owner only. Server returns 422 DP_BELOW_ZERO when the
  /// adjustment would drop the counter below 0; the impl rethrows so
  /// the cubit can route the message through `errorMessage`.
  Future<GameSession> adjustDp(String sessionId, {required int delta, String? reason});

  Future<List<DpEvent>> listDpEvents(String sessionId, {int limit = 20});

  // ── Invite management (Phase 8 Stream A, GM only) ─────────────────────────

  /// Returns whether an invite is active and when it was last rotated.
  /// Never returns the plaintext URL — that is revealed once by [rotateInvite].
  Future<InviteMetadata> getInviteMetadata(String sessionId);

  /// Generates (or rotates) the invite link. Returns the plaintext URL exactly
  /// once. If the GM loses the URL they must call this again.
  Future<InviteRotated> rotateInvite(String sessionId);

  /// Clears the invite hash. Subsequent accept attempts return 410.
  Future<void> revokeInvite(String sessionId);

  /// GM-only kick. The server backs this with
  /// `DELETE /api/v1/game-sessions/:id/members/:membershipId`. A player who
  /// wants to leave their own membership calls the same endpoint via
  /// `PlayerSessionRepository.leaveSession` — server gates kick-others on
  /// `ownerId == requester.id`.
  Future<void> removeMember(String sessionId, String membershipId);
}

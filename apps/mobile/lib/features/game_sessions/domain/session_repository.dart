import 'package:coriolis_companion/features/game_sessions/domain/game_session.dart';

/// Repository contract for game sessions (Phase 4 Features 7.2 + 7.3).
///
/// Mobile leans player-first: the GM-only ops (`adjustDp`,
/// `assign`/`unassign`) are exposed but the UI gates them on
/// `me.id == session.ownerId`. The server is the authoritative
/// permission boundary; the client gating is just to spare the user
/// a 403 round-trip.
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

  Future<GameSession> assignCharacter(String sessionId, String characterId);

  Future<void> unassignCharacter(String sessionId, String characterId);

  /// Adjusts DP by [delta]. Positive: GM owner OR system (roll push).
  /// Negative: GM owner only. Server returns 422 DP_BELOW_ZERO when the
  /// adjustment would drop the counter below 0; the impl rethrows so
  /// the cubit can route the message through `errorMessage`.
  Future<GameSession> adjustDp(String sessionId, {required int delta, String? reason});

  Future<List<DpEvent>> listDpEvents(String sessionId, {int limit = 20});
}

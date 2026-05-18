import 'package:app_api_client/app_api_client.dart' as api_client
    show
        GameSessionsApi,
        GameSessionStatus,
        GameSessionCreate,
        GameSessionUpdate,
        DpAdjustment;

import 'package:coriolis_companion/features/game_sessions/data/game_session_api_mapper.dart';
import 'package:coriolis_companion/features/game_sessions/domain/game_session.dart';
import 'package:coriolis_companion/features/game_sessions/domain/invite.dart'
    as domain;
import 'package:coriolis_companion/features/game_sessions/domain/session_repository.dart';

/// Adapter bridging `GameSessionsApi` (which on the Dart side hosts the
/// DP endpoints too — `adjustDp`, `listDpEvents`) with the domain
/// `SessionRepository`. Same boundary rule as the other features:
/// SDK types stay in this file; the presentation layer never imports
/// `app_api_client`.
class SessionRepositoryImpl implements SessionRepository {
  const SessionRepositoryImpl({required api_client.GameSessionsApi api}) : _api = api;

  final api_client.GameSessionsApi _api;

  // ── Implementation ──────────────────────────────────────────────────────

  @override
  Future<List<GameSession>> list({String? status, int limit = 20}) async {
    final res = await _api.listGameSessions(
      limit: limit,
      status: status == null ? null : api_client.GameSessionStatus.valueOf(status),
    );
    final list = res.data;
    if (list == null) return const [];
    return list.items.map(GameSessionApiMapper.toDomain).toList(growable: false);
  }

  @override
  Future<GameSession> get(String id) async {
    final res = await _api.getGameSession(id: id);
    final s = res.data;
    if (s == null) throw StateError('GET game-session returned empty body');
    return GameSessionApiMapper.toDomain(s);
  }

  @override
  Future<GameSession> create({required String name, String? description}) async {
    final body = api_client.GameSessionCreate(
      (b) => b
        ..name = name
        ..description = description,
    );
    final res = await _api.createGameSession(gameSessionCreate: body);
    final s = res.data;
    if (s == null) throw StateError('POST game-session returned empty body');
    return GameSessionApiMapper.toDomain(s);
  }

  @override
  Future<GameSession> setStatus(String id, String status) async {
    final body = api_client.GameSessionUpdate(
      (b) => b..status = api_client.GameSessionStatus.valueOf(status),
    );
    final res = await _api.updateGameSession(id: id, gameSessionUpdate: body);
    final s = res.data;
    if (s == null) throw StateError('PATCH game-session returned empty body');
    return GameSessionApiMapper.toDomain(s);
  }

  @override
  Future<void> delete(String id) async {
    await _api.deleteGameSession(id: id);
  }

  @override
  Future<GameSession> adjustDp(String sessionId, {required int delta, String? reason}) async {
    final body = api_client.DpAdjustment(
      (b) => b
        ..delta = delta
        ..reason = reason,
    );
    final res = await _api.adjustDp(id: sessionId, dpAdjustment: body);
    final s = res.data;
    if (s == null) throw StateError('Adjust-DP returned empty body');
    return GameSessionApiMapper.toDomain(s);
  }

  @override
  Future<List<DpEvent>> listDpEvents(String sessionId, {int limit = 20}) async {
    final res = await _api.listDpEvents(id: sessionId, limit: limit);
    final list = res.data;
    if (list == null) return const [];
    return list.items.map(GameSessionApiMapper.dpEventToDomain).toList(growable: false);
  }

  // ── Invite management (Phase 8 Stream A, GM only) ─────────────────────────

  @override
  Future<domain.InviteMetadata> getInviteMetadata(String sessionId) async {
    final res = await _api.getInviteMetadata(id: sessionId);
    final d = res.data;
    if (d == null) throw StateError('GET invite-metadata returned empty body');
    return domain.InviteMetadata(active: d.active, rotatedAt: d.rotatedAt);
  }

  @override
  Future<domain.InviteRotated> rotateInvite(String sessionId) async {
    final res = await _api.rotateInvite(id: sessionId);
    final d = res.data;
    if (d == null) throw StateError('POST rotate-invite returned empty body');
    return domain.InviteRotated(
      url: d.url,
      token: d.token,
      rotatedAt: d.rotatedAt,
    );
  }

  @override
  Future<void> revokeInvite(String sessionId) async {
    await _api.revokeInvite(id: sessionId);
  }

  @override
  Future<void> removeMember(String sessionId, String membershipId) async {
    await _api.removeMembership(id: sessionId, membershipId: membershipId);
  }
}

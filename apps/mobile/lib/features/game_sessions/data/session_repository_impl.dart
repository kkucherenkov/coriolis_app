import 'package:app_api_client/app_api_client.dart' as api_client
    show
        GameSession,
        GameSessionsApi,
        GameSessionStatus,
        GameSessionCreate,
        GameSessionUpdate,
        AssignCharacterToSession,
        DpAdjustment,
        DpEvent;

import 'package:coriolis_companion/features/game_sessions/domain/game_session.dart';
import 'package:coriolis_companion/features/game_sessions/domain/session_repository.dart';

/// Adapter bridging `GameSessionsApi` (which on the Dart side hosts the
/// DP endpoints too — `adjustDp`, `listDpEvents`) with the domain
/// `SessionRepository`. Same boundary rule as the other features:
/// SDK types stay in this file; the presentation layer never imports
/// `app_api_client`.
class SessionRepositoryImpl implements SessionRepository {
  const SessionRepositoryImpl({required api_client.GameSessionsApi api}) : _api = api;

  final api_client.GameSessionsApi _api;

  // ── Mapping ─────────────────────────────────────────────────────────────

  static GameSession _toDomain(api_client.GameSession src) => GameSession(
        id: src.id,
        ownerId: src.ownerId,
        name: src.name,
        description: src.description,
        status: src.status.name,
        dpCount: src.dpCount,
        characterIds: src.characterIds.toList(growable: false),
        shipId: src.shipId,
        createdAt: src.createdAt,
        updatedAt: src.updatedAt,
      );

  static DpEvent _toDpEvent(api_client.DpEvent src) => DpEvent(
        id: src.id,
        gameSessionId: src.gameSessionId,
        delta: src.delta,
        // The Dart codegen renames `source` → `source_` (built_value
        // collision avoidance). Wire name is unchanged.
        source: src.source_.name,
        reason: src.reason,
        rollId: src.rollId,
        createdAt: src.createdAt,
      );

  // ── Implementation ──────────────────────────────────────────────────────

  @override
  Future<List<GameSession>> list({String? status, int limit = 20}) async {
    final res = await _api.listGameSessions(
      limit: limit,
      status: status == null ? null : api_client.GameSessionStatus.valueOf(status),
    );
    final list = res.data;
    if (list == null) return const [];
    return list.items.map(_toDomain).toList(growable: false);
  }

  @override
  Future<GameSession> get(String id) async {
    final res = await _api.getGameSession(id: id);
    final s = res.data;
    if (s == null) throw StateError('GET game-session returned empty body');
    return _toDomain(s);
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
    return _toDomain(s);
  }

  @override
  Future<GameSession> setStatus(String id, String status) async {
    final body = api_client.GameSessionUpdate(
      (b) => b..status = api_client.GameSessionStatus.valueOf(status),
    );
    final res = await _api.updateGameSession(id: id, gameSessionUpdate: body);
    final s = res.data;
    if (s == null) throw StateError('PATCH game-session returned empty body');
    return _toDomain(s);
  }

  @override
  Future<void> delete(String id) async {
    await _api.deleteGameSession(id: id);
  }

  @override
  Future<GameSession> assignCharacter(String sessionId, String characterId) async {
    final body = api_client.AssignCharacterToSession(
      (b) => b..characterId = characterId,
    );
    final res = await _api.assignCharacterToSession(
      id: sessionId,
      assignCharacterToSession: body,
    );
    final s = res.data;
    if (s == null) throw StateError('Assign-character returned empty body');
    return _toDomain(s);
  }

  @override
  Future<void> unassignCharacter(String sessionId, String characterId) async {
    await _api.unassignCharacterFromSession(id: sessionId, characterId: characterId);
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
    return _toDomain(s);
  }

  @override
  Future<List<DpEvent>> listDpEvents(String sessionId, {int limit = 20}) async {
    final res = await _api.listDpEvents(id: sessionId, limit: limit);
    final list = res.data;
    if (list == null) return const [];
    return list.items.map(_toDpEvent).toList(growable: false);
  }
}

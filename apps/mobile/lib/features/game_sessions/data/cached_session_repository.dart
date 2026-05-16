import 'package:dio/dio.dart';

import 'package:coriolis_companion/features/game_sessions/data/game_session_api_mapper.dart';
import 'package:coriolis_companion/features/game_sessions/data/game_session_cache.dart';
import 'package:coriolis_companion/features/game_sessions/domain/game_session.dart';
import 'package:coriolis_companion/features/game_sessions/domain/invite.dart';
import 'package:coriolis_companion/features/game_sessions/domain/session_repository.dart';

/// Read-through cache decorator over a remote [SessionRepository].
///
/// **Reads** — `list()` and `get(id)` first try the remote. On a network
/// `DioException` the call falls back to [LocalGameSessionCache]. Non-network
/// failures propagate unchanged. A cache miss on the fallback path rethrows
/// the original network error.
///
/// **Sub-resources** — `listDpEvents` and `getInviteMetadata` are remote-only:
/// DP events are an ordered audit log that would be misleading when stale, and
/// invite metadata is only useful live (the URL is single-use and only returned
/// once by `rotateInvite`). Neither is worth caching.
///
/// **Writes** — every mutation forwards to remote; on success the cache row for
/// the affected session is invalidated via [LocalGameSessionCache.delete]. The
/// next `get()` re-fetches and the interceptor refills the cache. Mutations
/// while offline are NOT queued here — that is handled by the write-queue
/// (Phase 7 Block 2).
///
/// **List cache** — `list()` falls back to `cache.readAll()` without applying
/// the `status` filter. The list cache is a "last-known sessions" snapshot;
/// status filtering is a server-side operation and cannot be reliably replicated
/// offline from the partial cached set.
class CachedSessionRepository implements SessionRepository {
  CachedSessionRepository({
    required SessionRepository remote,
    required LocalGameSessionCache cache,
  })  : _remote = remote,
        _cache = cache;

  final SessionRepository _remote;
  final LocalGameSessionCache _cache;

  static const _networkTypes = {
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
  };

  bool _isNetwork(Object e) =>
      e is DioException && _networkTypes.contains(e.type);

  // ── Reads ─────────────────────────────────────────────────────────────────

  @override
  Future<List<GameSession>> list({String? status, int limit = 20}) async {
    try {
      return await _remote.list(status: status, limit: limit);
    } catch (e) {
      if (!_isNetwork(e)) rethrow;
      // Status filtering is not applied to the cache fallback — the cached
      // list is a last-known snapshot; applying a client-side filter on an
      // incomplete dataset would silently hide sessions.
      final cached = await _cache.readAll();
      return cached.map(GameSessionApiMapper.toDomain).toList(growable: false);
    }
  }

  @override
  Future<GameSession> get(String id) async {
    try {
      return await _remote.get(id);
    } catch (e) {
      if (!_isNetwork(e)) rethrow;
      final cached = await _cache.read(id);
      if (cached == null) rethrow;
      return GameSessionApiMapper.toDomain(cached);
    }
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  @override
  Future<GameSession> create({required String name, String? description}) async {
    final created = await _remote.create(name: name, description: description);
    await _cache.delete(created.id);
    return created;
  }

  @override
  Future<GameSession> setStatus(String id, String status) async {
    final updated = await _remote.setStatus(id, status);
    await _cache.delete(id);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await _remote.delete(id);
    await _cache.delete(id);
  }

  @override
  Future<GameSession> adjustDp(
    String sessionId, {
    required int delta,
    String? reason,
  }) async {
    final updated = await _remote.adjustDp(sessionId, delta: delta, reason: reason);
    await _cache.delete(sessionId);
    return updated;
  }

  // ── Sub-resources (remote-only, not cached) ────────────────────────────────

  /// DP events are an ordered audit log — a stale snapshot would be misleading.
  /// Remote-only; no cache fallback.
  @override
  Future<List<DpEvent>> listDpEvents(String sessionId, {int limit = 20}) =>
      _remote.listDpEvents(sessionId, limit: limit);

  /// Invite metadata is only actionable live (rotate/revoke). Remote-only.
  @override
  Future<InviteMetadata> getInviteMetadata(String sessionId) =>
      _remote.getInviteMetadata(sessionId);

  @override
  Future<InviteRotated> rotateInvite(String sessionId) async {
    final result = await _remote.rotateInvite(sessionId);
    await _cache.delete(sessionId);
    return result;
  }

  @override
  Future<void> revokeInvite(String sessionId) async {
    await _remote.revokeInvite(sessionId);
    await _cache.delete(sessionId);
  }
}

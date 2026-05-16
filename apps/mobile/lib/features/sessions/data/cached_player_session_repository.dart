import 'package:dio/dio.dart';

import 'package:coriolis_companion/features/sessions/data/player_membership_api_mapper.dart';
import 'package:coriolis_companion/features/sessions/data/player_membership_cache.dart';
import 'package:coriolis_companion/features/sessions/domain/invite_preview.dart';
import 'package:coriolis_companion/features/sessions/domain/player_membership.dart';
import 'package:coriolis_companion/features/sessions/domain/player_session_repository.dart';

/// Read-through cache decorator over a remote [PlayerSessionRepository].
///
/// **`getMyMemberships`** — tries remote first; on a network [DioException]
/// falls back to [LocalPlayerMembershipCache]. Non-network errors propagate.
/// An empty cache on fallback returns `[]` — unlike the single-entity case,
/// an empty list is a valid offline state.
///
/// **Write-through note:** Cache population is intentionally left to the
/// [PlayerMembershipsCacheInterceptor] (option b). The decorator owns only:
///   - read fallback (getMyMemberships offline → cache)
///   - write invalidation on mutations (acceptInvite clears all; leaveSession
///     deletes one row)
///
/// This mirrors the [CachedCharacterRepository] pattern where the interceptor
/// handles write-through and the decorator handles read fallback + invalidation.
class CachedPlayerSessionRepository implements PlayerSessionRepository {
  CachedPlayerSessionRepository({
    required PlayerSessionRepository remote,
    required LocalPlayerMembershipCache cache,
  })  : _remote = remote,
        _cache = cache;

  final PlayerSessionRepository _remote;
  final LocalPlayerMembershipCache _cache;

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
  Future<List<PlayerMembership>> getMyMemberships() async {
    try {
      return await _remote.getMyMemberships();
    } catch (e) {
      if (!_isNetwork(e)) rethrow;
      final cached = await _cache.readAll();
      // Empty cache on fallback is a valid offline state — do not rethrow.
      return cached
          .map(PlayerMembershipApiMapper.fromSummary)
          .toList(growable: false);
    }
  }

  // ── Pass-throughs (no caching value) ─────────────────────────────────────

  @override
  Future<InvitePreview> getInvitePreview(String token) =>
      _remote.getInvitePreview(token);

  // ── Writes with cache invalidation ───────────────────────────────────────

  @override
  Future<PlayerMembership> acceptInvite(String token,
      {String? characterId}) async {
    final result = await _remote.acceptInvite(token, characterId: characterId);
    // Clear the entire cache; the next getMyMemberships() will repopulate
    // via the interceptor with the current server state.
    final stale = await _cache.readAll();
    for (final m in stale) {
      await _cache.delete(m.membershipId);
    }
    return result;
  }

  @override
  Future<void> leaveSession(String membershipId, String gameSessionId) async {
    await _remote.leaveSession(membershipId, gameSessionId);
    await _cache.delete(membershipId);
  }
}

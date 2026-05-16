import 'package:dio/dio.dart';

import 'package:coriolis_companion/features/npcs/data/npc_api_mapper.dart';
import 'package:coriolis_companion/features/npcs/data/npc_cache.dart';
import 'package:coriolis_companion/features/npcs/domain/npc_repository.dart';
import 'package:coriolis_companion/features/npcs/domain/npc_summary.dart';

/// Read-through cache decorator over a remote [NpcRepository].
///
/// **`list`** — tries remote first; on a network [DioException]
/// falls back to [LocalNpcCache]. Non-network errors propagate.
/// An empty cache on fallback returns `[]` — an empty list is a valid
/// offline state for a list view.
///
/// **Write-through note:** Cache population is intentionally left to the
/// [NpcsCacheInterceptor] (option b). The decorator owns only the read
/// fallback. This mirrors the [CachedPlayerSessionRepository] decision where
/// the interceptor handles write-through and the decorator handles read fallback.
class CachedNpcRepository implements NpcRepository {
  CachedNpcRepository({
    required NpcRepository remote,
    required LocalNpcCache cache,
  })  : _remote = remote,
        _cache = cache;

  final NpcRepository _remote;
  final LocalNpcCache _cache;

  static const _networkTypes = {
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
  };

  bool _isNetwork(Object e) =>
      e is DioException && _networkTypes.contains(e.type);

  @override
  Future<List<NpcSummary>> list({int limit = 20}) async {
    try {
      return await _remote.list(limit: limit);
    } catch (e) {
      if (!_isNetwork(e)) rethrow;
      final cached = await _cache.readAll();
      // Empty cache on fallback is a valid offline state — do not rethrow.
      return cached
          .map(NpcApiMapper.fromWire)
          .toList(growable: false);
    }
  }
}

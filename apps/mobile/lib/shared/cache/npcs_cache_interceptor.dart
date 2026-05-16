import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:app_api_client/app_api_client.dart' show standardSerializers;
import 'package:dio/dio.dart';

import 'package:coriolis_companion/features/npcs/data/npc_cache.dart';

/// Sniffs successful `GET /npcs` responses and writes each wire item
/// into [LocalNpcCache].
///
/// Decoupled from the repository layer so [NpcRepository] stays free
/// of caching concerns; the [CachedNpcRepository] decorator only
/// reads from the cache on the fallback path.
///
/// Cache failures never propagate to the request flow — a flaky disk must
/// not break a user-visible network call.
///
/// Stale-row strategy: new rows are upserted (insertOnConflictUpdate) but
/// deleted NPCs are NOT purged here. The UI only renders NPCs from the
/// freshly-fetched domain list; stale cached rows are invisible until
/// the next successful remote fetch repopulates via this interceptor.
class NpcsCacheInterceptor extends Interceptor {
  NpcsCacheInterceptor({required LocalNpcCache cache}) : _cache = cache;

  final LocalNpcCache _cache;

  // Matches exactly `/npcs` (no trailing slash, no id segment).
  // Works for both the real Dio path (`/api/v1/npcs`) and the
  // short form used in unit tests (`/npcs`).
  static final RegExp _listPath = RegExp(r'(^|/)npcs$');

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final req = response.requestOptions;
    final shouldCache = req.method == 'GET' &&
        response.statusCode == 200 &&
        _listPath.hasMatch(req.path) &&
        response.data is Map<String, dynamic>;

    if (shouldCache) {
      // Fire-and-forget — cache I/O must never block the response.
      _writeSafe(response.data as Map<String, dynamic>);
    }
    handler.next(response);
  }

  Future<void> _writeSafe(Map<String, dynamic> data) async {
    try {
      final rawItems = data['items'];
      if (rawItems is! List<dynamic>) return;
      for (final rawItem in rawItems) {
        final wire = standardSerializers.deserializeWith(
          api_client.Npc.serializer,
          rawItem,
        );
        if (wire != null) {
          await _cache.write(wire);
        }
      }
    } catch (_) {
      // Intentional swallow — cache errors must not break the request flow.
    }
  }
}

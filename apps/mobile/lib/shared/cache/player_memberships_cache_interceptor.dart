import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:app_api_client/app_api_client.dart' show standardSerializers;
import 'package:dio/dio.dart';

import 'package:coriolis_companion/features/sessions/data/player_membership_cache.dart';

/// Sniffs successful `GET /me/memberships` responses and writes each wire item
/// into [LocalPlayerMembershipCache].
///
/// Decoupled from the repository layer so [PlayerSessionRepository] stays free
/// of caching concerns; the [CachedPlayerSessionRepository] decorator only
/// reads from the cache on the fallback path.
///
/// Cache failures never propagate to the request flow — a flaky disk must
/// not break a user-visible network call.
///
/// Stale-row strategy: new rows are upserted (insertOnConflictUpdate) but
/// deleted memberships are NOT purged here. The UI only renders memberships
/// from the freshly-fetched domain list; stale cached rows are invisible until
/// the next successful remote fetch repopulates via this interceptor.
class PlayerMembershipsCacheInterceptor extends Interceptor {
  PlayerMembershipsCacheInterceptor({required LocalPlayerMembershipCache cache})
      : _cache = cache;

  final LocalPlayerMembershipCache _cache;

  // Matches exactly `/me/memberships` (no trailing slash, no id segment).
  // Works for both the real Dio path (`/api/v1/me/memberships`) and the
  // short form used in unit tests (`/me/memberships`).
  static final RegExp _listPath = RegExp(r'(^|/)me/memberships$');

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
          api_client.MyMembershipSummary.serializer,
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

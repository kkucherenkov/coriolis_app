import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:app_api_client/app_api_client.dart' show standardSerializers;
import 'package:dio/dio.dart';

import 'package:coriolis_companion/features/ships/data/ship_cache.dart';

/// Sniffs successful `GET /ships/{id}` responses and writes the wire
/// payload into [LocalShipCache].
///
/// Decoupled from the repository layer so the `ShipRepository` port
/// stays free of caching concerns; the decorator only consumes the cache
/// on the read-fallback path.
///
/// Cache failures never propagate to the request flow — a flaky disk must
/// not break a user-visible network call.
class ShipCacheInterceptor extends Interceptor {
  ShipCacheInterceptor({required LocalShipCache cache}) : _cache = cache;

  final LocalShipCache _cache;

  // Matches `/ships/<id>` (no trailing slash, no further segments).
  static final RegExp _idPath = RegExp(r'^/ships/[^/]+$');

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final req = response.requestOptions;
    final shouldCache = req.method == 'GET' &&
        response.statusCode == 200 &&
        _idPath.hasMatch(req.path) &&
        response.data is Map<String, dynamic>;

    if (shouldCache) {
      // Fire-and-forget — cache I/O must never block the response.
      _writeSafe(response.data as Map<String, dynamic>);
    }
    handler.next(response);
  }

  Future<void> _writeSafe(Map<String, dynamic> data) async {
    try {
      final wire = standardSerializers.deserializeWith(
        api_client.Ship.serializer,
        data,
      );
      if (wire != null) {
        await _cache.write(wire);
      }
    } catch (_) {
      // Intentional swallow — cache errors must not break the request flow.
    }
  }
}

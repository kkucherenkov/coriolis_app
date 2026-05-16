import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'package:coriolis_companion/shared/queue/mutation_queue.dart';

/// Catches PATCH / PUT / DELETE that cannot reach the server and persists them
/// to [LocalMutationQueue]. The caller receives a synthetic 200 `{}` response
/// so optimistic UI does not roll back.
///
/// Mirrors `apps/web/app/plugins/api-client.client.ts` from T-2026-05-11-008.
///
/// **Two trigger paths.**
/// - `onRequest`: skips the call entirely when connectivity is already gone,
///   avoiding a full `connectionTimeout` round-trip on a flaky network.
/// - `onError`: catches mid-flight network failures connectivity_plus did not
///   predict (captive portal, DNS hiccup, server unreachable).
///
/// **Synthetic resolve, not re-throw.** `handler.resolve(response, true)`
/// short-circuits with a fake success so generated SDK code continues without
/// error. Optimistic UI spread-merges local state on success; an empty `{}`
/// echo is a no-op against that.
///
/// **Authorization stripped on persist.** The bearer token at replay time is
/// current; the one captured here may have expired. The auth interceptor
/// (registered earlier in the chain) re-injects a fresh one on replay.
///
/// **Drainer bypass.** Requests with `extra['skipMutationQueue'] == true` pass
/// through unconditionally so the drainer's own replay calls do not re-enqueue
/// on failure.
class MutationQueueInterceptor extends Interceptor {
  MutationQueueInterceptor({
    required LocalMutationQueue queue,
    required Connectivity connectivity,
  })  : _queue = queue,
        _connectivity = connectivity;

  final LocalMutationQueue _queue;
  final Connectivity _connectivity;

  static const _queueable = {'PATCH', 'PUT', 'DELETE'};

  static const _networkErrorTypes = {
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
  };

  bool _isQueueable(String method) => _queueable.contains(method.toUpperCase());

  bool _isNetworkError(DioException err) =>
      _networkErrorTypes.contains(err.type);

  Future<bool> _isOffline() async {
    final results = await _connectivity.checkConnectivity();
    // connectivity_plus 6.x returns List<ConnectivityResult>.
    // "offline" means empty OR every result is `none`.
    if (results.isEmpty) return true;
    return results.every((r) => r == ConnectivityResult.none);
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isQueueable(options.method)) return handler.next(options);
    if (options.extra['skipMutationQueue'] == true) return handler.next(options);
    if (await _isOffline()) {
      await _enqueue(options);
      return handler.resolve(_syntheticAck(options), true);
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;
    if (!_isQueueable(req.method) ||
        req.extra['skipMutationQueue'] == true ||
        !_isNetworkError(err)) {
      return handler.next(err);
    }
    await _enqueue(req);
    handler.resolve(_syntheticAck(req));
  }

  Future<void> _enqueue(RequestOptions options) async {
    final body = _serializeBody(options.data);
    final headers = <String, String>{};
    options.headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization') return;
      if (value == null) return;
      headers[key] = value.toString();
    });
    await _queue.enqueue(
      method: options.method.toUpperCase(),
      path: options.path,
      body: body,
      headers: headers,
    );
  }

  String? _serializeBody(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is List<int>) return utf8.decode(data, allowMalformed: true);
    return jsonEncode(data);
  }

  Response<dynamic> _syntheticAck(RequestOptions options) {
    return Response<dynamic>(
      requestOptions: options,
      statusCode: 200,
      statusMessage: 'OK (queued offline)',
      data: <String, dynamic>{},
      headers: Headers.fromMap(const {
        'content-type': ['application/json'],
      }),
    );
  }
}

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'package:coriolis_companion/features/characters/data/character_cache.dart';
import 'package:coriolis_companion/shared/auth/token_storage.dart';
import 'package:coriolis_companion/shared/cache/character_cache_interceptor.dart';
import 'package:coriolis_companion/shared/config/app_config.dart';
import 'package:coriolis_companion/shared/queue/mutation_queue.dart';
import 'package:coriolis_companion/shared/queue/mutation_queue_interceptor.dart';

/// Builds the shared [Dio] with a bearer-token interceptor and an optional
/// write-through cache interceptor for `GET /characters/{id}` responses.
///
/// Interceptor order:
/// 1. Auth interceptor — injects `Authorization` header.
/// 2. [MutationQueueInterceptor] — sees the authed request; persists offline
///    mutations (auth stripped) and returns a synthetic 200 on enqueue.
/// 3. [CharacterCacheInterceptor] — only runs on real network responses.
///
/// Registered in `lib/shared/di/injector.dart`; domain and presentation code
/// must never import `dio` directly — only `features/*/data/` consumes this.
Dio buildDio({
  required AppConfig config,
  required TokenStorage tokenStorage,
  required LocalCharacterCache characterCache,
  required LocalMutationQueue mutationQueue,
  required Connectivity connectivity,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: const {'Accept': 'application/json'},
    ),
  );

  // 1. Auth interceptor.
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // 401 → drop any stale token so the next interceptor pass sends an
        // unauthenticated request. Re-auth is the presentation layer's job.
        if (error.response?.statusCode == 401) {
          await tokenStorage.clear();
        }
        handler.next(error);
      },
    ),
  );

  // 2. Offline mutation queue interceptor — must come after auth so the
  //    auth header is already present when we decide to enqueue (we strip it
  //    on persist; the drainer re-injects a fresh one at replay time).
  dio.interceptors.add(
    MutationQueueInterceptor(queue: mutationQueue, connectivity: connectivity),
  );

  // 3. Read-cache interceptor — only sees real network responses.
  dio.interceptors.add(CharacterCacheInterceptor(cache: characterCache));

  return dio;
}

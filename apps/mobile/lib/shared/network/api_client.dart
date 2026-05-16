import 'package:dio/dio.dart';

import 'package:coriolis_companion/features/characters/data/character_cache.dart';
import 'package:coriolis_companion/shared/auth/token_storage.dart';
import 'package:coriolis_companion/shared/cache/character_cache_interceptor.dart';
import 'package:coriolis_companion/shared/config/app_config.dart';

/// Builds the shared [Dio] with a bearer-token interceptor and an optional
/// write-through cache interceptor for `GET /characters/{id}` responses.
///
/// Registered in `lib/shared/di/injector.dart`; domain and presentation code
/// must never import `dio` directly — only `features/*/data/` consumes this.
Dio buildDio({
  required AppConfig config,
  required TokenStorage tokenStorage,
  required LocalCharacterCache characterCache,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: const {'Accept': 'application/json'},
    ),
  );

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

  dio.interceptors.add(CharacterCacheInterceptor(cache: characterCache));

  return dio;
}

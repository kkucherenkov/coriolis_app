//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:built_value/serializer.dart';
import 'package:app_api_client/src/serializers.dart';
import 'package:app_api_client/src/auth/api_key_auth.dart';
import 'package:app_api_client/src/auth/basic_auth.dart';
import 'package:app_api_client/src/auth/bearer_auth.dart';
import 'package:app_api_client/src/auth/oauth.dart';
import 'package:app_api_client/src/api/characters_api.dart';
import 'package:app_api_client/src/api/dice_api.dart';
import 'package:app_api_client/src/api/game_sessions_api.dart';
import 'package:app_api_client/src/api/npcs_api.dart';
import 'package:app_api_client/src/api/public_api.dart';
import 'package:app_api_client/src/api/realtime_api.dart';
import 'package:app_api_client/src/api/sharing_api.dart';
import 'package:app_api_client/src/api/ships_api.dart';
import 'package:app_api_client/src/api/system_api.dart';
import 'package:app_api_client/src/api/users_api.dart';

class AppApiClient {
  static const String basePath = r'http://localhost:3010';

  final Dio dio;
  final Serializers serializers;

  AppApiClient({
    Dio? dio,
    Serializers? serializers,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : this.serializers = serializers ?? standardSerializers,
        this.dio = dio ??
            Dio(BaseOptions(
              baseUrl: basePathOverride ?? basePath,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens[name] = token;
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens[name] = token;
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo[name] = BasicAuthInfo(username, password);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys[name] = apiKey;
    }
  }

  /// Get CharactersApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  CharactersApi getCharactersApi() {
    return CharactersApi(dio, serializers);
  }

  /// Get DiceApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DiceApi getDiceApi() {
    return DiceApi(dio, serializers);
  }

  /// Get GameSessionsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  GameSessionsApi getGameSessionsApi() {
    return GameSessionsApi(dio, serializers);
  }

  /// Get NpcsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  NpcsApi getNpcsApi() {
    return NpcsApi(dio, serializers);
  }

  /// Get PublicApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  PublicApi getPublicApi() {
    return PublicApi(dio, serializers);
  }

  /// Get RealtimeApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  RealtimeApi getRealtimeApi() {
    return RealtimeApi(dio, serializers);
  }

  /// Get SharingApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SharingApi getSharingApi() {
    return SharingApi(dio, serializers);
  }

  /// Get ShipsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ShipsApi getShipsApi() {
    return ShipsApi(dio, serializers);
  }

  /// Get SystemApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SystemApi getSystemApi() {
    return SystemApi(dio, serializers);
  }

  /// Get UsersApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  UsersApi getUsersApi() {
    return UsersApi(dio, serializers);
  }
}

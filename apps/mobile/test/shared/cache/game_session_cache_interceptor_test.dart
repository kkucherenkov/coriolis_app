import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:app_api_client/app_api_client.dart' show standardSerializers;
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/game_sessions/data/game_session_cache.dart';
import 'package:coriolis_companion/shared/cache/game_session_cache_interceptor.dart';

class _MockCache extends Mock implements LocalGameSessionCache {}

api_client.GameSession _wire({
  String id = 'session-1',
  String name = 'The Dying Ship',
}) =>
    api_client.$GameSession((b) => b
      ..id = id
      ..ownerId = 'user-1'
      ..name = name
      ..status = api_client.GameSessionStatus.active
      ..dpCount = 0
      ..characterIds.replace(BuiltList<String>())
      ..memberships.replace(BuiltList<api_client.GameSessionMembership>())
      ..createdAt = DateTime.utc(2026, 5, 16)
      ..updatedAt = DateTime.utc(2026, 5, 17));

Map<String, dynamic> _wireJson() {
  return standardSerializers.serializeWith(
    api_client.GameSession.serializer,
    _wire(),
  ) as Map<String, dynamic>;
}

void main() {
  late _MockCache cache;
  late GameSessionCacheInterceptor sut;

  setUp(() {
    cache = _MockCache();
    sut = GameSessionCacheInterceptor(cache: cache);
    registerFallbackValue(_wire());
  });

  test('writes wire payload on GET /game-sessions/{id} 200', () async {
    when(() => cache.write(any())).thenAnswer((_) async {});
    final response = Response<Map<String, dynamic>>(
      requestOptions:
          RequestOptions(path: '/game-sessions/session-1', method: 'GET'),
      statusCode: 200,
      data: _wireJson(),
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    verify(() => cache.write(any())).called(1);
  });

  test('skips sub-resource paths like /game-sessions/{id}/characters', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(
        path: '/game-sessions/session-1/characters',
        method: 'GET',
      ),
      statusCode: 200,
      data: {'items': <dynamic>[]},
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => cache.write(any()));
  });

  test('skips non-GET methods', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions:
          RequestOptions(path: '/game-sessions/session-1', method: 'PATCH'),
      statusCode: 200,
      data: _wireJson(),
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => cache.write(any()));
  });

  test('skips non-200 responses', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions:
          RequestOptions(path: '/game-sessions/session-1', method: 'GET'),
      statusCode: 404,
      data: null,
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => cache.write(any()));
  });

  test('skips list endpoint /game-sessions (no id segment)', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions:
          RequestOptions(path: '/game-sessions', method: 'GET'),
      statusCode: 200,
      data: {'items': <dynamic>[]},
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => cache.write(any()));
  });

  test('cache write failure does NOT propagate to request flow', () async {
    when(() => cache.write(any())).thenThrow(StateError('disk full'));
    final response = Response<Map<String, dynamic>>(
      requestOptions:
          RequestOptions(path: '/game-sessions/session-1', method: 'GET'),
      statusCode: 200,
      data: _wireJson(),
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);

    expect(handler.capturedError, isNull);
    expect(handler.capturedNext, equals(response));
  });
}

class _CapturingResponseHandler extends ResponseInterceptorHandler {
  Response<dynamic>? capturedNext;
  DioException? capturedError;

  @override
  void next(Response<dynamic> response) {
    capturedNext = response;
    super.next(response);
  }

  @override
  void reject(DioException err, [bool callFollowingErrorInterceptor = false]) {
    capturedError = err;
    super.reject(err, callFollowingErrorInterceptor);
  }
}

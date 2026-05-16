import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:app_api_client/app_api_client.dart' show standardSerializers;
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/characters/data/character_cache.dart';
import 'package:coriolis_companion/shared/cache/character_cache_interceptor.dart';

class _MockCache extends Mock implements LocalCharacterCache {}

api_client.Character _wire({String id = 'char-1', String name = 'Tael'}) =>
    api_client.Character((b) => b
      ..id = id
      ..ownerId = 'user-1'
      ..name = name
      ..upbringing = api_client.Upbringing.plebeian
      ..reputation = 0
      ..startingWealth = 0
      ..birr = 0
      ..mutant = false
      ..status = api_client.CharacterStatusEnum.draft
      ..attributes.replace(api_client.Attributes((a) => a
        ..strength = 3
        ..agility = 3
        ..wits = 3
        ..empathy = 3))
      ..skills.replace(api_client.Skills((s) => s
        ..dexterity = 0
        ..force = 0
        ..infiltration = 0
        ..manipulation = 0
        ..meleeCombat = 0
        ..observation = 0
        ..rangedCombat = 0
        ..survival = 0
        ..command = 0
        ..culture = 0
        ..dataDjinn = 0
        ..medicurgy = 0
        ..mysticPowers = 0
        ..pilot = 0
        ..science = 0
        ..technology = 0))
      ..hp.replace(api_client.CharacterHp((h) => h
        ..current = 5
        ..max = 5))
      ..mp.replace(api_client.CharacterMp((m) => m
        ..current = 5
        ..max = 5))
      ..encumbrance.replace(api_client.CharacterEncumbrance((e) => e
        ..current = 0
        ..max = 10))
      ..experience = 0
      ..conditions.replace(api_client.ConditionFlags((c) => c
        ..exhausted = false
        ..sleepless = false
        ..thirsty = false
        ..hungry = false))
      ..criticalInjuries.replace(BuiltList<api_client.CriticalInjury>())
      ..talents.replace(BuiltList<api_client.Talent>())
      ..relationships.replace(BuiltList<api_client.Relationship>())
      ..inventory.replace(BuiltList<api_client.Item>())
      ..updatedAt = DateTime.utc(2026, 5, 16)
      ..createdAt = DateTime.utc(2026, 5, 16));

Map<String, dynamic> _wireJson() {
  return standardSerializers.serializeWith(
    api_client.Character.serializer,
    _wire(),
  ) as Map<String, dynamic>;
}

void main() {
  late _MockCache cache;
  late CharacterCacheInterceptor sut;

  setUp(() {
    cache = _MockCache();
    sut = CharacterCacheInterceptor(cache: cache);
    registerFallbackValue(_wire());
  });

  test('writes the wire payload on GET /characters/{id} 200', () async {
    when(() => cache.write(any())).thenAnswer((_) async {});
    final response = Response<Map<String, dynamic>>(
      requestOptions:
          RequestOptions(path: '/characters/char-1', method: 'GET'),
      statusCode: 200,
      data: _wireJson(),
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    verify(() => cache.write(any())).called(1);
  });

  test('skips non-character paths', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/ships/ship-1', method: 'GET'),
      statusCode: 200,
      data: {'id': 'ship-1'},
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => cache.write(any()));
  });

  test('skips POST /characters/{id}', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions:
          RequestOptions(path: '/characters/char-1', method: 'POST'),
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
          RequestOptions(path: '/characters/char-1', method: 'GET'),
      statusCode: 404,
      data: null,
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => cache.write(any()));
  });

  test('skips list endpoint /characters (no id segment)', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/characters', method: 'GET'),
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
          RequestOptions(path: '/characters/char-1', method: 'GET'),
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

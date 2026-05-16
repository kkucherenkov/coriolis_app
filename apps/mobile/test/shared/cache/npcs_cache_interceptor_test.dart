import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:app_api_client/app_api_client.dart' show standardSerializers;
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/npcs/data/npc_cache.dart';
import 'package:coriolis_companion/shared/cache/npcs_cache_interceptor.dart';

class _MockCache extends Mock implements LocalNpcCache {}

api_client.Npc _wire({
  String id = 'npc-1',
  String name = 'Syndicate Guard',
}) =>
    api_client.Npc((b) => b
      ..id = id
      ..ownerId = 'user-1'
      ..name = name
      ..updatedAt = DateTime.utc(2026, 5, 17)
      ..createdAt = DateTime.utc(2026, 5, 17)
      ..attributes.update((ab) => ab
        ..strength = 3
        ..agility = 3
        ..wits = 2
        ..empathy = 2)
      ..skills.update((sb) => sb
        ..dexterity = 0
        ..force = 1
        ..infiltration = 0
        ..manipulation = 0
        ..meleeCombat = 1
        ..observation = 0
        ..rangedCombat = 2
        ..survival = 0
        ..command = 0
        ..culture = 0
        ..dataDjinn = 0
        ..medicurgy = 0
        ..mysticPowers = 0
        ..pilot = 0
        ..science = 0
        ..technology = 0)
      ..hp.update((hb) => hb
        ..current = 6
        ..max = 6)
      ..mp.update((mb) => mb
        ..current = 4
        ..max = 4)
      ..armor.replace(BuiltList<api_client.ItemArmor>())
      ..weapons.replace(BuiltList<api_client.ItemWeapon>())
      ..tags.replace(BuiltList<String>()));

dynamic _wireJson(api_client.Npc wire) =>
    standardSerializers.serializeWith(api_client.Npc.serializer, wire);

Map<String, dynamic> _envelope(List<api_client.Npc> items) => {
      'items': items.map(_wireJson).toList(),
    };

void main() {
  late _MockCache cache;
  late NpcsCacheInterceptor sut;

  setUp(() {
    cache = _MockCache();
    sut = NpcsCacheInterceptor(cache: cache);
    registerFallbackValue(_wire());
  });

  test('GET /npcs 200 with 2 items → cache.write called twice', () async {
    when(() => cache.write(any())).thenAnswer((_) async {});
    final response = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/npcs', method: 'GET'),
      statusCode: 200,
      data: _envelope([_wire(id: 'npc-1'), _wire(id: 'npc-2')]),
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    verify(() => cache.write(any())).called(2);
  });

  test('GET /npcs non-200 → no writes', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/npcs', method: 'GET'),
      statusCode: 404,
      data: null,
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => cache.write(any()));
  });

  test('non-GET POST /npcs → no writes', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/npcs', method: 'POST'),
      statusCode: 200,
      data: _envelope([_wire()]),
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => cache.write(any()));
  });

  test('path mismatch GET /npcs/abc → no writes', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/npcs/abc', method: 'GET'),
      statusCode: 200,
      data: {'items': <dynamic>[]},
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => cache.write(any()));
  });

  test('cache.write throws → handler.next still called with response', () async {
    when(() => cache.write(any())).thenThrow(StateError('disk full'));
    final response = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/npcs', method: 'GET'),
      statusCode: 200,
      data: _envelope([_wire()]),
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);
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

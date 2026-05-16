import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:app_api_client/app_api_client.dart' show standardSerializers;
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/ships/data/ship_cache.dart';
import 'package:coriolis_companion/shared/cache/ship_cache_interceptor.dart';

class _MockCache extends Mock implements LocalShipCache {}

api_client.Ship _wire({String id = 'ship-1', String name = 'Tannhauser Gate'}) =>
    api_client.Ship((b) => b
      ..id = id
      ..ownerId = 'user-1'
      ..name = name
      ..class_ = api_client.ShipClass.lightFreighter
      ..armor = 0
      ..maneuverability = 0
      ..signature = 0
      ..speed = 3
      ..cargoCapacity = 50
      ..hull.replace(api_client.ShipHull((h) => h
        ..current = 8
        ..max = 8))
      ..energy.replace(api_client.ShipEnergy((e) => e
        ..current = 6
        ..max = 6))
      ..modules.replace(BuiltList<api_client.ShipModule>())
      ..crew.replace(BuiltList<api_client.CrewSlot>())
      ..problems.replace(BuiltList<String>())
      ..createdAt = DateTime.utc(2026, 5, 17)
      ..updatedAt = DateTime.utc(2026, 5, 17));

Map<String, dynamic> _wireJson() =>
    standardSerializers.serializeWith(
      api_client.Ship.serializer,
      _wire(),
    ) as Map<String, dynamic>;

void main() {
  late _MockCache cache;
  late ShipCacheInterceptor sut;

  setUp(() {
    cache = _MockCache();
    sut = ShipCacheInterceptor(cache: cache);
    registerFallbackValue(_wire());
  });

  test('writes the wire payload on GET /ships/{id} 200', () async {
    when(() => cache.write(any())).thenAnswer((_) async {});
    final response = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/ships/ship-1', method: 'GET'),
      statusCode: 200,
      data: _wireJson(),
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    verify(() => cache.write(any())).called(1);
  });

  test('skips GET /ships (list — no id segment)', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/ships', method: 'GET'),
      statusCode: 200,
      data: {'items': <dynamic>[]},
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => cache.write(any()));
  });

  test('skips GET /ships/{id}/modules (sub-path)', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions:
          RequestOptions(path: '/ships/ship-1/modules', method: 'GET'),
      statusCode: 200,
      data: {'items': <dynamic>[]},
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => cache.write(any()));
  });

  test('skips POST /ships', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/ships/ship-1', method: 'POST'),
      statusCode: 200,
      data: _wireJson(),
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => cache.write(any()));
  });

  test('skips non-200 GET /ships/{id}', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/ships/ship-1', method: 'GET'),
      statusCode: 404,
      data: null,
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => cache.write(any()));
  });

  test('cache write failure does NOT propagate to request flow', () async {
    when(() => cache.write(any())).thenThrow(StateError('disk full'));
    final response = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/ships/ship-1', method: 'GET'),
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

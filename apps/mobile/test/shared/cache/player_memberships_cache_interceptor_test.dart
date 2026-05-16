import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:app_api_client/app_api_client.dart' show standardSerializers;
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/sessions/data/player_membership_cache.dart';
import 'package:coriolis_companion/shared/cache/player_memberships_cache_interceptor.dart';

class _MockCache extends Mock implements LocalPlayerMembershipCache {}

api_client.MyMembershipSummary _wire({
  String membershipId = 'mem-1',
  String sessionName = 'The Dying Ship',
}) =>
    api_client.MyMembershipSummary((b) => b
      ..membershipId = membershipId
      ..gameSessionId = 'gs-1'
      ..sessionName = sessionName
      ..role = api_client.GameSessionMemberRole.player
      ..joinedAt = DateTime.utc(2026, 5, 16));

dynamic _wireJson(api_client.MyMembershipSummary wire) =>
    standardSerializers.serializeWith(
      api_client.MyMembershipSummary.serializer,
      wire,
    );

Map<String, dynamic> _envelope(List<api_client.MyMembershipSummary> items) => {
      'items': items.map(_wireJson).toList(),
    };

void main() {
  late _MockCache cache;
  late PlayerMembershipsCacheInterceptor sut;

  setUp(() {
    cache = _MockCache();
    sut = PlayerMembershipsCacheInterceptor(cache: cache);
    registerFallbackValue(_wire());
  });

  test('GET /me/memberships 200 with 2 items → cache.write called twice',
      () async {
    when(() => cache.write(any())).thenAnswer((_) async {});
    final response = Response<Map<String, dynamic>>(
      requestOptions:
          RequestOptions(path: '/me/memberships', method: 'GET'),
      statusCode: 200,
      data: _envelope([_wire(membershipId: 'mem-1'), _wire(membershipId: 'mem-2')]),
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    verify(() => cache.write(any())).called(2);
  });

  test('GET /me/memberships non-200 → no writes', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions:
          RequestOptions(path: '/me/memberships', method: 'GET'),
      statusCode: 401,
      data: null,
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => cache.write(any()));
  });

  test('non-GET /me/memberships → no writes', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions:
          RequestOptions(path: '/me/memberships', method: 'POST'),
      statusCode: 200,
      data: _envelope([_wire()]),
    );
    final handler = _CapturingResponseHandler();

    sut.onResponse(response, handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => cache.write(any()));
  });

  test('path mismatch /me/memberships/abc → no writes', () async {
    final response = Response<Map<String, dynamic>>(
      requestOptions:
          RequestOptions(path: '/me/memberships/abc', method: 'GET'),
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
      requestOptions:
          RequestOptions(path: '/me/memberships', method: 'GET'),
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

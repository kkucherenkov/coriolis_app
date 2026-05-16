import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/sessions/data/cached_player_session_repository.dart';
import 'package:coriolis_companion/features/sessions/data/player_membership_cache.dart';
import 'package:coriolis_companion/features/sessions/domain/invite_preview.dart';
import 'package:coriolis_companion/features/sessions/domain/player_membership.dart';
import 'package:coriolis_companion/features/sessions/domain/player_session_repository.dart';

class _MockRemote extends Mock implements PlayerSessionRepository {}

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

PlayerMembership _domain({
  String membershipId = 'mem-1',
  String sessionName = 'The Dying Ship',
}) =>
    PlayerMembership(
      membershipId: membershipId,
      gameSessionId: 'gs-1',
      sessionName: sessionName,
      role: 'player',
      joinedAt: DateTime.utc(2026, 5, 16),
    );

DioException _networkError() => DioException(
      requestOptions: RequestOptions(path: '/me/memberships'),
      type: DioExceptionType.connectionError,
    );

DioException _badResponse(int status) => DioException(
      requestOptions: RequestOptions(path: '/me/memberships'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/me/memberships'),
        statusCode: status,
      ),
    );

void main() {
  late _MockRemote remote;
  late _MockCache cache;
  late CachedPlayerSessionRepository sut;

  setUp(() {
    remote = _MockRemote();
    cache = _MockCache();
    sut = CachedPlayerSessionRepository(remote: remote, cache: cache);
    registerFallbackValue(_wire());
    registerFallbackValue(_domain());
  });

  group('getMyMemberships', () {
    test('happy path — returns remote list, cache not read', () async {
      final memberships = [_domain()];
      when(() => remote.getMyMemberships()).thenAnswer((_) async => memberships);

      final result = await sut.getMyMemberships();

      expect(result, equals(memberships));
      verifyNever(() => cache.readAll());
    });

    test('network error → cache hit → returns mapped list', () async {
      when(() => remote.getMyMemberships()).thenThrow(_networkError());
      when(() => cache.readAll()).thenAnswer((_) async => [_wire()]);

      final result = await sut.getMyMemberships();

      expect(result.length, 1);
      expect(result.first.membershipId, 'mem-1');
      expect(result.first.sessionName, 'The Dying Ship');
    });

    test('network error → empty cache → returns [] (no rethrow)', () async {
      when(() => remote.getMyMemberships()).thenThrow(_networkError());
      when(() => cache.readAll()).thenAnswer((_) async => []);

      final result = await sut.getMyMemberships();

      expect(result, isEmpty);
    });

    test('4xx response → propagates (non-network error)', () async {
      final err = _badResponse(403);
      when(() => remote.getMyMemberships()).thenThrow(err);

      expect(() => sut.getMyMemberships(), throwsA(same(err)));
      verifyNever(() => cache.readAll());
    });
  });

  group('getInvitePreview', () {
    test('forwards to remote without touching cache', () async {
      const preview = InvitePreview(
        sessionName: 'Test',
        gmDisplayName: 'GM',
        alreadyJoined: false,
      );
      when(() => remote.getInvitePreview('tok-1'))
          .thenAnswer((_) async => preview);

      final result = await sut.getInvitePreview('tok-1');

      expect(result.sessionName, 'Test');
      verifyNever(() => cache.readAll());
      verifyNever(() => cache.write(any()));
      verifyNever(() => cache.delete(any()));
    });
  });

  group('acceptInvite', () {
    test('success → cache cleared (all rows deleted)', () async {
      final membership = _domain();
      when(() => remote.acceptInvite('tok-1', characterId: null))
          .thenAnswer((_) async => membership);
      when(() => cache.readAll()).thenAnswer(
        (_) async => [
          _wire(membershipId: 'mem-1'),
          _wire(membershipId: 'mem-2'),
        ],
      );
      when(() => cache.delete(any())).thenAnswer((_) async {});

      await sut.acceptInvite('tok-1');

      verify(() => cache.delete('mem-1')).called(1);
      verify(() => cache.delete('mem-2')).called(1);
    });
  });

  group('leaveSession', () {
    test('success → cache.delete called with membershipId', () async {
      when(() => remote.leaveSession('mem-1', 'gs-1'))
          .thenAnswer((_) async {});
      when(() => cache.delete('mem-1')).thenAnswer((_) async {});

      await sut.leaveSession('mem-1', 'gs-1');

      verify(() => remote.leaveSession('mem-1', 'gs-1')).called(1);
      verify(() => cache.delete('mem-1')).called(1);
    });
  });
}

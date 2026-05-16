import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/game_sessions/data/cached_session_repository.dart';
import 'package:coriolis_companion/features/game_sessions/data/game_session_api_mapper.dart';
import 'package:coriolis_companion/features/game_sessions/data/game_session_cache.dart';
import 'package:coriolis_companion/features/game_sessions/domain/game_session.dart';
import 'package:coriolis_companion/features/game_sessions/domain/invite.dart';
import 'package:coriolis_companion/features/game_sessions/domain/session_repository.dart';

class _MockRemote extends Mock implements SessionRepository {}

class _MockCache extends Mock implements LocalGameSessionCache {}

api_client.GameSession _wireSession({
  String id = 'session-1',
  String name = 'The Dying Ship',
}) =>
    api_client.$GameSession((b) => b
      ..id = id
      ..ownerId = 'user-1'
      ..name = name
      ..status = api_client.GameSessionStatus.active
      ..dpCount = 0
      ..memberships.replace(BuiltList<api_client.GameSessionMembership>())
      ..createdAt = DateTime.utc(2026, 5, 16)
      ..updatedAt = DateTime.utc(2026, 5, 17));

GameSession _domainSession({
  String id = 'session-1',
  String name = 'The Dying Ship',
}) =>
    GameSessionApiMapper.toDomain(_wireSession(id: id, name: name));

DioException _networkError(String path) => DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.connectionError,
    );

DioException _httpError(String path, int status) => DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: path),
        statusCode: status,
      ),
    );

void main() {
  late _MockRemote remote;
  late _MockCache cache;
  late CachedSessionRepository sut;

  setUp(() {
    remote = _MockRemote();
    cache = _MockCache();
    sut = CachedSessionRepository(remote: remote, cache: cache);
    registerFallbackValue(_wireSession());
  });

  group('get', () {
    test('happy path — returns remote result, does NOT touch cache', () async {
      final domain = _domainSession();
      when(() => remote.get('session-1')).thenAnswer((_) async => domain);

      final got = await sut.get('session-1');

      expect(got.id, 'session-1');
      verifyNever(() => cache.read(any()));
      verifyNever(() => cache.write(any()));
    });

    test('network error → cache hit → returns cached session', () async {
      when(() => remote.get('session-1'))
          .thenThrow(_networkError('/game-sessions/session-1'));
      when(() => cache.read('session-1'))
          .thenAnswer((_) async => _wireSession());

      final got = await sut.get('session-1');

      expect(got.id, 'session-1');
    });

    test('network error → cache miss → rethrows original error', () async {
      final err = _networkError('/game-sessions/session-1');
      when(() => remote.get('session-1')).thenThrow(err);
      when(() => cache.read('session-1')).thenAnswer((_) async => null);

      expect(() => sut.get('session-1'), throwsA(same(err)));
    });

    test('4xx (non-network) → propagates, does NOT touch cache', () async {
      final err = _httpError('/game-sessions/session-1', 404);
      when(() => remote.get('session-1')).thenThrow(err);

      expect(() => sut.get('session-1'), throwsA(same(err)));
      verifyNever(() => cache.read(any()));
    });
  });

  group('list', () {
    test('happy path — returns remote list', () async {
      when(() => remote.list(limit: 20)).thenAnswer(
        (_) async => [_domainSession()],
      );

      final sessions = await sut.list();

      expect(sessions.single.id, 'session-1');
      verifyNever(() => cache.readAll());
    });

    test('network error → falls back to cache.readAll', () async {
      when(() => remote.list(limit: 20))
          .thenThrow(_networkError('/game-sessions'));
      when(() => cache.readAll())
          .thenAnswer((_) async => [_wireSession(name: 'Offline Session')]);

      final sessions = await sut.list();

      expect(sessions.single.name, 'Offline Session');
      verify(() => cache.readAll()).called(1);
    });
  });

  group('setStatus', () {
    test('success → cache.delete(id) called once', () async {
      final updated = _domainSession();
      when(() => remote.setStatus('session-1', 'active'))
          .thenAnswer((_) async => updated);
      when(() => cache.delete('session-1')).thenAnswer((_) async {});

      await sut.setStatus('session-1', 'active');

      verify(() => cache.delete('session-1')).called(1);
    });
  });

  group('adjustDp', () {
    test('success → cache.delete(sessionId) called once', () async {
      final updated = _domainSession();
      when(() => remote.adjustDp('session-1', delta: 1))
          .thenAnswer((_) async => updated);
      when(() => cache.delete('session-1')).thenAnswer((_) async {});

      await sut.adjustDp('session-1', delta: 1);

      verify(() => cache.delete('session-1')).called(1);
    });
  });

  group('delete', () {
    test('success → cache.delete(id) called once', () async {
      when(() => remote.delete('session-1')).thenAnswer((_) async {});
      when(() => cache.delete('session-1')).thenAnswer((_) async {});

      await sut.delete('session-1');

      verify(() => remote.delete('session-1')).called(1);
      verify(() => cache.delete('session-1')).called(1);
    });
  });

  group('listDpEvents', () {
    test('does NOT touch cache — delegates directly to remote', () async {
      when(() => remote.listDpEvents('session-1', limit: 20))
          .thenAnswer((_) async => const []);

      await sut.listDpEvents('session-1');

      verifyNever(() => cache.read(any()));
      verifyNever(() => cache.readAll());
      verifyNever(() => cache.write(any()));
      verifyNever(() => cache.delete(any()));
    });
  });

  group('getInviteMetadata', () {
    test('does NOT touch cache — delegates directly to remote', () async {
      when(() => remote.getInviteMetadata('session-1')).thenAnswer(
        (_) async => const InviteMetadata(active: true),
      );

      await sut.getInviteMetadata('session-1');

      verifyNever(() => cache.read(any()));
      verifyNever(() => cache.readAll());
      verifyNever(() => cache.write(any()));
      verifyNever(() => cache.delete(any()));
    });
  });
}

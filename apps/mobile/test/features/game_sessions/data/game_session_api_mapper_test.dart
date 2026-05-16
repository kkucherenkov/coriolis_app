import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/features/game_sessions/data/game_session_api_mapper.dart';
import 'package:coriolis_companion/features/game_sessions/domain/game_session.dart';

api_client.GameSessionMembership _wireMember({
  String id = 'mem-1',
  String userId = 'user-1',
  api_client.GameSessionMemberRole role = api_client.GameSessionMemberRole.gm,
  String? displayName,
  String? characterId,
  String? characterName,
}) =>
    api_client.GameSessionMembership((b) => b
      ..id = id
      ..gameSessionId = 'session-1'
      ..userId = userId
      ..role = role
      ..displayName = displayName
      ..characterId = characterId
      ..characterName = characterName
      ..joinedAt = DateTime.utc(2026, 5, 16));

api_client.GameSession _wireSession({
  String id = 'session-1',
  String name = 'The Dying Ship',
  String? description,
  api_client.GameSessionStatus status = api_client.GameSessionStatus.active,
  int dpCount = 3,
  List<api_client.GameSessionMembership>? memberships,
}) =>
    api_client.$GameSession((b) => b
      ..id = id
      ..ownerId = 'user-1'
      ..name = name
      ..description = description
      ..status = status
      ..dpCount = dpCount
      ..memberships.replace(
        BuiltList<api_client.GameSessionMembership>(
          memberships ?? [_wireMember()],
        ),
      )
      ..createdAt = DateTime.utc(2026, 5, 16)
      ..updatedAt = DateTime.utc(2026, 5, 17));

api_client.DpEvent _wireDpEvent({
  String id = 'dp-1',
  String gameSessionId = 'session-1',
  int delta = 2,
  api_client.DpSource source = api_client.DpSource.gmManual,
  String? reason,
  String? rollId,
}) =>
    api_client.DpEvent((b) => b
      ..id = id
      ..gameSessionId = gameSessionId
      ..delta = delta
      ..source_ = source
      ..reason = reason
      ..rollId = rollId
      ..createdAt = DateTime.utc(2026, 5, 16));

void main() {
  group('GameSessionApiMapper.toDomain', () {
    test('maps scalar fields correctly', () {
      final GameSession domain =
          GameSessionApiMapper.toDomain(_wireSession(name: 'Mercy of Ikons'));

      expect(domain.id, 'session-1');
      expect(domain.name, 'Mercy of Ikons');
      expect(domain.ownerId, 'user-1');
      expect(domain.status, 'active');
      expect(domain.dpCount, 3);
    });

    test('maps memberships into members with role + character link', () {
      final domain = GameSessionApiMapper.toDomain(
        _wireSession(memberships: [
          _wireMember(
            id: 'mem-gm',
            userId: 'user-gm',
            role: api_client.GameSessionMemberRole.gm,
            displayName: 'Zara',
          ),
          _wireMember(
            id: 'mem-1',
            userId: 'user-player',
            role: api_client.GameSessionMemberRole.player,
            displayName: 'Ravi',
            characterId: 'char-1',
            characterName: 'Mira Vance',
          ),
        ]),
      );

      expect(domain.members, hasLength(2));
      expect(domain.members.first.isGm, isTrue);
      expect(domain.members.first.displayName, 'Zara');
      expect(domain.members.last.characterName, 'Mira Vance');
      expect(domain.linkedCharacterIds, ['char-1']);
    });

    test('maps archived status correctly', () {
      final domain = GameSessionApiMapper.toDomain(
        _wireSession(status: api_client.GameSessionStatus.archived),
      );

      expect(domain.status, 'archived');
    });

    test('maps optional description and shipId as null when absent', () {
      final domain = GameSessionApiMapper.toDomain(_wireSession());

      expect(domain.description, isNull);
      expect(domain.shipId, isNull);
    });
  });

  group('GameSessionApiMapper.dpEventToDomain', () {
    test('maps scalar fields correctly', () {
      final DpEvent domain = GameSessionApiMapper.dpEventToDomain(
        _wireDpEvent(delta: 2, reason: 'Boss encounter'),
      );

      expect(domain.id, 'dp-1');
      expect(domain.gameSessionId, 'session-1');
      expect(domain.delta, 2);
      expect(domain.reason, 'Boss encounter');
    });

    test('maps source enum name as string', () {
      final domain = GameSessionApiMapper.dpEventToDomain(
        _wireDpEvent(source: api_client.DpSource.rollPush),
      );

      expect(domain.source, 'rollPush');
    });

    test('null rollId is preserved as null', () {
      final domain = GameSessionApiMapper.dpEventToDomain(
        _wireDpEvent(rollId: null),
      );

      expect(domain.rollId, isNull);
    });
  });
}

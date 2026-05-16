import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/features/sessions/data/player_membership_api_mapper.dart';

api_client.MyMembershipSummary _summary({
  String membershipId = 'mem-1',
  String gameSessionId = 'gs-1',
  String sessionName = 'The Mercy of Kua',
  api_client.GameSessionMemberRole role =
      api_client.GameSessionMemberRole.player,
  String? characterId,
  String? characterName,
}) =>
    api_client.MyMembershipSummary((b) => b
      ..membershipId = membershipId
      ..gameSessionId = gameSessionId
      ..sessionName = sessionName
      ..role = role
      ..characterId = characterId
      ..characterName = characterName
      ..joinedAt = DateTime.utc(2026, 5, 16));

api_client.GameSessionMembership _membership({
  String id = 'mem-2',
  String gameSessionId = 'gs-2',
  api_client.GameSessionMemberRole role = api_client.GameSessionMemberRole.gm,
  String? characterId,
  String? characterName,
}) =>
    api_client.GameSessionMembership((b) => b
      ..id = id
      ..gameSessionId = gameSessionId
      ..userId = 'user-1'
      ..role = role
      ..characterId = characterId
      ..characterName = characterName
      ..joinedAt = DateTime.utc(2026, 5, 16));

void main() {
  group('PlayerMembershipApiMapper.fromSummary', () {
    test('maps all fields from MyMembershipSummary', () {
      final src = _summary(
        membershipId: 'mem-1',
        gameSessionId: 'gs-1',
        sessionName: 'The Dying Ship',
        role: api_client.GameSessionMemberRole.player,
        characterId: 'char-1',
        characterName: 'Tael',
      );

      final domain = PlayerMembershipApiMapper.fromSummary(src);

      expect(domain.membershipId, 'mem-1');
      expect(domain.gameSessionId, 'gs-1');
      expect(domain.sessionName, 'The Dying Ship');
      expect(domain.role, 'player');
      expect(domain.characterId, 'char-1');
      expect(domain.characterName, 'Tael');
      expect(domain.joinedAt, DateTime.utc(2026, 5, 16));
    });

    test('maps gm role correctly', () {
      final src = _summary(role: api_client.GameSessionMemberRole.gm);
      final domain = PlayerMembershipApiMapper.fromSummary(src);
      expect(domain.role, 'gm');
    });

    test('null optional fields are preserved', () {
      final src = _summary(characterId: null, characterName: null);
      final domain = PlayerMembershipApiMapper.fromSummary(src);
      expect(domain.characterId, isNull);
      expect(domain.characterName, isNull);
    });
  });

  group('PlayerMembershipApiMapper.fromMembership', () {
    test('maps all fields from GameSessionMembership with sessionName stub', () {
      final src = _membership(
        id: 'mem-2',
        gameSessionId: 'gs-2',
        role: api_client.GameSessionMemberRole.gm,
        characterId: 'char-2',
        characterName: 'Zora',
      );

      final domain = PlayerMembershipApiMapper.fromMembership(
        src,
        sessionName: 'Mercy of Ikons',
      );

      expect(domain.membershipId, 'mem-2');
      expect(domain.gameSessionId, 'gs-2');
      expect(domain.sessionName, 'Mercy of Ikons');
      expect(domain.role, 'gm');
      expect(domain.characterId, 'char-2');
      expect(domain.characterName, 'Zora');
    });

    test('empty sessionName stub is preserved (caller fills it later)', () {
      final src = _membership();
      final domain =
          PlayerMembershipApiMapper.fromMembership(src, sessionName: '');
      expect(domain.sessionName, '');
    });

    test('player role is mapped from GameSessionMembership', () {
      final src = _membership(role: api_client.GameSessionMemberRole.player);
      final domain =
          PlayerMembershipApiMapper.fromMembership(src, sessionName: 'Test');
      expect(domain.role, 'player');
    });
  });
}

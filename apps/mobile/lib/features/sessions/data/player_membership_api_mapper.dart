import 'package:app_api_client/app_api_client.dart' as api_client;

import 'package:coriolis_companion/features/sessions/domain/player_membership.dart';

/// Single source of truth for the wire→domain transform for [PlayerMembership].
///
/// Used by [PlayerSessionRepositoryImpl] for live API responses and by
/// [CachedPlayerSessionRepository] for hydrating cached payloads.
final class PlayerMembershipApiMapper {
  const PlayerMembershipApiMapper._();

  static PlayerMembership fromSummary(api_client.MyMembershipSummary src) =>
      PlayerMembership(
        membershipId: src.membershipId,
        gameSessionId: src.gameSessionId,
        sessionName: src.sessionName,
        // EnumClass.name returns the Dart identifier ('gm' / 'player').
        role: src.role.name,
        characterId: src.characterId,
        characterName: src.characterName,
        joinedAt: src.joinedAt,
      );

  static PlayerMembership fromMembership(
    api_client.GameSessionMembership src, {
    required String sessionName,
  }) =>
      PlayerMembership(
        membershipId: src.id,
        gameSessionId: src.gameSessionId,
        // Server returns GameSessionMembership after accept; sessionName is
        // not included — callers pass a stub value from the preview step.
        sessionName: sessionName,
        role: src.role.name,
        characterId: src.characterId,
        characterName: src.characterName,
        joinedAt: src.joinedAt,
      );
}

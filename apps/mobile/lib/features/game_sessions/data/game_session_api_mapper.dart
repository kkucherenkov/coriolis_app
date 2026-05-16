import 'package:app_api_client/app_api_client.dart' as api_client show GameSession, DpEvent;

import 'package:coriolis_companion/features/game_sessions/domain/game_session.dart';

/// Single source of truth for the wire→domain transform for game sessions.
///
/// Used by [SessionRepositoryImpl] for live API responses and by
/// [CachedSessionRepository] for hydrating cached payloads.
final class GameSessionApiMapper {
  const GameSessionApiMapper._();

  static GameSession toDomain(api_client.GameSession src) => GameSession(
        id: src.id,
        ownerId: src.ownerId,
        name: src.name,
        description: src.description,
        status: src.status.name,
        dpCount: src.dpCount,
        characterIds: src.characterIds.toList(growable: false),
        shipId: src.shipId,
        createdAt: src.createdAt,
        updatedAt: src.updatedAt,
      );

  static DpEvent dpEventToDomain(api_client.DpEvent src) => DpEvent(
        id: src.id,
        gameSessionId: src.gameSessionId,
        delta: src.delta,
        // The Dart codegen renames `source` → `source_` (built_value
        // collision avoidance). Wire name is unchanged.
        source: src.source_.name,
        reason: src.reason,
        rollId: src.rollId,
        createdAt: src.createdAt,
      );
}

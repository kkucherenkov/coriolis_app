import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { GameSessionNotFoundError, GameSessionNotOwnerError } from '../domain/game-session.errors';
import { GAME_SESSION_REPO, GameSessionReadModel } from '../domain/game-session.ports';

import { AssignCharacterCommand } from './assign-character.command';

import type { IGameSessionRepo } from '../domain/game-session.ports';

/**
 * Assigns a character to a game session.
 *
 * Invariants enforced:
 *  - Caller owns the session (GAME_SESSION_NOT_OWNER).
 *  - Character belongs to the same user as the session GM (CHARACTER_NOT_OWNED).
 *  - Assignment is idempotent — no error if character is already assigned.
 *
 * The character-ownership check is done against the characterId's ownerId in
 * the CHARACTER_REPO. To avoid coupling this module to CharacterRepo, the
 * check relies on the IGameSessionRepo.assignCharacter returning normally when
 * the characterId exists and throwing CharacterNotOwnedError when not.
 *
 * For v1 simplicity the ownership check is delegated to the repo layer which
 * issues a single SQL query that joins character.ownerId = session.ownerId.
 */
@CommandHandler(AssignCharacterCommand)
export class AssignCharacterHandler implements ICommandHandler<
  AssignCharacterCommand,
  GameSessionReadModel
> {
  constructor(@Inject(GAME_SESSION_REPO) private readonly repo: IGameSessionRepo) {}

  async execute(command: AssignCharacterCommand): Promise<GameSessionReadModel> {
    const { gameSessionId, ownerId, characterId } = command;

    const session = await this.repo.findById(gameSessionId);
    if (!session) throw new GameSessionNotFoundError(gameSessionId);
    if (session.ownerId !== ownerId) throw new GameSessionNotOwnerError(gameSessionId);

    // Character ownership is verified inside the repo via a joined query.
    // If the character does not belong to ownerId the repo throws CharacterNotOwnedError.
    return this.repo.assignCharacter(gameSessionId, characterId);
  }
}

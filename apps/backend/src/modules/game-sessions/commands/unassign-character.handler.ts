import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { GameSessionNotFoundError, GameSessionNotOwnerError } from '../domain/game-session.errors';
import { GAME_SESSION_REPO } from '../domain/game-session.ports';

import { UnassignCharacterCommand } from './unassign-character.command';

import type { IGameSessionRepo } from '../domain/game-session.ports';

@CommandHandler(UnassignCharacterCommand)
export class UnassignCharacterHandler implements ICommandHandler<UnassignCharacterCommand, void> {
  constructor(@Inject(GAME_SESSION_REPO) private readonly repo: IGameSessionRepo) {}

  async execute(command: UnassignCharacterCommand): Promise<void> {
    const { gameSessionId, ownerId, characterId } = command;

    const session = await this.repo.findById(gameSessionId);
    if (!session) throw new GameSessionNotFoundError(gameSessionId);
    if (session.ownerId !== ownerId) throw new GameSessionNotOwnerError(gameSessionId);

    // Silently succeeds if character was not assigned
    await this.repo.unassignCharacter(gameSessionId, characterId);
  }
}

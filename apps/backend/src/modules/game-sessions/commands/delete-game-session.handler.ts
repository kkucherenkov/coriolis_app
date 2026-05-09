import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { GameSessionNotFoundError, GameSessionNotOwnerError } from '../domain/game-session.errors';
import { GAME_SESSION_REPO } from '../domain/game-session.ports';

import { DeleteGameSessionCommand } from './delete-game-session.command';

import type { IGameSessionRepo } from '../domain/game-session.ports';

@CommandHandler(DeleteGameSessionCommand)
export class DeleteGameSessionHandler implements ICommandHandler<DeleteGameSessionCommand, void> {
  constructor(@Inject(GAME_SESSION_REPO) private readonly repo: IGameSessionRepo) {}

  async execute(command: DeleteGameSessionCommand): Promise<void> {
    const { id, ownerId } = command;

    const session = await this.repo.findById(id);
    if (!session) throw new GameSessionNotFoundError(id);
    if (session.ownerId !== ownerId) throw new GameSessionNotOwnerError(id);

    await this.repo.delete(id);
  }
}

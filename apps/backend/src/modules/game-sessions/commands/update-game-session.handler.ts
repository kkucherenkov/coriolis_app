import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import {
  GameSessionNotFoundError,
  GameSessionNotOwnerError,
  GameSessionNameEmptyError,
  GameSessionNameTooLongError,
  InvalidGameSessionStatusTransitionError,
} from '../domain/game-session.errors';
import { GAME_SESSION_REPO, GameSessionReadModel } from '../domain/game-session.ports';

import { UpdateGameSessionCommand } from './update-game-session.command';

import type { GameSessionStatus, IGameSessionRepo } from '../domain/game-session.ports';

const VALID_STATUSES = new Set<GameSessionStatus>(['active', 'archived']);

@CommandHandler(UpdateGameSessionCommand)
export class UpdateGameSessionHandler implements ICommandHandler<
  UpdateGameSessionCommand,
  GameSessionReadModel
> {
  constructor(@Inject(GAME_SESSION_REPO) private readonly repo: IGameSessionRepo) {}

  async execute(command: UpdateGameSessionCommand): Promise<GameSessionReadModel> {
    const { id, ownerId, dto } = command;

    const session = await this.repo.findById(id);
    if (!session) throw new GameSessionNotFoundError(id);
    if (session.ownerId !== ownerId) throw new GameSessionNotOwnerError(id);

    if (dto.name !== undefined) {
      if (dto.name.trim() === '') throw new GameSessionNameEmptyError();
      if (dto.name.length > 80) throw new GameSessionNameTooLongError();
    }

    if (dto.status !== undefined && !VALID_STATUSES.has(dto.status)) {
      throw new InvalidGameSessionStatusTransitionError(session.status, dto.status);
    }

    const updateData: Parameters<IGameSessionRepo['update']>[1] = {};
    if (dto.name !== undefined) updateData.name = dto.name.trim();
    if ('description' in dto) updateData.description = dto.description ?? null;
    if (dto.status !== undefined) updateData.status = dto.status;
    if ('shipId' in dto) updateData.shipId = dto.shipId ?? null;

    return this.repo.update(id, updateData);
  }
}

import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import {
  GameSessionNameEmptyError,
  GameSessionNameTooLongError,
} from '../domain/game-session.errors';
import { GAME_SESSION_REPO, GameSessionReadModel } from '../domain/game-session.ports';

import { CreateGameSessionCommand } from './create-game-session.command';

import type { IGameSessionRepo } from '../domain/game-session.ports';

@CommandHandler(CreateGameSessionCommand)
export class CreateGameSessionHandler implements ICommandHandler<
  CreateGameSessionCommand,
  GameSessionReadModel
> {
  constructor(@Inject(GAME_SESSION_REPO) private readonly repo: IGameSessionRepo) {}

  async execute(command: CreateGameSessionCommand): Promise<GameSessionReadModel> {
    const { ownerId, dto } = command;

    // Defence-in-depth — DTO is already validated by ValidationPipe
    if (!dto.name || dto.name.trim() === '') throw new GameSessionNameEmptyError();
    if (dto.name.length > 80) throw new GameSessionNameTooLongError();

    return this.repo.create({
      ownerId,
      name: dto.name.trim(),
      description: dto.description ?? null,
      shipId: dto.shipId ?? null,
    });
  }
}

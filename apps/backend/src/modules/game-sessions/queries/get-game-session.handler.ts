import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { GameSessionNotFoundError, GameSessionNotOwnerError } from '../domain/game-session.errors';
import { GAME_SESSION_REPO, GameSessionReadModel } from '../domain/game-session.ports';

import { GetGameSessionQuery } from './get-game-session.query';

import type { IGameSessionRepo } from '../domain/game-session.ports';

@QueryHandler(GetGameSessionQuery)
export class GetGameSessionHandler implements IQueryHandler<
  GetGameSessionQuery,
  GameSessionReadModel
> {
  constructor(@Inject(GAME_SESSION_REPO) private readonly repo: IGameSessionRepo) {}

  async execute(query: GetGameSessionQuery): Promise<GameSessionReadModel> {
    const { id, ownerId } = query;

    const session = await this.repo.findById(id);
    if (!session) throw new GameSessionNotFoundError(id);
    if (session.ownerId !== ownerId) throw new GameSessionNotOwnerError(id);

    return session;
  }
}

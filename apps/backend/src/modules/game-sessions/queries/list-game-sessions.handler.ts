import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { GAME_SESSION_REPO, GameSessionReadModel } from '../domain/game-session.ports';

import { ListGameSessionsQuery } from './list-game-sessions.query';

import type { IGameSessionRepo, ListGameSessionsOptions } from '../domain/game-session.ports';

export interface GameSessionListResult {
  items: GameSessionReadModel[];
  nextCursor: string | null;
}

@QueryHandler(ListGameSessionsQuery)
export class ListGameSessionsHandler implements IQueryHandler<
  ListGameSessionsQuery,
  GameSessionListResult
> {
  constructor(@Inject(GAME_SESSION_REPO) private readonly repo: IGameSessionRepo) {}

  async execute(query: ListGameSessionsQuery): Promise<GameSessionListResult> {
    const opts: ListGameSessionsOptions = {
      ownerId: query.ownerId,
      limit: query.limit,
    };
    if (query.cursor !== undefined) opts.cursor = query.cursor;
    if (query.status !== undefined) opts.status = query.status;
    return this.repo.list(opts);
  }
}

/**
 * WHY this file exists:
 * Returns the paginated DP audit log for a session. Only accessible by the
 * GM owner — other callers get GAME_SESSION_NOT_OWNER.
 */
import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import {
  GameSessionNotFoundError,
  GameSessionNotOwnerError,
} from '../../domain/game-session.errors';
import { GAME_SESSION_REPO } from '../../domain/game-session.ports';
import { DP_REPO } from '../domain/dp.ports';

import { ListDpEventsQuery } from './list-dp-events.query';

import type { IGameSessionRepo } from '../../domain/game-session.ports';
import type { DpEventReadModel, IDpRepo } from '../domain/dp.ports';

export interface DpEventListResult {
  items: DpEventReadModel[];
  nextCursor: string | null;
}

@QueryHandler(ListDpEventsQuery)
export class ListDpEventsHandler implements IQueryHandler<ListDpEventsQuery, DpEventListResult> {
  constructor(
    @Inject(GAME_SESSION_REPO) private readonly sessionRepo: IGameSessionRepo,
    @Inject(DP_REPO) private readonly dpRepo: IDpRepo,
  ) {}

  async execute(query: ListDpEventsQuery): Promise<DpEventListResult> {
    const { gameSessionId, callerId, limit, cursor } = query;

    const session = await this.sessionRepo.findById(gameSessionId);
    if (!session) throw new GameSessionNotFoundError(gameSessionId);
    if (session.ownerId !== callerId) throw new GameSessionNotOwnerError(gameSessionId);

    return this.dpRepo.listEvents({ gameSessionId, limit, ...(cursor ? { cursor } : {}) });
  }
}

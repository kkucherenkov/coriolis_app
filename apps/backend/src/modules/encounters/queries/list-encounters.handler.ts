import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { EncounterAccessDeniedError, EncounterNotFoundError } from '../domain/encounter.errors';
import { GAME_SESSION_ACCESS } from '../domain/game-session-access.ports';
import { ENCOUNTER_REPO } from '../domain/encounter.ports';

import { ListEncountersQuery } from './list-encounters.query';

import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type { EncounterReadModel, IEncounterRepo } from '../domain/encounter.ports';

export interface EncounterListResult {
  items: EncounterReadModel[];
  nextCursor: string | null;
}

@QueryHandler(ListEncountersQuery)
export class ListEncountersHandler implements IQueryHandler<
  ListEncountersQuery,
  EncounterListResult
> {
  constructor(
    @Inject(ENCOUNTER_REPO) private readonly repo: IEncounterRepo,
    @Inject(GAME_SESSION_ACCESS) private readonly access: IGameSessionAccess,
  ) {}

  async execute(query: ListEncountersQuery): Promise<EncounterListResult> {
    const { gameSessionId, callerId, limit, cursor, status } = query;

    // Per spec: only GM owner may list. 404 if session not found, 403 if not owner.
    const ownerId = await this.access.getOwnerId(gameSessionId);
    if (ownerId === null) throw new EncounterNotFoundError(gameSessionId);
    if (ownerId !== callerId) throw new EncounterAccessDeniedError(gameSessionId);

    return this.repo.list({
      gameSessionId,
      limit,
      ...(cursor === undefined ? {} : { cursor }),
      ...(status === undefined ? {} : { status }),
    });
  }
}

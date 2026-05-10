import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { EncounterAccessDeniedError, EncounterNotFoundError } from '../domain/encounter.errors';
import { GAME_SESSION_ACCESS } from '../domain/game-session-access.ports';
import { ENCOUNTER_REPO } from '../domain/encounter.ports';

import { GetEncounterQuery } from './get-encounter.query';

import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type { EncounterReadModel, IEncounterRepo } from '../domain/encounter.ports';

@QueryHandler(GetEncounterQuery)
export class GetEncounterHandler implements IQueryHandler<GetEncounterQuery, EncounterReadModel> {
  constructor(
    @Inject(ENCOUNTER_REPO) private readonly repo: IEncounterRepo,
    @Inject(GAME_SESSION_ACCESS) private readonly access: IGameSessionAccess,
  ) {}

  async execute(query: GetEncounterQuery): Promise<EncounterReadModel> {
    const { id, callerId } = query;

    const encounter = await this.repo.findById(id);
    if (!encounter) throw new EncounterNotFoundError(id);

    // Per spec: only the GM owner may read. Returns 403 if exists but not owner.
    const ownerId = await this.access.getOwnerId(encounter.gameSessionId);
    if (ownerId === null) throw new EncounterNotFoundError(id);
    if (ownerId !== callerId) throw new EncounterAccessDeniedError(id);

    return encounter;
  }
}

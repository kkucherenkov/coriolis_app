/**
 * WHY this file exists:
 * Handles GET /api/v1/encounters/{id}/combatants.
 *
 * Returns all combatants for an encounter ordered by turnOrder ASC (nulls last),
 * then createdAt ASC. Owner-gated through the encounter's parent game session.
 *
 * No Prisma in this file. All I/O via injected ports.
 */
import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import {
  EncounterAccessDeniedError,
  EncounterNotFoundError,
} from '../../encounters/domain/encounter.errors';
import { GAME_SESSION_ACCESS } from '../../encounters/domain/game-session-access.ports';
import { ENCOUNTER_REPO } from '../../encounters/domain/encounter.ports';
import { COMBATANT_REPO } from '../domain/combatant.ports';

import { ListCombatantsQuery } from './list-combatants.query';

import type { IGameSessionAccess } from '../../encounters/domain/game-session-access.ports';
import type { IEncounterRepo } from '../../encounters/domain/encounter.ports';
import type { ICombatantRepo, CombatantReadModel } from '../domain/combatant.ports';

export interface CombatantListResult {
  items: CombatantReadModel[];
}

@QueryHandler(ListCombatantsQuery)
export class ListCombatantsHandler implements IQueryHandler<
  ListCombatantsQuery,
  CombatantListResult
> {
  constructor(
    @Inject(ENCOUNTER_REPO) private readonly encounterRepo: IEncounterRepo,
    @Inject(GAME_SESSION_ACCESS) private readonly access: IGameSessionAccess,
    @Inject(COMBATANT_REPO) private readonly combatantRepo: ICombatantRepo,
  ) {}

  async execute(query: ListCombatantsQuery): Promise<CombatantListResult> {
    const { encounterId, callerId } = query;

    const encounter = await this.encounterRepo.findById(encounterId);
    if (!encounter) throw new EncounterNotFoundError(encounterId);

    const ownerId = await this.access.getOwnerId(encounter.gameSessionId);
    if (ownerId === null) throw new EncounterNotFoundError(encounterId);
    if (ownerId !== callerId) throw new EncounterAccessDeniedError(encounterId);

    const items = await this.combatantRepo.listByEncounter(encounterId);
    return { items };
  }
}

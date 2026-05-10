/**
 * WHY this file exists:
 * Handles PATCH /api/v1/encounters/{id}/initiative.
 *
 * Steps:
 * 1. Load encounter; guard 404/403.
 * 2. Guard: status must be 'active' (ENCOUNTER_INVALID_STATUS).
 * 3. Load combatants for encounter.
 * 4. Validate combatantIds array:
 *    - duplicates → INITIATIVE_DUPLICATE
 *    - unknown ids → INITIATIVE_UNKNOWN_COMBATANT
 *    - missing ids → INITIATIVE_INCOMPLETE
 * 5. Persist new turnOrder atomically.
 * 6. Return InitiativeRollResult (does NOT change activeCombatantId/round/initiative).
 */
import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { COMBATANT_REPO } from '../../combatants/domain/combatant.ports';
import {
  EncounterAccessDeniedError,
  EncounterInvalidStatusError,
  EncounterNotFoundError,
  InitiativeDuplicateError,
  InitiativeIncompleteError,
  InitiativeUnknownCombatantError,
} from '../domain/encounter.errors';
import { GAME_SESSION_ACCESS } from '../domain/game-session-access.ports';
import { ENCOUNTER_REPO, INITIATIVE_REPO } from '../domain/encounter.ports';

import { ReorderInitiativeCommand } from './reorder-initiative.command';

import type { ICombatantRepo } from '../../combatants/domain/combatant.ports';
import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type {
  IEncounterRepo,
  IInitiativeRepo,
  InitiativeRollResult,
} from '../domain/encounter.ports';

@CommandHandler(ReorderInitiativeCommand)
export class ReorderInitiativeHandler implements ICommandHandler<
  ReorderInitiativeCommand,
  InitiativeRollResult
> {
  constructor(
    @Inject(ENCOUNTER_REPO) private readonly repo: IEncounterRepo,
    @Inject(GAME_SESSION_ACCESS) private readonly access: IGameSessionAccess,
    @Inject(COMBATANT_REPO) private readonly combatantRepo: ICombatantRepo,
    @Inject(INITIATIVE_REPO) private readonly initiativeRepo: IInitiativeRepo,
  ) {}

  async execute(command: ReorderInitiativeCommand): Promise<InitiativeRollResult> {
    const { encounterId, callerId, dto } = command;

    // 1. Load encounter
    const encounter = await this.repo.findById(encounterId);
    if (!encounter) throw new EncounterNotFoundError(encounterId);

    // 2. Auth: owner-only
    const ownerId = await this.access.getOwnerId(encounter.gameSessionId);
    if (ownerId === null) throw new EncounterNotFoundError(encounterId);
    if (ownerId !== callerId) throw new EncounterAccessDeniedError(encounterId);

    // 3. Status guard: must be 'active'
    if (encounter.status !== 'active') {
      throw new EncounterInvalidStatusError(
        encounter.status,
        'active',
        'Reorder is only allowed during active combat.',
      );
    }

    // 4. Load combatants for encounter
    const existingCombatants = await this.combatantRepo.listByEncounter(encounterId);
    const expectedIds = new Set(existingCombatants.map((c) => c.id));
    const received = dto.combatantIds;

    // Validate: duplicates first
    const seen = new Set<string>();
    for (const id of received) {
      if (seen.has(id)) {
        throw new InitiativeDuplicateError(id);
      }
      seen.add(id);
    }

    // Validate: unknown ids
    for (const id of received) {
      if (!expectedIds.has(id)) {
        throw new InitiativeUnknownCombatantError(id, encounterId);
      }
    }

    // Validate: incomplete (missing ids)
    for (const id of expectedIds) {
      if (!seen.has(id)) {
        throw new InitiativeIncompleteError(id);
      }
    }

    // 5. Persist new turnOrder atomically
    return this.initiativeRepo.reorderInitiative({
      encounterId,
      orderedIds: received,
    });
  }
}

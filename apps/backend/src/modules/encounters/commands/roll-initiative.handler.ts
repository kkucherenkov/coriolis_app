/**
 * WHY this file exists:
 * Handles POST /api/v1/encounters/{id}/initiative/roll.
 *
 * Steps (all atomic via IInitiativeRepo.rollInitiative):
 * 1. Load encounter; guard 404/403.
 * 2. Guard: status must be 'setup' (ENCOUNTER_INVALID_TRANSITION).
 * 3. Guard: encounter must have ≥1 combatant (ENCOUNTER_NO_COMBATANTS).
 * 4. Load combatants with snapshots (single query, no N+1).
 * 5. Roll initiative for each via crypto.randomInt(1, 11).
 * 6. Sort: sortInitiative() — initiative desc, agility desc, createdAt asc.
 * 7. Assign turnOrder 0..N-1.
 * 8. Persist atomically; encounter → active, round=1, activeCombatantId=first.
 * 9. Return InitiativeRollResult.
 */
import { randomInt } from 'node:crypto';
import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { COMBATANT_REPO } from '../../combatants/domain/combatant.ports';
import {
  EncounterAccessDeniedError,
  EncounterInvalidTransitionError,
  EncounterNoCombatantsError,
  EncounterNotFoundError,
} from '../domain/encounter.errors';
import { GAME_SESSION_ACCESS } from '../domain/game-session-access.ports';
import { ENCOUNTER_REPO, INITIATIVE_REPO } from '../domain/encounter.ports';
import { sortInitiative } from '../domain/initiative';

import { RollInitiativeCommand } from './roll-initiative.command';

import type { ICombatantRepo } from '../../combatants/domain/combatant.ports';
import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type {
  IEncounterRepo,
  IInitiativeRepo,
  InitiativeRollResult,
} from '../domain/encounter.ports';

@CommandHandler(RollInitiativeCommand)
export class RollInitiativeHandler implements ICommandHandler<
  RollInitiativeCommand,
  InitiativeRollResult
> {
  constructor(
    @Inject(ENCOUNTER_REPO) private readonly repo: IEncounterRepo,
    @Inject(GAME_SESSION_ACCESS) private readonly access: IGameSessionAccess,
    @Inject(COMBATANT_REPO) private readonly combatantRepo: ICombatantRepo,
    @Inject(INITIATIVE_REPO) private readonly initiativeRepo: IInitiativeRepo,
  ) {}

  async execute(command: RollInitiativeCommand): Promise<InitiativeRollResult> {
    const { encounterId, callerId } = command;

    // 1. Load encounter
    const encounter = await this.repo.findById(encounterId);
    if (!encounter) throw new EncounterNotFoundError(encounterId);

    // 2. Auth: owner-only
    const ownerId = await this.access.getOwnerId(encounter.gameSessionId);
    if (ownerId === null) throw new EncounterNotFoundError(encounterId);
    if (ownerId !== callerId) throw new EncounterAccessDeniedError(encounterId);

    // 3. Status guard: must be 'setup'
    if (encounter.status !== 'setup') {
      throw new EncounterInvalidTransitionError(encounter.status, 'active');
    }

    // 4. Load combatants with snapshots (single query)
    const combatantsWithSnapshots =
      await this.combatantRepo.listByEncounterWithSnapshot(encounterId);

    // 5. Guard: must have ≥1 combatant
    if (combatantsWithSnapshots.length === 0) {
      throw new EncounterNoCombatantsError();
    }

    // 6. Roll initiative for each combatant
    const withRolls = combatantsWithSnapshots.map((item) => ({
      ...item,
      combatant: {
        ...item.combatant,
        initiative: randomInt(1, 11), // 1..10 inclusive
      },
    }));

    // 7. Sort: initiative desc, agility desc, createdAt asc
    const sorted = sortInitiative(withRolls);

    // 8. Assign turnOrder 0..N-1
    const combatantPatches = sorted.map((item, index) => ({
      id: item.combatant.id,
      // initiative is set by randomInt above; guaranteed non-null at this point
      initiative: item.combatant.initiative ?? 0,
      turnOrder: index,
    }));

    // sorted.length ≥ 1 guaranteed by the ENCOUNTER_NO_COMBATANTS guard above.
    const firstItem = sorted.at(0);
    // This branch is unreachable but satisfies the type-checker.
    if (!firstItem) throw new EncounterNoCombatantsError();
    const firstCombatantId = firstItem.combatant.id;

    // 9. Persist atomically
    return this.initiativeRepo.rollInitiative({
      encounterId,
      combatantPatches,
      activeCombatantId: firstCombatantId,
    });
  }
}

/**
 * WHY this file exists:
 * Handles POST /api/v1/encounters/{id}/initiative/roll.
 *
 * Steps (all atomic via IInitiativeRepo.rollInitiative):
 * 1. Load encounter; guard 404/403.
 * 2. Guard: status must be 'setup' (ENCOUNTER_INVALID_TRANSITION).
 * 3. Guard: encounter must have ≥1 combatant (ENCOUNTER_NO_COMBATANTS).
 * 4. Load combatants with snapshots (single query, no N+1).
 * 5. Roll a d6 for each combatant via crypto.randomInt(1, 7) — ST3001
 *    ГЛАВА 5 «Бросьте по кубику за всех участников сражения».
 * 6. Reroll d6 for ties (ST3001 ГЛАВА 5: «В случае ничьей… бросьте ещё
 *    по одному кубику, только на этот раз безо всяких модификаторов»),
 *    up to rerollTies() bounded passes.
 * 7. Sort: sortInitiative() — initiative desc, createdAt asc as a stable
 *    fallback for combatants still tied after the reroll budget.
 * 8. Assign turnOrder 0..N-1.
 * 9. Persist atomically; encounter → active, round=1, activeCombatantId=first.
 * 10. Publish combat.updated snapshot (non-fatal).
 * 11. Return InitiativeRollResult.
 */
import { randomInt } from 'node:crypto';
import { Inject, Logger } from '@nestjs/common';
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
import { rerollTies, sortInitiative } from '../domain/initiative';
import { COMBAT_PUBLISHER } from '../infra/combat.publisher';

import { RollInitiativeCommand } from './roll-initiative.command';

import type { ICombatantRepo } from '../../combatants/domain/combatant.ports';
import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type {
  IEncounterRepo,
  IInitiativeRepo,
  InitiativeRollResult,
} from '../domain/encounter.ports';
import type { ICombatPublisher } from '../infra/combat.publisher';

@CommandHandler(RollInitiativeCommand)
export class RollInitiativeHandler implements ICommandHandler<
  RollInitiativeCommand,
  InitiativeRollResult
> {
  private readonly logger = new Logger(RollInitiativeHandler.name);

  constructor(
    @Inject(ENCOUNTER_REPO) private readonly repo: IEncounterRepo,
    @Inject(GAME_SESSION_ACCESS) private readonly access: IGameSessionAccess,
    @Inject(COMBATANT_REPO) private readonly combatantRepo: ICombatantRepo,
    @Inject(INITIATIVE_REPO) private readonly initiativeRepo: IInitiativeRepo,
    @Inject(COMBAT_PUBLISHER) private readonly combatPublisher: ICombatPublisher,
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

    // 6. Roll a d6 for each combatant (ST3001 ГЛАВА 5)
    const withRolls = combatantsWithSnapshots.map((item) => ({
      ...item,
      combatant: {
        ...item.combatant,
        initiative: randomInt(1, 7), // 1..6 inclusive
      },
    }));

    // 7. Reroll d6 for ties (bounded passes) and sort
    const broken = rerollTies(withRolls, () => randomInt(1, 7));
    const sorted = sortInitiative(broken);

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
    const result = await this.initiativeRepo.rollInitiative({
      encounterId,
      combatantPatches,
      activeCombatantId: firstCombatantId,
    });

    // 10. Publish combat.updated — non-fatal; DB write is already committed
    try {
      const updatedEncounter = await this.repo.findById(encounterId);
      if (updatedEncounter) {
        await this.combatPublisher.publishUpdated(
          updatedEncounter.gameSessionId,
          updatedEncounter,
          result.combatants,
        );
      }
    } catch (error) {
      this.logger.error(
        `Failed to publish combat.updated for encounter ${encounterId}: ${String(error)}`,
      );
    }

    return result;
  }
}

/**
 * WHY this file exists:
 * Handles POST /api/v1/encounters/{id}/turn/advance.
 *
 * Steps:
 * 1. Load encounter; guard 404/403.
 * 2. Guard: status must be 'active' (ENCOUNTER_INVALID_STATUS).
 * 3. Guard: activeCombatantId must not be null (ENCOUNTER_INITIATIVE_NOT_ROLLED).
 * 4. Load combatants sorted by turnOrder asc.
 * 5. Find current combatant index; if not found → ENCOUNTER_INITIATIVE_NOT_ROLLED (defensive).
 * 6. Compute nextIndex = (currentIndex + 1) % combatants.length.
 * 7. isNewRound = nextIndex === 0.
 * 8. Persist: activeCombatantId, and round if new round.
 * 9. Return TurnAdvanceResult.
 */
import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { COMBATANT_REPO } from '../../combatants/domain/combatant.ports';
import {
  EncounterAccessDeniedError,
  EncounterInitiativeNotRolledError,
  EncounterInvalidStatusError,
  EncounterNotFoundError,
} from '../domain/encounter.errors';
import { GAME_SESSION_ACCESS } from '../domain/game-session-access.ports';
import { ENCOUNTER_REPO, INITIATIVE_REPO } from '../domain/encounter.ports';

import { AdvanceTurnCommand } from './advance-turn.command';

import type { ICombatantRepo } from '../../combatants/domain/combatant.ports';
import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type { IEncounterRepo, IInitiativeRepo, TurnAdvanceResult } from '../domain/encounter.ports';

@CommandHandler(AdvanceTurnCommand)
export class AdvanceTurnHandler implements ICommandHandler<AdvanceTurnCommand, TurnAdvanceResult> {
  constructor(
    @Inject(ENCOUNTER_REPO) private readonly repo: IEncounterRepo,
    @Inject(GAME_SESSION_ACCESS) private readonly access: IGameSessionAccess,
    @Inject(COMBATANT_REPO) private readonly combatantRepo: ICombatantRepo,
    @Inject(INITIATIVE_REPO) private readonly initiativeRepo: IInitiativeRepo,
  ) {}

  async execute(command: AdvanceTurnCommand): Promise<TurnAdvanceResult> {
    const { encounterId, callerId } = command;

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
        'Turn advance is only allowed during active combat.',
      );
    }

    // 4. Guard: activeCombatantId must not be null
    if (encounter.activeCombatantId === null) {
      throw new EncounterInitiativeNotRolledError();
    }

    // 5. Load combatants sorted by turnOrder asc
    const combatants = await this.combatantRepo.listByEncounter(encounterId);

    // 6. Find current index (defensive: if not found → ENCOUNTER_INITIATIVE_NOT_ROLLED)
    const currentIndex = combatants.findIndex((c) => c.id === encounter.activeCombatantId);
    if (currentIndex === -1) {
      throw new EncounterInitiativeNotRolledError();
    }

    // 7. Compute next index
    const nextIndex = (currentIndex + 1) % combatants.length;
    const isNewRound = nextIndex === 0;
    const newRound = isNewRound ? encounter.round + 1 : encounter.round;
    // combatants.at(nextIndex) is always defined: nextIndex is in [0, length-1]
    // guaranteed by modulo arithmetic on a non-empty array (verified by guard above).
    const nextCombatantId = combatants.at(nextIndex)?.id ?? combatants[0]?.id ?? '';

    // 8. Persist atomically
    await this.initiativeRepo.advanceTurn({
      encounterId,
      activeCombatantId: nextCombatantId,
      round: newRound,
    });

    // 9. Return result
    return {
      activeCombatantId: nextCombatantId,
      round: newRound,
      isNewRound,
    };
  }
}

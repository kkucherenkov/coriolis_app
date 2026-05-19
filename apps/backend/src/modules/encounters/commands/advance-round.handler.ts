/**
 * WHY this file exists:
 * Handles POST /api/v1/encounters/{id}/round/advance.
 *
 * Steps:
 * 1. Load encounter; guard 404/403.
 * 2. Guard: status must be 'active' (ENCOUNTER_INVALID_STATUS).
 * 3. Guard: activeCombatantId must not be null (ENCOUNTER_INITIATIVE_NOT_ROLLED).
 * 4. Load combatants sorted by turnOrder asc.
 * 5. If combatants list is empty → ENCOUNTER_INITIATIVE_NOT_ROLLED (defensive).
 * 6. Persist atomically: round = round + 1, activeCombatantId = turnOrder[0].id.
 * 7. Publish combat.updated snapshot (non-fatal).
 * 8. Return TurnAdvanceResult with isNewRound always true.
 */
import { Inject, Logger } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import { COMBATANT_REPO } from '../../combatants/domain/combatant.ports';
import {
  EncounterAccessDeniedError,
  EncounterInitiativeNotRolledError,
  EncounterInvalidStatusError,
  EncounterNotFoundError,
} from '../domain/encounter.errors';
import { GAME_SESSION_ACCESS } from '../domain/game-session-access.ports';
import { ENCOUNTER_REPO, INITIATIVE_REPO } from '../domain/encounter.ports';
import { RoundAdvancedEvent } from '../events/round-advanced.event';
import { COMBAT_PUBLISHER } from '../infra/combat.publisher';

import { AdvanceRoundCommand } from './advance-round.command';

import type { ICombatantRepo } from '../../combatants/domain/combatant.ports';
import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type { IEncounterRepo, IInitiativeRepo, TurnAdvanceResult } from '../domain/encounter.ports';
import type { ICombatPublisher } from '../infra/combat.publisher';

@CommandHandler(AdvanceRoundCommand)
export class AdvanceRoundHandler implements ICommandHandler<
  AdvanceRoundCommand,
  TurnAdvanceResult
> {
  private readonly logger = new Logger(AdvanceRoundHandler.name);

  constructor(
    @Inject(ENCOUNTER_REPO) private readonly repo: IEncounterRepo,
    @Inject(GAME_SESSION_ACCESS) private readonly access: IGameSessionAccess,
    @Inject(COMBATANT_REPO) private readonly combatantRepo: ICombatantRepo,
    @Inject(INITIATIVE_REPO) private readonly initiativeRepo: IInitiativeRepo,
    @Inject(COMBAT_PUBLISHER) private readonly combatPublisher: ICombatPublisher,
    private readonly eventBus: EventBus,
  ) {}

  async execute(command: AdvanceRoundCommand): Promise<TurnAdvanceResult> {
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
        'Round advance is only allowed during active combat.',
      );
    }

    // 4. Guard: activeCombatantId must not be null
    if (encounter.activeCombatantId === null) {
      throw new EncounterInitiativeNotRolledError();
    }

    // 5. Load combatants sorted by turnOrder asc (defensive: empty list guard)
    const combatants = await this.combatantRepo.listByEncounter(encounterId);
    if (combatants.length === 0) {
      throw new EncounterInitiativeNotRolledError();
    }

    // 6. Persist atomically: round + 1, activeCombatantId = first in turn order
    const newRound = encounter.round + 1;
    // combatants.at(0) is safe: length guard above ensures ≥1 element.
    const nextCombatantId = combatants.at(0)?.id ?? '';

    await this.initiativeRepo.advanceTurn({
      encounterId,
      activeCombatantId: nextCombatantId,
      round: newRound,
    });

    const result: TurnAdvanceResult = {
      activeCombatantId: nextCombatantId,
      round: newRound,
      isNewRound: true,
    };

    // 7. Publish combat.updated — non-fatal; DB write is already committed
    try {
      const updatedEncounter = await this.repo.findById(encounterId);
      if (updatedEncounter) {
        await this.combatPublisher.publishUpdated(
          updatedEncounter.gameSessionId,
          updatedEncounter,
          combatants,
        );
      }
    } catch (error) {
      this.logger.error(
        `Failed to publish combat.updated for encounter ${encounterId}: ${String(error)}`,
      );
    }

    // Publish RoundAdvancedEvent after the combat snapshot. Uses the gameSessionId
    // from the pre-advance encounter load (gameSessionId never changes on an encounter).
    this.eventBus.publish(new RoundAdvancedEvent(encounterId, encounter.gameSessionId, newRound));

    // 8. Return result
    return result;
  }
}

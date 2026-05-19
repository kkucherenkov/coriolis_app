import { Inject, Logger } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import { COMBATANT_COUNT, COMBATANT_REPO } from '../../combatants/domain/combatant.ports';
import { EncounterAccessDeniedError, EncounterNotFoundError } from '../domain/encounter.errors';
import { GAME_SESSION_ACCESS } from '../domain/game-session-access.ports';
import { ENCOUNTER_REPO } from '../domain/encounter.ports';
import { guardTransition, requiresCombatants } from '../domain/encounter.state-machine';
import { EncounterEndedEvent } from '../events/encounter-ended.event';
import { EncounterStartedEvent } from '../events/encounter-started.event';
import { COMBAT_PUBLISHER } from '../infra/combat.publisher';

import { UpdateEncounterCommand } from './update-encounter.command';

import type { ICombatantCount, ICombatantRepo } from '../../combatants/domain/combatant.ports';
import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type {
  EncounterReadModel,
  EncounterUpdateData,
  IEncounterRepo,
} from '../domain/encounter.ports';
import type { ICombatPublisher } from '../infra/combat.publisher';

@CommandHandler(UpdateEncounterCommand)
export class UpdateEncounterHandler implements ICommandHandler<
  UpdateEncounterCommand,
  EncounterReadModel
> {
  private readonly logger = new Logger(UpdateEncounterHandler.name);

  constructor(
    @Inject(ENCOUNTER_REPO) private readonly repo: IEncounterRepo,
    @Inject(GAME_SESSION_ACCESS) private readonly access: IGameSessionAccess,
    @Inject(COMBATANT_COUNT) private readonly combatantCount: ICombatantCount,
    @Inject(COMBATANT_REPO) private readonly combatantRepo: ICombatantRepo,
    @Inject(COMBAT_PUBLISHER) private readonly combatPublisher: ICombatPublisher,
    private readonly eventBus: EventBus,
  ) {}

  async execute(command: UpdateEncounterCommand): Promise<EncounterReadModel> {
    const { id, callerId, dto } = command;

    // Load encounter
    const encounter = await this.repo.findById(id);
    if (!encounter) throw new EncounterNotFoundError(id);

    // Auth: writes require GM owner
    const ownerId = await this.access.getOwnerId(encounter.gameSessionId);
    if (ownerId === null) throw new EncounterNotFoundError(id);
    if (ownerId !== callerId) throw new EncounterAccessDeniedError(id);

    // State machine guard
    const patch: EncounterUpdateData = {};

    // Capture previous status before patching — used after DB commit to decide
    // which lifecycle event (if any) to publish.
    const previousStatus = encounter.status;

    if (dto.status !== undefined && dto.status !== encounter.status) {
      // Only count combatants when the transition actually requires it (setup → active).
      // This avoids an unnecessary DB query for active → ended.
      let hasCombatants = false;
      if (requiresCombatants(encounter.status, dto.status)) {
        hasCombatants = (await this.combatantCount.countByEncounter(id)) > 0;
      }
      guardTransition(encounter.status, dto.status, hasCombatants);

      patch.status = dto.status;

      // active → ended: reset activeCombatantId atomically
      if (dto.status === 'ended') {
        patch.activeCombatantId = null;
      }
    }

    if (dto.name !== undefined) patch.name = dto.name.trim();
    if ('notes' in dto) patch.notes = dto.notes ?? null;

    const updated = await this.repo.update(id, patch);

    // Publish snapshot — non-fatal; DB write is already committed
    try {
      const combatants = await this.combatantRepo.listByEncounter(id);
      await this.combatPublisher.publishUpdated(updated.gameSessionId, updated, combatants);
    } catch (error) {
      this.logger.error(
        `Failed to fetch combatants for combat.updated publish (encounter ${id}): ${String(error)}`,
      );
    }

    // Publish lifecycle events after the combat snapshot so the system message
    // arrives after the realtime combat state update.
    if (patch.status !== undefined) {
      if (previousStatus === 'setup' && patch.status === 'active') {
        this.eventBus.publish(new EncounterStartedEvent(id, updated.gameSessionId));
      } else if (previousStatus === 'active' && patch.status === 'ended') {
        this.eventBus.publish(new EncounterEndedEvent(id, updated.gameSessionId));
      }
    }

    return updated;
  }
}

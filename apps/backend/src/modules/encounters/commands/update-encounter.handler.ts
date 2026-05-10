import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { COMBATANT_COUNT } from '../../combatants/domain/combatant.ports';
import { EncounterAccessDeniedError, EncounterNotFoundError } from '../domain/encounter.errors';
import { GAME_SESSION_ACCESS } from '../domain/game-session-access.ports';
import { ENCOUNTER_REPO } from '../domain/encounter.ports';
import { guardTransition, requiresCombatants } from '../domain/encounter.state-machine';

import { UpdateEncounterCommand } from './update-encounter.command';

import type { ICombatantCount } from '../../combatants/domain/combatant.ports';
import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type {
  EncounterReadModel,
  EncounterUpdateData,
  IEncounterRepo,
} from '../domain/encounter.ports';

@CommandHandler(UpdateEncounterCommand)
export class UpdateEncounterHandler implements ICommandHandler<
  UpdateEncounterCommand,
  EncounterReadModel
> {
  constructor(
    @Inject(ENCOUNTER_REPO) private readonly repo: IEncounterRepo,
    @Inject(GAME_SESSION_ACCESS) private readonly access: IGameSessionAccess,
    @Inject(COMBATANT_COUNT) private readonly combatantCount: ICombatantCount,
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

    return this.repo.update(id, patch);
  }
}

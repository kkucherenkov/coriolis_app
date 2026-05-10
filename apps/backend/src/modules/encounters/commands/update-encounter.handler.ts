import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { EncounterAccessDeniedError, EncounterNotFoundError } from '../domain/encounter.errors';
import { GAME_SESSION_ACCESS } from '../domain/game-session-access.ports';
import { ENCOUNTER_REPO } from '../domain/encounter.ports';
import { guardTransition } from '../domain/encounter.state-machine';

import { UpdateEncounterCommand } from './update-encounter.command';

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
      // Block 3 will pass the real combatant count; until then always false.
      const hasCombatants = false;
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

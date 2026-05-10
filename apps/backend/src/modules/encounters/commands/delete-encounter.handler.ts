import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { EncounterAccessDeniedError, EncounterNotFoundError } from '../domain/encounter.errors';
import { GAME_SESSION_ACCESS } from '../domain/game-session-access.ports';
import { ENCOUNTER_REPO } from '../domain/encounter.ports';

import { DeleteEncounterCommand } from './delete-encounter.command';

import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type { IEncounterRepo } from '../domain/encounter.ports';

@CommandHandler(DeleteEncounterCommand)
export class DeleteEncounterHandler implements ICommandHandler<DeleteEncounterCommand, void> {
  constructor(
    @Inject(ENCOUNTER_REPO) private readonly repo: IEncounterRepo,
    @Inject(GAME_SESSION_ACCESS) private readonly access: IGameSessionAccess,
  ) {}

  async execute(command: DeleteEncounterCommand): Promise<void> {
    const { id, callerId } = command;

    const encounter = await this.repo.findById(id);
    if (!encounter) throw new EncounterNotFoundError(id);

    const ownerId = await this.access.getOwnerId(encounter.gameSessionId);
    if (ownerId === null) throw new EncounterNotFoundError(id);
    if (ownerId !== callerId) throw new EncounterAccessDeniedError(id);

    await this.repo.delete(id);
  }
}

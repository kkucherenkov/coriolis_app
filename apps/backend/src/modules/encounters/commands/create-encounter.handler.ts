import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { GAME_SESSION_ACCESS } from '../domain/game-session-access.ports';
import { EncounterAccessDeniedError, EncounterNotFoundError } from '../domain/encounter.errors';
import { ENCOUNTER_REPO } from '../domain/encounter.ports';

import { CreateEncounterCommand } from './create-encounter.command';

import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type { EncounterReadModel, IEncounterRepo } from '../domain/encounter.ports';

@CommandHandler(CreateEncounterCommand)
export class CreateEncounterHandler implements ICommandHandler<
  CreateEncounterCommand,
  EncounterReadModel
> {
  constructor(
    @Inject(ENCOUNTER_REPO) private readonly repo: IEncounterRepo,
    @Inject(GAME_SESSION_ACCESS) private readonly access: IGameSessionAccess,
  ) {}

  async execute(command: CreateEncounterCommand): Promise<EncounterReadModel> {
    const { gameSessionId, callerId, dto } = command;

    // Session must exist and caller must be the GM owner (writes are GM-only)
    const ownerId = await this.access.getOwnerId(gameSessionId);
    if (ownerId === null) throw new EncounterNotFoundError(gameSessionId);
    if (ownerId !== callerId) throw new EncounterAccessDeniedError(gameSessionId);

    return this.repo.create({
      gameSessionId,
      name: dto.name.trim(),
      notes: dto.notes ?? null,
    });
  }
}

import { Inject, Logger } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { COMBATANT_REPO } from '../../combatants/domain/combatant.ports';
import { GAME_SESSION_ACCESS } from '../domain/game-session-access.ports';
import { EncounterAccessDeniedError, EncounterNotFoundError } from '../domain/encounter.errors';
import { ENCOUNTER_REPO } from '../domain/encounter.ports';
import { COMBAT_PUBLISHER } from '../infra/combat.publisher';

import { CreateEncounterCommand } from './create-encounter.command';

import type { ICombatantRepo } from '../../combatants/domain/combatant.ports';
import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type { EncounterReadModel, IEncounterRepo } from '../domain/encounter.ports';
import type { ICombatPublisher } from '../infra/combat.publisher';

@CommandHandler(CreateEncounterCommand)
export class CreateEncounterHandler implements ICommandHandler<
  CreateEncounterCommand,
  EncounterReadModel
> {
  private readonly logger = new Logger(CreateEncounterHandler.name);

  constructor(
    @Inject(ENCOUNTER_REPO) private readonly repo: IEncounterRepo,
    @Inject(GAME_SESSION_ACCESS) private readonly access: IGameSessionAccess,
    @Inject(COMBATANT_REPO) private readonly combatantRepo: ICombatantRepo,
    @Inject(COMBAT_PUBLISHER) private readonly combatPublisher: ICombatPublisher,
  ) {}

  async execute(command: CreateEncounterCommand): Promise<EncounterReadModel> {
    const { gameSessionId, callerId, dto } = command;

    // Session must exist and caller must be the GM owner (writes are GM-only)
    const ownerId = await this.access.getOwnerId(gameSessionId);
    if (ownerId === null) throw new EncounterNotFoundError(gameSessionId);
    if (ownerId !== callerId) throw new EncounterAccessDeniedError(gameSessionId);

    const encounter = await this.repo.create({
      gameSessionId,
      name: dto.name.trim(),
      notes: dto.notes ?? null,
    });

    // Publish snapshot — non-fatal; DB write is already committed
    try {
      const combatants = await this.combatantRepo.listByEncounter(encounter.id);
      await this.combatPublisher.publishUpdated(gameSessionId, encounter, combatants);
    } catch (error) {
      this.logger.error(
        `Failed to fetch combatants for combat.updated publish (encounter ${encounter.id}): ${String(error)}`,
      );
    }

    return encounter;
  }
}

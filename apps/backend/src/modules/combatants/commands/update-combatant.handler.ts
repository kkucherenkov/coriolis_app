/**
 * WHY this file exists:
 * Handles PATCH /api/v1/combatants/{id}.
 *
 * Responsibilities:
 * 1. Load the combatant; 404 if not found.
 * 2. Walk to encounter → game session to verify GM ownership; 404 if not owner.
 * 3. Reject if encounter is 'ended' (ENCOUNTER_ENDED 422).
 * 4. Apply patch (hpCurrent, armor, signature, statusFlags, notes, displayName).
 *    initiative and turnOrder are NOT accepted here — Block 4 only.
 *
 * No Prisma in this file. All I/O via injected ports.
 */
import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { GAME_SESSION_ACCESS } from '../../encounters/domain/game-session-access.ports';
import { ENCOUNTER_REPO } from '../../encounters/domain/encounter.ports';
import { COMBATANT_REPO } from '../domain/combatant.ports';
import { CombatantNotFoundError, EncounterEndedError } from '../domain/combatant.errors';

import { UpdateCombatantCommand } from './update-combatant.command';

import type { IGameSessionAccess } from '../../encounters/domain/game-session-access.ports';
import type { IEncounterRepo } from '../../encounters/domain/encounter.ports';
import type {
  ICombatantRepo,
  CombatantReadModel,
  CombatantUpdateData,
} from '../domain/combatant.ports';

@CommandHandler(UpdateCombatantCommand)
export class UpdateCombatantHandler implements ICommandHandler<
  UpdateCombatantCommand,
  CombatantReadModel
> {
  constructor(
    @Inject(COMBATANT_REPO) private readonly combatantRepo: ICombatantRepo,
    @Inject(ENCOUNTER_REPO) private readonly encounterRepo: IEncounterRepo,
    @Inject(GAME_SESSION_ACCESS) private readonly access: IGameSessionAccess,
  ) {}

  async execute(command: UpdateCombatantCommand): Promise<CombatantReadModel> {
    const { id, callerId, dto } = command;

    // Load combatant
    const combatant = await this.combatantRepo.findById(id);
    if (!combatant) throw new CombatantNotFoundError(id);

    // Walk to encounter → game session → owner
    const encounter = await this.encounterRepo.findById(combatant.encounterId);
    if (!encounter) throw new CombatantNotFoundError(id); // encounter gone

    const ownerId = await this.access.getOwnerId(encounter.gameSessionId);
    if (ownerId === null || ownerId !== callerId) {
      // Don't leak existence — return 404
      throw new CombatantNotFoundError(id);
    }

    // Reject mutations on ended encounters
    if (encounter.status === 'ended') {
      throw new EncounterEndedError(encounter.id);
    }

    const patch: CombatantUpdateData = {};
    if (dto.displayName !== undefined) patch.displayName = dto.displayName;
    if (dto.hpCurrent !== undefined) patch.hpCurrent = dto.hpCurrent;
    if (dto.armor !== undefined) patch.armor = dto.armor;
    if (dto.signature !== undefined) patch.signature = dto.signature;
    if (dto.statusFlags !== undefined) patch.statusFlags = dto.statusFlags;
    if ('notes' in dto) patch.notes = dto.notes ?? null;
    // initiative and turnOrder intentionally excluded — Block 4 only

    return this.combatantRepo.update(id, patch);
  }
}

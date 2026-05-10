/**
 * WHY this file exists:
 * Handles POST /api/v1/encounters/{id}/combatants.
 *
 * Responsibilities:
 * 1. Verify the encounter exists and the caller owns its game session.
 * 2. Reject if encounter is not in 'setup' (ENCOUNTER_LOCKED_FOR_COMBAT 422).
 * 3. Look up the source entity (Character or Npc); 422 if not found / not owned.
 * 4. Build the snapshot (read-once-at-add-time — subsequent mutations to the
 *    source entity do NOT propagate to the combatant row).
 * 5. Create the Combatant row via ICombatantRepo.
 *
 * No Prisma in this file. All I/O via injected ports.
 */
import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import {
  EncounterAccessDeniedError,
  EncounterNotFoundError,
} from '../../encounters/domain/encounter.errors';
import { GAME_SESSION_ACCESS } from '../../encounters/domain/game-session-access.ports';
import { ENCOUNTER_REPO } from '../../encounters/domain/encounter.ports';
import { COMBATANT_REPO } from '../domain/combatant.ports';
import { SOURCE_LOOKUP } from '../domain/source-lookup.ports';
import {
  CombatantSourceNotFoundError,
  CombatantSourceNotOwnedError,
  EncounterLockedForCombatError,
} from '../domain/combatant.errors';

import { AddCombatantCommand } from './add-combatant.command';

import type { IGameSessionAccess } from '../../encounters/domain/game-session-access.ports';
import type { IEncounterRepo } from '../../encounters/domain/encounter.ports';
import type {
  ICombatantRepo,
  CombatantReadModel,
  PcSnapshot,
  NpcSnapshot,
} from '../domain/combatant.ports';
import type { ISourceLookup } from '../domain/source-lookup.ports';

@CommandHandler(AddCombatantCommand)
export class AddCombatantHandler implements ICommandHandler<
  AddCombatantCommand,
  CombatantReadModel
> {
  constructor(
    @Inject(ENCOUNTER_REPO) private readonly encounterRepo: IEncounterRepo,
    @Inject(GAME_SESSION_ACCESS) private readonly access: IGameSessionAccess,
    @Inject(COMBATANT_REPO) private readonly combatantRepo: ICombatantRepo,
    @Inject(SOURCE_LOOKUP) private readonly sourceLookup: ISourceLookup,
  ) {}

  async execute(command: AddCombatantCommand): Promise<CombatantReadModel> {
    const { encounterId, callerId, dto } = command;

    // Load encounter
    const encounter = await this.encounterRepo.findById(encounterId);
    if (!encounter) throw new EncounterNotFoundError(encounterId);

    // Auth: GM owner only
    const ownerId = await this.access.getOwnerId(encounter.gameSessionId);
    if (ownerId === null) throw new EncounterNotFoundError(encounterId);
    if (ownerId !== callerId) throw new EncounterAccessDeniedError(encounterId);

    // State guard: only 'setup' allows adding combatants
    if (encounter.status !== 'setup') {
      throw new EncounterLockedForCombatError();
    }

    if (dto.combatantType === 'pc') {
      const character = await this.sourceLookup.findCharacterById(dto.sourceId);
      if (!character) throw new CombatantSourceNotFoundError(dto.sourceId);
      if (character.ownerId !== callerId) throw new CombatantSourceNotOwnedError(dto.sourceId);

      const pcSnapshot: PcSnapshot = {
        attributes: character.attributes,
        skills: character.skills,
        hpMax: character.hpMax,
      };

      return this.combatantRepo.create({
        encounterId,
        combatantType: 'pc',
        characterId: dto.sourceId,
        displayName: dto.displayName ?? character.name,
        hpCurrent: character.hpCurrent,
        hpMax: character.hpMax,
        armor: character.armor,
        signature: character.signature,
        notes: dto.notes ?? null,
        pcSnapshot,
      });
    } else {
      const npc = await this.sourceLookup.findNpcById(dto.sourceId);
      if (!npc) throw new CombatantSourceNotFoundError(dto.sourceId);
      if (npc.ownerId !== callerId) throw new CombatantSourceNotOwnedError(dto.sourceId);

      const npcSnapshot: NpcSnapshot = {
        attributes: npc.attributes,
        skills: npc.skills,
        hpMax: npc.hpMax,
        signature: npc.signature,
      };

      return this.combatantRepo.create({
        encounterId,
        combatantType: 'npc',
        npcId: dto.sourceId,
        displayName: dto.displayName ?? npc.name,
        hpCurrent: npc.hpCurrent,
        hpMax: npc.hpMax,
        armor: npc.armor,
        signature: npc.signature,
        notes: dto.notes ?? null,
        npcSnapshot,
      });
    }
  }
}

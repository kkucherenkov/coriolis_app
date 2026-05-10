import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import {
  NpcNameEmptyError,
  NpcNameTooLongError,
  NpcNotFoundError,
  NpcNotOwnerError,
} from '../domain/npc.errors';
import { NPC_REPO } from '../domain/npc.ports';

import { UpdateNpcCommand } from './update-npc.command';

import type {
  INpcRepo,
  NpcItemArmor,
  NpcItemWeapon,
  NpcReadModel,
  NpcUpdateData,
} from '../domain/npc.ports';

@CommandHandler(UpdateNpcCommand)
export class UpdateNpcHandler implements ICommandHandler<UpdateNpcCommand, NpcReadModel> {
  constructor(@Inject(NPC_REPO) private readonly repo: INpcRepo) {}

  async execute(command: UpdateNpcCommand): Promise<NpcReadModel> {
    const { id, ownerId, dto } = command;

    const npc = await this.repo.findById(id);
    if (!npc) throw new NpcNotFoundError(id);
    if (npc.ownerId !== ownerId) throw new NpcNotOwnerError(id);

    if (dto.name !== undefined) {
      if (dto.name.trim() === '') throw new NpcNameEmptyError();
      if (dto.name.length > 120) throw new NpcNameTooLongError();
    }

    const patch: NpcUpdateData = {};
    if (dto.name !== undefined) patch.name = dto.name.trim();
    if ('description' in dto) patch.description = dto.description ?? null;
    if (dto.attributes !== undefined) {
      patch.attributes = {
        strength: dto.attributes['strength'] ?? 2,
        agility: dto.attributes['agility'] ?? 2,
        wits: dto.attributes['wits'] ?? 2,
        empathy: dto.attributes['empathy'] ?? 2,
      };
    }
    if (dto.skills !== undefined) {
      patch.skills = {
        dexterity: dto.skills['dexterity'] ?? 0,
        force: dto.skills['force'] ?? 0,
        infiltration: dto.skills['infiltration'] ?? 0,
        manipulation: dto.skills['manipulation'] ?? 0,
        meleeCombat: dto.skills['meleeCombat'] ?? 0,
        observation: dto.skills['observation'] ?? 0,
        rangedCombat: dto.skills['rangedCombat'] ?? 0,
        survival: dto.skills['survival'] ?? 0,
        command: dto.skills['command'] ?? 0,
        culture: dto.skills['culture'] ?? 0,
        dataDjinn: dto.skills['dataDjinn'] ?? 0,
        medicurgy: dto.skills['medicurgy'] ?? 0,
        mysticPowers: dto.skills['mysticPowers'] ?? 0,
        pilot: dto.skills['pilot'] ?? 0,
        science: dto.skills['science'] ?? 0,
        technology: dto.skills['technology'] ?? 0,
      };
    }
    if (dto.hp?.current !== undefined) patch.hpCurrent = dto.hp.current;
    if (dto.hp?.max !== undefined) patch.hpMax = dto.hp.max;
    if (dto.mp?.current !== undefined) patch.mpCurrent = dto.mp.current;
    if (dto.mp?.max !== undefined) patch.mpMax = dto.mp.max;
    if (dto.signature !== undefined) patch.signature = dto.signature;
    if (dto.keySkillModifier !== undefined) patch.keySkillModifier = dto.keySkillModifier;
    if (dto.armor !== undefined) patch.armor = dto.armor as NpcItemArmor[];
    if (dto.weapons !== undefined) patch.weapons = dto.weapons as NpcItemWeapon[];
    if (dto.tags !== undefined) patch.tags = dto.tags;

    return this.repo.update(id, patch);
  }
}

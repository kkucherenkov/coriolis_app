import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { NpcNameEmptyError, NpcNameTooLongError } from '../domain/npc.errors';
import { NPC_REPO } from '../domain/npc.ports';

import { CreateNpcCommand } from './create-npc.command';

import type {
  INpcRepo,
  NpcAttributes,
  NpcItemArmor,
  NpcItemWeapon,
  NpcReadModel,
  NpcSkills,
} from '../domain/npc.ports';

const DEFAULT_ATTRIBUTES: NpcAttributes = {
  strength: 2,
  agility: 2,
  wits: 2,
  empathy: 2,
};

const DEFAULT_SKILLS: NpcSkills = {
  dexterity: 0,
  force: 0,
  infiltration: 0,
  manipulation: 0,
  meleeCombat: 0,
  observation: 0,
  rangedCombat: 0,
  survival: 0,
  command: 0,
  culture: 0,
  dataDjinn: 0,
  medicurgy: 0,
  mysticPowers: 0,
  pilot: 0,
  science: 0,
  technology: 0,
};

function mergeAttributes(partial?: Record<string, number>): NpcAttributes {
  if (!partial) return { ...DEFAULT_ATTRIBUTES };
  return {
    strength: partial['strength'] ?? DEFAULT_ATTRIBUTES.strength,
    agility: partial['agility'] ?? DEFAULT_ATTRIBUTES.agility,
    wits: partial['wits'] ?? DEFAULT_ATTRIBUTES.wits,
    empathy: partial['empathy'] ?? DEFAULT_ATTRIBUTES.empathy,
  };
}

function mergeSkills(partial?: Record<string, number>): NpcSkills {
  if (!partial) return { ...DEFAULT_SKILLS };
  return {
    dexterity: partial['dexterity'] ?? 0,
    force: partial['force'] ?? 0,
    infiltration: partial['infiltration'] ?? 0,
    manipulation: partial['manipulation'] ?? 0,
    meleeCombat: partial['meleeCombat'] ?? 0,
    observation: partial['observation'] ?? 0,
    rangedCombat: partial['rangedCombat'] ?? 0,
    survival: partial['survival'] ?? 0,
    command: partial['command'] ?? 0,
    culture: partial['culture'] ?? 0,
    dataDjinn: partial['dataDjinn'] ?? 0,
    medicurgy: partial['medicurgy'] ?? 0,
    mysticPowers: partial['mysticPowers'] ?? 0,
    pilot: partial['pilot'] ?? 0,
    science: partial['science'] ?? 0,
    technology: partial['technology'] ?? 0,
  };
}

@CommandHandler(CreateNpcCommand)
export class CreateNpcHandler implements ICommandHandler<CreateNpcCommand, NpcReadModel> {
  constructor(@Inject(NPC_REPO) private readonly repo: INpcRepo) {}

  async execute(command: CreateNpcCommand): Promise<NpcReadModel> {
    const { ownerId, dto } = command;

    // Defence-in-depth — DTO is already validated by ValidationPipe
    if (!dto.name || dto.name.trim() === '') throw new NpcNameEmptyError();
    if (dto.name.length > 120) throw new NpcNameTooLongError();

    const attributes = mergeAttributes(dto.attributes);
    const skills = mergeSkills(dto.skills);

    // Spec: hp defaults to {current: 4, max: 4}, mp defaults to {current: 4, max: 4}
    const hpMax = dto.hp?.max ?? 4;
    const hpCurrent = dto.hp?.current ?? hpMax;
    const mpMax = dto.mp?.max ?? 4;
    const mpCurrent = dto.mp?.current ?? mpMax;

    return this.repo.create({
      ownerId,
      name: dto.name.trim(),
      description: dto.description ?? null,
      attributes,
      skills,
      hpCurrent,
      hpMax,
      mpCurrent,
      mpMax,
      signature: dto.signature ?? 0,
      keySkillModifier: dto.keySkillModifier ?? 0,
      armor: (dto.armor ?? []) as NpcItemArmor[],
      weapons: (dto.weapons ?? []) as NpcItemWeapon[],
      tags: dto.tags ?? [],
    });
  }
}

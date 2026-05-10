/**
 * WHY this file exists:
 * Infrastructure adapter — the Prisma-backed implementation of INpcRepo.
 * This is the only file in the npcs bounded context that imports PrismaService.
 * Handlers inject INpcRepo by the NPC_REPO token.
 *
 * attributes, skills, armor, weapons are stored as JSON columns.
 * The mapper casts them to their typed interfaces.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';

import type {
  INpcRepo,
  NpcAttributes,
  NpcCreateData,
  NpcItemArmor,
  NpcItemWeapon,
  NpcListOptions,
  NpcReadModel,
  NpcSkills,
  NpcUpdateData,
} from '../domain/npc.ports';

const NPC_SELECT = {
  id: true,
  ownerId: true,
  name: true,
  description: true,
  attributes: true,
  skills: true,
  hpCurrent: true,
  hpMax: true,
  mpCurrent: true,
  mpMax: true,
  signature: true,
  keySkillModifier: true,
  armor: true,
  weapons: true,
  tags: true,
  createdAt: true,
  updatedAt: true,
} as const;

interface PrismaNpcRow {
  id: string;
  ownerId: string;
  name: string;
  description: string | null;
  attributes: unknown;
  skills: unknown;
  hpCurrent: number;
  hpMax: number;
  mpCurrent: number;
  mpMax: number;
  signature: number;
  keySkillModifier: number;
  armor: unknown;
  weapons: unknown;
  tags: string[];
  createdAt: Date;
  updatedAt: Date;
}

function toNpcReadModel(row: PrismaNpcRow): NpcReadModel {
  return {
    id: row.id,
    ownerId: row.ownerId,
    name: row.name,
    description: row.description,
    attributes: row.attributes as NpcAttributes,
    skills: row.skills as NpcSkills,
    hp: { current: row.hpCurrent, max: row.hpMax },
    mp: { current: row.mpCurrent, max: row.mpMax },
    signature: row.signature,
    keySkillModifier: row.keySkillModifier,
    armor: (row.armor ?? []) as NpcItemArmor[],
    weapons: (row.weapons ?? []) as NpcItemWeapon[],
    tags: row.tags,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

@Injectable()
export class NpcRepo implements INpcRepo {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string): Promise<NpcReadModel | null> {
    const row = await this.prisma.npc.findFirst({
      where: { id },
      select: NPC_SELECT,
    });
    return row ? toNpcReadModel(row) : null;
  }

  async list(opts: NpcListOptions): Promise<{ items: NpcReadModel[]; nextCursor: string | null }> {
    const { ownerId, limit, cursor } = opts;
    const take = limit + 1;

    const rows = await this.prisma.npc.findMany({
      where: { ownerId },
      select: NPC_SELECT,
      orderBy: { createdAt: 'desc' },
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
      take,
    });

    const hasNext = rows.length > limit;
    const items = hasNext ? rows.slice(0, limit) : rows;

    return {
      items: items.map((r) => toNpcReadModel(r)),
      nextCursor: hasNext ? (items.at(-1)?.id ?? null) : null,
    };
  }

  async create(data: NpcCreateData): Promise<NpcReadModel> {
    const row = await this.prisma.npc.create({
      data: {
        ownerId: data.ownerId,
        name: data.name,
        description: data.description ?? null,
        attributes: data.attributes,
        skills: data.skills,
        hpCurrent: data.hpCurrent,
        hpMax: data.hpMax,
        mpCurrent: data.mpCurrent,
        mpMax: data.mpMax,
        signature: data.signature,
        keySkillModifier: data.keySkillModifier,
        armor: data.armor,
        weapons: data.weapons,
        tags: data.tags,
      },
      select: NPC_SELECT,
    });
    return toNpcReadModel(row);
  }

  async update(id: string, data: NpcUpdateData): Promise<NpcReadModel> {
    const payload: Record<string, unknown> = {};
    if (data.name !== undefined) payload['name'] = data.name;
    if ('description' in data) payload['description'] = data.description;
    if (data.attributes !== undefined) payload['attributes'] = data.attributes;
    if (data.skills !== undefined) payload['skills'] = data.skills;
    if (data.hpCurrent !== undefined) payload['hpCurrent'] = data.hpCurrent;
    if (data.hpMax !== undefined) payload['hpMax'] = data.hpMax;
    if (data.mpCurrent !== undefined) payload['mpCurrent'] = data.mpCurrent;
    if (data.mpMax !== undefined) payload['mpMax'] = data.mpMax;
    if (data.signature !== undefined) payload['signature'] = data.signature;
    if (data.keySkillModifier !== undefined) payload['keySkillModifier'] = data.keySkillModifier;
    if (data.armor !== undefined) payload['armor'] = data.armor;
    if (data.weapons !== undefined) payload['weapons'] = data.weapons;
    if (data.tags !== undefined) payload['tags'] = data.tags;

    const row = await this.prisma.npc.update({
      where: { id },
      data: payload,
      select: NPC_SELECT,
    });
    return toNpcReadModel(row);
  }

  async delete(id: string): Promise<void> {
    await this.prisma.npc.delete({ where: { id } });
  }

  async duplicate(sourceId: string, ownerId: string, newName: string): Promise<NpcReadModel> {
    const source = await this.prisma.npc.findFirst({
      where: { id: sourceId },
      select: {
        description: true,
        attributes: true,
        skills: true,
        hpCurrent: true,
        hpMax: true,
        mpCurrent: true,
        mpMax: true,
        signature: true,
        keySkillModifier: true,
        armor: true,
        weapons: true,
        tags: true,
      },
    });

    if (!source) throw new Error('NPC not found in duplicate()');

    const row = await this.prisma.npc.create({
      data: {
        ownerId,
        name: newName,
        description: source.description,
        attributes: source.attributes ?? {},
        skills: source.skills ?? {},
        hpCurrent: source.hpCurrent,
        hpMax: source.hpMax,
        mpCurrent: source.mpCurrent,
        mpMax: source.mpMax,
        signature: source.signature,
        keySkillModifier: source.keySkillModifier,
        armor: source.armor ?? [],
        weapons: source.weapons ?? [],
        tags: source.tags,
      },
      select: NPC_SELECT,
    });

    return toNpcReadModel(row);
  }

  async listNamesByPrefix(ownerId: string, prefix: string): Promise<string[]> {
    const rows = await this.prisma.npc.findMany({
      where: { ownerId, name: { startsWith: prefix } },
      select: { name: true },
    });
    return rows.map((r) => r.name);
  }
}

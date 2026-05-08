/**
 * WHY this file exists:
 * Infrastructure adapter — the Prisma-backed implementation of ICharacterRepo.
 * This is the only place in the characters bounded context that imports PrismaService.
 * Handlers inject ICharacterRepo by the CHARACTER_REPO token.
 *
 * SELECT shapes are scoped to use cases:
 * - list() omits heavy nested arrays (inventory, talents, etc.) for performance
 * - findActiveById() fetches the full graph needed for CharacterReadModel
 *
 * Derived stats are placeholders until Story 3.2.2 (rules-engine):
 *   hp.max = 14
 *   mp.max = 10
 *   encumbrance.current = 0
 *   encumbrance.max = 5
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';

import type {
  Attributes,
  CharacterListItem,
  CharacterReadModel,
  ConditionFlags,
  CriticalInjuryReadModel,
  CriticalInjurySeverity,
  IconId,
  ICharacterRepo,
  ItemReadModel,
  ItemType,
  ListCharactersOptions,
  RelationshipKind,
  RelationshipReadModel,
  Skills,
  TalentReadModel,
} from '../domain/character.ports';

// --------------- Prisma row types (scoped selects) ---------------

const CHARACTER_FULL_SELECT = {
  id: true,
  ownerId: true,
  name: true,
  concept: true,
  iconId: true,
  attributes: true,
  skills: true,
  hpCurrent: true,
  mpCurrent: true,
  experience: true,
  conditions: true,
  notes: true,
  createdAt: true,
  updatedAt: true,
  items: {
    select: { id: true, type: true, data: true },
    orderBy: { id: 'asc' as const },
  },
  talents: {
    select: { id: true, name: true, description: true, rank: true, acquiredAt: true },
    orderBy: { acquiredAt: 'asc' as const },
  },
  relationships: {
    select: { id: true, targetName: true, kind: true, notes: true },
    orderBy: { id: 'asc' as const },
  },
  criticalInjuries: {
    select: { id: true, name: true, severity: true, effect: true, acquiredAt: true },
    orderBy: { acquiredAt: 'asc' as const },
  },
} as const;

const CHARACTER_LIST_SELECT = {
  id: true,
  ownerId: true,
  name: true,
  concept: true,
  iconId: true,
  hpCurrent: true,
  mpCurrent: true,
  conditions: true,
  createdAt: true,
  updatedAt: true,
} as const;

// --------------- Mappers ---------------

type PrismaCharacterFull = {
  id: string;
  ownerId: string;
  name: string;
  concept: string | null;
  iconId: string | null;
  attributes: unknown;
  skills: unknown;
  hpCurrent: number;
  mpCurrent: number;
  experience: number;
  conditions: unknown;
  notes: string | null;
  createdAt: Date;
  updatedAt: Date;
  items: Array<{ id: string; type: string; data: unknown }>;
  talents: Array<{ id: string; name: string; description: string; rank: number; acquiredAt: Date }>;
  relationships: Array<{ id: string; targetName: string; kind: string; notes: string | null }>;
  criticalInjuries: Array<{
    id: string;
    name: string;
    severity: string;
    effect: string;
    acquiredAt: Date;
  }>;
};

function mapTalent(t: {
  id: string;
  name: string;
  description: string;
  rank: number;
  acquiredAt: Date;
}): TalentReadModel {
  return { id: t.id, name: t.name, description: t.description, rank: t.rank, acquiredAt: t.acquiredAt.toISOString() };
}

function mapRelationship(r: {
  id: string;
  targetName: string;
  kind: string;
  notes: string | null;
}): RelationshipReadModel {
  return { id: r.id, targetName: r.targetName, kind: r.kind as RelationshipKind, notes: r.notes };
}

function mapInjury(i: {
  id: string;
  name: string;
  severity: string;
  effect: string;
  acquiredAt: Date;
}): CriticalInjuryReadModel {
  return {
    id: i.id,
    name: i.name,
    severity: i.severity as CriticalInjurySeverity,
    effect: i.effect,
    acquiredAt: i.acquiredAt.toISOString(),
  };
}

function mapItem(item: { id: string; type: string; data: unknown }): ItemReadModel {
  const data = item.data as Record<string, unknown>;
  return { id: item.id, type: item.type as ItemType, ...data };
}

function toReadModel(row: PrismaCharacterFull): CharacterReadModel {
  return {
    id: row.id,
    ownerId: row.ownerId,
    name: row.name,
    concept: row.concept,
    iconId: row.iconId as unknown as IconId | null,
    attributes: row.attributes as Attributes,
    skills: row.skills as Skills,
    hp: {
      current: row.hpCurrent,
      // TODO(rules-engine, T-3.2.2): replace with computeHpMax(strength, agility)
      max: 14,
    },
    mp: {
      current: row.mpCurrent,
      // TODO(rules-engine, T-3.2.2): replace with computeMpMax(wits, empathy)
      max: 10,
    },
    encumbrance: {
      // TODO(rules-engine, T-3.2.2): replace with sum of equipped item weights
      current: 0,
      // TODO(rules-engine, T-3.2.2): replace with computeEncumbrance(strength)
      max: 5,
    },
    experience: row.experience,
    conditions: row.conditions as unknown as ConditionFlags,
    criticalInjuries: row.criticalInjuries.map(mapInjury),
    talents: row.talents.map(mapTalent),
    relationships: row.relationships.map(mapRelationship),
    inventory: row.items.map(mapItem),
    notes: row.notes,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

// --------------- Repo ---------------

@Injectable()
export class CharacterRepo implements ICharacterRepo {
  constructor(private readonly prisma: PrismaService) {}

  async findActiveById(id: string): Promise<CharacterReadModel | null> {
    const row = await this.prisma.character.findFirst({
      where: { id },
      select: CHARACTER_FULL_SELECT,
    });
    return row ? toReadModel(row as unknown as PrismaCharacterFull) : null;
  }

  async findOwnerIdById(id: string): Promise<{ ownerId: string } | null> {
    const row = await this.prisma.character.findFirst({
      where: { id },
      select: { ownerId: true },
    });
    return row ?? null;
  }

  async list(opts: ListCharactersOptions): Promise<{ items: CharacterListItem[]; nextCursor: string | null }> {
    const { ownerId, limit, cursor } = opts;
    const take = limit + 1; // fetch one extra to detect next page

    const rows = await this.prisma.character.findMany({
      where: { ownerId },
      select: CHARACTER_LIST_SELECT,
      orderBy: { createdAt: 'desc' },
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
      take,
    });

    const hasNext = rows.length > limit;
    const items = hasNext ? rows.slice(0, limit) : rows;

    return {
      items: items.map((row) => ({
        id: row.id,
        ownerId: row.ownerId,
        name: row.name,
        concept: row.concept,
        iconId: row.iconId as unknown as IconId | null,
        hp: {
          current: row.hpCurrent,
          // TODO(rules-engine, T-3.2.2): replace with computeHpMax
          max: 14,
        },
        mp: {
          current: row.mpCurrent,
          // TODO(rules-engine, T-3.2.2): replace with computeMpMax
          max: 10,
        },
        conditions: row.conditions as unknown as ConditionFlags,
        createdAt: row.createdAt.toISOString(),
        updatedAt: row.updatedAt.toISOString(),
      })),
      nextCursor: hasNext ? (items[items.length - 1]?.id ?? null) : null,
    };
  }

  async create(data: {
    ownerId: string;
    name: string;
    concept?: string | null;
    iconId?: IconId | null;
    attributes: Attributes;
    skills: Skills;
    hpCurrent: number;
    mpCurrent: number;
    experience: number;
    conditions: ConditionFlags;
    notes?: string | null;
  }): Promise<CharacterReadModel> {
    const row = await this.prisma.character.create({
      data: {
        ownerId: data.ownerId,
        name: data.name,
        concept: data.concept ?? null,
        iconId: data.iconId ? this.toIconIdEnum(data.iconId) : null,
        attributes: data.attributes as object,
        skills: data.skills as object,
        hpCurrent: data.hpCurrent,
        mpCurrent: data.mpCurrent,
        experience: data.experience,
        conditions: data.conditions as object,
        notes: data.notes ?? null,
      },
      select: CHARACTER_FULL_SELECT,
    });
    return toReadModel(row as unknown as PrismaCharacterFull);
  }

  async update(
    id: string,
    data: Partial<{
      name: string;
      concept: string | null;
      iconId: IconId | null;
      attributes: Attributes;
      skills: Skills;
      hpCurrent: number;
      mpCurrent: number;
      experience: number;
      conditions: ConditionFlags;
      criticalInjuries: Array<{
        name: string;
        severity: CriticalInjurySeverity;
        effect: string;
        acquiredAt: string;
      }>;
      notes: string | null;
    }>,
  ): Promise<CharacterReadModel> {
    const { criticalInjuries, iconId, ...rest } = data;

    await this.prisma.$transaction(async (tx) => {
      // Replace critical injuries if provided
      if (criticalInjuries !== undefined) {
        await tx.criticalInjury.deleteMany({ where: { characterId: id } });
        if (criticalInjuries.length > 0) {
          await tx.criticalInjury.createMany({
            data: criticalInjuries.map((inj) => ({
              characterId: id,
              name: inj.name,
              severity: inj.severity as 'LIGHT' | 'SEVERE' | 'CRITICAL',
              effect: inj.effect,
              acquiredAt: new Date(inj.acquiredAt),
            })),
          });
        }
      }

      const updateData: Record<string, unknown> = { ...rest };
      if (iconId !== undefined) {
        updateData['iconId'] = iconId ? this.toIconIdEnum(iconId) : null;
      }
      if (rest.attributes) updateData['attributes'] = rest.attributes as object;
      if (rest.skills) updateData['skills'] = rest.skills as object;
      if (rest.conditions) updateData['conditions'] = rest.conditions as object;

      if (Object.keys(updateData).length > 0) {
        await tx.character.update({ where: { id }, data: updateData });
      }
    });

    const updated = await this.findActiveById(id);
    // findActiveById should always find the row we just updated
    return updated!;
  }

  async delete(id: string): Promise<void> {
    // Prisma cascades to items, talents, relationships, criticalInjuries
    await this.prisma.character.delete({ where: { id } });
  }

  /** Maps kebab-case IconId string to Prisma enum value. */
  private toIconIdEnum(iconId: IconId): import('@prisma/client').IconId {
    // Prisma stores the @map values; pass the raw string through —
    // Prisma client handles the enum mapping automatically when using
    // string literals that match the @map values in schema.
    return iconId as unknown as import('@prisma/client').IconId;
  }
}

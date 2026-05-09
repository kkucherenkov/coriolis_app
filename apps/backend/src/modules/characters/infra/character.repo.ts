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
 * Derived stats are computed by the rules-engine module (Story 3.2.2):
 *   hp.max         = computeHpMax(strength, agility)     — PRD §5.2
 *   mp.max         = computeMpMax(wits, empathy)          — PRD §5.2
 *   encumbrance.max     = computeEncumbranceMax(strength)      — PRD §5.2
 *   encumbrance.current = computeEncumbranceCurrent(items) — PRD §5.3
 *
 * For the list() projection, items are not fetched (perf), so encumbrance.current
 * is not returned in CharacterListItem — only in CharacterReadModel (full).
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';
import {
  computeEncumbranceCurrent,
  computeEncumbranceMax,
  computeHpMax,
  computeMpMax,
} from '../../rules-engine';

import type {
  Attributes,
  CharacterListItem,
  CharacterReadModel,
  CharacterStatus,
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
  status: true,
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
  attributes: true,
  hpCurrent: true,
  mpCurrent: true,
  conditions: true,
  status: true,
  createdAt: true,
  updatedAt: true,
} as const;

// --------------- Mappers ---------------

interface PrismaCharacterFull {
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
  /** Prisma enum value: 'ACTIVE' | 'DRAFT' (uppercase). Mapped to lowercase at boundary. */
  status: string;
  createdAt: Date;
  updatedAt: Date;
  items: { id: string; type: string; data: unknown }[];
  talents: { id: string; name: string; description: string; rank: number; acquiredAt: Date }[];
  relationships: { id: string; targetName: string; kind: string; notes: string | null }[];
  criticalInjuries: {
    id: string;
    name: string;
    severity: string;
    effect: string;
    acquiredAt: Date;
  }[];
}

/** Maps Prisma UPPERCASE enum to OpenAPI lowercase wire value. */
function toCharacterStatus(s: string): CharacterStatus {
  return s.toLowerCase() as CharacterStatus;
}

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
  const attrs = row.attributes as Attributes;
  const inventory = row.items.map((it) => mapItem(it));
  return {
    id: row.id,
    ownerId: row.ownerId,
    name: row.name,
    concept: row.concept,
    iconId: row.iconId as unknown as IconId | null,
    attributes: attrs,
    skills: row.skills as Skills,
    hp: {
      current: row.hpCurrent,
      max: computeHpMax(attrs.strength, attrs.agility),
    },
    mp: {
      current: row.mpCurrent,
      max: computeMpMax(attrs.wits, attrs.empathy),
    },
    encumbrance: {
      current: computeEncumbranceCurrent(inventory),
      max: computeEncumbranceMax(attrs.strength),
    },
    experience: row.experience,
    conditions: row.conditions as ConditionFlags,
    criticalInjuries: row.criticalInjuries.map((ci) => mapInjury(ci)),
    talents: row.talents.map((t) => mapTalent(t)),
    relationships: row.relationships.map((r) => mapRelationship(r)),
    inventory,
    notes: row.notes,
    status: toCharacterStatus(row.status),
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
    return row ? toReadModel(row) : null;
  }

  async findOwnerIdById(id: string): Promise<{ ownerId: string } | null> {
    const row = await this.prisma.character.findFirst({
      where: { id },
      select: { ownerId: true },
    });
    return row ?? null;
  }

  async list(opts: ListCharactersOptions): Promise<{ items: CharacterListItem[]; nextCursor: string | null }> {
    const { ownerId, limit, cursor, includeDrafts } = opts;
    const take = limit + 1; // fetch one extra to detect next page

    // Default behaviour: only return ACTIVE characters (dashboard-safe).
    // When includeDrafts=true, return both ACTIVE and DRAFT.
    const statusFilter = includeDrafts ? undefined : ('ACTIVE' as const);

    const rows = await this.prisma.character.findMany({
      where: {
        ownerId,
        ...(statusFilter ? { status: statusFilter } : {}),
      },
      select: CHARACTER_LIST_SELECT,
      orderBy: { createdAt: 'desc' },
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
      take,
    });

    const hasNext = rows.length > limit;
    const items = hasNext ? rows.slice(0, limit) : rows;

    return {
      items: items.map((row) => {
        const attrs = row.attributes as unknown as Attributes;
        return {
          id: row.id,
          ownerId: row.ownerId,
          name: row.name,
          concept: row.concept,
          iconId: row.iconId as unknown as IconId | null,
          hp: {
            current: row.hpCurrent,
            max: computeHpMax(attrs.strength, attrs.agility),
          },
          mp: {
            current: row.mpCurrent,
            max: computeMpMax(attrs.wits, attrs.empathy),
          },
          conditions: row.conditions as unknown as ConditionFlags,
          status: toCharacterStatus(row.status),
          createdAt: row.createdAt.toISOString(),
          updatedAt: row.updatedAt.toISOString(),
        };
      }),
      nextCursor: hasNext ? (items.at(-1)?.id ?? null) : null,
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
    status?: CharacterStatus;
  }): Promise<CharacterReadModel> {
    // Map lowercase wire status to Prisma UPPERCASE enum value.
    const statusEnum = (data.status?.toUpperCase() ?? 'ACTIVE') as 'ACTIVE' | 'DRAFT';

    const row = await this.prisma.character.create({
      data: {
        ownerId: data.ownerId,
        name: data.name,
        concept: data.concept ?? null,
        iconId: data.iconId ? this.toIconIdEnum(data.iconId) : null,
        attributes: data.attributes as unknown as import('@prisma/client').Prisma.InputJsonValue,
        skills: data.skills as unknown as import('@prisma/client').Prisma.InputJsonValue,
        hpCurrent: data.hpCurrent,
        mpCurrent: data.mpCurrent,
        experience: data.experience,
        conditions: data.conditions as unknown as import('@prisma/client').Prisma.InputJsonValue,
        notes: data.notes ?? null,
        status: statusEnum,
      },
      select: CHARACTER_FULL_SELECT,
    });
    return toReadModel(row);
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
      criticalInjuries: {
        name: string;
        severity: CriticalInjurySeverity;
        effect: string;
        acquiredAt: string;
      }[];
      notes: string | null;
      status: CharacterStatus;
    }>,
  ): Promise<CharacterReadModel> {
    const { criticalInjuries, iconId, status, ...rest } = data;

    await this.prisma.$transaction(async (tx) => {
      // Replace critical injuries if provided
      if (criticalInjuries !== undefined) {
        await tx.criticalInjury.deleteMany({ where: { characterId: id } });
        if (criticalInjuries.length > 0) {
          await tx.criticalInjury.createMany({
            data: criticalInjuries.map((inj) => ({
              characterId: id,
              name: inj.name,
              severity: inj.severity,
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
      if (rest.attributes) updateData['attributes'] = rest.attributes;
      if (rest.skills) updateData['skills'] = rest.skills;
      if (rest.conditions) updateData['conditions'] = rest.conditions;
      // Map lowercase wire status to Prisma UPPERCASE enum on update.
      if (status !== undefined) {
        updateData['status'] = status.toUpperCase();
      }

      if (Object.keys(updateData).length > 0) {
        await tx.character.update({ where: { id }, data: updateData });
      }
    });

    const updated = await this.findActiveById(id);
    if (!updated) {
      throw new Error(`Character ${id} not found after update — race condition or missing row.`);
    }
    return updated;
  }

  async deleteAbandonedDrafts(cutoff: Date): Promise<number> {
    const result = await this.prisma.character.deleteMany({
      where: {
        status: 'DRAFT' as const,
        updatedAt: { lt: cutoff },
      },
    });
    return result.count;
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

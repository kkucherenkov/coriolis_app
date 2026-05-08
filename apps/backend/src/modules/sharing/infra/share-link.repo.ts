/**
 * WHY this file exists:
 * Prisma-backed implementation of IShareLinkRepo.
 * The only place in the sharing bounded context that imports PrismaService.
 * All SELECT shapes are scoped to use-case needs per the architecture rules.
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
  CharacterReadModel,
  CharacterStatus,
  ConditionFlags,
  CriticalInjurySeverity,
  IconId,
  ItemReadModel,
  ItemType,
  RelationshipKind,
  RelationshipReadModel,
  Skills,
  TalentReadModel,
} from '../../characters/domain/character.ports';
import type {
  CreateShareLinkData,
  IShareLinkRepo,
  ShareLinkReadModel,
  ViewFlushEntry,
} from '../domain/share-link.ports';

// --------------- Scoped select shapes ---------------

const SHARE_LINK_SELECT = {
  id: true,
  slug: true,
  characterId: true,
  includeGmNotes: true,
  label: true,
  expiresAt: true,
  revokedAt: true,
  lastViewedAt: true,
  viewCount: true,
  createdAt: true,
  updatedAt: true,
} as const;

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

// --------------- Row types ---------------

interface PrismaShareLinkRow {
  id: string;
  slug: string;
  characterId: string;
  includeGmNotes: boolean;
  label: string | null;
  expiresAt: Date | null;
  revokedAt: Date | null;
  lastViewedAt: Date | null;
  viewCount: number;
  createdAt: Date;
  updatedAt: Date;
}

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
  status: string;
  createdAt: Date;
  updatedAt: Date;
  items: { id: string; type: string; data: unknown }[];
  talents: { id: string; name: string; description: string; rank: number; acquiredAt: Date }[];
  relationships: { id: string; targetName: string; kind: string; notes: string | null }[];
  criticalInjuries: { id: string; name: string; severity: string; effect: string; acquiredAt: Date }[];
}

// --------------- Mappers ---------------

function mapShareLink(row: PrismaShareLinkRow): ShareLinkReadModel {
  return {
    id: row.id,
    slug: row.slug,
    characterId: row.characterId,
    includeGmNotes: row.includeGmNotes,
    label: row.label,
    expiresAt: row.expiresAt?.toISOString() ?? null,
    revokedAt: row.revokedAt?.toISOString() ?? null,
    lastViewedAt: row.lastViewedAt?.toISOString() ?? null,
    viewCount: row.viewCount,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

function mapCharacter(row: PrismaCharacterFull): CharacterReadModel {
  const attributes = row.attributes as Attributes;
  const skills = row.skills as Skills;
  const conditions = row.conditions as ConditionFlags;
  const items = row.items.map((item): ItemReadModel => ({
    id: item.id,
    type: item.type as ItemType,
    ...(item.data as Record<string, unknown>),
  }));
  const talents = row.talents.map((t): TalentReadModel => ({
    id: t.id,
    name: t.name,
    description: t.description,
    rank: t.rank,
    acquiredAt: t.acquiredAt.toISOString(),
  }));
  const relationships = row.relationships.map((r): RelationshipReadModel => ({
    id: r.id,
    targetName: r.targetName,
    kind: r.kind as RelationshipKind,
    notes: r.notes,
  }));
  const criticalInjuries = row.criticalInjuries.map((c) => ({
    id: c.id,
    name: c.name,
    severity: c.severity as CriticalInjurySeverity,
    effect: c.effect,
    acquiredAt: c.acquiredAt.toISOString(),
  }));

  return {
    id: row.id,
    ownerId: row.ownerId,
    name: row.name,
    concept: row.concept,
    iconId: row.iconId as IconId | null,
    attributes,
    skills,
    hp: { current: row.hpCurrent, max: computeHpMax(attributes.strength, attributes.agility) },
    mp: { current: row.mpCurrent, max: computeMpMax(attributes.wits, attributes.empathy) },
    encumbrance: {
      current: computeEncumbranceCurrent(items),
      max: computeEncumbranceMax(attributes.strength),
    },
    experience: row.experience,
    conditions,
    criticalInjuries,
    talents,
    relationships,
    inventory: items,
    notes: row.notes,
    status: row.status.toLowerCase() as CharacterStatus,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

// --------------- Repository ---------------

@Injectable()
export class ShareLinkRepo implements IShareLinkRepo {
  constructor(private readonly prisma: PrismaService) {}

  async create(data: CreateShareLinkData): Promise<ShareLinkReadModel> {
    const row = await this.prisma.shareLink.create({
      data: {
        slug: data.slug,
        characterId: data.characterId,
        includeGmNotes: data.includeGmNotes,
        label: data.label,
        expiresAt: data.expiresAt,
      },
      select: SHARE_LINK_SELECT,
    });
    return mapShareLink(row);
  }

  async findBySlug(slug: string): Promise<ShareLinkReadModel | null> {
    const row = await this.prisma.shareLink.findUnique({
      where: { slug },
      select: SHARE_LINK_SELECT,
    });
    return row ? mapShareLink(row) : null;
  }

  async findById(id: string): Promise<ShareLinkReadModel | null> {
    const row = await this.prisma.shareLink.findUnique({
      where: { id },
      select: SHARE_LINK_SELECT,
    });
    return row ? mapShareLink(row) : null;
  }

  async findOwnerIdByShareLinkId(id: string): Promise<{ ownerId: string } | null> {
    const row = await this.prisma.shareLink.findUnique({
      where: { id },
      select: { character: { select: { ownerId: true } } },
    });
    if (!row) return null;
    return { ownerId: row.character.ownerId };
  }

  async listByCharacterId(characterId: string): Promise<ShareLinkReadModel[]> {
    const rows = await this.prisma.shareLink.findMany({
      where: { characterId, revokedAt: null },
      select: SHARE_LINK_SELECT,
      orderBy: { createdAt: 'desc' },
    });
    return rows.map((row) => mapShareLink(row));
  }

  async revoke(id: string): Promise<void> {
    await this.prisma.shareLink.update({
      where: { id },
      data: { revokedAt: new Date() },
    });
  }

  async findCharacterBySlug(slug: string): Promise<{
    shareLink: ShareLinkReadModel;
    character: CharacterReadModel;
  } | null> {
    const row = await this.prisma.shareLink.findUnique({
      where: { slug },
      select: {
        ...SHARE_LINK_SELECT,
        character: { select: CHARACTER_FULL_SELECT },
      },
    });
    if (!row) return null;

    const { character, ...shareLinkRow } = row;
    return {
      shareLink: mapShareLink(shareLinkRow),
      character: mapCharacter(character),
    };
  }

  async flushViewCounts(entries: ViewFlushEntry[]): Promise<void> {
    if (entries.length === 0) return;

    const now = new Date();
    await this.prisma.$transaction(
      entries.map((entry) =>
        this.prisma.shareLink.updateMany({
          where: { slug: entry.slug },
          data: {
            viewCount: { increment: entry.count },
            lastViewedAt: now,
          },
        }),
      ),
    );
  }
}

/**
 * WHY this file exists:
 * Prisma-backed implementation of IRollRepo. The only place in the dice
 * bounded context that imports PrismaService. All SELECT shapes are scoped
 * to use-case needs per the architecture rules.
 */
import { Injectable, Logger } from '@nestjs/common';
import type { Prisma } from '@prisma/client';

import { PrismaService } from '../../../common/prisma/prisma.service';
import { toRollKind } from '../domain/roll.ports';

import type { IRollRepo, RollBreakdown, RollReadModel } from '../domain/roll.ports';

// --------------- Scoped select shape ---------------

const ROLL_SELECT = {
  id: true,
  characterId: true,
  gameSessionId: true,
  label: true,
  pool: true,
  dice: true,
  hits: true,
  pushed: true,
  kind: true,
  breakdown: true,
  createdAt: true,
} as const;

// --------------- Logger ---------------

const logger = new Logger('RollRepo');

// --------------- Row type ---------------

interface PrismaRollRow {
  id: string;
  characterId: string;
  gameSessionId: string | null;
  label: string;
  pool: number;
  dice: number[];
  hits: number;
  pushed: boolean;
  kind: string;
  breakdown: unknown;
  createdAt: Date;
}

/** Narrows the raw JSONB blob to RollBreakdown; returns null on malformed data. */
function toRollBreakdown(raw: unknown, rollId: string): RollBreakdown | null {
  if (raw === null || raw === undefined) return null;
  if (
    typeof raw === 'object' &&
    !Array.isArray(raw) &&
    'attribute' in raw &&
    'skill' in raw &&
    'gear' in raw &&
    'modifier' in raw &&
    'helpers' in raw
  ) {
    const r = raw as Record<string, unknown>;
    if (
      typeof r['attribute'] === 'number' &&
      typeof r['skill'] === 'number' &&
      typeof r['gear'] === 'number' &&
      typeof r['modifier'] === 'number' &&
      typeof r['helpers'] === 'number'
    ) {
      return {
        attribute: r['attribute'],
        skill: r['skill'],
        gear: r['gear'],
        modifier: r['modifier'],
        helpers: r['helpers'],
      };
    }
  }
  logger.warn(`Malformed breakdown JSONB on roll ${rollId}; treating as null`);
  return null;
}

// --------------- Mapper ---------------

function mapRoll(row: PrismaRollRow): RollReadModel {
  const kind = toRollKind(row.kind);
  if (kind !== row.kind) {
    logger.warn(
      `Unexpected roll.kind value '${row.kind}' for roll ${row.id}; defaulting to 'skill'`,
    );
  }
  return {
    id: row.id,
    characterId: row.characterId,
    gameSessionId: row.gameSessionId,
    label: row.label,
    pool: row.pool,
    dice: row.dice,
    hits: row.hits,
    pushed: row.pushed,
    kind,
    breakdown: toRollBreakdown(row.breakdown, row.id),
    createdAt: row.createdAt.toISOString(),
  };
}

// --------------- Repository ---------------

@Injectable()
export class RollRepo implements IRollRepo {
  constructor(private readonly prisma: PrismaService) {}

  async create(data: {
    characterId: string;
    gameSessionId: string | null;
    label: string;
    pool: number;
    dice: number[];
    hits: number;
    kind: import('../domain/roll.ports').RollKind;
    breakdown: import('../domain/roll.ports').RollBreakdown | null;
  }): Promise<RollReadModel> {
    // exactOptionalPropertyTypes: don't pass `undefined` to an optional Prisma
    // input — spread the breakdown only when it's a real object so the key is
    // omitted entirely on null. (Passing `undefined` literal is a TS error;
    // omitting the key Prisma reads as "leave the column at its DB default
    // / NULL", which is exactly what we want for a roll without breakdown.)
    const row = await this.prisma.roll.create({
      data: {
        characterId: data.characterId,
        gameSessionId: data.gameSessionId,
        label: data.label,
        pool: data.pool,
        dice: data.dice,
        hits: data.hits,
        kind: data.kind,
        // RollBreakdown is a fixed-shape interface; Prisma's InputJsonValue
        // wants an index signature, so we cast through `unknown` to land in
        // the InputJsonValue lattice without weakening the domain type.
        ...(data.breakdown === null
          ? {}
          : { breakdown: data.breakdown as unknown as Prisma.InputJsonValue }),
      },
      select: ROLL_SELECT,
    });
    return mapRoll(row);
  }

  async findById(id: string): Promise<RollReadModel | null> {
    const row = await this.prisma.roll.findUnique({
      where: { id },
      select: ROLL_SELECT,
    });
    return row ? mapRoll(row) : null;
  }

  async push(id: string, dice: number[], hits: number): Promise<RollReadModel> {
    const row = await this.prisma.roll.update({
      where: { id },
      data: { dice, hits, pushed: true },
      select: ROLL_SELECT,
    });
    return mapRoll(row);
  }

  async listByCharacterId(characterId: string, limit: number): Promise<RollReadModel[]> {
    const rows = await this.prisma.roll.findMany({
      where: { characterId },
      select: ROLL_SELECT,
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
    return rows.map((row) => mapRoll(row as PrismaRollRow));
  }
}

/**
 * WHY this file exists:
 * Prisma-backed implementation of IRollRepo. The only place in the dice
 * bounded context that imports PrismaService. All SELECT shapes are scoped
 * to use-case needs per the architecture rules.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';

import type { IRollRepo, RollReadModel } from '../domain/roll.ports';

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
  createdAt: true,
} as const;

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
  createdAt: Date;
}

// --------------- Mapper ---------------

function mapRoll(row: PrismaRollRow): RollReadModel {
  return {
    id: row.id,
    characterId: row.characterId,
    gameSessionId: row.gameSessionId,
    label: row.label,
    pool: row.pool,
    dice: row.dice,
    hits: row.hits,
    pushed: row.pushed,
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
  }): Promise<RollReadModel> {
    const row = await this.prisma.roll.create({
      data: {
        characterId: data.characterId,
        gameSessionId: data.gameSessionId,
        label: data.label,
        pool: data.pool,
        dice: data.dice,
        hits: data.hits,
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
    return rows.map((row) => mapRoll(row));
  }
}

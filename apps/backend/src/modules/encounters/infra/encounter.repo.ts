/**
 * WHY this file exists:
 * Infrastructure adapter — the Prisma-backed implementation of IEncounterRepo.
 * This is the only file in the encounters bounded context that imports PrismaService.
 * Handlers inject IEncounterRepo by the ENCOUNTER_REPO token.
 *
 * status is stored as a Prisma enum (uppercase: SETUP / ACTIVE / ENDED).
 * The mapper converts to lowercase wire values on read, and back to uppercase on write.
 */
import { Injectable } from '@nestjs/common';

import { type EncounterStatus as PrismaEncounterStatus } from '@prisma/client';

import { PrismaService } from '../../../common/prisma/prisma.service';

import type {
  EncounterCreateData,
  EncounterListOptions,
  EncounterReadModel,
  EncounterStatus,
  EncounterUpdateData,
  IEncounterRepo,
} from '../domain/encounter.ports';

// --------------- Select shape ---------------

const ENCOUNTER_SELECT = {
  id: true,
  gameSessionId: true,
  name: true,
  notes: true,
  status: true,
  round: true,
  activeCombatantId: true,
  createdAt: true,
  updatedAt: true,
} as const;

interface PrismaEncounterRow {
  id: string;
  gameSessionId: string;
  name: string;
  notes: string | null;
  status: string;
  round: number;
  activeCombatantId: string | null;
  createdAt: Date;
  updatedAt: Date;
}

// --------------- Mapper ---------------

function toStatus(s: string): EncounterStatus {
  return s.toLowerCase() as EncounterStatus;
}

function toPrismaStatus(s: EncounterStatus): PrismaEncounterStatus {
  return s.toUpperCase() as PrismaEncounterStatus;
}

function toReadModel(row: PrismaEncounterRow): EncounterReadModel {
  return {
    id: row.id,
    gameSessionId: row.gameSessionId,
    name: row.name,
    notes: row.notes,
    status: toStatus(row.status),
    round: row.round,
    activeCombatantId: row.activeCombatantId,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

// --------------- Repo ---------------

@Injectable()
export class EncounterRepo implements IEncounterRepo {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string): Promise<EncounterReadModel | null> {
    const row = await this.prisma.encounter.findFirst({
      where: { id },
      select: ENCOUNTER_SELECT,
    });
    return row ? toReadModel(row) : null;
  }

  async list(
    opts: EncounterListOptions,
  ): Promise<{ items: EncounterReadModel[]; nextCursor: string | null }> {
    const { gameSessionId, limit, cursor, status } = opts;
    const take = limit + 1;

    const rows = await this.prisma.encounter.findMany({
      where: {
        gameSessionId,
        ...(status ? { status: toPrismaStatus(status) } : {}),
      },
      select: ENCOUNTER_SELECT,
      orderBy: { createdAt: 'desc' },
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
      take,
    });

    const hasNext = rows.length > limit;
    const items = hasNext ? rows.slice(0, limit) : rows;

    return {
      items: items.map((r) => toReadModel(r)),
      nextCursor: hasNext ? (items.at(-1)?.id ?? null) : null,
    };
  }

  async create(data: EncounterCreateData): Promise<EncounterReadModel> {
    const row = await this.prisma.encounter.create({
      data: {
        gameSessionId: data.gameSessionId,
        name: data.name,
        notes: data.notes ?? null,
      },
      select: ENCOUNTER_SELECT,
    });
    return toReadModel(row);
  }

  async update(id: string, data: EncounterUpdateData): Promise<EncounterReadModel> {
    const payload: Record<string, unknown> = {};
    if (data.name !== undefined) payload['name'] = data.name;
    if ('notes' in data) payload['notes'] = data.notes ?? null;
    if (data.status !== undefined) payload['status'] = toPrismaStatus(data.status);
    if (data.round !== undefined) payload['round'] = data.round;
    if ('activeCombatantId' in data) payload['activeCombatantId'] = data.activeCombatantId ?? null;

    const row = await this.prisma.encounter.update({
      where: { id },
      data: payload,
      select: ENCOUNTER_SELECT,
    });
    return toReadModel(row);
  }

  async delete(id: string): Promise<void> {
    await this.prisma.encounter.delete({ where: { id } });
  }
}

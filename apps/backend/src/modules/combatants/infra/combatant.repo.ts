/**
 * WHY this file exists:
 * Infrastructure adapter — the Prisma-backed implementation of ICombatantRepo.
 * This is the only file in the combatants bounded context that imports PrismaService.
 * Handlers inject ICombatantRepo by the COMBATANT_REPO token.
 *
 * combatantType is stored as a Prisma enum (uppercase: PC / NPC).
 * The mapper converts to lowercase wire values on read, and back to uppercase on write.
 *
 * Unique-violation on (encounterId, characterId) or (encounterId, npcId) is caught
 * and re-thrown as CombatantDuplicateError (422).
 */
import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../../../common/prisma/prisma.service';
import { CombatantDuplicateError } from '../domain/combatant.errors';

import type {
  CombatantCreateData,
  CombatantReadModel,
  CombatantTypeValue,
  CombatantUpdateData,
  CombatantWithSnapshot,
  ICombatantCount,
  ICombatantRepo,
  NpcSnapshot,
  PcSnapshot,
} from '../domain/combatant.ports';

// --------------- Select shape ---------------

const COMBATANT_SELECT = {
  id: true,
  encounterId: true,
  combatantType: true,
  characterId: true,
  npcId: true,
  displayName: true,
  initiative: true,
  turnOrder: true,
  hpCurrent: true,
  hpMax: true,
  armor: true,
  signature: true,
  statusFlags: true,
  notes: true,
  createdAt: true,
  updatedAt: true,
  // intentionally excludes pcSnapshot / npcSnapshot — snapshots are write-once
  // and read only by Block 4 initiative logic, not by the general read path
} as const;

interface PrismaCombatantRow {
  id: string;
  encounterId: string;
  combatantType: string;
  characterId: string | null;
  npcId: string | null;
  displayName: string;
  initiative: number | null;
  turnOrder: number | null;
  hpCurrent: number;
  hpMax: number;
  armor: number;
  signature: number;
  statusFlags: string[];
  notes: string | null;
  createdAt: Date;
  updatedAt: Date;
}

// --------------- Mappers ---------------

function toCombatantType(s: string): CombatantTypeValue {
  return s.toLowerCase() as CombatantTypeValue;
}

function toPrismaType(t: CombatantTypeValue): string {
  return t.toUpperCase();
}

function toReadModel(row: PrismaCombatantRow): CombatantReadModel {
  const sourceId = row.characterId ?? row.npcId ?? '';
  return {
    id: row.id,
    encounterId: row.encounterId,
    combatantType: toCombatantType(row.combatantType),
    sourceId,
    displayName: row.displayName,
    initiative: row.initiative,
    turnOrder: row.turnOrder,
    hpCurrent: row.hpCurrent,
    hpMax: row.hpMax,
    armor: row.armor,
    signature: row.signature,
    statusFlags: row.statusFlags,
    notes: row.notes,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

/** Converts an optional snapshot object to a Prisma JSON value or JsonNull sentinel. */
function toJsonValue(value: object | undefined): Prisma.InputJsonValue | typeof Prisma.JsonNull {
  if (value === undefined) return Prisma.JsonNull;
  return value;
}

function catchDuplicate(err: unknown, combatantType: string, sourceId: string): never {
  if (err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002') {
    throw new CombatantDuplicateError(combatantType, sourceId);
  }
  throw err;
}

// --------------- Repo ---------------

@Injectable()
export class CombatantRepo implements ICombatantRepo, ICombatantCount {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string): Promise<CombatantReadModel | null> {
    const row = await this.prisma.combatant.findFirst({
      where: { id },
      select: COMBATANT_SELECT,
    });
    return row ? toReadModel(row) : null;
  }

  async listByEncounter(encounterId: string): Promise<CombatantReadModel[]> {
    const rows = await this.prisma.combatant.findMany({
      where: { encounterId },
      select: COMBATANT_SELECT,
      orderBy: [{ turnOrder: 'asc' }, { createdAt: 'asc' }],
    });
    return rows.map((r) => toReadModel(r));
  }

  async listByEncounterWithSnapshot(encounterId: string): Promise<CombatantWithSnapshot[]> {
    const rows = await this.prisma.combatant.findMany({
      where: { encounterId },
      select: {
        ...COMBATANT_SELECT,
        pcSnapshot: true,
        npcSnapshot: true,
      },
      orderBy: [{ createdAt: 'asc' }],
    });
    return rows.map((r) => ({
      combatant: toReadModel(r),
      pcSnapshot: r.pcSnapshot as PcSnapshot | null,
      npcSnapshot: r.npcSnapshot as NpcSnapshot | null,
    }));
  }

  async create(data: CombatantCreateData): Promise<CombatantReadModel> {
    const sourceId = data.characterId ?? data.npcId ?? '';
    try {
      const row = await this.prisma.combatant.create({
        data: {
          encounterId: data.encounterId,
          combatantType: toPrismaType(data.combatantType) as 'PC' | 'NPC',
          characterId: data.characterId ?? null,
          npcId: data.npcId ?? null,
          displayName: data.displayName,
          hpCurrent: data.hpCurrent,
          hpMax: data.hpMax,
          armor: data.armor,
          signature: data.signature,
          notes: data.notes ?? null,
          pcSnapshot: toJsonValue(data.pcSnapshot),
          npcSnapshot: toJsonValue(data.npcSnapshot),
        },
        select: COMBATANT_SELECT,
      });
      return toReadModel(row);
    } catch (error) {
      catchDuplicate(error, data.combatantType, sourceId);
    }
  }

  async update(id: string, data: CombatantUpdateData): Promise<CombatantReadModel> {
    const payload: Record<string, unknown> = {};
    if (data.displayName !== undefined) payload['displayName'] = data.displayName;
    if (data.hpCurrent !== undefined) payload['hpCurrent'] = data.hpCurrent;
    if (data.armor !== undefined) payload['armor'] = data.armor;
    if (data.signature !== undefined) payload['signature'] = data.signature;
    if (data.statusFlags !== undefined) payload['statusFlags'] = data.statusFlags;
    if ('notes' in data) payload['notes'] = data.notes ?? null;
    if ('initiative' in data) payload['initiative'] = data.initiative ?? null;
    if ('turnOrder' in data) payload['turnOrder'] = data.turnOrder ?? null;

    const row = await this.prisma.combatant.update({
      where: { id },
      data: payload,
      select: COMBATANT_SELECT,
    });
    return toReadModel(row);
  }

  async delete(id: string): Promise<void> {
    await this.prisma.combatant.delete({ where: { id } });
  }

  async countByEncounter(encounterId: string): Promise<number> {
    return this.prisma.combatant.count({ where: { encounterId } });
  }

  /**
   * Returns raw snapshot JSON for Block 4 initiative tie-breaking.
   * Not part of ICombatantRepo — only called by initiative handlers.
   */
  async findWithSnapshot(
    id: string,
  ): Promise<{ pcSnapshot: PcSnapshot | null; npcSnapshot: NpcSnapshot | null } | null> {
    const row = await this.prisma.combatant.findFirst({
      where: { id },
      select: { pcSnapshot: true, npcSnapshot: true },
    });
    if (!row) return null;
    return {
      pcSnapshot: row.pcSnapshot as PcSnapshot | null,
      npcSnapshot: row.npcSnapshot as NpcSnapshot | null,
    };
  }
}

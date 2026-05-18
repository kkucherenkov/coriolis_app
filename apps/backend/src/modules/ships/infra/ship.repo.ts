/**
 * WHY this file exists:
 * Infrastructure adapter — the Prisma-backed implementation of IShipRepo.
 * This is the only file in the ships bounded context that imports PrismaService.
 * Handlers inject IShipRepo by the SHIP_REPO token.
 *
 * Reads always include modules + crew in a single query (include: { modules: true, crew: true })
 * to match the OpenAPI Ship shape. No post-hoc JS projection over full entities.
 */
import { Injectable } from '@nestjs/common';

import {
  Prisma,
  type ShipClass as PrismaShipClass,
  type ShipModuleSlot as PrismaShipModuleSlot,
  type CrewPosition as PrismaCrewPosition,
} from '@prisma/client';

import { PrismaService } from '../../../common/prisma/prisma.service';
import { fromDbSlot, toShipReadModel } from './ship.mapper';

import type {
  IShipRepo,
  ShipClass,
  ShipListOptions,
  ShipModuleCreateData,
  ShipModuleReadModel,
  ShipModuleUpdateData,
  ShipReadModel,
} from '../domain/ship.ports';

/** Wire kebab-case ShipClass → Prisma underscore_case ShipClass */
function toDbShipClass(c: ShipClass): PrismaShipClass {
  return c.replaceAll('-', '_') as PrismaShipClass;
}

/** Wire SCREAMING-KEBAB ShipModuleSlot → Prisma SCREAMING_UNDERSCORE ShipModuleSlot */
function toDbSlot(s: string): PrismaShipModuleSlot {
  return s.replaceAll('-', '_') as PrismaShipModuleSlot;
}

/** Wire CrewPosition → Prisma CrewPosition (same values, cast only) */
function toDbPosition(p: string): PrismaCrewPosition {
  return p as PrismaCrewPosition;
}

const SHIP_INCLUDE = {
  modules: {
    select: { id: true, slot: true, name: true, energyUse: true, data: true },
    orderBy: { createdAt: 'asc' as const },
  },
  crew: {
    select: { position: true, assignedCharacterId: true },
    orderBy: { position: 'asc' as const },
  },
} as const;

const SHIP_SELECT = {
  id: true,
  ownerId: true,
  name: true,
  class: true,
  model: true,
  registry: true,
  hullCurrent: true,
  hullMax: true,
  energyCurrent: true,
  energyMax: true,
  armor: true,
  maneuverability: true,
  signature: true,
  speed: true,
  cargoCapacity: true,
  problems: true,
  history: true,
  notes: true,
  createdAt: true,
  updatedAt: true,
  modules: SHIP_INCLUDE.modules,
  crew: SHIP_INCLUDE.crew,
} as const;

@Injectable()
export class ShipRepo implements IShipRepo {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string): Promise<ShipReadModel | null> {
    const row = await this.prisma.ship.findFirst({
      where: { id },
      select: SHIP_SELECT,
    });
    return row ? toShipReadModel(row) : null;
  }

  async list(
    opts: ShipListOptions,
  ): Promise<{ items: ShipReadModel[]; nextCursor: string | null }> {
    const { ownerId, limit, cursor } = opts;
    const take = limit + 1;

    const rows = await this.prisma.ship.findMany({
      where: { ownerId },
      select: SHIP_SELECT,
      orderBy: { createdAt: 'desc' },
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
      take,
    });

    const hasNext = rows.length > limit;
    const items = hasNext ? rows.slice(0, limit) : rows;

    return {
      items: items.map((r) => toShipReadModel(r)),
      nextCursor: hasNext ? (items.at(-1)?.id ?? null) : null,
    };
  }

  async create(data: {
    ownerId: string;
    name: string;
    class: ShipClass;
    model?: string | null;
    registry?: string | null;
    hullCurrent: number;
    hullMax: number;
    energyCurrent: number;
    energyMax: number;
    armor: number;
    maneuverability: number;
    signature: number;
    speed: number;
    cargoCapacity: number;
    notes?: string | null;
    history?: string | null;
  }): Promise<ShipReadModel> {
    const row = await this.prisma.ship.create({
      data: {
        ownerId: data.ownerId,
        name: data.name,
        class: toDbShipClass(data.class),
        model: data.model ?? null,
        registry: data.registry ?? null,
        hullCurrent: data.hullCurrent,
        hullMax: data.hullMax,
        energyCurrent: data.energyCurrent,
        energyMax: data.energyMax,
        armor: data.armor,
        maneuverability: data.maneuverability,
        signature: data.signature,
        speed: data.speed,
        cargoCapacity: data.cargoCapacity,
        notes: data.notes ?? null,
        history: data.history ?? null,
        // Auto-create mandatory modules
        modules: {
          create: [
            { slot: 'BRIDGE', name: 'Bridge', energyUse: 1, data: {} },
            { slot: 'REACTOR', name: 'Reactor', energyUse: 0, data: {} },
            { slot: 'DRIVE', name: 'Drive', energyUse: 2, data: {} },
          ],
        },
        // Auto-create six crew slots
        crew: {
          create: [
            { position: 'captain', assignedCharacterId: null },
            { position: 'pilot', assignedCharacterId: null },
            { position: 'sensorOp', assignedCharacterId: null },
            { position: 'gunner', assignedCharacterId: null },
            { position: 'engineer', assignedCharacterId: null },
            { position: 'serviceCrew', assignedCharacterId: null },
          ],
        },
      },
      select: SHIP_SELECT,
    });
    return toShipReadModel(row);
  }

  async update(
    id: string,
    data: Partial<{
      name: string;
      model: string | null;
      registry: string | null;
      hullCurrent: number;
      hullMax: number;
      energyCurrent: number;
      energyMax: number;
      armor: number;
      maneuverability: number;
      signature: number;
      speed: number;
      problems: string[];
      history: string | null;
      notes: string | null;
    }>,
  ): Promise<ShipReadModel> {
    const payload: Record<string, unknown> = {};
    if (data.name !== undefined) payload['name'] = data.name;
    if ('model' in data) payload['model'] = data.model;
    if ('registry' in data) payload['registry'] = data.registry;
    if (data.hullCurrent !== undefined) payload['hullCurrent'] = data.hullCurrent;
    if (data.hullMax !== undefined) payload['hullMax'] = data.hullMax;
    if (data.energyCurrent !== undefined) payload['energyCurrent'] = data.energyCurrent;
    if (data.energyMax !== undefined) payload['energyMax'] = data.energyMax;
    if (data.armor !== undefined) payload['armor'] = data.armor;
    if (data.maneuverability !== undefined) payload['maneuverability'] = data.maneuverability;
    if (data.signature !== undefined) payload['signature'] = data.signature;
    if (data.speed !== undefined) payload['speed'] = data.speed;
    if ('problems' in data) payload['problems'] = data.problems;
    if ('history' in data) payload['history'] = data.history;
    if ('notes' in data) payload['notes'] = data.notes;

    const row = await this.prisma.ship.update({
      where: { id },
      data: payload,
      select: SHIP_SELECT,
    });
    return toShipReadModel(row);
  }

  async delete(id: string): Promise<void> {
    // Cascade deletes modules + crew slots
    await this.prisma.ship.delete({ where: { id } });
  }

  async findModuleById(
    moduleId: string,
  ): Promise<(ShipModuleReadModel & { shipId: string }) | null> {
    const row = await this.prisma.shipModule.findFirst({
      where: { id: moduleId },
      select: { id: true, shipId: true, slot: true, name: true, energyUse: true, data: true },
    });
    if (!row) return null;
    return {
      id: row.id,
      shipId: row.shipId,
      slot: fromDbSlot(row.slot),
      name: row.name,
      energyUse: row.energyUse,
      data: (row.data ?? {}) as Record<string, unknown>,
    };
  }

  async addModule(shipId: string, data: ShipModuleCreateData): Promise<ShipModuleReadModel> {
    const row = await this.prisma.shipModule.create({
      data: {
        shipId,
        slot: toDbSlot(data.slot),
        name: data.name,
        energyUse: data.energyUse,
        data: data.data as Prisma.InputJsonValue,
      },
      select: { id: true, slot: true, name: true, energyUse: true, data: true },
    });
    return {
      id: row.id,
      slot: fromDbSlot(row.slot),
      name: row.name,
      energyUse: row.energyUse,
      data: (row.data ?? {}) as Record<string, unknown>,
    };
  }

  async updateModule(moduleId: string, data: ShipModuleUpdateData): Promise<ShipModuleReadModel> {
    const payload: Record<string, unknown> = {};
    if (data.name !== undefined) payload['name'] = data.name;
    if (data.energyUse !== undefined) payload['energyUse'] = data.energyUse;
    if ('notes' in data) payload['notes'] = data.notes;
    if (data.data !== undefined) payload['data'] = data.data;

    const row = await this.prisma.shipModule.update({
      where: { id: moduleId },
      data: payload,
      select: { id: true, slot: true, name: true, energyUse: true, data: true },
    });
    return {
      id: row.id,
      slot: fromDbSlot(row.slot),
      name: row.name,
      energyUse: row.energyUse,
      data: (row.data ?? {}) as Record<string, unknown>,
    };
  }

  async deleteModule(moduleId: string): Promise<void> {
    await this.prisma.shipModule.delete({ where: { id: moduleId } });
  }

  async findCrewSlot(
    shipId: string,
    position: string,
  ): Promise<import('../domain/ship.ports').CrewSlotReadModel | null> {
    const row = await this.prisma.crewSlot.findFirst({
      where: { shipId, position: toDbPosition(position) },
      select: { position: true, assignedCharacterId: true },
    });
    if (!row) return null;
    return { position: row.position, assignedCharacterId: row.assignedCharacterId };
  }

  async findCrewSlotByCharacter(
    shipId: string,
    characterId: string,
  ): Promise<import('../domain/ship.ports').CrewSlotReadModel | null> {
    const row = await this.prisma.crewSlot.findFirst({
      where: { shipId, assignedCharacterId: characterId },
      select: { position: true, assignedCharacterId: true },
    });
    if (!row) return null;
    return { position: row.position, assignedCharacterId: row.assignedCharacterId };
  }

  async assignCrewSlot(
    shipId: string,
    position: string,
    characterId: string,
  ): Promise<import('../domain/ship.ports').CrewSlotReadModel> {
    const row = await this.prisma.crewSlot.update({
      where: { shipId_position: { shipId, position: toDbPosition(position) } },
      data: { assignedCharacterId: characterId },
      select: { position: true, assignedCharacterId: true },
    });
    return { position: row.position, assignedCharacterId: row.assignedCharacterId };
  }

  async unassignCrewSlot(shipId: string, characterId: string): Promise<void> {
    await this.prisma.crewSlot.updateMany({
      where: { shipId, assignedCharacterId: characterId },
      data: { assignedCharacterId: null },
    });
  }

  async duplicate(sourceId: string, ownerId: string, newName: string): Promise<ShipReadModel> {
    const source = await this.prisma.ship.findFirst({
      where: { id: sourceId },
      select: {
        class: true,
        model: true,
        registry: true,
        hullCurrent: true,
        hullMax: true,
        energyCurrent: true,
        energyMax: true,
        armor: true,
        maneuverability: true,
        signature: true,
        speed: true,
        cargoCapacity: true,
        problems: true,
        history: true,
        notes: true,
        modules: { select: { slot: true, name: true, energyUse: true, data: true } },
      },
    });

    if (!source) throw new Error('Ship not found in duplicate()');

    const row = await this.prisma.ship.create({
      data: {
        ownerId,
        name: newName,
        class: source.class,
        model: source.model,
        registry: source.registry,
        hullCurrent: source.hullCurrent,
        hullMax: source.hullMax,
        energyCurrent: source.energyCurrent,
        energyMax: source.energyMax,
        armor: source.armor,
        maneuverability: source.maneuverability,
        signature: source.signature,
        speed: source.speed,
        cargoCapacity: source.cargoCapacity,
        problems: source.problems,
        history: source.history,
        notes: source.notes,
        modules: {
          create: source.modules.map((m) => ({
            slot: m.slot,
            name: m.name,
            energyUse: m.energyUse,
            data: m.data ?? {},
          })),
        },
        crew: {
          create: [
            { position: 'captain', assignedCharacterId: null },
            { position: 'pilot', assignedCharacterId: null },
            { position: 'sensorOp', assignedCharacterId: null },
            { position: 'gunner', assignedCharacterId: null },
            { position: 'engineer', assignedCharacterId: null },
            { position: 'serviceCrew', assignedCharacterId: null },
          ],
        },
      },
      select: SHIP_SELECT,
    });

    return toShipReadModel(row);
  }

  async listNamesByPrefix(ownerId: string, prefix: string): Promise<string[]> {
    const rows = await this.prisma.ship.findMany({
      where: { ownerId, name: { startsWith: prefix } },
      select: { name: true },
    });
    return rows.map((r) => r.name);
  }
}

/**
 * WHY this file exists:
 * Maps Prisma row shapes to ShipReadModel. Prisma's @map directives mean the
 * enum values that come back from the client are already in the wire format
 * (kebab-case for ShipClass, SCREAMING-KEBAB for ShipModuleSlot).
 * This mapper is the single source of truth for that translation.
 */

import type { ShipClass, CrewPosition, ShipReadModel } from '../domain/ship.ports';

/** Prisma row returned by SHIP_SELECT */
export interface PrismaShipRow {
  id: string;
  ownerId: string;
  name: string;
  class: string;
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
  cargoCapacity: number;
  problems: string[];
  history: string | null;
  notes: string | null;
  modules: PrismaShipModuleRow[];
  crew: PrismaCrewSlotRow[];
  createdAt: Date;
  updatedAt: Date;
}

export interface PrismaShipModuleRow {
  id: string;
  slot: string;
  name: string;
  energyUse: number;
  data: unknown;
}

export interface PrismaCrewSlotRow {
  position: string;
  assignedCharacterId: string | null;
}

export function toShipReadModel(row: PrismaShipRow): ShipReadModel {
  return {
    id: row.id,
    ownerId: row.ownerId,
    name: row.name,
    class: row.class as ShipClass,
    model: row.model,
    registry: row.registry,
    hull: { current: row.hullCurrent, max: row.hullMax },
    energy: { current: row.energyCurrent, max: row.energyMax },
    armor: row.armor,
    maneuverability: row.maneuverability,
    signature: row.signature,
    speed: row.speed,
    cargoCapacity: row.cargoCapacity,
    modules: row.modules.map((m) => ({
      id: m.id,
      slot: m.slot,
      name: m.name,
      energyUse: m.energyUse,
      data: (m.data ?? {}) as Record<string, unknown>,
    })),
    crew: row.crew.map((c) => ({
      position: c.position as CrewPosition,
      assignedCharacterId: c.assignedCharacterId,
    })),
    problems: row.problems,
    history: row.history,
    notes: row.notes,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

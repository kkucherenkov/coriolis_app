/**
 * WHY this file exists:
 * Maps Prisma row shapes to ShipReadModel. Prisma's `@map` directives push the
 * **database value** (kebab-case for `ShipClass`, SCREAMING-KEBAB for
 * `ShipModuleSlot`) onto the wire, but the **Prisma TypeScript client** reads
 * those columns back as the original TS identifier (underscore-form:
 * `courier_yacht`, `ESCAPE_PODS`). Without this mapper's reverse translation
 * the OpenAPI response validator rejects the payload with
 * `enum.openapi.validation` on `/response/class`. This is the single source
 * of truth for Prisma-identifier → wire-format translation on reads.
 */

import type { ShipClass, CrewPosition, ShipReadModel } from '../domain/ship.ports';

/**
 * Prisma TS identifier (`courier_yacht`, `ESCAPE_PODS`) → OpenAPI wire format
 * (`courier-yacht`, `ESCAPE-PODS`).
 *
 * Exported so handler/repo specs can exercise the round-trip explicitly. The
 * write-side equivalents live in `ship.repo.ts` (`toDbShipClass`, `toDbSlot`).
 */
export function fromDbShipClass(c: string): ShipClass {
  return c.replaceAll('_', '-') as ShipClass;
}

export function fromDbSlot(s: string): string {
  return s.replaceAll('_', '-');
}

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
    class: fromDbShipClass(row.class),
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
      slot: fromDbSlot(m.slot),
      name: m.name,
      energyUse: m.energyUse,
      data: (m.data ?? {}) as Record<string, unknown>,
    })),
    crew: row.crew.map((c) => ({
      // `CrewPosition` enum values are already identical between the Prisma
      // TS identifier and the OpenAPI wire format — no `@map` per value.
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

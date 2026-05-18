/**
 * Regression coverage for T-2026-05-18-004.
 *
 * Prisma's `@map` on per-value enums (e.g. `courier_yacht @map("courier-yacht")`)
 * means the **database column** holds the wire value, but the Prisma TS client
 * returns the **TS identifier** (underscore form). Without the mapper's reverse
 * translation `POST /api/v1/ships` fails response validation with
 * `enum.openapi.validation` on `/response/class`.
 */
import { describe, expect, it } from 'vitest';

import { fromDbShipClass, fromDbSlot, toShipReadModel } from './ship.mapper';
import type { PrismaShipRow } from './ship.mapper';

describe('fromDbShipClass', () => {
  // Each pair: [Prisma TS identifier read back from the column, OpenAPI wire value]
  const CASES: [string, string][] = [
    ['fighter', 'fighter'],
    ['shuttle', 'shuttle'],
    ['torpedo_boat', 'torpedo-boat'],
    ['light_freighter', 'light-freighter'],
    ['light_passenger', 'light-passenger'],
    ['courier_yacht', 'courier-yacht'],
    ['clipper', 'clipper'],
    ['patrol_boat', 'patrol-boat'],
    ['gunboat', 'gunboat'],
    ['assault_ship', 'assault-ship'],
    ['blockade_runner', 'blockade-runner'],
    ['pleasure_yacht', 'pleasure-yacht'],
    ['flying_circus', 'flying-circus'],
    ['prospector', 'prospector'],
    ['rescue_ship', 'rescue-ship'],
    ['passenger_liner', 'passenger-liner'],
    ['heavy_freighter', 'heavy-freighter'],
    ['cruiser', 'cruiser'],
    ['destroyer', 'destroyer'],
    ['heavy_cruiser', 'heavy-cruiser'],
  ];

  it.each(CASES)('converts %s → %s', (db, wire) => {
    expect(fromDbShipClass(db)).toBe(wire);
  });
});

describe('fromDbSlot', () => {
  it.each([
    ['BRIDGE', 'BRIDGE'],
    ['ESCAPE_PODS', 'ESCAPE-PODS'],
    ['CONCEALED_HOLD', 'CONCEALED-HOLD'],
    ['PROXY_DECK', 'PROXY-DECK'],
    ['QUARTERS', 'QUARTERS'],
  ])('converts %s → %s', (db, wire) => {
    expect(fromDbSlot(db)).toBe(wire);
  });
});

describe('toShipReadModel', () => {
  const NOW = new Date('2026-05-18T12:00:00.000Z');

  function row(overrides: Partial<PrismaShipRow> = {}): PrismaShipRow {
    return {
      id: 'cuid_ship01',
      ownerId: 'cuid_user01',
      name: 'Madara',
      // Prisma client returns the TS identifier (underscore) — the wire is kebab.
      class: 'courier_yacht',
      model: null,
      registry: null,
      hullCurrent: 6,
      hullMax: 6,
      energyCurrent: 5,
      energyMax: 5,
      armor: 5,
      maneuverability: 0,
      signature: 0,
      speed: 2,
      cargoCapacity: 50,
      problems: [],
      history: null,
      notes: null,
      modules: [],
      crew: [],
      createdAt: NOW,
      updatedAt: NOW,
      ...overrides,
    };
  }

  it('translates underscore ShipClass back to the kebab wire format', () => {
    expect(toShipReadModel(row()).class).toBe('courier-yacht');
  });

  it('translates underscore ShipModuleSlot back to the kebab wire format', () => {
    const mapped = toShipReadModel(
      row({
        modules: [
          {
            id: 'mod1',
            slot: 'ESCAPE_PODS',
            name: 'Escape pods',
            energyUse: 0,
            data: {},
          },
          {
            id: 'mod2',
            slot: 'CONCEALED_HOLD',
            name: 'Concealed hold',
            energyUse: 0,
            data: {},
          },
          {
            id: 'mod3',
            slot: 'BRIDGE',
            name: 'Bridge',
            energyUse: 1,
            data: {},
          },
        ],
      }),
    );
    expect(mapped.modules.map((m) => m.slot)).toEqual(['ESCAPE-PODS', 'CONCEALED-HOLD', 'BRIDGE']);
  });

  it('leaves CrewPosition values untouched (no per-value @map in Prisma)', () => {
    const mapped = toShipReadModel(
      row({
        crew: [
          { position: 'captain', assignedCharacterId: 'cuid_char01' },
          { position: 'sensorOp', assignedCharacterId: null },
          { position: 'serviceCrew', assignedCharacterId: null },
        ],
      }),
    );
    expect(mapped.crew.map((c) => c.position)).toEqual(['captain', 'sensorOp', 'serviceCrew']);
  });
});

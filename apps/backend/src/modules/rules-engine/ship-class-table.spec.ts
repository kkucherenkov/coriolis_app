/**
 * Unit tests for ship-class-table.ts.
 *
 * Verifies that BASE_STATS_BY_TIER matches ТАБЛИЦА 7.5 from ST3001 ГЛАВА 7
 * verbatim, and that all 19 ship-type slugs map to the correct tier.
 *
 * Source canon:
 *   /Users/kkucherenkov/Documents/vaults/obsidian/70.01 Areas/TRPG/Coriolis/ST3001/
 *   ГЛАВА 7 Космические корабли и космос.md  line 145
 */
import { describe, expect, it } from 'vitest';

import {
  BASE_STATS_BY_CLASS,
  BASE_STATS_BY_TIER,
  TIER_BY_SHIP_TYPE,
  getBaseStatsByShipType,
  getTierForShipType,
} from './ship-class-table';

import type { ShipBaseStats, ShipTier } from './ship-class-table';
import type { ShipClass } from '../ships/domain/ship.ports';

// --------------- ТАБЛИЦА 7.5 verbatim ---------------

describe('BASE_STATS_BY_TIER', () => {
  it('is frozen', () => {
    expect(Object.isFrozen(BASE_STATS_BY_TIER)).toBe(true);
  });

  it('has exactly five tiers (I..V)', () => {
    expect(Object.keys(BASE_STATS_BY_TIER).toSorted()).toEqual(['I', 'II', 'III', 'IV', 'V']);
  });

  // Table-driven: [tier, energyMax, hullMax, maneuverability, signature, armor, speed, moduleSlots]
  const TABLE_75: [ShipTier, ShipBaseStats][] = [
    [
      'I',
      {
        energyMax: 3,
        hullMax: 2,
        maneuverability: 2,
        signature: -2,
        armor: 3,
        speed: 4,
        moduleSlots: 3,
      },
    ],
    [
      'II',
      {
        energyMax: 4,
        hullMax: 4,
        maneuverability: 1,
        signature: -1,
        armor: 4,
        speed: 4,
        moduleSlots: 6,
      },
    ],
    [
      'III',
      {
        energyMax: 5,
        hullMax: 6,
        maneuverability: 0,
        signature: 0,
        armor: 5,
        speed: 2,
        moduleSlots: 10,
      },
    ],
    [
      'IV',
      {
        energyMax: 6,
        hullMax: 9,
        maneuverability: -1,
        signature: 2,
        armor: 7,
        speed: 1,
        moduleSlots: 20,
      },
    ],
    [
      'V',
      {
        energyMax: 7,
        hullMax: 12,
        maneuverability: -2,
        signature: 3,
        armor: 9,
        speed: 1,
        moduleSlots: 40,
      },
    ],
  ];

  it.each(TABLE_75)('tier %s matches ТАБЛИЦА 7.5 verbatim', (tier, expected) => {
    expect(BASE_STATS_BY_TIER[tier]).toEqual(expected);
  });

  it('no cargoCapacity field — it is not in ТАБЛИЦА 7.5', () => {
    for (const stats of Object.values(BASE_STATS_BY_TIER)) {
      expect('cargoCapacity' in stats).toBe(false);
    }
  });
});

// --------------- TIER_BY_SHIP_TYPE coverage ---------------

describe('TIER_BY_SHIP_TYPE', () => {
  it('is frozen', () => {
    expect(Object.isFrozen(TIER_BY_SHIP_TYPE)).toBe(true);
  });

  it('covers exactly 20 ship-type slugs', () => {
    expect(Object.keys(TIER_BY_SHIP_TYPE)).toHaveLength(20);
  });

  // [shipType, expectedTier] — covers all 20 entries
  const MAPPING: [ShipClass, ShipTier][] = [
    // Class I
    ['fighter', 'I'],
    ['shuttle', 'I'],
    // Class II
    ['torpedo-boat', 'II'],
    // Class III
    ['light-freighter', 'III'],
    ['light-passenger', 'III'],
    ['courier-yacht', 'III'],
    ['clipper', 'III'],
    ['patrol-boat', 'III'],
    ['gunboat', 'III'],
    ['assault-ship', 'III'],
    ['blockade-runner', 'III'],
    ['pleasure-yacht', 'III'],
    // Class IV
    ['flying-circus', 'IV'],
    ['prospector', 'IV'],
    ['rescue-ship', 'IV'],
    ['passenger-liner', 'IV'],
    // Class V
    ['heavy-freighter', 'V'],
    ['cruiser', 'V'],
    ['destroyer', 'V'],
    ['heavy-cruiser', 'V'],
  ];

  it.each(MAPPING)('%s → tier %s', (shipType, expectedTier) => {
    expect(TIER_BY_SHIP_TYPE[shipType]).toBe(expectedTier);
  });
});

// --------------- getBaseStatsByShipType spot-checks ---------------

describe('getBaseStatsByShipType', () => {
  it('fighter → Class I (energyMax=3, hullMax=2, maneuverability=2, signature=-2)', () => {
    const stats = getBaseStatsByShipType('fighter');
    expect(stats.energyMax).toBe(3);
    expect(stats.hullMax).toBe(2);
    expect(stats.maneuverability).toBe(2);
    expect(stats.signature).toBe(-2);
    expect(stats.armor).toBe(3);
    expect(stats.speed).toBe(4);
    expect(stats.moduleSlots).toBe(3);
  });

  it('torpedo-boat → Class II (energyMax=4, hullMax=4, maneuverability=1, signature=-1)', () => {
    const stats = getBaseStatsByShipType('torpedo-boat');
    expect(stats.energyMax).toBe(4);
    expect(stats.hullMax).toBe(4);
    expect(stats.maneuverability).toBe(1);
    expect(stats.signature).toBe(-1);
    expect(stats.armor).toBe(4);
    expect(stats.speed).toBe(4);
    expect(stats.moduleSlots).toBe(6);
  });

  it('light-freighter → Class III (energyMax=5, hullMax=6, maneuverability=0)', () => {
    const stats = getBaseStatsByShipType('light-freighter');
    expect(stats.energyMax).toBe(5);
    expect(stats.hullMax).toBe(6);
    expect(stats.maneuverability).toBe(0);
    expect(stats.signature).toBe(0);
    expect(stats.armor).toBe(5);
    expect(stats.speed).toBe(2);
    expect(stats.moduleSlots).toBe(10);
  });

  it('passenger-liner → Class IV (energyMax=6, hullMax=9, maneuverability=-1, signature=2)', () => {
    const stats = getBaseStatsByShipType('passenger-liner');
    expect(stats.energyMax).toBe(6);
    expect(stats.hullMax).toBe(9);
    expect(stats.maneuverability).toBe(-1);
    expect(stats.signature).toBe(2);
    expect(stats.armor).toBe(7);
    expect(stats.speed).toBe(1);
    expect(stats.moduleSlots).toBe(20);
  });

  it('cruiser → Class V (energyMax=7, hullMax=12, maneuverability=-2, signature=3, armor=9)', () => {
    const stats = getBaseStatsByShipType('cruiser');
    expect(stats.energyMax).toBe(7);
    expect(stats.hullMax).toBe(12);
    expect(stats.maneuverability).toBe(-2);
    expect(stats.signature).toBe(3);
    expect(stats.armor).toBe(9);
    expect(stats.speed).toBe(1);
    expect(stats.moduleSlots).toBe(40);
  });
});

// --------------- getTierForShipType ---------------

describe('getTierForShipType', () => {
  it('returns the correct tier for every ship type (table-driven loop)', () => {
    for (const [shipType, expectedTier] of Object.entries(TIER_BY_SHIP_TYPE) as [
      ShipClass,
      ShipTier,
    ][]) {
      expect(getTierForShipType(shipType)).toBe(expectedTier);
    }
  });
});

// --------------- BASE_STATS_BY_CLASS backwards-compat alias ---------------

describe('BASE_STATS_BY_CLASS (backwards-compat)', () => {
  it('is frozen', () => {
    expect(Object.isFrozen(BASE_STATS_BY_CLASS)).toBe(true);
  });

  it('has 20 entries — one per ship-type slug', () => {
    expect(Object.keys(BASE_STATS_BY_CLASS)).toHaveLength(20);
  });

  it('every entry is the same reference as BASE_STATS_BY_TIER for its tier', () => {
    for (const [shipType, stats] of Object.entries(BASE_STATS_BY_CLASS) as [
      ShipClass,
      ShipBaseStats,
    ][]) {
      const tier = TIER_BY_SHIP_TYPE[shipType];
      expect(stats).toEqual(BASE_STATS_BY_TIER[tier]);
    }
  });

  // Spot-check a few canonical values through the alias
  it('cruiser carries Class V canon values', () => {
    expect(BASE_STATS_BY_CLASS['cruiser'].hullMax).toBe(12);
    expect(BASE_STATS_BY_CLASS['cruiser'].energyMax).toBe(7);
    expect(BASE_STATS_BY_CLASS['cruiser'].armor).toBe(9);
    expect(BASE_STATS_BY_CLASS['cruiser'].signature).toBe(3);
  });

  it('fighter carries Class I canon values', () => {
    expect(BASE_STATS_BY_CLASS['fighter'].hullMax).toBe(2);
    expect(BASE_STATS_BY_CLASS['fighter'].energyMax).toBe(3);
    expect(BASE_STATS_BY_CLASS['fighter'].maneuverability).toBe(2);
    expect(BASE_STATS_BY_CLASS['fighter'].signature).toBe(-2);
  });

  it('all 19 ship types map to correct per-tier stat block (loop)', () => {
    for (const shipType of Object.keys(TIER_BY_SHIP_TYPE) as ShipClass[]) {
      const tier = TIER_BY_SHIP_TYPE[shipType];
      expect(BASE_STATS_BY_CLASS[shipType]).toEqual(BASE_STATS_BY_TIER[tier]);
    }
  });

  it('no cargoCapacity field on any entry', () => {
    for (const stats of Object.values(BASE_STATS_BY_CLASS)) {
      expect('cargoCapacity' in stats).toBe(false);
    }
  });
});

/**
 * WHY this file exists:
 * Base stat blocks per ship CLASS TIER (I..V) from ST3001 ГЛАВА 7
 * ТАБЛИЦА 7.5 (Базовые характеристики космических кораблей).
 *
 * The table is keyed by tier (I..V), not by individual ship type.
 * All 19 ship-type slugs map to a tier via TIER_BY_SHIP_TYPE.
 *
 * Yard modifiers (Хелеб +1 манёвренность, Хальгрия −1 манёвренность)
 * and upgrade modifiers (Прочный корпус +1 hull, Мощный реактор +1 energy)
 * layer on top of these canonical values — the spec keeps those fields
 * editable on write for exactly that reason.
 *
 * cargoCapacity is NOT in ТАБЛИЦА 7.5: it is a sum of installed hold modules
 * (ТАБЛИЦА 7.6 § Грузовой отсек) and must not be derived from the class tier.
 * The field stays on ShipReadModel (spec compliance) but the base-stat block
 * no longer carries it.
 */

import type { ShipClass } from '../ships/domain/ship.ports';

/** Canonical ship class tier (I, II, III, IV, V) per ST3001 ГЛАВА 7. */
export type ShipTier = 'I' | 'II' | 'III' | 'IV' | 'V';

export interface ShipBaseStats {
  /** Энергия — base reactor energy max */
  energyMax: number;
  /** Прочность — base hull points max */
  hullMax: number;
  /** Манёвренность — signed maneuverability modifier */
  maneuverability: number;
  /** Заметность — signed signature modifier */
  signature: number;
  /** Броня — armor dice */
  armor: number;
  /** Скорость — interplanetary speed in AU/day */
  speed: number;
  /** Module slots — modular bay count */
  moduleSlots: number;
}

/**
 * Base stat block per ship CLASS (I..V), verbatim from ST3001 ГЛАВА 7
 * ТАБЛИЦА 7.5. Yard modifiers (Хелеб +1 maneuverability, Хальгрия −1
 * maneuverability, etc) and upgrade modifiers (Прочный корпус +1 hull,
 * Мощный реактор +1 energy) layer on top of these values — see
 * `ship.ports.ts` for the editable-on-write read-model fields.
 */
export const BASE_STATS_BY_TIER: Readonly<Record<ShipTier, ShipBaseStats>> = Object.freeze({
  I:   { energyMax: 3,  hullMax: 2,  maneuverability:  2, signature: -2, armor: 3, speed: 4, moduleSlots:  3 },
  II:  { energyMax: 4,  hullMax: 4,  maneuverability:  1, signature: -1, armor: 4, speed: 4, moduleSlots:  6 },
  III: { energyMax: 5,  hullMax: 6,  maneuverability:  0, signature:  0, armor: 5, speed: 2, moduleSlots: 10 },
  IV:  { energyMax: 6,  hullMax: 9,  maneuverability: -1, signature:  2, armor: 7, speed: 1, moduleSlots: 20 },
  V:   { energyMax: 7,  hullMax: 12, maneuverability: -2, signature:  3, armor: 9, speed: 1, moduleSlots: 40 },
});

/**
 * Maps each ship-type slug from the OpenAPI ShipClass enum to its
 * canonical ГЛАВА 7 tier (I..V). Source: ShipClass.description in
 * packages/specs/openapi/openapi.yaml.
 */
export const TIER_BY_SHIP_TYPE: Readonly<Record<ShipClass, ShipTier>> = Object.freeze({
  // Class I
  fighter: 'I',
  shuttle: 'I',
  // Class II
  'torpedo-boat': 'II',
  // Class III
  'light-freighter': 'III',
  'light-passenger': 'III',
  'courier-yacht': 'III',
  clipper: 'III',
  'patrol-boat': 'III',
  gunboat: 'III',
  'assault-ship': 'III',
  'blockade-runner': 'III',
  'pleasure-yacht': 'III',
  // Class IV
  'flying-circus': 'IV',
  prospector: 'IV',
  'rescue-ship': 'IV',
  'passenger-liner': 'IV',
  // Class V
  'heavy-freighter': 'V',
  cruiser: 'V',
  destroyer: 'V',
  'heavy-cruiser': 'V',
});

export function getTierForShipType(shipType: ShipClass): ShipTier {
  return TIER_BY_SHIP_TYPE[shipType];
}

export function getBaseStatsByShipType(shipType: ShipClass): ShipBaseStats {
  return BASE_STATS_BY_TIER[TIER_BY_SHIP_TYPE[shipType]];
}

/**
 * Backwards-compat alias — existing call sites that reference
 * BASE_STATS_BY_CLASS[shipType] continue to work transparently.
 * The per-type lookup routes through the tier table, so all 19 ship
 * types now carry canonical ТАБЛИЦА 7.5 values.
 */
export const BASE_STATS_BY_CLASS: Readonly<Record<ShipClass, ShipBaseStats>> = Object.freeze(
  Object.fromEntries(
    (Object.keys(TIER_BY_SHIP_TYPE) as ShipClass[]).map((shipType) => [
      shipType,
      BASE_STATS_BY_TIER[TIER_BY_SHIP_TYPE[shipType]],
    ]),
  ) as Record<ShipClass, ShipBaseStats>,
);

/**
 * WHY this file exists:
 * Base stat blocks for every ship class in ST3001 ГЛАВА 7 Table 7.5.
 * The create-ship command seeds these values when the caller does not
 * provide explicit overrides. Exported from the rules-engine barrel so
 * the web class-picker can consume the same data.
 *
 * TODO(ship-stats): verify exact values against ST3001 ГЛАВА 7 Table 7.5.
 * Values below are scaled plausibly (Class I < II < ... < V) with the
 * maneuverability/signature signed per rulebook examples.
 */

import type { ShipClass } from '../ships/domain/ship.ports';

export interface ShipBaseStats {
  /** Maximum hull points (Прочность) */
  hullMax: number;
  /** Maximum energy points (Энергия) */
  energyMax: number;
  /** Armor dice (Броня) */
  armor: number;
  /** Maneuverability modifier — negative for large classes */
  maneuverability: number;
  /** Signature modifier — negative means harder to detect */
  signature: number;
  /** Speed in AU/day */
  speed: number;
  /** Cargo capacity in tonnes */
  cargoCapacity: number;
}

// TODO(ship-stats): verify against ST3001 ГЛАВА 7 Table 7.5
export const BASE_STATS_BY_CLASS: Record<ShipClass, ShipBaseStats> = {
  // --- Class I ---
  fighter: {
    hullMax: 4,
    energyMax: 3,
    armor: 3,
    maneuverability: 2,
    signature: -1,
    speed: 4,
    cargoCapacity: 2,
  },
  shuttle: {
    hullMax: 4,
    energyMax: 3,
    armor: 2,
    maneuverability: 1,
    signature: 0,
    speed: 3,
    cargoCapacity: 5,
  },

  // --- Class II ---
  'torpedo-boat': {
    hullMax: 5,
    energyMax: 4,
    armor: 3,
    maneuverability: 1,
    signature: -1,
    speed: 3,
    cargoCapacity: 5,
  },

  // --- Class III ---
  'light-freighter': {
    hullMax: 6,
    energyMax: 5,
    armor: 5,
    maneuverability: 0,
    signature: 0,
    speed: 2,
    cargoCapacity: 50,
  },
  'light-passenger': {
    hullMax: 6,
    energyMax: 5,
    armor: 4,
    maneuverability: 0,
    signature: 0,
    speed: 3,
    cargoCapacity: 20,
  },
  'courier-yacht': {
    hullMax: 6,
    energyMax: 5,
    armor: 5,
    maneuverability: 0,
    signature: 0,
    speed: 2,
    cargoCapacity: 50,
  },
  clipper: {
    hullMax: 6,
    energyMax: 5,
    armor: 4,
    maneuverability: 0,
    signature: 1,
    speed: 2,
    cargoCapacity: 40,
  },
  'patrol-boat': {
    hullMax: 6,
    energyMax: 5,
    armor: 5,
    maneuverability: 1,
    signature: 0,
    speed: 3,
    cargoCapacity: 10,
  },
  gunboat: {
    hullMax: 7,
    energyMax: 6,
    armor: 6,
    maneuverability: 0,
    signature: 0,
    speed: 2,
    cargoCapacity: 10,
  },
  'assault-ship': {
    hullMax: 7,
    energyMax: 6,
    armor: 7,
    maneuverability: 0,
    signature: 0,
    speed: 2,
    cargoCapacity: 15,
  },
  'blockade-runner': {
    hullMax: 6,
    energyMax: 5,
    armor: 4,
    maneuverability: 1,
    signature: -1,
    speed: 3,
    cargoCapacity: 30,
  },
  'pleasure-yacht': {
    hullMax: 6,
    energyMax: 5,
    armor: 3,
    maneuverability: 0,
    signature: 1,
    speed: 2,
    cargoCapacity: 15,
  },

  // --- Class IV ---
  'flying-circus': {
    hullMax: 8,
    energyMax: 7,
    armor: 5,
    maneuverability: -1,
    signature: 1,
    speed: 1,
    cargoCapacity: 80,
  },
  prospector: {
    hullMax: 8,
    energyMax: 7,
    armor: 5,
    maneuverability: -1,
    signature: 0,
    speed: 1,
    cargoCapacity: 100,
  },
  'rescue-ship': {
    hullMax: 8,
    energyMax: 7,
    armor: 4,
    maneuverability: -1,
    signature: 1,
    speed: 2,
    cargoCapacity: 60,
  },
  'passenger-liner': {
    hullMax: 9,
    energyMax: 8,
    armor: 4,
    maneuverability: -1,
    signature: 2,
    speed: 1,
    cargoCapacity: 80,
  },

  // --- Class V ---
  'heavy-freighter': {
    hullMax: 10,
    energyMax: 9,
    armor: 6,
    maneuverability: -2,
    signature: 2,
    speed: 1,
    cargoCapacity: 200,
  },
  cruiser: {
    hullMax: 12,
    energyMax: 10,
    armor: 8,
    maneuverability: -2,
    signature: 1,
    speed: 1,
    cargoCapacity: 30,
  },
  destroyer: {
    hullMax: 11,
    energyMax: 10,
    armor: 8,
    maneuverability: -1,
    signature: 0,
    speed: 2,
    cargoCapacity: 20,
  },
  'heavy-cruiser': {
    hullMax: 14,
    energyMax: 12,
    armor: 10,
    maneuverability: -2,
    signature: 2,
    speed: 1,
    cargoCapacity: 40,
  },
};

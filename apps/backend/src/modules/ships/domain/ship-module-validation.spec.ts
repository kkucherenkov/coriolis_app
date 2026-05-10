/**
 * Unit tests for ship-module-validation helpers.
 * Pure functions — no NestJS bootstrapping needed.
 */
import { describe, expect, it } from 'vitest';

import { ShipModuleSlotInvalidError, ShipModuleTypeMismatchError } from './ship.errors';
import { validateModuleCreate, validateModuleUpdate } from './ship-module-validation';

// ---------------------------------------------------------------------------
// validateModuleCreate — happy paths
// ---------------------------------------------------------------------------
describe('validateModuleCreate', () => {
  it('accepts a WEAPON payload and populates data fields', () => {
    const result = validateModuleCreate({
      slot: 'WEAPON',
      name: 'Graviton Projector',
      energyUse: 2,
      weaponBonus: 1,
      weaponRange: 'medium',
      weaponDamage: 2,
      weaponCritThreshold: 3,
    });
    expect(result.slot).toBe('WEAPON');
    expect(result.data).toMatchObject({
      weaponBonus: 1,
      weaponRange: 'medium',
      weaponDamage: 2,
      weaponCritThreshold: 3,
    });
  });

  it('accepts a TORPEDO payload', () => {
    const result = validateModuleCreate({
      slot: 'TORPEDO',
      name: 'Torpedo Bay',
      energyUse: 1,
      torpedoCount: 4,
      mineCount: 0,
    });
    expect(result.slot).toBe('TORPEDO');
    expect(result.data).toMatchObject({ torpedoCount: 4, mineCount: 0 });
  });

  it('accepts a HOLD payload', () => {
    const result = validateModuleCreate({
      slot: 'HOLD',
      name: 'Main Hold',
      energyUse: 0,
      cargoTons: 50,
      concealed: false,
    });
    expect(result.slot).toBe('HOLD');
    expect(result.data).toMatchObject({ cargoTons: 50, concealed: false });
  });

  it('accepts a SENSOR payload', () => {
    const result = validateModuleCreate({
      slot: 'SENSOR',
      name: 'Long-Range Sensor Tower',
      energyUse: 1,
      detectionBonus: 1,
    });
    expect(result.slot).toBe('SENSOR');
    expect(result.data).toMatchObject({ detectionBonus: 1 });
  });

  it('accepts an OTHER (COMMS) payload with no extra data fields', () => {
    const result = validateModuleCreate({
      slot: 'COMMS',
      name: 'Long-Range Comms Array',
      energyUse: 1,
    });
    expect(result.slot).toBe('COMMS');
    expect(Object.keys(result.data)).toHaveLength(0);
  });

  // ---------------------------------------------------------------------------
  // validateModuleCreate — error cases
  // ---------------------------------------------------------------------------

  it('throws ShipModuleSlotInvalidError for an unknown slot', () => {
    expect(() =>
      validateModuleCreate({ slot: 'UNKNOWN', name: 'X', energyUse: 0 }),
    ).toThrow(ShipModuleSlotInvalidError);
  });

  it('throws ShipModuleTypeMismatchError when weaponBonus is provided for slot HOLD', () => {
    expect(() =>
      validateModuleCreate({ slot: 'HOLD', name: 'X', energyUse: 0, weaponBonus: 2 }),
    ).toThrow(ShipModuleTypeMismatchError);
  });

  it('throws ShipModuleTypeMismatchError when WEAPON is missing required fields', () => {
    expect(() =>
      validateModuleCreate({ slot: 'WEAPON', name: 'X', energyUse: 0 }),
    ).toThrow(ShipModuleTypeMismatchError);
  });
});

// ---------------------------------------------------------------------------
// validateModuleUpdate — happy path + mismatch
// ---------------------------------------------------------------------------
describe('validateModuleUpdate', () => {
  it('accepts partial HOLD update', () => {
    const result = validateModuleUpdate({ slot: 'HOLD', cargoTons: 60 }, 'HOLD');
    expect(result.data).toMatchObject({ cargoTons: 60 });
  });

  it('throws ShipModuleTypeMismatchError when slot discriminator changes', () => {
    expect(() =>
      validateModuleUpdate({ slot: 'WEAPON' }, 'HOLD'),
    ).toThrow(ShipModuleTypeMismatchError);
  });

  it('throws ShipModuleTypeMismatchError when foreign field is included', () => {
    expect(() =>
      validateModuleUpdate({ slot: 'HOLD', weaponBonus: 1 }, 'HOLD'),
    ).toThrow(ShipModuleTypeMismatchError);
  });
});

/**
 * WHY this file exists:
 * Pure discriminator-aware validation for ShipModuleCreate / ShipModuleUpdate payloads.
 * Keeping it in the domain layer makes it injectable-free and trivially unit-testable.
 * The controller dispatches after class-validator runs; this layer checks slot-specific
 * field presence / absence so we can produce typed DomainErrors instead of generic 400s.
 */

import { ShipModuleSlotInvalidError, ShipModuleTypeMismatchError } from './ship.errors';
import type { ShipModuleSlot, ShipWeaponRange } from './ship.ports';

export const VALID_SLOTS = new Set<ShipModuleSlot>([
  'BRIDGE',
  'REACTOR',
  'DRIVE',
  'HOLD',
  'WEAPON',
  'TORPEDO',
  'SENSOR',
  'COMMS',
  'HANGAR',
  'QUARTERS',
  'MEDICAL',
  'WORKSHOP',
  'CHAPEL',
  'ESCAPE-PODS',
  'CRYO',
  'DOCKING',
  'MINING',
  'REPAIR',
  'CONCEALED-HOLD',
  'PROXY-DECK',
  'OTHER',
]);

const WEAPON_RANGES = new Set<ShipWeaponRange>(['zero', 'close', 'medium', 'long', 'extreme']);

export function assertValidSlot(slot: unknown): asserts slot is ShipModuleSlot {
  if (typeof slot !== 'string' || !VALID_SLOTS.has(slot as ShipModuleSlot)) {
    throw new ShipModuleSlotInvalidError(String(slot));
  }
}

/** Weapon-specific required fields */
const WEAPON_FIELDS = [
  'weaponBonus',
  'weaponRange',
  'weaponDamage',
  'weaponCritThreshold',
] as const;
/** Slot-specific field sets (for type-mismatch guard). Only typed slots are listed. */
const TYPED_FIELD_SETS: Record<string, ReadonlySet<string>> = {
  WEAPON: new Set(WEAPON_FIELDS),
  TORPEDO: new Set(['torpedoCount', 'mineCount']),
  HOLD: new Set(['cargoTons', 'concealed']),
  SENSOR: new Set(['detectionBonus']),
};

/**
 * Returns true if the given key is a slot-specific field that belongs to a
 * *different* slot family than `slot`.
 */
function isForeignField(key: string, slot: ShipModuleSlot): boolean {
  for (const [family, fields] of Object.entries(TYPED_FIELD_SETS)) {
    if (family !== slot && fields.has(key)) return true;
  }
  return false;
}

/** Validated create payload returned after passing validation */
export interface ValidatedModuleCreate {
  slot: ShipModuleSlot;
  name: string;
  energyUse: number;
  notes: string | null;
  data: Record<string, unknown>;
}

/** Validated update payload returned after passing validation */
export interface ValidatedModuleUpdate {
  name?: string;
  energyUse?: number;
  notes?: string | null;
  data: Record<string, unknown>;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any -- raw DTO from controller
type RawBody = Record<string, any>;

/**
 * Validates a ShipModuleCreate body.
 * Throws ShipModuleSlotInvalidError or ShipModuleTypeMismatchError on failure.
 * Returns a structured payload with common fields separated from slot-specific `data`.
 */
export function validateModuleCreate(body: RawBody): ValidatedModuleCreate {
  assertValidSlot(body['slot']);
  const slot = body['slot'];

  // Guard: detect foreign fields
  for (const key of Object.keys(body)) {
    if (isForeignField(key, slot)) {
      throw new ShipModuleTypeMismatchError(`${key} is not valid for slot ${slot}`);
    }
  }

  if (slot === 'WEAPON') {
    for (const field of WEAPON_FIELDS) {
      if (body[field] == null) {
        throw new ShipModuleTypeMismatchError(`${field} is required for slot WEAPON`);
      }
    }

    const range = String(body['weaponRange']);
    if (!WEAPON_RANGES.has(range as ShipWeaponRange)) {
      throw new ShipModuleTypeMismatchError(
        `weaponRange "${range}" is not a valid ShipWeaponRange`,
      );
    }
  }

  const data = buildData(slot, body);

  return {
    slot,
    name: String(body['name']),
    energyUse: Number(body['energyUse'] ?? 0),
    notes: body['notes'] == null ? null : String(body['notes']),
    data,
  };
}

/**
 * Validates a ShipModuleUpdate body against the installed module's slot.
 * Throws ShipModuleTypeMismatchError if the slot discriminator changed or
 * foreign fields are present.
 */
export function validateModuleUpdate(
  body: RawBody,
  installedSlot: ShipModuleSlot,
): ValidatedModuleUpdate {
  // slot field in the PATCH body must match the installed slot if present
  if (body['slot'] !== undefined && body['slot'] !== installedSlot) {
    throw new ShipModuleTypeMismatchError('Module slot cannot be changed after installation');
  }

  // Guard: detect foreign fields
  for (const key of Object.keys(body)) {
    if (key !== 'slot' && isForeignField(key, installedSlot)) {
      throw new ShipModuleTypeMismatchError(`${key} is not valid for slot ${installedSlot}`);
    }
  }

  if (installedSlot === 'WEAPON' && body['weaponRange'] !== undefined) {
    const range = String(body['weaponRange']);
    if (!WEAPON_RANGES.has(range as ShipWeaponRange)) {
      throw new ShipModuleTypeMismatchError(
        `weaponRange "${range}" is not a valid ShipWeaponRange`,
      );
    }
  }

  const dataOverride = buildData(installedSlot, body, true);

  const result: ValidatedModuleUpdate = { data: dataOverride };
  if (body['name'] !== undefined) result.name = String(body['name']);
  if (body['energyUse'] !== undefined) result.energyUse = Number(body['energyUse']);
  if ('notes' in body) result.notes = body['notes'] == null ? null : String(body['notes']);
  return result;
}

function buildData(slot: ShipModuleSlot, body: RawBody, partial = false): Record<string, unknown> {
  const d: Record<string, unknown> = {};

  switch (slot) {
    case 'WEAPON': {
      if (!partial || body['weaponBonus'] !== undefined)
        d['weaponBonus'] = Number(body['weaponBonus'] ?? 0);
      if (!partial || body['weaponRange'] !== undefined) d['weaponRange'] = body['weaponRange'];
      if (!partial || body['weaponDamage'] !== undefined)
        d['weaponDamage'] = Number(body['weaponDamage'] ?? 0);
      if (!partial || body['weaponCritThreshold'] !== undefined)
        d['weaponCritThreshold'] = Number(body['weaponCritThreshold'] ?? 3);
      break;
    }
    case 'TORPEDO': {
      if (!partial || body['torpedoCount'] !== undefined)
        d['torpedoCount'] = Number(body['torpedoCount'] ?? 0);
      if (!partial || body['mineCount'] !== undefined)
        d['mineCount'] = Number(body['mineCount'] ?? 0);
      break;
    }
    case 'HOLD': {
      if (!partial || body['cargoTons'] !== undefined)
        d['cargoTons'] = Number(body['cargoTons'] ?? 0);
      if (!partial || body['concealed'] !== undefined)
        d['concealed'] = Boolean(body['concealed'] ?? false);
      break;
    }
    case 'SENSOR': {
      if (!partial || body['detectionBonus'] !== undefined)
        d['detectionBonus'] = Number(body['detectionBonus'] ?? 1);
      break;
    }
    default: {
      // OTHER variants: no extra fields in data
      break;
    }
  }

  return d;
}

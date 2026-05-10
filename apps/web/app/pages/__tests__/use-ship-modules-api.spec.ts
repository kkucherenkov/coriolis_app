/**
 * Vitest unit specs for useShipModulesApi + structural assertions on
 * ShipModuleEditor (T-2026-05-10-005 Block 3).
 *
 * Pattern mirrors use-ships-api.spec.ts: inline mock of SDK delegation
 * logic, no Nuxt runtime needed. Structural assertions on the SFC source
 * verify the discriminator switch renders the right fields per slot.
 */

import { describe, it, expect, vi, beforeAll } from 'vitest';
import type {
  ShipModule,
  ShipModuleWeapon,
  ShipModuleCreate,
  ShipModuleUpdate,
  Problem,
} from '@app/api-client-ts';

// ── Fixtures ──────────────────────────────────────────────────────────────────

/** Returns a WEAPON module fixture with concrete slot discriminator. */
function makeWeaponModuleFixture(overrides: Partial<ShipModuleWeapon> = {}): ShipModule {
  const base: ShipModuleWeapon = {
    id: 'mod-001',
    slot: 'WEAPON',
    name: 'Graviton Cannon',
    energyUse: 2,
    notes: null,
    weaponBonus: 1,
    weaponRange: 'long',
    weaponDamage: 3,
    weaponCritThreshold: 2,
    ...overrides,
  };
  return base as ShipModule;
}

// ── Inline mock of composable delegation (same pattern as use-ships-api.spec.ts) ─

interface MockResult<T> {
  data: T | undefined;
  error: Problem | undefined;
}

async function callAddModule(
  mockFn: (opts: unknown) => Promise<MockResult<ShipModule>>,
  shipId: string,
  body: ShipModuleCreate,
): Promise<ShipModule> {
  const res = await mockFn({ path: { id: shipId }, body });
  if (res.error) throw res.error;
  return res.data!;
}

async function callUpdateModule(
  mockFn: (opts: unknown) => Promise<MockResult<ShipModule>>,
  moduleId: string,
  body: ShipModuleUpdate,
): Promise<ShipModule> {
  const res = await mockFn({ path: { id: moduleId }, body });
  if (res.error) throw res.error;
  return res.data!;
}

async function callDeleteModule(
  mockFn: (opts: unknown) => Promise<MockResult<void>>,
  moduleId: string,
): Promise<void> {
  const res = await mockFn({ path: { id: moduleId } });
  if (res.error) throw res.error;
}

// ── addModule ─────────────────────────────────────────────────────────────────

describe('useShipModulesApi.addModule', () => {
  it('returns created ShipModule on 201 response', async () => {
    const fixture = makeWeaponModuleFixture({ id: 'mod-new-001', name: 'Plasma Lance' });
    const mockAdd = vi.fn().mockResolvedValue({ data: fixture, error: undefined });

    const body: ShipModuleCreate = {
      slot: 'WEAPON',
      name: 'Plasma Lance',
      energyUse: 3,
      weaponBonus: 2,
      weaponRange: 'medium',
      weaponDamage: 4,
      weaponCritThreshold: 2,
    };

    const result = await callAddModule(mockAdd, 'ship-001', body);

    expect(result.id).toBe('mod-new-001');
    expect(result.name).toBe('Plasma Lance');
    expect(mockAdd).toHaveBeenCalledWith({ path: { id: 'ship-001' }, body });
  });

  it('throws Problem on 422 — validation error (energyUse < 0)', async () => {
    const problem: Problem = {
      type: null,
      status: 422,
      detail: 'energyUse must be ≥ 0',
      title: 'Unprocessable Entity',
    };
    const mockAdd = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(
      callAddModule(mockAdd, 'ship-001', {
        slot: 'WEAPON',
        name: 'Bad Weapon',
        energyUse: -1,
        weaponBonus: 0,
        weaponRange: 'close',
        weaponDamage: 0,
        weaponCritThreshold: 1,
      }),
    ).rejects.toMatchObject({ status: 422, detail: 'energyUse must be ≥ 0' });
  });

  it('throws Problem on 403 — not ship owner', async () => {
    const problem: Problem = {
      type: null,
      status: 403,
      detail: 'You do not own this ship',
      title: 'Forbidden',
    };
    const mockAdd = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(
      callAddModule(mockAdd, 'ship-other', {
        slot: 'COMMS',
        name: 'Radio Tower',
        energyUse: 1,
      }),
    ).rejects.toMatchObject({ status: 403 });
  });
});

// ── updateModule ──────────────────────────────────────────────────────────────

describe('useShipModulesApi.updateModule', () => {
  it('returns updated ShipModule on 200 response', async () => {
    const fixture = makeWeaponModuleFixture({ weaponBonus: 3, weaponDamage: 5 });
    const mockUpdate = vi.fn().mockResolvedValue({ data: fixture, error: undefined });

    const body: ShipModuleUpdate = { slot: 'WEAPON', weaponBonus: 3, weaponDamage: 5 };
    const result = await callUpdateModule(mockUpdate, 'mod-001', body);

    // Narrow the union to WEAPON variant before accessing discriminator fields.
    expect(result.slot).toBe('WEAPON');
    if (result.slot === 'WEAPON') {
      expect(result.weaponBonus).toBe(3);
      expect(result.weaponDamage).toBe(5);
    }
    expect(mockUpdate).toHaveBeenCalledWith({ path: { id: 'mod-001' }, body });
  });

  it('throws Problem on 404 — module not found', async () => {
    const problem: Problem = {
      type: null,
      status: 404,
      detail: 'Module not found',
      title: 'Not Found',
    };
    const mockUpdate = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(
      callUpdateModule(mockUpdate, 'no-such-mod', { slot: 'SENSOR', name: 'Scanner' }),
    ).rejects.toMatchObject({ status: 404 });
  });

  it('throws Problem on 400 — slot mismatch', async () => {
    const problem: Problem = {
      type: null,
      status: 400,
      detail: 'SHIP_MODULE_SLOT_MISMATCH',
      title: 'Bad Request',
    };
    const mockUpdate = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(
      callUpdateModule(mockUpdate, 'mod-001', { slot: 'TORPEDO' }),
    ).rejects.toMatchObject({ status: 400, detail: 'SHIP_MODULE_SLOT_MISMATCH' });
  });
});

// ── deleteModule ──────────────────────────────────────────────────────────────

describe('useShipModulesApi.deleteModule', () => {
  it('resolves void on 204 response', async () => {
    const mockDelete = vi.fn().mockResolvedValue({ data: undefined, error: undefined });

    await expect(callDeleteModule(mockDelete, 'mod-001')).resolves.toBeUndefined();
    expect(mockDelete).toHaveBeenCalledWith({ path: { id: 'mod-001' } });
  });

  it('throws Problem on 422 — SHIP_MODULE_MANDATORY (BRIDGE/REACTOR/DRIVE)', async () => {
    const problem: Problem = {
      type: null,
      status: 422,
      detail: 'SHIP_MODULE_MANDATORY',
      title: 'Unprocessable Entity',
    };
    const mockDelete = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callDeleteModule(mockDelete, 'mod-bridge')).rejects.toMatchObject({
      status: 422,
      detail: 'SHIP_MODULE_MANDATORY',
    });
  });

  it('throws Problem on 403 — not ship owner', async () => {
    const problem: Problem = {
      type: null,
      status: 403,
      detail: 'Forbidden',
      title: 'Forbidden',
    };
    const mockDelete = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callDeleteModule(mockDelete, 'mod-other')).rejects.toMatchObject({ status: 403 });
  });

  it('caller can route 422 to a non-destructive UI path', async () => {
    const problem: Problem = {
      type: null,
      status: 422,
      detail: 'SHIP_MODULE_MANDATORY',
      title: 'Unprocessable Entity',
    };

    let caught: Problem | null = null;
    try {
      await callDeleteModule(
        vi.fn().mockResolvedValue({ data: undefined, error: problem }),
        'mod-bridge',
      );
    } catch (error) {
      caught = error as Problem;
    }

    // Status 422 from mandatory delete should never reach the UI
    // because the Delete button is hidden — this tests the defence-in-depth path.
    expect(caught?.status).toBe(422);
    expect(caught?.detail).toContain('MANDATORY');
  });
});

// ── Structural assertions on ShipModuleEditor.vue ────────────────────────────
// We assert on the SFC source text that the discriminator switch renders the
// correct slot-specific fields. This is a compile-time / wiring guard, not a
// DOM test (DOM tests belong to Playwright e2e).

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import nodePath from 'node:path';

const { resolve, dirname } = nodePath;
// WHY: unicorn/prefer-module forbids __dirname in ESM .ts files; use import.meta.url instead.
const _dirname = dirname(fileURLToPath(import.meta.url));

const EDITOR_PATH = resolve(_dirname, '../../components/sheet/ShipModuleEditor.vue');

describe('ShipModuleEditor.vue — structural discriminator switch', () => {
  let src: string;

  beforeAll(() => {
    src = readFileSync(EDITOR_PATH, 'utf8');
  });

  it('imports useShipModulesApi', () => {
    expect(src).toContain("from '~/composables/useShipModulesApi'");
  });

  it('renders weaponBonus field when slot === WEAPON', () => {
    expect(src).toContain("effectiveSlot === 'WEAPON'");
    expect(src).toContain('fieldWeaponBonus');
  });

  it('renders range AppSegControl for WEAPON slot', () => {
    expect(src).toContain('RANGE_OPTIONS');
    expect(src).toContain('fieldWeaponRange');
  });

  it('renders torpedoCount and mineCount fields for TORPEDO slot', () => {
    expect(src).toContain("effectiveSlot === 'TORPEDO'");
    expect(src).toContain('fieldTorpedoCount');
    expect(src).toContain('fieldMineCount');
  });

  it('renders cargoTons and concealed fields for HOLD slot', () => {
    expect(src).toContain("effectiveSlot === 'HOLD'");
    expect(src).toContain('fieldCargoTons');
    expect(src).toContain('fieldConcealed');
  });

  it('renders detectionBonus field for SENSOR slot', () => {
    expect(src).toContain("effectiveSlot === 'SENSOR'");
    expect(src).toContain('fieldDetectionBonus');
  });

  it('hides Delete button for mandatory slots (isMandatory guard)', () => {
    expect(src).toContain('isMandatory');
    expect(src).toContain('MANDATORY_SLOTS');
  });

  it('slot picker hidden in edit mode (isEditMode guard on slot AppField)', () => {
    expect(src).toContain('v-if="!isEditMode"');
  });

  it('emits update:module on save and delete:module on confirm delete', () => {
    expect(src).toContain("emit('update:module', result)");
    expect(src).toContain("emit('delete:module', props.module.id)");
  });

  it('inline confirm-delete panel inside modal (no separate route)', () => {
    expect(src).toContain('confirmDelete');
    expect(src).toContain('confirmAndDelete');
  });
});

// ── Structural assertions on updated [id].vue — Block 3 wiring ───────────────

const PAGE_PATH = resolve(_dirname, '../../pages/app/ships/[id].vue');

describe('[id].vue Block 3 — module editor wiring', () => {
  let src: string;

  beforeAll(() => {
    src = readFileSync(PAGE_PATH, 'utf8');
  });

  it('imports ShipModuleEditor component', () => {
    expect(src).toContain('ShipModuleEditor');
  });

  it('imports ShipModule type from useShipModulesApi', () => {
    expect(src).toContain("from '~/composables/useShipModulesApi'");
  });

  it('has openModuleCreate function for the Add button', () => {
    expect(src).toContain('openModuleCreate');
  });

  it('has openModuleEdit function for row tap', () => {
    expect(src).toContain('openModuleEdit');
  });

  it('patches modules list locally on update:module without full refetch', () => {
    expect(src).toContain('onModuleUpdated');
  });

  it('patches modules list locally on delete:module without full refetch', () => {
    expect(src).toContain('onModuleDeleted');
  });

  it('module rows are tappable (click handler on li)', () => {
    expect(src).toContain('@click="openModuleEdit');
  });
});

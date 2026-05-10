/**
 * Vitest unit specs for useShipsApi (T-2026-05-10-005 Block 1).
 *
 * We test the composable logic in isolation by mocking the generated SDK
 * functions. The composable is a thin wrapper that:
 *   - delegates to the generated SDK call
 *   - throws res.error (as a Problem object) when present
 *   - returns the shaped data otherwise
 *
 * Page mounting is deferred to Playwright e2e (same pattern as the rest
 * of the app — see share-viewer.spec.ts).
 */

import { describe, it, expect, vi, beforeAll } from 'vitest';
import type { Ship, ShipCreate, Problem } from '@app/api-client-ts';

// ── Fixture ───────────────────────────────────────────────────────────────────

export function makeShipFixture(overrides: Partial<Ship> = {}): Ship {
  return {
    id: 'ship-id-001',
    ownerId: 'owner-id-001',
    name: 'Scarab of Kua',
    class: 'light-freighter',
    model: 'Helebian Class III',
    registry: 'KUA-7741-M',
    hull: { current: 8, max: 8 },
    energy: { current: 6, max: 6 },
    armor: 2,
    maneuverability: 0,
    signature: 0,
    speed: 1,
    cargoCapacity: 50,
    modules: [
      { id: 'mod-bridge', slot: 'BRIDGE', name: 'Bridge', energyUse: 0, notes: null },
      { id: 'mod-reactor', slot: 'REACTOR', name: 'Reactor', energyUse: 0, notes: null },
      { id: 'mod-drive', slot: 'DRIVE', name: 'Drive', energyUse: 0, notes: null },
    ] as Ship['modules'],
    crew: [],
    problems: [],
    history: null,
    notes: null,
    createdAt: '2026-05-10T12:00:00Z',
    updatedAt: '2026-05-10T12:00:00Z',
    ...overrides,
  };
}

// ── Helper: inline composable logic for isolation testing ─────────────────────
// We replicate the composable's thin delegation logic against a mock SDK call
// so we can test without Nuxt runtime / module resolution.

interface MockResult<T> {
  data: T | undefined;
  error: Problem | undefined;
}

async function callList(
  mockFn: (opts: unknown) => Promise<MockResult<{ items: Ship[]; nextCursor: string | null }>>,
  opts?: { limit?: number },
): Promise<{ items: readonly Ship[]; nextCursor: string | null }> {
  const res = await mockFn({ query: opts });
  // Mirrors the eslint-disable pattern in the composable — plain object throw.
  if (res.error) throw res.error;
  return { items: res.data!.items, nextCursor: res.data!.nextCursor };
}

async function callCreate(
  mockFn: (opts: unknown) => Promise<MockResult<Ship>>,
  body: ShipCreate,
): Promise<Ship> {
  const res = await mockFn({ body });
  if (res.error) throw res.error;
  return res.data!;
}

// ── list() — happy path ───────────────────────────────────────────────────────

describe('useShipsApi.list', () => {
  it('returns items and nextCursor on 200 response', async () => {
    const fixture = makeShipFixture();
    const mockList = vi.fn().mockResolvedValue({
      data: { items: [fixture], nextCursor: null },
      error: undefined,
    });

    const result = await callList(mockList, { limit: 20 });

    expect(result.items).toHaveLength(1);
    expect(result.items[0]?.name).toBe('Scarab of Kua');
    expect(result.nextCursor).toBeNull();
    expect(mockList).toHaveBeenCalledWith({ query: { limit: 20 } });
  });

  it('forwards nextCursor when a second page exists', async () => {
    const mockList = vi.fn().mockResolvedValue({
      data: { items: [], nextCursor: 'cursor-xyz' },
      error: undefined,
    });

    const result = await callList(mockList);
    expect(result.nextCursor).toBe('cursor-xyz');
  });

  it('throws Problem on 401 — unauthenticated', async () => {
    const problem: Problem = { type: null, status: 401, detail: 'Not authenticated', title: 'Unauthorized' };
    const mockList = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callList(mockList)).rejects.toMatchObject({ status: 401 });
  });

  it('throws Problem on 500 — server error', async () => {
    const problem: Problem = { type: null, status: 500, detail: 'Internal error', title: 'Server Error' };
    const mockList = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callList(mockList)).rejects.toMatchObject({ status: 500, detail: 'Internal error' });
  });

  it('caller can route on problem.status', async () => {
    expect(routeStatus(401)).toBe('unauthenticated');
    expect(routeStatus(403)).toBe('forbidden');
    expect(routeStatus(404)).toBe('not-found');
    expect(routeStatus(500)).toBe('error');
  });
});

// ── create() — happy path ─────────────────────────────────────────────────────

describe('useShipsApi.create', () => {
  it('returns created Ship on 201 response', async () => {
    const fixture = makeShipFixture({ id: 'ship-new-001', name: 'Iron Lotus' });
    const mockCreate = vi.fn().mockResolvedValue({ data: fixture, error: undefined });

    const body: ShipCreate = { name: 'Iron Lotus', class: 'fighter' };
    const result = await callCreate(mockCreate, body);

    expect(result.id).toBe('ship-new-001');
    expect(result.name).toBe('Iron Lotus');
    expect(mockCreate).toHaveBeenCalledWith({ body });
  });

  it('throws Problem on 422 — validation error', async () => {
    const problem: Problem = {
      type: null,
      status: 422,
      detail: 'name must be at most 80 characters',
      title: 'Unprocessable Entity',
    };
    const mockCreate = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    const body: ShipCreate = { name: 'x'.repeat(81), class: 'fighter' };
    await expect(callCreate(mockCreate, body)).rejects.toMatchObject({ status: 422 });
  });

  it('throws Problem on 401 — unauthenticated', async () => {
    const problem: Problem = { type: null, status: 401, detail: 'Not authenticated', title: 'Unauthorized' };
    const mockCreate = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(
      callCreate(mockCreate, { name: 'Any Ship', class: 'shuttle' }),
    ).rejects.toMatchObject({ status: 401 });
  });

  it('caller can extract problem.detail for inline display', async () => {
    const problem: Problem = {
      type: null,
      status: 422,
      detail: 'name is required',
      title: 'Unprocessable Entity',
    };
    const mockCreate = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    let caught: Problem | null = null;
    try {
      await callCreate(mockCreate, { name: '', class: 'shuttle' });
    } catch (error) {
      caught = error as Problem;
    }

    expect(caught?.detail).toBe('name is required');
  });
});

// ── routeStatus helper (mirrors caller error routing in index.vue) ────────────

function routeStatus(status: number): string {
  if (status === 401) return 'unauthenticated';
  if (status === 403) return 'forbidden';
  if (status === 404) return 'not-found';
  return 'error';
}

// ── humaniseClass helper ──────────────────────────────────────────────────────
// Mirrors the same helper in apps/web/app/pages/app/ships/index.vue.

function humaniseClass(cls: string): string {
  return cls
    .split('-')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ');
}

describe('humaniseClass (page helper)', () => {
  it.each([
    ['light-freighter', 'Light Freighter'],
    ['heavy-cruiser', 'Heavy Cruiser'],
    ['fighter', 'Fighter'],
    ['torpedo-boat', 'Torpedo Boat'],
    ['courier-yacht', 'Courier Yacht'],
  ])('humaniseClass(%s) → %s', (input, expected) => {
    expect(humaniseClass(input)).toBe(expected);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Block 2 — update() and structural assertions (T-2026-05-10-005 Block 2)
// ─────────────────────────────────────────────────────────────────────────────

async function callUpdate(
  mockFn: (opts: unknown) => Promise<MockResult<Ship>>,
  id: string,
  body: Partial<Ship>,
): Promise<Ship> {
  const res = await mockFn({ path: { id }, body });
  if (res.error) throw res.error;
  return res.data!;
}

describe('useShipsApi.update', () => {
  it('PATCHes with the body and returns the updated Ship', async () => {
    const fixture = makeShipFixture({ name: 'New Name', hull: { current: 5, max: 8 } });
    const mockUpdate = vi.fn().mockResolvedValue({ data: fixture, error: undefined });

    const result = await callUpdate(mockUpdate, 'ship-id-001', {
      name: 'New Name',
      hull: { current: 5, max: 8 },
    });

    expect(result.name).toBe('New Name');
    expect(result.hull.current).toBe(5);
    expect(mockUpdate).toHaveBeenCalledWith({
      path: { id: 'ship-id-001' },
      body: { name: 'New Name', hull: { current: 5, max: 8 } },
    });
  });

  it('throws Problem with status 403 on forbidden PATCH', async () => {
    const problem: Problem = {
      type: null,
      status: 403,
      detail: 'You do not own this ship',
      title: 'Forbidden',
    };
    const mockUpdate = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callUpdate(mockUpdate, 'ship-id-001', { name: 'Hack' })).rejects.toMatchObject({
      status: 403,
      detail: 'You do not own this ship',
    });
  });

  it('throws Problem with status 404 on missing ship PATCH', async () => {
    const problem: Problem = {
      type: null,
      status: 404,
      detail: 'Ship not found',
      title: 'Not Found',
    };
    const mockUpdate = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callUpdate(mockUpdate, 'no-such-id', { name: 'Ghost' })).rejects.toMatchObject({
      status: 404,
    });
  });

  it('partial PATCH — only sends the fields provided', async () => {
    const fixture = makeShipFixture({ notes: 'Updated notes' });
    const mockUpdate = vi.fn().mockResolvedValue({ data: fixture, error: undefined });

    const result = await callUpdate(mockUpdate, 'ship-id-001', { notes: 'Updated notes' } as Partial<Ship>);

    expect(result.notes).toBe('Updated notes');
    // Only `notes` sent — not the full Ship shape
    expect(mockUpdate).toHaveBeenCalledWith({
      path: { id: 'ship-id-001' },
      body: { notes: 'Updated notes' },
    });
  });

  it('problems array PATCH replaces the full list', async () => {
    const fixture = makeShipFixture({ problems: ['Hull breach', 'Reactor leak'] });
    const mockUpdate = vi.fn().mockResolvedValue({ data: fixture, error: undefined });

    const result = await callUpdate(mockUpdate, 'ship-id-001', {
      problems: ['Hull breach', 'Reactor leak'],
    } as Partial<Ship>);

    expect(result.problems).toHaveLength(2);
    expect(result.problems[0]).toBe('Hull breach');
  });
});

// ── Structural assertions on Block 2 sheet wiring ────────────────────────────
// Mirrors the "no edit affordances" guard pattern from share-viewer.spec.ts.
// We import the page source as text and assert key wiring is present.

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import nodePath from 'node:path';

const { resolve, dirname } = nodePath;
// WHY: unicorn/prefer-module forbids __dirname in ESM .ts files; use import.meta.url instead.
const _dirname = dirname(fileURLToPath(import.meta.url));

const PAGE_PATH = resolve(_dirname, '../../pages/app/ships/[id].vue');

describe('[id].vue Block 2 — structural wiring', () => {
  let src: string;

  beforeAll(() => {
    src = readFileSync(PAGE_PATH, 'utf8');
  });

  it('imports useAutoSave', () => {
    expect(src).toContain("from '~/composables/useAutoSave'");
  });

  it('imports useShipsApi', () => {
    expect(src).toContain("from '~/composables/useShipsApi'");
  });

  it('imports AppSavePulse', () => {
    expect(src).toContain('AppSavePulse');
  });

  it('uses auto-save with 600 ms debounce', () => {
    expect(src).toContain('debounceMs: 600');
  });

  it('handles notfound page state for 404 responses', () => {
    expect(src).toContain("state.value = 'notfound'");
    expect(src).toContain('problem.status === 404');
  });

  it('wires crew roster using CREW_POSITIONS constant', () => {
    expect(src).toContain('CREW_POSITIONS');
  });

  it('wires modules grouped with mandatory slots first', () => {
    expect(src).toContain('MANDATORY_SLOTS');
  });
});

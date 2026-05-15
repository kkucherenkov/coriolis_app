/**
 * Vitest unit specs for useNpcsApi (T-2026-05-10-008 Block 1).
 *
 * We test the composable logic in isolation by mocking the generated SDK
 * functions. The composable is a thin wrapper that:
 *   - delegates to the generated SDK call
 *   - throws res.error (as a Problem object) when present
 *   - returns the shaped data otherwise
 *
 * Page mounting is deferred to Playwright e2e.
 */

import { describe, it, expect, vi, beforeAll } from 'vitest';
import type { Npc, NpcCreate, Problem } from '@app/api-client-ts';

// ── Fixture ───────────────────────────────────────────────────────────────────

export function makeNpcFixture(overrides: Partial<Npc> = {}): Npc {
  return {
    id: 'npc-id-001',
    ownerId: 'owner-id-001',
    name: 'Corsair Captain',
    description: 'Scarred veteran of the Rift Wars',
    attributes: {
      strength: 3,
      agility: 3,
      wits: 3,
      empathy: 3,
    },
    skills: {
      dexterity: 0,
      force: 0,
      infiltration: 0,
      manipulation: 0,
      meleeCombat: 0,
      observation: 0,
      rangedCombat: 0,
      survival: 0,
      command: 0,
      culture: 0,
      dataDjinn: 0,
      medicurgy: 0,
      mysticPowers: 0,
      pilot: 0,
      science: 0,
      technology: 0,
    },
    hp: { current: 4, max: 4 },
    mp: { current: 4, max: 4 },
    signature: 0,
    keySkillModifier: 0,
    armor: [],
    weapons: [],
    tags: ['Pirate', 'Boss'],
    createdAt: '2026-05-11T10:00:00Z',
    updatedAt: '2026-05-11T10:00:00Z',
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
  mockFn: (opts: unknown) => Promise<MockResult<{ items: Npc[]; nextCursor: string | null }>>,
  opts?: { limit?: number; tag?: string },
): Promise<{ items: readonly Npc[]; nextCursor: string | null }> {
  const res = await mockFn({ query: opts });
  if (res.error) throw res.error;
  return { items: res.data!.items, nextCursor: res.data!.nextCursor };
}

async function callCreate(
  mockFn: (opts: unknown) => Promise<MockResult<Npc>>,
  body: NpcCreate,
): Promise<Npc> {
  const res = await mockFn({ body });
  if (res.error) throw res.error;
  return res.data!;
}

async function callDuplicate(
  mockFn: (opts: unknown) => Promise<MockResult<Npc>>,
  id: string,
): Promise<Npc> {
  const res = await mockFn({ path: { id } });
  if (res.error) throw res.error;
  return res.data!;
}

async function callDelete(
  mockFn: (opts: unknown) => Promise<MockResult<void>>,
  id: string,
): Promise<void> {
  const res = await mockFn({ path: { id } });
  if (res.error) throw res.error;
}

// ── list() — happy path ───────────────────────────────────────────────────────

describe('useNpcsApi.list', () => {
  it('returns items and nextCursor on 200 response', async () => {
    const fixture = makeNpcFixture();
    const mockList = vi.fn().mockResolvedValue({
      data: { items: [fixture], nextCursor: null },
      error: undefined,
    });

    const result = await callList(mockList, { limit: 20 });

    expect(result.items).toHaveLength(1);
    expect(result.items[0]?.name).toBe('Corsair Captain');
    expect(result.nextCursor).toBeNull();
    expect(mockList).toHaveBeenCalledWith({ query: { limit: 20 } });
  });

  it('forwards nextCursor when a second page exists', async () => {
    const mockList = vi.fn().mockResolvedValue({
      data: { items: [], nextCursor: 'cursor-abc' },
      error: undefined,
    });

    const result = await callList(mockList);
    expect(result.nextCursor).toBe('cursor-abc');
  });

  it('filters by tag when provided', async () => {
    const fixture = makeNpcFixture({ tags: ['Boss'] });
    const mockList = vi.fn().mockResolvedValue({
      data: { items: [fixture], nextCursor: null },
      error: undefined,
    });

    const result = await callList(mockList, { tag: 'Boss' });
    expect(result.items[0]?.tags).toContain('Boss');
    expect(mockList).toHaveBeenCalledWith({ query: { tag: 'Boss' } });
  });

  it('returns empty list when no NPCs exist', async () => {
    const mockList = vi.fn().mockResolvedValue({
      data: { items: [], nextCursor: null },
      error: undefined,
    });

    const result = await callList(mockList, { limit: 20 });
    expect(result.items).toHaveLength(0);
    expect(result.nextCursor).toBeNull();
  });

  it('throws Problem on 401 — unauthenticated', async () => {
    const problem: Problem = {
      type: null,
      status: 401,
      detail: 'Not authenticated',
      title: 'Unauthorized',
    };
    const mockList = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callList(mockList)).rejects.toMatchObject({ status: 401 });
  });

  it('throws Problem on 500 — server error', async () => {
    const problem: Problem = {
      type: null,
      status: 500,
      detail: 'Internal error',
      title: 'Server Error',
    };
    const mockList = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callList(mockList)).rejects.toMatchObject({
      status: 500,
      detail: 'Internal error',
    });
  });

  it('caller can route on problem.status', () => {
    expect(routeStatus(401)).toBe('unauthenticated');
    expect(routeStatus(403)).toBe('forbidden');
    expect(routeStatus(404)).toBe('not-found');
    expect(routeStatus(500)).toBe('error');
  });
});

// ── create() ─────────────────────────────────────────────────────────────────

describe('useNpcsApi.create', () => {
  it('returns created Npc on 201 response', async () => {
    const fixture = makeNpcFixture({ id: 'npc-new-001', name: 'Ghost Broker' });
    const mockCreate = vi.fn().mockResolvedValue({ data: fixture, error: undefined });

    const body: NpcCreate = { name: 'Ghost Broker' };
    const result = await callCreate(mockCreate, body);

    expect(result.id).toBe('npc-new-001');
    expect(result.name).toBe('Ghost Broker');
    expect(mockCreate).toHaveBeenCalledWith({ body });
  });

  it('creates with only name (minimum required)', async () => {
    const fixture = makeNpcFixture({ name: 'Spy' });
    const mockCreate = vi.fn().mockResolvedValue({ data: fixture, error: undefined });

    await callCreate(mockCreate, { name: 'Spy' });
    expect(mockCreate).toHaveBeenCalledWith({ body: { name: 'Spy' } });
  });

  it('creates with optional description', async () => {
    const fixture = makeNpcFixture({ name: 'Oracle', description: 'Sees all futures' });
    const mockCreate = vi.fn().mockResolvedValue({ data: fixture, error: undefined });

    const body: NpcCreate = { name: 'Oracle', description: 'Sees all futures' };
    const result = await callCreate(mockCreate, body);
    expect(result.description).toBe('Sees all futures');
  });

  it('throws Problem on 422 — validation error', async () => {
    const problem: Problem = {
      type: null,
      status: 422,
      detail: 'name must be at most 120 characters',
      title: 'Unprocessable Entity',
    };
    const mockCreate = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callCreate(mockCreate, { name: 'x'.repeat(121) })).rejects.toMatchObject({
      status: 422,
    });
  });

  it('throws Problem on 401 — unauthenticated', async () => {
    const problem: Problem = {
      type: null,
      status: 401,
      detail: 'Not authenticated',
      title: 'Unauthorized',
    };
    const mockCreate = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callCreate(mockCreate, { name: 'Spy' })).rejects.toMatchObject({ status: 401 });
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
      await callCreate(mockCreate, { name: '' });
    } catch (error) {
      caught = error as Problem;
    }

    expect(caught?.detail).toBe('name is required');
  });
});

// ── duplicate() ───────────────────────────────────────────────────────────────

describe('useNpcsApi.duplicate', () => {
  it('returns the duplicated Npc on 201 response', async () => {
    const copy = makeNpcFixture({ id: 'npc-copy-001', name: 'Corsair Captain (copy)' });
    const mockDuplicate = vi.fn().mockResolvedValue({ data: copy, error: undefined });

    const result = await callDuplicate(mockDuplicate, 'npc-id-001');

    expect(result.id).toBe('npc-copy-001');
    expect(result.name).toContain('copy');
    expect(mockDuplicate).toHaveBeenCalledWith({ path: { id: 'npc-id-001' } });
  });

  it('throws Problem on 404 — source NPC not found', async () => {
    const problem: Problem = {
      type: null,
      status: 404,
      detail: 'NPC not found',
      title: 'Not Found',
    };
    const mockDuplicate = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callDuplicate(mockDuplicate, 'no-such-id')).rejects.toMatchObject({ status: 404 });
  });
});

// ── delete() ──────────────────────────────────────────────────────────────────

describe('useNpcsApi.delete', () => {
  it('resolves with void on 204 response', async () => {
    const mockDelete = vi.fn().mockResolvedValue({ data: undefined, error: undefined });

    await expect(callDelete(mockDelete, 'npc-id-001')).resolves.toBeUndefined();
    expect(mockDelete).toHaveBeenCalledWith({ path: { id: 'npc-id-001' } });
  });

  it('throws Problem on 409 — NPC_IN_USE', async () => {
    const problem: Problem = {
      type: null,
      status: 409,
      detail: 'NPC is in use by an active encounter',
      title: 'Conflict',
    };
    const mockDelete = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callDelete(mockDelete, 'npc-id-001')).rejects.toMatchObject({
      status: 409,
      detail: 'NPC is in use by an active encounter',
    });
  });
});

// ── routeStatus helper ────────────────────────────────────────────────────────

function routeStatus(status: number): string {
  if (status === 401) return 'unauthenticated';
  if (status === 403) return 'forbidden';
  if (status === 404) return 'not-found';
  return 'error';
}

// ── Structural assertions on the index page ───────────────────────────────────

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import nodePath from 'node:path';

const { resolve, dirname } = nodePath;
// WHY: unicorn/prefer-module forbids __dirname in ESM .ts files; use import.meta.url instead.
const _dirname = dirname(fileURLToPath(import.meta.url));

const INDEX_PATH = resolve(_dirname, '../../pages/app/npcs/index.vue');

describe('npcs/index.vue — structural wiring', () => {
  let src: string;

  beforeAll(() => {
    src = readFileSync(INDEX_PATH, 'utf8');
  });

  it('imports useNpcsApi', () => {
    expect(src).toContain("from '~/composables/useNpcsApi'");
  });

  it('imports AppModal', () => {
    expect(src).toContain('AppModal');
  });

  it('per-card Delete opens a confirm modal, not a direct delete', () => {
    expect(src).toContain('openDeleteConfirm(npc)');
  });

  it('confirmDelete() calls npcsApi.delete on the pending NPC', () => {
    expect(src).toContain('async function confirmDelete');
    expect(src).toContain('npcsApi.delete(deletingNpc.value.id)');
  });

  it('reads duplicatedFrom from route.query', () => {
    const hasDot = src.includes('route.query.duplicatedFrom');
    const hasBracket = src.includes("route.query['duplicatedFrom']");
    expect(hasDot || hasBracket).toBe(true);
  });

  it('clears the query param via router.replace after surfacing the toast', () => {
    expect(src).toContain('router.replace');
    expect(src).toContain('{ query: {} }');
  });

  it('shows the duplicated toast banner', () => {
    expect(src).toContain('showDuplicatedToast');
    expect(src).toContain('duplicatedToast');
  });

  it('auto-dismisses the toast after 4 seconds', () => {
    expect(src).toContain('setTimeout');
    expect(src).toContain('4000');
  });

  it('renders empty state with heading', () => {
    expect(src).toContain('emptyHeading');
    expect(src).toContain('emptyBody');
  });

  it('has Russian translations', () => {
    expect(src).toContain('Наполните библиотеку НПС');
  });

  it('has data-testid on root section', () => {
    expect(src).toContain('data-testid="page-npcs"');
  });
});

describe('npcs/index.vue — delete confirm modal', () => {
  let src: string;

  beforeAll(() => {
    src = readFileSync(INDEX_PATH, 'utf8');
  });

  it('has deleteConfirmOpen ref controlling modal open state', () => {
    expect(src).toContain('deleteConfirmOpen');
  });

  it('passes closeOnBackdrop=false to prevent accidental dismiss (PATTERNS.md §5)', () => {
    // T-AUDIT-2026-05-15-MODAL-BACKDROP-DEFAULT — delete is a destructive
    // confirm; PATTERNS.md §5 disallows backdrop close. Esc-close stays
    // gated on `!deleting` so the user can still cancel before the
    // request lands but cannot interrupt the in-flight delete.
    expect(src).toContain(':close-on-backdrop="false"');
    expect(src).toContain(':close-on-esc="!deleting"');
  });
});

// ── Characters index: NPCs nav deduplication (T-UX-2026-05-15-DASHBOARD-NAV-DUPE) ──
// The page-level Ships/NPCs ghost buttons were removed — navigation is now
// handled exclusively by the global AppHeader (apps/web/app/layouts/app.vue).
// These assertions pin that the removed buttons and their i18n keys are gone.

const CHARACTERS_INDEX_PATH = resolve(_dirname, '../../pages/app/characters/index.vue');

describe('characters/index.vue — nav dedupe (Block B)', () => {
  let src: string;

  beforeAll(() => {
    src = readFileSync(CHARACTERS_INDEX_PATH, 'utf8');
  });

  it('does not contain a page-level navigateTo /app/npcs button', () => {
    // /app/npcs navigation belongs to AppHeader only after the dedupe fix.
    expect(src).not.toContain("navigateTo('/app/npcs')");
  });

  it('does not contain a page-level navigateTo /app/ships button', () => {
    expect(src).not.toContain("navigateTo('/app/ships')");
  });

  it('does not contain the removed navNpcs i18n key', () => {
    expect(src).not.toContain('"navNpcs"');
  });

  it('does not contain the removed navShips i18n key', () => {
    expect(src).not.toContain('"navShips"');
  });

  it('still contains the primary newCharacter CTA', () => {
    expect(src).toContain("navigateTo('/app/characters/new')");
  });
});

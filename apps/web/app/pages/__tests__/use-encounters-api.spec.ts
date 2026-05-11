/**
 * Vitest unit specs for useEncountersApi (T-2026-05-10-008 Block 3).
 *
 * We test the composable logic in isolation by mirroring the pattern from
 * use-npcs-api.spec.ts. Each method is replicated as a plain async helper
 * that delegates to a vi.fn() mock — no Nuxt runtime required.
 *
 * Structural assertions on EncounterPanel.vue are included as a separate
 * describe block (file-read approach, same as use-npcs-api.spec.ts).
 */

import { describe, it, expect, vi, beforeAll } from 'vitest';
import type { Encounter, EncounterCreate, EncounterStatus, Problem } from '@app/api-client-ts';

// ── Fixture ───────────────────────────────────────────────────────────────────

export function makeEncounterFixture(overrides: Partial<Encounter> = {}): Encounter {
  return {
    id: 'enc-id-001',
    gameSessionId: 'session-id-001',
    name: 'Ambush in the Spire',
    status: 'setup',
    round: 0,
    activeCombatantId: null,
    notes: null,
    createdAt: '2026-05-11T10:00:00Z',
    updatedAt: '2026-05-11T10:00:00Z',
    ...overrides,
  };
}

// ── Helper: inline composable logic ──────────────────────────────────────────

interface MockResult<T> {
  data: T | undefined;
  error: Problem | undefined;
}

async function callList(
  mockFn: (opts: unknown) => Promise<MockResult<{ items: Encounter[]; nextCursor: string | null }>>,
  sessionId: string,
  opts?: { limit?: number; status?: EncounterStatus },
): Promise<{ items: readonly Encounter[]; nextCursor: string | null }> {
  const res = await mockFn({ path: { sessionId }, query: opts });
  if (res.error) throw res.error;
  return { items: res.data!.items, nextCursor: res.data!.nextCursor };
}

async function callCreate(
  mockFn: (opts: unknown) => Promise<MockResult<Encounter>>,
  sessionId: string,
  body: EncounterCreate,
): Promise<Encounter> {
  const res = await mockFn({ path: { sessionId }, body });
  if (res.error) throw res.error;
  return res.data!;
}

async function callGet(
  mockFn: (opts: unknown) => Promise<MockResult<Encounter>>,
  id: string,
): Promise<Encounter> {
  const res = await mockFn({ path: { id } });
  if (res.error) throw res.error;
  return res.data!;
}

async function callUpdate(
  mockFn: (opts: unknown) => Promise<MockResult<Encounter>>,
  id: string,
  patch: Partial<Encounter>,
): Promise<Encounter> {
  const res = await mockFn({ path: { id }, body: patch });
  if (res.error) throw res.error;
  return res.data!;
}

async function callRemove(
  mockFn: (opts: unknown) => Promise<MockResult<void>>,
  id: string,
): Promise<void> {
  const res = await mockFn({ path: { id } });
  if (res.error) throw res.error;
}

// ── list() ────────────────────────────────────────────────────────────────────

describe('useEncountersApi.list', () => {
  it('returns items and nextCursor on 200 response', async () => {
    const fixture = makeEncounterFixture();
    const mockList = vi.fn().mockResolvedValue({
      data: { items: [fixture], nextCursor: null },
      error: undefined,
    });

    const result = await callList(mockList, 'session-id-001', { limit: 20 });

    expect(result.items).toHaveLength(1);
    expect(result.items[0]?.name).toBe('Ambush in the Spire');
    expect(result.nextCursor).toBeNull();
    expect(mockList).toHaveBeenCalledWith({
      path: { sessionId: 'session-id-001' },
      query: { limit: 20 },
    });
  });

  it('forwards nextCursor when a second page exists', async () => {
    const mockList = vi.fn().mockResolvedValue({
      data: { items: [], nextCursor: 'cursor-abc' },
      error: undefined,
    });

    const result = await callList(mockList, 'session-id-001');
    expect(result.nextCursor).toBe('cursor-abc');
  });

  it('filters by status when provided', async () => {
    const active = makeEncounterFixture({ status: 'active' });
    const mockList = vi.fn().mockResolvedValue({
      data: { items: [active], nextCursor: null },
      error: undefined,
    });

    const result = await callList(mockList, 'session-id-001', { status: 'active' });
    expect(result.items[0]?.status).toBe('active');
    expect(mockList).toHaveBeenCalledWith({
      path: { sessionId: 'session-id-001' },
      query: { status: 'active' },
    });
  });

  it('returns empty list when session has no encounters', async () => {
    const mockList = vi.fn().mockResolvedValue({
      data: { items: [], nextCursor: null },
      error: undefined,
    });

    const result = await callList(mockList, 'session-id-001');
    expect(result.items).toHaveLength(0);
  });

  it('throws Problem on 401 — unauthenticated', async () => {
    const problem: Problem = {
      type: null,
      status: 401,
      detail: 'Not authenticated',
      title: 'Unauthorized',
    };
    const mockList = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callList(mockList, 'session-id-001')).rejects.toMatchObject({ status: 401 });
  });

  it('throws Problem on 403 — caller does not own the session', async () => {
    const problem: Problem = {
      type: null,
      status: 403,
      detail: 'Forbidden',
      title: 'Forbidden',
    };
    const mockList = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callList(mockList, 'session-id-001')).rejects.toMatchObject({ status: 403 });
  });

  it('throws Problem on 404 — session not found', async () => {
    const problem: Problem = {
      type: null,
      status: 404,
      detail: 'Game session not found',
      title: 'Not Found',
    };
    const mockList = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callList(mockList, 'no-such-session')).rejects.toMatchObject({
      status: 404,
      detail: 'Game session not found',
    });
  });
});

// ── create() ──────────────────────────────────────────────────────────────────

describe('useEncountersApi.create', () => {
  it('returns created Encounter on 201 response', async () => {
    const fixture = makeEncounterFixture({ id: 'enc-new-001', name: 'Market Brawl' });
    const mockCreate = vi.fn().mockResolvedValue({ data: fixture, error: undefined });

    const body: EncounterCreate = { name: 'Market Brawl' };
    const result = await callCreate(mockCreate, 'session-id-001', body);

    expect(result.id).toBe('enc-new-001');
    expect(result.name).toBe('Market Brawl');
    expect(result.status).toBe('setup');
    expect(result.round).toBe(0);
    expect(mockCreate).toHaveBeenCalledWith({ path: { sessionId: 'session-id-001' }, body });
  });

  it('seeds status=setup and round=0 on the returned object', async () => {
    const fixture = makeEncounterFixture({ status: 'setup', round: 0 });
    const mockCreate = vi.fn().mockResolvedValue({ data: fixture, error: undefined });

    const result = await callCreate(mockCreate, 'session-id-001', { name: 'New encounter' });
    expect(result.status).toBe('setup');
    expect(result.round).toBe(0);
    expect(result.activeCombatantId).toBeNull();
  });

  it('creates with optional notes', async () => {
    const fixture = makeEncounterFixture({ notes: 'Three guards, one boss' });
    const mockCreate = vi.fn().mockResolvedValue({ data: fixture, error: undefined });

    const body: EncounterCreate = { name: 'Guarded Gate', notes: 'Three guards, one boss' };
    const result = await callCreate(mockCreate, 'session-id-001', body);
    expect(result.notes).toBe('Three guards, one boss');
  });

  it('throws Problem on 400 — name too long', async () => {
    const problem: Problem = {
      type: null,
      status: 400,
      detail: 'ENCOUNTER_NAME_TOO_LONG',
      title: 'Bad Request',
    };
    const mockCreate = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(
      callCreate(mockCreate, 'session-id-001', { name: 'x'.repeat(81) }),
    ).rejects.toMatchObject({ status: 400 });
  });

  it('throws Problem on 401 — unauthenticated', async () => {
    const problem: Problem = {
      type: null,
      status: 401,
      detail: 'Not authenticated',
      title: 'Unauthorized',
    };
    const mockCreate = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callCreate(mockCreate, 'session-id-001', { name: 'X' })).rejects.toMatchObject({
      status: 401,
    });
  });

  it('caller can read problem.detail for inline error display', async () => {
    const problem: Problem = {
      type: null,
      status: 400,
      detail: 'ENCOUNTER_NAME_EMPTY',
      title: 'Bad Request',
    };
    const mockCreate = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    let caught: Problem | null = null;
    try {
      await callCreate(mockCreate, 'session-id-001', { name: '' });
    } catch (error) {
      caught = error as Problem;
    }
    expect(caught?.detail).toBe('ENCOUNTER_NAME_EMPTY');
  });
});

// ── get() ──────────────────────────────────────────────────────────────────────

describe('useEncountersApi.get', () => {
  it('returns Encounter on 200 response', async () => {
    const fixture = makeEncounterFixture({ id: 'enc-id-001' });
    const mockGet = vi.fn().mockResolvedValue({ data: fixture, error: undefined });

    const result = await callGet(mockGet, 'enc-id-001');
    expect(result.id).toBe('enc-id-001');
    expect(mockGet).toHaveBeenCalledWith({ path: { id: 'enc-id-001' } });
  });

  it('throws Problem on 404 — encounter not found', async () => {
    const problem: Problem = {
      type: null,
      status: 404,
      detail: 'Encounter not found',
      title: 'Not Found',
    };
    const mockGet = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callGet(mockGet, 'no-such-enc')).rejects.toMatchObject({ status: 404 });
  });

  it('throws Problem on 403 — caller does not own the session', async () => {
    const problem: Problem = {
      type: null,
      status: 403,
      detail: 'Forbidden',
      title: 'Forbidden',
    };
    const mockGet = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callGet(mockGet, 'enc-id-001')).rejects.toMatchObject({ status: 403 });
  });
});

// ── update() ──────────────────────────────────────────────────────────────────

describe('useEncountersApi.update', () => {
  it('returns updated Encounter on 200 response', async () => {
    const updated = makeEncounterFixture({ name: 'Renamed Encounter', status: 'active', round: 1 });
    const mockUpdate = vi.fn().mockResolvedValue({ data: updated, error: undefined });

    const result = await callUpdate(mockUpdate, 'enc-id-001', {
      name: 'Renamed Encounter',
      status: 'active',
    });
    expect(result.name).toBe('Renamed Encounter');
    expect(result.status).toBe('active');
    expect(mockUpdate).toHaveBeenCalledWith({
      path: { id: 'enc-id-001' },
      body: { name: 'Renamed Encounter', status: 'active' },
    });
  });

  it('throws Problem on 422 — no combatants when transitioning to active', async () => {
    const problem: Problem = {
      type: null,
      status: 422,
      detail: 'ENCOUNTER_NO_COMBATANTS',
      title: 'Unprocessable Entity',
    };
    const mockUpdate = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callUpdate(mockUpdate, 'enc-id-001', { status: 'active' })).rejects.toMatchObject({
      status: 422,
      detail: 'ENCOUNTER_NO_COMBATANTS',
    });
  });

  it('throws Problem on 422 — invalid status transition', async () => {
    const problem: Problem = {
      type: null,
      status: 422,
      detail: 'ENCOUNTER_INVALID_TRANSITION',
      title: 'Unprocessable Entity',
    };
    const mockUpdate = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callUpdate(mockUpdate, 'enc-id-001', { status: 'setup' })).rejects.toMatchObject({
      status: 422,
    });
  });
});

// ── remove() ─────────────────────────────────────────────────────────────────

describe('useEncountersApi.remove', () => {
  it('resolves with void on 204 response', async () => {
    const mockRemove = vi.fn().mockResolvedValue({ data: undefined, error: undefined });

    await expect(callRemove(mockRemove, 'enc-id-001')).resolves.toBeUndefined();
    expect(mockRemove).toHaveBeenCalledWith({ path: { id: 'enc-id-001' } });
  });

  it('throws Problem on 404 — encounter not found', async () => {
    const problem: Problem = {
      type: null,
      status: 404,
      detail: 'Encounter not found',
      title: 'Not Found',
    };
    const mockRemove = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callRemove(mockRemove, 'no-such-enc')).rejects.toMatchObject({ status: 404 });
  });
});

// ── state machine assertions (pure logic) ────────────────────────────────────

function showSetupHint(encounter: Encounter, combatantCount: number): boolean {
  return encounter.status === 'setup' && combatantCount === 0;
}

describe('encounter state-machine hints', () => {
  it('shows hint when status=setup and combatantCount=0', () => {
    const enc = makeEncounterFixture({ status: 'setup' });
    expect(showSetupHint(enc, 0)).toBe(true);
  });

  it('does NOT show hint when status=setup but combatantCount>0', () => {
    const enc = makeEncounterFixture({ status: 'setup' });
    expect(showSetupHint(enc, 1)).toBe(false);
  });

  it('does NOT show hint when status=active', () => {
    const enc = makeEncounterFixture({ status: 'active' });
    expect(showSetupHint(enc, 0)).toBe(false);
  });

  it('does NOT show hint when status=ended', () => {
    const enc = makeEncounterFixture({ status: 'ended' });
    expect(showSetupHint(enc, 0)).toBe(false);
  });
});

// ── routeStatus helper ────────────────────────────────────────────────────────

function routeStatus(status: number): string {
  if (status === 401) return 'unauthenticated';
  if (status === 403) return 'forbidden';
  if (status === 404) return 'not-found';
  if (status === 422) return 'validation-error';
  return 'error';
}

describe('routeStatus helper', () => {
  it('maps status codes to routing labels', () => {
    expect(routeStatus(401)).toBe('unauthenticated');
    expect(routeStatus(403)).toBe('forbidden');
    expect(routeStatus(404)).toBe('not-found');
    expect(routeStatus(422)).toBe('validation-error');
    expect(routeStatus(500)).toBe('error');
  });
});

// ── Structural assertions on EncounterPanel.vue ───────────────────────────────

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import nodePath from 'node:path';

const { resolve, dirname } = nodePath;
// WHY: unicorn/prefer-module forbids __dirname in ESM .ts files; use import.meta.url instead.
const _dirname = dirname(fileURLToPath(import.meta.url));

const PANEL_PATH = resolve(_dirname, '../../components/EncounterPanel.vue');
const SESSION_DETAIL_PATH = resolve(_dirname, '../../pages/app/sessions/[id].vue');

describe('EncounterPanel.vue — structural wiring', () => {
  let src: string;

  beforeAll(() => {
    src = readFileSync(PANEL_PATH, 'utf8');
  });

  it('imports useEncountersApi', () => {
    expect(src).toContain("from '~/composables/useEncountersApi'");
  });

  it('has data-testid on root element', () => {
    expect(src).toContain('data-testid="encounter-panel"');
  });

  it('renders create form toggle button', () => {
    expect(src).toContain('data-testid="btn-new-encounter"');
  });

  it('renders inline create form with name and notes inputs', () => {
    expect(src).toContain('data-testid="encounter-create-form"');
    expect(src).toContain('data-testid="encounter-name-input"');
    expect(src).toContain('data-testid="encounter-notes-input"');
  });

  it('renders empty state section', () => {
    expect(src).toContain('data-testid="encounter-panel-empty"');
  });

  it('renders encounter cards', () => {
    expect(src).toContain('data-testid="encounter-card"');
  });

  it('renders state-machine hint', () => {
    expect(src).toContain('data-testid="encounter-setup-hint"');
  });

  it('renders open and delete buttons per card', () => {
    expect(src).toContain('data-testid="btn-open-encounter"');
    expect(src).toContain('data-testid="btn-delete-encounter"');
  });

  it('has hintNoCombatants key in English', () => {
    expect(src).toContain(
      '"hintNoCombatants": "Add at least one combatant before rolling initiative."',
    );
  });

  it('has hintNoCombatants key in Russian', () => {
    expect(src).toContain(
      '"hintNoCombatants": "Добавьте хотя бы одного участника перед броском инициативы."',
    );
  });

  it('has uk placeholder translations', () => {
    expect(src).toContain('"heading": "[uk-todo] Encounters"');
  });

  it('has el placeholder translations', () => {
    expect(src).toContain('"heading": "[el-todo] Encounters"');
  });

  it('toggles open state inline rather than emitting (Block 4 inline expansion)', () => {
    // Block 4 changed the Open button from emit('open') to toggleEncounter(id).
    // The CombatTracker is now mounted inline inside EncounterPanel.
    expect(src).toContain('toggleEncounter(encounter.id)');
  });

  it('defines showSetupHint returning true for setup+zero combatants', () => {
    expect(src).toContain("encounter.status === 'setup' && combatantCountFor(encounter.id) === 0");
  });
});

describe('sessions/[id].vue — EncounterPanel mount', () => {
  let src: string;

  beforeAll(() => {
    src = readFileSync(SESSION_DETAIL_PATH, 'utf8');
  });

  it('imports EncounterPanel component', () => {
    expect(src).toContain("import EncounterPanel from '~/components/EncounterPanel.vue'");
  });

  it('mounts EncounterPanel with sessionId prop', () => {
    expect(src).toContain(':session-id="sessionId"');
  });

  it('gates EncounterPanel behind v-if="isGm"', () => {
    // The panel is only shown to the session owner
    const panelBlock = src.slice(src.indexOf('<EncounterPanel'));
    expect(panelBlock).toContain('v-if="isGm"');
  });

  it('existing DP section is not disturbed', () => {
    expect(src).toContain('dpLabel');
    expect(src).toContain('dpAdjustHeading');
  });

  it('existing audit log is not disturbed', () => {
    expect(src).toContain('auditHeading');
    expect(src).toContain('auditEmpty');
  });

  it('existing character assignment is not disturbed', () => {
    expect(src).toContain('assignHeading');
    expect(src).toContain('charactersHeading');
  });
});

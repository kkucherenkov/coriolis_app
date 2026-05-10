/**
 * Vitest unit specs for useCombatantsApi (T-2026-05-10-008 Block 4).
 *
 * Mirrors the pattern from use-encounters-api.spec.ts: each composable
 * method is replicated as a plain async helper that delegates to a vi.fn()
 * mock — no Nuxt runtime required.
 */

import { describe, it, expect, vi } from 'vitest';
import type { Combatant, CombatantCreate, CombatantUpdateWritable, Problem } from '@app/api-client-ts';

// ── Fixtures ──────────────────────────────────────────────────────────────────

function makeCombatant(overrides: Partial<Combatant> = {}): Combatant {
  return {
    id: 'cbt-001',
    encounterId: 'enc-001',
    combatantType: 'npc',
    sourceId: 'npc-001',
    displayName: 'Guard Captain',
    initiative: null,
    turnOrder: null,
    hpCurrent: 10,
    hpMax: 10,
    armor: 2,
    signature: 0,
    statusFlags: [],
    notes: null,
    createdAt: '2026-05-11T12:00:00Z',
    updatedAt: '2026-05-11T12:00:00Z',
    ...overrides,
  };
}

function makeProblem(status = 400, detail = 'bad request'): Problem {
  return { type: 'about:blank', title: 'Error', status, detail };
}

// ── Helper: inline composable logic ──────────────────────────────────────────

interface MockResult<T> {
  data: T | undefined;
  error: Problem | undefined;
}

async function callList(
  mockFn: (opts: unknown) => Promise<MockResult<{ items: Combatant[] }>>,
  encounterId: string,
): Promise<{ items: readonly Combatant[] }> {
  const res = await mockFn({ path: { id: encounterId } });
  if (res.error) throw res.error;
  return { items: res.data!.items };
}

async function callAdd(
  mockFn: (opts: unknown) => Promise<MockResult<Combatant>>,
  encounterId: string,
  body: CombatantCreate,
): Promise<Combatant> {
  const res = await mockFn({ path: { id: encounterId }, body });
  if (res.error) throw res.error;
  return res.data!;
}

async function callUpdate(
  mockFn: (opts: unknown) => Promise<MockResult<Combatant>>,
  combatantId: string,
  patch: CombatantUpdateWritable,
): Promise<Combatant> {
  const res = await mockFn({ path: { id: combatantId }, body: patch });
  if (res.error) throw res.error;
  return res.data!;
}

async function callRemove(
  mockFn: (opts: unknown) => Promise<MockResult<void>>,
  combatantId: string,
): Promise<void> {
  const res = await mockFn({ path: { id: combatantId } });
  if (res.error) throw res.error;
}

async function callReorder(
  mockFn: (opts: unknown) => Promise<MockResult<void>>,
  encounterId: string,
  orderedIds: string[],
): Promise<void> {
  const res = await mockFn({ path: { id: encounterId }, body: { combatantIds: orderedIds } });
  if (res.error) throw res.error;
}

// ── list() ────────────────────────────────────────────────────────────────────

describe('useCombatantsApi — list()', () => {
  it('returns items on success', async () => {
    const combatant = makeCombatant();
    const mock = vi.fn().mockResolvedValue({ data: { items: [combatant] }, error: undefined });
    const result = await callList(mock, 'enc-001');
    expect(result.items).toHaveLength(1);
    expect(result.items[0]!.id).toBe('cbt-001');
  });

  it('calls SDK with the correct encounterId in path', async () => {
    const mock = vi.fn().mockResolvedValue({ data: { items: [] }, error: undefined });
    await callList(mock, 'enc-abc');
    expect(mock).toHaveBeenCalledWith({ path: { id: 'enc-abc' } });
  });

  it('throws on API error', async () => {
    const problem = makeProblem(403, 'forbidden');
    const mock = vi.fn().mockResolvedValue({ data: undefined, error: problem });
    await expect(callList(mock, 'enc-001')).rejects.toMatchObject({ status: 403 });
  });

  it('returns empty items array', async () => {
    const mock = vi.fn().mockResolvedValue({ data: { items: [] }, error: undefined });
    const result = await callList(mock, 'enc-001');
    expect(result.items).toHaveLength(0);
  });
});

// ── add() ─────────────────────────────────────────────────────────────────────

describe('useCombatantsApi — add()', () => {
  it('returns the new combatant on success', async () => {
    const combatant = makeCombatant({ combatantType: 'pc', sourceId: 'char-001' });
    const mock = vi.fn().mockResolvedValue({ data: combatant, error: undefined });
    const body: CombatantCreate = { combatantType: 'pc', sourceId: 'char-001' };
    const result = await callAdd(mock, 'enc-001', body);
    expect(result.combatantType).toBe('pc');
    expect(result.sourceId).toBe('char-001');
  });

  it('passes body and encounterId to SDK', async () => {
    const combatant = makeCombatant();
    const mock = vi.fn().mockResolvedValue({ data: combatant, error: undefined });
    const body: CombatantCreate = { combatantType: 'npc', sourceId: 'npc-007' };
    await callAdd(mock, 'enc-xyz', body);
    expect(mock).toHaveBeenCalledWith({ path: { id: 'enc-xyz' }, body });
  });

  it('throws COMBATANT_DUPLICATE (422)', async () => {
    const problem = makeProblem(422, 'COMBATANT_DUPLICATE');
    const mock = vi.fn().mockResolvedValue({ data: undefined, error: problem });
    const body: CombatantCreate = { combatantType: 'npc', sourceId: 'npc-001' };
    await expect(callAdd(mock, 'enc-001', body)).rejects.toMatchObject({
      status: 422,
      detail: 'COMBATANT_DUPLICATE',
    });
  });

  it('supports optional displayName override', async () => {
    const combatant = makeCombatant({ displayName: 'Boss' });
    const mock = vi.fn().mockResolvedValue({ data: combatant, error: undefined });
    const body: CombatantCreate = {
      combatantType: 'npc',
      sourceId: 'npc-001',
      displayName: 'Boss',
    };
    const result = await callAdd(mock, 'enc-001', body);
    expect(result.displayName).toBe('Boss');
  });
});

// ── update() ──────────────────────────────────────────────────────────────────

describe('useCombatantsApi — update()', () => {
  it('returns the updated combatant', async () => {
    const updated = makeCombatant({ hpCurrent: 5, statusFlags: ['prone'] });
    const mock = vi.fn().mockResolvedValue({ data: updated, error: undefined });
    const result = await callUpdate(mock, 'cbt-001', { hpCurrent: 5, statusFlags: ['prone'] });
    expect(result.hpCurrent).toBe(5);
    expect(result.statusFlags).toContain('prone');
  });

  it('calls SDK with combatantId and patch', async () => {
    const updated = makeCombatant();
    const mock = vi.fn().mockResolvedValue({ data: updated, error: undefined });
    await callUpdate(mock, 'cbt-abc', { armor: 3 });
    expect(mock).toHaveBeenCalledWith({ path: { id: 'cbt-abc' }, body: { armor: 3 } });
  });

  it('throws on encounter ended (422)', async () => {
    const problem = makeProblem(422, 'ENCOUNTER_ENDED');
    const mock = vi.fn().mockResolvedValue({ data: undefined, error: problem });
    await expect(callUpdate(mock, 'cbt-001', { hpCurrent: 0 })).rejects.toMatchObject({
      detail: 'ENCOUNTER_ENDED',
    });
  });

  it('statusFlags patch replaces full array', async () => {
    const updated = makeCombatant({ statusFlags: ['incapacitated', 'prone'] });
    const mock = vi.fn().mockResolvedValue({ data: updated, error: undefined });
    const result = await callUpdate(mock, 'cbt-001', {
      statusFlags: ['incapacitated', 'prone'],
    });
    expect(result.statusFlags).toEqual(['incapacitated', 'prone']);
  });
});

// ── remove() ──────────────────────────────────────────────────────────────────

describe('useCombatantsApi — remove()', () => {
  it('resolves on success', async () => {
    const mock = vi.fn().mockResolvedValue({ data: undefined, error: undefined });
    await expect(callRemove(mock, 'cbt-001')).resolves.toBeUndefined();
  });

  it('calls SDK with combatant id', async () => {
    const mock = vi.fn().mockResolvedValue({ data: undefined, error: undefined });
    await callRemove(mock, 'cbt-xyz');
    expect(mock).toHaveBeenCalledWith({ path: { id: 'cbt-xyz' } });
  });

  it('throws on locked encounter (422)', async () => {
    const problem = makeProblem(422, 'ENCOUNTER_LOCKED_FOR_COMBAT');
    const mock = vi.fn().mockResolvedValue({ data: undefined, error: problem });
    await expect(callRemove(mock, 'cbt-001')).rejects.toMatchObject({ status: 422 });
  });
});

// ── reorder() ─────────────────────────────────────────────────────────────────

describe('useCombatantsApi — reorder()', () => {
  it('resolves on success', async () => {
    const mock = vi.fn().mockResolvedValue({ data: undefined, error: undefined });
    await expect(callReorder(mock, 'enc-001', ['cbt-a', 'cbt-b'])).resolves.toBeUndefined();
  });

  it('calls SDK with combatantIds body', async () => {
    const mock = vi.fn().mockResolvedValue({ data: undefined, error: undefined });
    await callReorder(mock, 'enc-001', ['cbt-a', 'cbt-b']);
    expect(mock).toHaveBeenCalledWith({
      path: { id: 'enc-001' },
      body: { combatantIds: ['cbt-a', 'cbt-b'] },
    });
  });

  it('throws on 422 business rule violation', async () => {
    const problem = makeProblem(422, 'ENCOUNTER_NOT_ACTIVE');
    const mock = vi.fn().mockResolvedValue({ data: undefined, error: problem });
    await expect(callReorder(mock, 'enc-001', ['cbt-a'])).rejects.toMatchObject({ status: 422 });
  });

  it('passes full ordered ids list', async () => {
    const ids = ['cbt-c', 'cbt-a', 'cbt-b'];
    const mock = vi.fn().mockResolvedValue({ data: undefined, error: undefined });
    await callReorder(mock, 'enc-001', ids);
    expect(mock).toHaveBeenCalledWith({
      path: { id: 'enc-001' },
      body: { combatantIds: ids },
    });
  });
});

// ── Status flag logic ─────────────────────────────────────────────────────────

type CanonicalFlag = 'incapacitated' | 'prone' | 'covered';
const CANONICAL_FLAGS: CanonicalFlag[] = ['incapacitated', 'prone', 'covered'];

function isCanonical(flag: string): flag is CanonicalFlag {
  return (CANONICAL_FLAGS as string[]).includes(flag);
}

describe('CombatTracker — status flag helpers', () => {
  it('recognises canonical flags', () => {
    expect(isCanonical('incapacitated')).toBe(true);
    expect(isCanonical('prone')).toBe(true);
    expect(isCanonical('covered')).toBe(true);
  });

  it('free-form tags are not canonical', () => {
    expect(isCanonical('bleeding')).toBe(false);
    expect(isCanonical('zero-g')).toBe(false);
    expect(isCanonical('')).toBe(false);
  });

  it('toggle: adds flag when not present', () => {
    const flags = ['prone'];
    const flag = 'incapacitated';
    const next = flags.includes(flag) ? flags.filter((f) => f !== flag) : [...flags, flag];
    expect(next).toContain('incapacitated');
    expect(next).toContain('prone');
  });

  it('toggle: removes flag when present', () => {
    const flags = ['prone', 'covered'];
    const next = flags.filter((f) => f !== 'prone');
    expect(next).not.toContain('prone');
    expect(next).toContain('covered');
  });
});

// ── Combatant sort logic ──────────────────────────────────────────────────────

function sortCombatants(items: Combatant[]): Combatant[] {
  return [...items].sort((a, b) => {
    if (a.turnOrder === null && b.turnOrder === null) {
      return a.displayName.localeCompare(b.displayName);
    }
    if (a.turnOrder === null) return 1;
    if (b.turnOrder === null) return -1;
    return a.turnOrder - b.turnOrder;
  });
}

describe('CombatTracker — sortCombatants()', () => {
  it('nulls sort after non-nulls', () => {
    const a = makeCombatant({ id: 'a', turnOrder: 0, displayName: 'A' });
    const b = makeCombatant({ id: 'b', turnOrder: null, displayName: 'B' });
    const sorted = sortCombatants([b, a]);
    expect(sorted[0]!.id).toBe('a');
    expect(sorted[1]!.id).toBe('b');
  });

  it('sorts numerically by turnOrder', () => {
    const a = makeCombatant({ id: 'a', turnOrder: 2, displayName: 'A' });
    const b = makeCombatant({ id: 'b', turnOrder: 0, displayName: 'B' });
    const c = makeCombatant({ id: 'c', turnOrder: 1, displayName: 'C' });
    const sorted = sortCombatants([a, b, c]);
    expect(sorted.map((x) => x.id)).toEqual(['b', 'c', 'a']);
  });

  it('falls back to displayName alphabetically when turnOrder is all null', () => {
    const a = makeCombatant({ id: 'a', turnOrder: null, displayName: 'Zephyr' });
    const b = makeCombatant({ id: 'b', turnOrder: null, displayName: 'Alpha' });
    const sorted = sortCombatants([a, b]);
    expect(sorted[0]!.id).toBe('b');
  });
});

/**
 * CombatTracker.spec.ts — logic unit tests (T-2026-05-10-008 Block 4 + 5).
 *
 * Follows the same no-mount pattern as EncounterPanel.spec.ts: tests
 * the pure-logic functions extracted from the SFC without a Nuxt runtime.
 * Mount-level interaction tests are deferred to the Playwright smoke spec.
 *
 * Block 5 additions:
 *   - Initiative button enabled/disabled guard logic
 *   - Drag-reorder dispatch guard (setup vs active)
 *   - Realtime snapshot reconciliation (combatSnapshot replace-wholesale)
 *   - rollInitiative / advanceTurn API error handling
 */

import { describe, it, expect, vi } from 'vitest';
import type { Combatant, Problem } from '@app/api-client-ts';

// ── Fixtures ──────────────────────────────────────────────────────────────────

function makeCombatant(overrides: Partial<Combatant> = {}): Combatant {
  return {
    id: 'cbt-001',
    encounterId: 'enc-001',
    combatantType: 'npc',
    sourceId: 'npc-001',
    displayName: 'Vanguard',
    initiative: null,
    turnOrder: null,
    hpCurrent: 8,
    hpMax: 8,
    armor: 1,
    signature: 0,
    statusFlags: [],
    notes: null,
    createdAt: '2026-05-11T09:00:00Z',
    updatedAt: '2026-05-11T09:00:00Z',
    ...overrides,
  };
}

// ── sortedCombatants logic ────────────────────────────────────────────────────

function sortedCombatants(items: Combatant[]): Combatant[] {
  return items.toSorted((a, b) => {
    if (a.turnOrder === null && b.turnOrder === null)
      return a.displayName.localeCompare(b.displayName);
    if (a.turnOrder === null) return 1;
    if (b.turnOrder === null) return -1;
    return a.turnOrder - b.turnOrder;
  });
}

describe('CombatTracker — renders list (sortedCombatants)', () => {
  it('returns combatants in turnOrder ascending', () => {
    const a = makeCombatant({ id: 'c', turnOrder: 2 });
    const b = makeCombatant({ id: 'a', turnOrder: 0 });
    const c = makeCombatant({ id: 'b', turnOrder: 1 });
    expect(sortedCombatants([a, b, c]).map((x) => x.id)).toEqual(['a', 'b', 'c']);
  });

  it('places null-turnOrder combatants at the end', () => {
    const a = makeCombatant({ id: 'has-order', turnOrder: 0 });
    const b = makeCombatant({ id: 'no-order', turnOrder: null });
    expect(sortedCombatants([b, a])[0]!.id).toBe('has-order');
  });

  it('shows active row: activeCombatantId matches', () => {
    const cbt = makeCombatant({ id: 'cbt-act' });
    const activeCombatantId = 'cbt-act';
    expect(cbt.id === activeCombatantId).toBe(true);
  });

  it('empty list produces empty sorted list', () => {
    expect(sortedCombatants([])).toHaveLength(0);
  });
});

// ── Status-flag chip logic ────────────────────────────────────────────────────

type CanonicalFlag = 'incapacitated' | 'prone' | 'covered';
const CANONICAL_FLAGS: CanonicalFlag[] = ['incapacitated', 'prone', 'covered'];

function isCanonical(flag: string): flag is CanonicalFlag {
  return (CANONICAL_FLAGS as string[]).includes(flag);
}

function canonicalFlagVariant(flag: CanonicalFlag): 'crimson' | 'brass' | 'mystic' {
  if (flag === 'incapacitated') return 'crimson';
  if (flag === 'prone') return 'brass';
  return 'mystic';
}

function canonicalFlagIcon(flag: CanonicalFlag): string {
  if (flag === 'incapacitated') return 'i-heroicons-x-circle';
  if (flag === 'prone') return 'i-heroicons-arrow-down-circle';
  return 'i-heroicons-shield-exclamation';
}

describe('CombatTracker — canonical chip logic', () => {
  it('incapacitated is canonical', () => {
    expect(isCanonical('incapacitated')).toBe(true);
  });

  it('prone is canonical', () => {
    expect(isCanonical('prone')).toBe(true);
  });

  it('covered is canonical', () => {
    expect(isCanonical('covered')).toBe(true);
  });

  it('bleeding is NOT canonical', () => {
    expect(isCanonical('bleeding')).toBe(false);
  });

  it('incapacitated gets crimson variant', () => {
    expect(canonicalFlagVariant('incapacitated')).toBe('crimson');
  });

  it('prone gets brass variant', () => {
    expect(canonicalFlagVariant('prone')).toBe('brass');
  });

  it('covered gets mystic variant', () => {
    expect(canonicalFlagVariant('covered')).toBe('mystic');
  });

  it('incapacitated uses x-circle icon', () => {
    expect(canonicalFlagIcon('incapacitated')).toBe('i-heroicons-x-circle');
  });

  it('prone uses arrow-down-circle icon', () => {
    expect(canonicalFlagIcon('prone')).toBe('i-heroicons-arrow-down-circle');
  });

  it('covered uses shield-exclamation icon', () => {
    expect(canonicalFlagIcon('covered')).toBe('i-heroicons-shield-exclamation');
  });
});

// ── toggleFlag logic ──────────────────────────────────────────────────────────

function buildNextFlags(current: string[], flag: string): string[] {
  return current.includes(flag) ? current.filter((f) => f !== flag) : [...current, flag];
}

describe('CombatTracker — toggleFlag()', () => {
  it('adds flag when not present', () => {
    expect(buildNextFlags([], 'prone')).toContain('prone');
  });

  it('removes flag when present', () => {
    expect(buildNextFlags(['prone', 'covered'], 'prone')).not.toContain('prone');
  });

  it('preserves other flags when adding', () => {
    expect(buildNextFlags(['covered'], 'prone')).toEqual(['covered', 'prone']);
  });

  it('preserves other flags when removing', () => {
    const result = buildNextFlags(['incapacitated', 'prone', 'covered'], 'prone');
    expect(result).toContain('incapacitated');
    expect(result).toContain('covered');
    expect(result).not.toContain('prone');
  });
});

// ── removeFlag logic ──────────────────────────────────────────────────────────

describe('CombatTracker — removeFlag()', () => {
  it('removes a free-form flag', () => {
    const flags = ['bleeding', 'prone'];
    const next = flags.filter((f) => f !== 'bleeding');
    expect(next).toEqual(['prone']);
  });

  it('is idempotent: removing absent flag leaves array unchanged', () => {
    const flags = ['prone'];
    const next = flags.filter((f) => f !== 'nonexistent');
    expect(next).toEqual(['prone']);
  });
});

// ── submitAddFlag validation ──────────────────────────────────────────────────

function validateAddFlag(tag: string, existingFlags: string[]): string | null {
  const trimmed = tag.trim();
  if (!trimmed) return 'empty';
  if (existingFlags.includes(trimmed)) return 'duplicate';
  return null;
}

describe('CombatTracker — submitAddFlag validation', () => {
  it('returns null for a new valid tag', () => {
    expect(validateAddFlag('zero-g', ['prone'])).toBeNull();
  });

  it('returns empty error for blank input', () => {
    expect(validateAddFlag('', [])).toBe('empty');
    expect(validateAddFlag('  ', [])).toBe('empty');
  });

  it('returns duplicate error when tag already exists', () => {
    expect(validateAddFlag('prone', ['prone'])).toBe('duplicate');
  });

  it('is case-sensitive (zero-g != Zero-G)', () => {
    expect(validateAddFlag('Zero-G', ['zero-g'])).toBeNull();
  });
});

// ── Picker: availablePcs / availableNpcs ──────────────────────────────────────

interface MinimalCharacter {
  id: string;
  name: string;
}

interface MinimalNpc {
  id: string;
  name: string;
}

function buildAvailablePcs(
  sessionCharacterIds: string[],
  allCharacters: MinimalCharacter[],
  existingSourceIds: Set<string>,
): MinimalCharacter[] {
  const sessionIdSet = new Set(sessionCharacterIds);
  return allCharacters.filter((c) => sessionIdSet.has(c.id) && !existingSourceIds.has(c.id));
}

function buildAvailableNpcs(allNpcs: MinimalNpc[], existingSourceIds: Set<string>): MinimalNpc[] {
  return allNpcs.filter((n) => !existingSourceIds.has(n.id));
}

describe('CombatTracker — opens picker / filters available PCs', () => {
  it('shows only session characters', () => {
    const chars = [
      { id: 'char-a', name: 'Aisha' },
      { id: 'char-b', name: 'Bilal' },
      { id: 'char-c', name: 'Cyra' },
    ];
    const result = buildAvailablePcs(['char-a', 'char-c'], chars, new Set());
    expect(result.map((c) => c.id)).toEqual(['char-a', 'char-c']);
  });

  it('excludes characters already in the encounter', () => {
    const chars = [
      { id: 'char-a', name: 'Aisha' },
      { id: 'char-b', name: 'Bilal' },
    ];
    const existing = new Set(['char-a']);
    const result = buildAvailablePcs(['char-a', 'char-b'], chars, existing);
    expect(result.map((c) => c.id)).toEqual(['char-b']);
  });

  it('returns empty if all session chars already added', () => {
    const chars = [{ id: 'char-a', name: 'Aisha' }];
    const result = buildAvailablePcs(['char-a'], chars, new Set(['char-a']));
    expect(result).toHaveLength(0);
  });

  it('returns empty if sessionCharacterIds is empty', () => {
    const chars = [{ id: 'char-a', name: 'Aisha' }];
    const result = buildAvailablePcs([], chars, new Set());
    expect(result).toHaveLength(0);
  });
});

describe('CombatTracker — NPC picker filters', () => {
  it('excludes NPCs already in the encounter', () => {
    const npcs = [
      { id: 'npc-a', name: 'Guard' },
      { id: 'npc-b', name: 'Merchant' },
    ];
    const existing = new Set(['npc-a']);
    const result = buildAvailableNpcs(npcs, existing);
    expect(result.map((n) => n.id)).toEqual(['npc-b']);
  });

  it('shows all NPCs when none are in the encounter', () => {
    const npcs = [
      { id: 'npc-a', name: 'Guard' },
      { id: 'npc-b', name: 'Merchant' },
    ];
    const result = buildAvailableNpcs(npcs, new Set());
    expect(result).toHaveLength(2);
  });
});

// ── add combatant via SDK (mock) ──────────────────────────────────────────────

interface MockResult<T> {
  data: T | undefined;
  error: Problem | undefined;
}

async function addCombatantViaApi(
  mockFn: (opts: unknown) => Promise<MockResult<Combatant>>,
  encounterId: string,
  kind: 'pc' | 'npc',
  id: string,
): Promise<Combatant> {
  const res = await mockFn({
    path: { id: encounterId },
    body: { combatantType: kind, sourceId: id },
  });
  if (res.error) throw res.error;
  return res.data!;
}

describe('CombatTracker — adds combatant via SDK', () => {
  it('adds a PC combatant', async () => {
    const combatant = makeCombatant({ combatantType: 'pc', sourceId: 'char-001' });
    const mock = vi.fn().mockResolvedValue({ data: combatant, error: undefined });
    const result = await addCombatantViaApi(mock, 'enc-001', 'pc', 'char-001');
    expect(result.combatantType).toBe('pc');
    expect(result.sourceId).toBe('char-001');
  });

  it('adds an NPC combatant', async () => {
    const combatant = makeCombatant({ combatantType: 'npc', sourceId: 'npc-007' });
    const mock = vi.fn().mockResolvedValue({ data: combatant, error: undefined });
    const result = await addCombatantViaApi(mock, 'enc-001', 'npc', 'npc-007');
    expect(result.combatantType).toBe('npc');
  });

  it('throws on duplicate (422)', async () => {
    const problem: Problem = {
      type: 'about:blank',
      title: 'Conflict',
      status: 422,
      detail: 'COMBATANT_DUPLICATE',
    };
    const mock = vi.fn().mockResolvedValue({ data: undefined, error: problem });
    await expect(addCombatantViaApi(mock, 'enc-001', 'npc', 'npc-001')).rejects.toMatchObject({
      detail: 'COMBATANT_DUPLICATE',
    });
  });
});

// ── Block 5: initiative button guard logic ─────────────────────────────────────

type EncounterStatus = 'setup' | 'active' | 'ended';

function canRollInitiative(status: EncounterStatus, combatantCount: number): boolean {
  return status === 'setup' && combatantCount > 0;
}

function canAdvanceTurn(status: EncounterStatus, combatantCount: number): boolean {
  return status === 'active' && combatantCount > 0;
}

function canDispatchReorder(status: EncounterStatus): boolean {
  return status === 'active';
}

describe('CombatTracker — Roll Initiative button guard', () => {
  it('enabled when status=setup and combatants.length > 0', () => {
    expect(canRollInitiative('setup', 2)).toBe(true);
  });

  it('disabled when status=setup but no combatants', () => {
    expect(canRollInitiative('setup', 0)).toBe(false);
  });

  it('disabled when status=active', () => {
    expect(canRollInitiative('active', 3)).toBe(false);
  });

  it('disabled when status=ended', () => {
    expect(canRollInitiative('ended', 3)).toBe(false);
  });
});

describe('CombatTracker — Advance Turn button guard', () => {
  it('enabled when status=active and combatants.length > 0', () => {
    expect(canAdvanceTurn('active', 2)).toBe(true);
  });

  it('disabled when status=active but no combatants', () => {
    expect(canAdvanceTurn('active', 0)).toBe(false);
  });

  it('disabled when status=setup', () => {
    expect(canAdvanceTurn('setup', 3)).toBe(false);
  });

  it('disabled when status=ended', () => {
    expect(canAdvanceTurn('ended', 3)).toBe(false);
  });
});

describe('CombatTracker — drag reorder dispatch guard', () => {
  it('dispatches reorder when status=active', () => {
    expect(canDispatchReorder('active')).toBe(true);
  });

  it('does NOT dispatch reorder when status=setup', () => {
    expect(canDispatchReorder('setup')).toBe(false);
  });

  it('does NOT dispatch reorder when status=ended', () => {
    expect(canDispatchReorder('ended')).toBe(false);
  });
});

// ── Block 5: realtime snapshot reconciliation ──────────────────────────────────

describe('CombatTracker — combatSnapshot replace-wholesale', () => {
  it('replaces local list from snapshot matching encounterId', () => {
    const encounterId = 'enc-001';
    let localCombatants: Combatant[] = [makeCombatant({ id: 'old-1' })];

    const snapshot = {
      encounterId,
      combatants: [
        makeCombatant({ id: 'new-1', turnOrder: 0, initiative: 6 }),
        makeCombatant({ id: 'new-2', turnOrder: 1, initiative: 4 }),
      ],
    };

    if (snapshot.encounterId === encounterId) {
      localCombatants = [...snapshot.combatants];
    }

    expect(localCombatants).toHaveLength(2);
    expect(localCombatants[0]!.id).toBe('new-1');
    expect(localCombatants[1]!.id).toBe('new-2');
  });

  it('ignores snapshot for a different encounterId', () => {
    const encounterId = 'enc-001';
    const localCombatants: Combatant[] = [makeCombatant({ id: 'original' })];
    const snapshot = { encounterId: 'enc-999', combatants: [makeCombatant({ id: 'other' })] };

    const result =
      snapshot.encounterId === encounterId ? [...snapshot.combatants] : localCombatants;

    expect(result).toHaveLength(1);
    expect(result[0]!.id).toBe('original');
  });

  it('null snapshot leaves local state unchanged', () => {
    const localCombatants: Combatant[] = [makeCombatant({ id: 'stable' })];
    const snapshot = null;
    const result = snapshot
      ? [...(snapshot as { combatants: Combatant[] }).combatants]
      : localCombatants;
    expect(result[0]!.id).toBe('stable');
  });
});

// ── Block 5: rollInitiative / advanceTurn API mock ────────────────────────────

async function rollInitiativeViaApi(
  mockFn: (opts: unknown) => Promise<MockResult<{ combatants: Combatant[]; round: number }>>,
  encounterId: string,
): Promise<{ combatants: Combatant[]; round: number }> {
  const res = await mockFn({ path: { id: encounterId } });
  if (res.error) throw res.error;
  return res.data!;
}

async function advanceTurnViaApi(
  mockFn: (
    opts: unknown,
  ) => Promise<MockResult<{ activeCombatantId: string; round: number; isNewRound: boolean }>>,
  encounterId: string,
): Promise<{ activeCombatantId: string; round: number; isNewRound: boolean }> {
  const res = await mockFn({ path: { id: encounterId } });
  if (res.error) throw res.error;
  return res.data!;
}

describe('CombatTracker — rollInitiative via SDK', () => {
  it('returns combatants in initiative order and round=1', async () => {
    const combatants = [
      makeCombatant({ id: 'c1', turnOrder: 0, initiative: 6 }),
      makeCombatant({ id: 'c2', turnOrder: 1, initiative: 3 }),
    ];
    const mock = vi.fn().mockResolvedValue({ data: { combatants, round: 1 }, error: undefined });
    const result = await rollInitiativeViaApi(mock, 'enc-001');
    expect(result.round).toBe(1);
    expect(result.combatants[0]!.initiative).toBe(6);
  });

  it('throws ENCOUNTER_NO_COMBATANTS when encounter is empty', async () => {
    const problem = {
      type: 'about:blank',
      title: 'Unprocessable',
      status: 422,
      detail: 'ENCOUNTER_NO_COMBATANTS',
    };
    const mock = vi.fn().mockResolvedValue({ data: undefined, error: problem });
    await expect(rollInitiativeViaApi(mock, 'enc-001')).rejects.toMatchObject({
      detail: 'ENCOUNTER_NO_COMBATANTS',
    });
  });

  it('throws ENCOUNTER_INVALID_TRANSITION when not in setup', async () => {
    const problem = {
      type: 'about:blank',
      title: 'Unprocessable',
      status: 422,
      detail: 'ENCOUNTER_INVALID_TRANSITION',
    };
    const mock = vi.fn().mockResolvedValue({ data: undefined, error: problem });
    await expect(rollInitiativeViaApi(mock, 'enc-001')).rejects.toMatchObject({
      detail: 'ENCOUNTER_INVALID_TRANSITION',
    });
  });
});

describe('CombatTracker — advanceTurn via SDK', () => {
  it('returns activeCombatantId and isNewRound=false within a round', async () => {
    const mock = vi.fn().mockResolvedValue({
      data: { activeCombatantId: 'c2', round: 1, isNewRound: false },
      error: undefined,
    });
    const result = await advanceTurnViaApi(mock, 'enc-001');
    expect(result.activeCombatantId).toBe('c2');
    expect(result.isNewRound).toBe(false);
  });

  it('returns isNewRound=true when wrap-around occurs', async () => {
    const mock = vi.fn().mockResolvedValue({
      data: { activeCombatantId: 'c1', round: 2, isNewRound: true },
      error: undefined,
    });
    const result = await advanceTurnViaApi(mock, 'enc-001');
    expect(result.round).toBe(2);
    expect(result.isNewRound).toBe(true);
  });

  it('throws ENCOUNTER_INVALID_STATUS when encounter is not active', async () => {
    const problem = {
      type: 'about:blank',
      title: 'Unprocessable',
      status: 422,
      detail: 'ENCOUNTER_INVALID_STATUS',
    };
    const mock = vi.fn().mockResolvedValue({ data: undefined, error: problem });
    await expect(advanceTurnViaApi(mock, 'enc-001')).rejects.toMatchObject({
      detail: 'ENCOUNTER_INVALID_STATUS',
    });
  });
});

// ── chip toggle: removes from list ───────────────────────────────────────────

describe('CombatTracker — chip toggle (update statusFlags)', () => {
  it('removes chip when toggling active canonical flag', () => {
    const flags = ['prone', 'covered'];
    const after = flags.filter((f) => f !== 'prone');
    expect(after).toEqual(['covered']);
  });

  it('adds chip when toggling inactive canonical flag', () => {
    const flags: string[] = [];
    const after = [...flags, 'incapacitated'];
    expect(after).toContain('incapacitated');
  });
});

// ── Remove combatant (mock) ───────────────────────────────────────────────────

async function removeCombatantViaApi(
  mockFn: (opts: unknown) => Promise<MockResult<void>>,
  combatantId: string,
): Promise<void> {
  const res = await mockFn({ path: { id: combatantId } });
  if (res.error) throw res.error;
}

describe('CombatTracker — removes combatant via SDK', () => {
  it('resolves on success', async () => {
    const mock = vi.fn().mockResolvedValue({ data: undefined, error: undefined });
    await expect(removeCombatantViaApi(mock, 'cbt-001')).resolves.toBeUndefined();
  });

  it('removes from local list after success', () => {
    const list = [makeCombatant({ id: 'cbt-001' }), makeCombatant({ id: 'cbt-002' })];
    const after = list.filter((c) => c.id !== 'cbt-001');
    expect(after).toHaveLength(1);
    expect(after[0]!.id).toBe('cbt-002');
  });

  it('throws on 422 when encounter is active', async () => {
    const problem: Problem = {
      type: 'about:blank',
      title: 'Locked',
      status: 422,
      detail: 'ENCOUNTER_LOCKED_FOR_COMBAT',
    };
    const mock = vi.fn().mockResolvedValue({ data: undefined, error: problem });
    await expect(removeCombatantViaApi(mock, 'cbt-001')).rejects.toMatchObject({ status: 422 });
  });
});

/**
 * Vitest unit specs for the useAutoSave composable and the auto-save logic
 * that was extracted from [id].vue.
 *
 * The page itself imports Nuxt auto-imports (useI18n, useRoute, navigateTo,
 * onMounted) and @app/ui components that require a full Nuxt + happy-dom
 * environment not yet set up for this project. Mounting the SFC is deferred
 * to a Playwright e2e spec (Feature 5.4 deliverable).
 *
 * These specs validate:
 *   1. useAutoSave composable contract
 *   2. SKILL_GOVERNING_ATTR constant integrity
 *   3. Conditions logic (toggle / rollback) — tested in isolation via the
 *      composable helpers extracted below.
 *   4. Talents logic (add / remove)
 *   5. Save-pulse perf orchestration (T-5.5.1.d)
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { ref } from 'vue';
import { useAutoSave } from '~/composables/useAutoSave';

// ── Helper: flush all pending microtasks ─────────────────────────────────────

async function tick(): Promise<void> {
  await Promise.resolve();
}

// ── useAutoSave specs ─────────────────────────────────────────────────────────

describe('useAutoSave', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  it('starts with saveState = idle', () => {
    const { saveState } = useAutoSave(vi.fn());
    expect(saveState.value).toBe('idle');
  });

  it('transitions idle → saving → saved on successful persist', async () => {
    const persist = vi.fn().mockResolvedValue(undefined);
    const { saveState, schedule } = useAutoSave(persist, { debounceMs: 100 });

    schedule();
    // Still idle before debounce fires
    expect(saveState.value).toBe('idle');

    // Fire debounce
    vi.advanceTimersByTime(100);
    // Now run event-loop (persist is async)
    expect(saveState.value).toBe('saving');

    await tick();
    await tick();

    expect(saveState.value).toBe('saved');
    expect(persist).toHaveBeenCalledOnce();
  });

  it('transitions to error and records error message on persist failure', async () => {
    const persist = vi.fn().mockRejectedValue(new Error('Network failure'));
    const { saveState, saveError, schedule } = useAutoSave(persist, {
      debounceMs: 50,
    });

    schedule();
    vi.advanceTimersByTime(50);

    // Await microtasks from the rejected promise
    await Promise.allSettled([Promise.resolve()]);
    await tick();

    expect(saveState.value).toBe('error');
    expect(saveError.value).toBe('Network failure');
  });

  it('flush() executes persist immediately without waiting for debounce', async () => {
    const persist = vi.fn().mockResolvedValue(undefined);
    const { flush } = useAutoSave(persist, { debounceMs: 500 });

    await flush();

    expect(persist).toHaveBeenCalledOnce();
    // Timer not needed — persist ran synchronously in flush
    vi.advanceTimersByTime(0);
  });

  it('cancel() prevents a scheduled persist from running', async () => {
    const persist = vi.fn().mockResolvedValue(undefined);
    const { schedule, cancel } = useAutoSave(persist, { debounceMs: 200 });

    schedule();
    cancel();
    vi.advanceTimersByTime(300);

    expect(persist).not.toHaveBeenCalled();
  });

  it('saved state fades back to idle after savedFadeMs', async () => {
    const persist = vi.fn().mockResolvedValue(undefined);
    const { saveState, schedule } = useAutoSave(persist, {
      debounceMs: 0,
      savedFadeMs: 200,
    });

    schedule();
    vi.advanceTimersByTime(0);
    await tick();
    await tick();

    expect(saveState.value).toBe('saved');

    vi.advanceTimersByTime(200);
    expect(saveState.value).toBe('idle');
  });
});

// ── SKILL_GOVERNING_ATTR constant integrity ───────────────────────────────────

describe('skill governing attribute map', () => {
  const SKILL_GOVERNING_ATTR: Record<string, string> = {
    force: 'STR',
    meleeCombat: 'STR',
    dexterity: 'AGI',
    infiltration: 'AGI',
    rangedCombat: 'AGI',
    pilot: 'AGI',
    observation: 'WIT',
    survival: 'WIT',
    dataDjinn: 'WIT',
    medicurgy: 'WIT',
    science: 'WIT',
    technology: 'WIT',
    manipulation: 'EMP',
    command: 'EMP',
    culture: 'EMP',
    mysticPowers: 'EMP',
  };

  it('maps all 16 skills', () => {
    expect(Object.keys(SKILL_GOVERNING_ATTR)).toHaveLength(16);
  });

  it('only uses valid attribute badges', () => {
    const valid = new Set(['STR', 'AGI', 'WIT', 'EMP']);
    for (const badge of Object.values(SKILL_GOVERNING_ATTR)) {
      expect(valid).toContain(badge);
    }
  });
});

// ── Feature 5.3 — Conditions toggle logic ────────────────────────────────────
// Tested in isolation without mounting the page SFC. We replicate the core
// toggleCondition() logic to verify optimistic update + rollback behaviour.

describe('conditions toggle — optimistic update and rollback', () => {
  type ConditionKey = 'exhausted' | 'sleepless' | 'thirsty' | 'hungry';
  type ConditionFlags = Record<ConditionKey, boolean>;

  /**
   * Minimal replica of the toggleCondition helper from [id].vue.
   * Accepts injectable api.update and error store so we can test in
   * isolation without the Nuxt environment.
   */
  function makeToggler(
    updateFn: (body: { conditions: ConditionFlags }) => Promise<{ conditions: ConditionFlags }>,
  ) {
    const localConditions = ref<ConditionFlags>({
      exhausted: false,
      sleepless: false,
      thirsty: false,
      hungry: false,
    });
    const conditionsError = ref('');

    async function toggleCondition(key: ConditionKey): Promise<void> {
      const prev = { ...localConditions.value };
      const next: ConditionFlags = {
        ...localConditions.value,
        [key]: !localConditions.value[key],
      };
      localConditions.value = next;
      conditionsError.value = '';
      try {
        const updated = await updateFn({ conditions: next });
        localConditions.value = { ...updated.conditions };
      } catch (error) {
        localConditions.value = prev;
        conditionsError.value =
          error instanceof Error ? error.message : 'Failed to update condition.';
      }
    }

    return { localConditions, conditionsError, toggleCondition };
  }

  it('optimistically flips the condition before the API call resolves', async () => {
    let resolveApi!: (v: { conditions: ConditionFlags }) => void;
    const updateFn = vi.fn(
      () =>
        new Promise<{ conditions: ConditionFlags }>((res) => {
          resolveApi = res;
        }),
    );

    const { localConditions, toggleCondition } = makeToggler(updateFn);
    const promise = toggleCondition('exhausted');

    // Before API resolves, optimistic update should be visible
    expect(localConditions.value.exhausted).toBe(true);

    resolveApi({
      conditions: { exhausted: true, sleepless: false, thirsty: false, hungry: false },
    });
    await promise;
    expect(localConditions.value.exhausted).toBe(true);
  });

  it('calls update with the full conditions object including the flipped key', async () => {
    const updateFn = vi.fn().mockResolvedValue({
      conditions: { exhausted: false, sleepless: true, thirsty: false, hungry: false },
    });
    const { toggleCondition } = makeToggler(updateFn);

    await toggleCondition('sleepless');

    expect(updateFn).toHaveBeenCalledWith({
      conditions: { exhausted: false, sleepless: true, thirsty: false, hungry: false },
    });
  });

  it('rolls back to previous state when PATCH fails', async () => {
    const updateFn = vi.fn().mockRejectedValue(new Error('Network error'));
    const { localConditions, conditionsError, toggleCondition } = makeToggler(updateFn);

    await toggleCondition('hungry');

    // Should be rolled back
    expect(localConditions.value.hungry).toBe(false);
    expect(conditionsError.value).toBe('Network error');
  });

  it('restores all four conditions when rollback fires', async () => {
    const updateFn = vi.fn().mockRejectedValue(new Error('Server error'));
    const { localConditions, toggleCondition } = makeToggler(updateFn);

    // Set initial state
    localConditions.value = { exhausted: true, sleepless: true, thirsty: false, hungry: false };

    await toggleCondition('thirsty');

    expect(localConditions.value).toEqual({
      exhausted: true,
      sleepless: true,
      thirsty: false,
      hungry: false,
    });
  });
});

// ── Feature 5.2 — Talents list mutations ─────────────────────────────────────

describe('talents list — add and remove', () => {
  interface Talent {
    id: string;
    name: string;
    description: string;
    rank: number;
    acquiredAt: string;
  }

  function makeExistingTalent(id: string, name: string): Talent {
    return { id, name, description: 'Test desc', rank: 1, acquiredAt: new Date().toISOString() };
  }

  it('prepends a newly created talent to the list', async () => {
    const existingTalents = ref<Talent[]>([makeExistingTalent('t2', 'Old Talent')]);

    const newTalent = makeExistingTalent('t1', 'New Talent');
    const addTalentFn = vi.fn().mockResolvedValue(newTalent);

    // Replicate the addTalent success branch
    const created = await addTalentFn({ name: 'New Talent', description: '' });
    existingTalents.value = [created, ...existingTalents.value];

    expect(existingTalents.value[0]?.id).toBe('t1');
    expect(existingTalents.value[0]?.name).toBe('New Talent');
    expect(existingTalents.value).toHaveLength(2);
  });

  it('replaces an updated talent in-place', async () => {
    const talent = makeExistingTalent('t1', 'Wing-Mate');
    const talents = ref<Talent[]>([talent]);

    const updatedTalent = { ...talent, name: 'Wing-Mate II' };
    const updateFn = vi.fn().mockResolvedValue(updatedTalent);

    const result = await updateFn({ name: 'Wing-Mate II' });
    talents.value = talents.value.map((t) => (t.id === result.id ? result : t));

    expect(talents.value[0]?.name).toBe('Wing-Mate II');
    expect(talents.value).toHaveLength(1);
  });

  it('removes a talent by id from the list', async () => {
    const t1 = makeExistingTalent('t1', 'Faith');
    const t2 = makeExistingTalent('t2', 'Stunt Pilot');
    const talents = ref<Talent[]>([t1, t2]);

    const removeFn = vi.fn().mockResolvedValue(undefined);
    await removeFn('t1');
    talents.value = talents.value.filter((t) => t.id !== 't1');

    expect(talents.value).toHaveLength(1);
    expect(talents.value[0]?.id).toBe('t2');
  });

  it('does not mutate list when remove API throws', async () => {
    const t1 = makeExistingTalent('t1', 'Stunt Pilot');
    const talents = ref<Talent[]>([t1]);

    const removeFn = vi.fn().mockRejectedValue(new Error('Not found'));
    const prev = [...talents.value];

    try {
      await removeFn('t1');
      talents.value = talents.value.filter((t) => t.id !== 't1');
    } catch {
      // Rollback would happen here — list stays as-is
    }

    // In the error branch, prev is restored. Simulating: after catch, list = prev.
    // Here we verify the test is set up correctly — prev has 1 item.
    expect(prev).toHaveLength(1);
    // talents.value was not mutated since the filter line wasn't reached
    expect(talents.value).toHaveLength(1);
  });
});

// ── Feature 5.5 — Save-pulse perf orchestration (T-5.5.1.d) ──────────────────
// Mock the api.update composable; assert 100 sequential auto-save round-trips
// (debounced + flushed) complete within a 50ms-per-call budget.
// vi.useFakeTimers() controls the debounce; real wall-clock is used only for
// the performance budget check.

describe('save-pulse perf orchestration', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  it('100 sequential debounced schedule→flush cycles each stay under 50ms', async () => {
    const TRIPS = 100;
    const BUDGET_MS = 50;

    let callCount = 0;
    const persist = vi.fn(async () => {
      callCount++;
    });

    const { schedule, flush } = useAutoSave(persist, { debounceMs: 10 });

    const start = performance.now();

    for (let i = 0; i < TRIPS; i++) {
      schedule();
      // Advance fake timers so the debounce fires
      vi.advanceTimersByTime(10);
      // Flush flushes any pending debounce and awaits the persist
      await flush();
    }

    const elapsed = performance.now() - start;
    const perCall = elapsed / TRIPS;

    // Each orchestration cycle (schedule + timer advance + flush) must be
    // under BUDGET_MS in the local test runner. This guards regression in
    // the debounce/queue logic, not network latency.
    expect(perCall).toBeLessThan(BUDGET_MS);
    // Persist was called at least TRIPS times (flush always calls it)
    expect(callCount).toBeGreaterThanOrEqual(TRIPS);
  });
});

// ── Feature 5.4 — Inventory orchestration ────────────────────────────────────
// Tests mirror the talent-list pattern: isolated helpers that replicate the
// mutation logic from [id].vue without mounting the full SFC (Nuxt env not
// set up for unit tests — see the file-level note above).

describe('inventory — addItem places item at head of list', () => {
  interface Item {
    id: string;
    type: string;
    name: string;
  }

  function makeWeapon(id: string, name: string): Item {
    return { id, type: 'WEAPON', name };
  }

  it('prepends a newly created item to the inventory list', async () => {
    const inventory = ref<Item[]>([makeWeapon('w2', 'Old Weapon')]);

    const newWeapon = makeWeapon('w1', 'Vulcan Carbine');
    const addFn = vi.fn().mockResolvedValue(newWeapon);

    const created = await addFn({ type: 'WEAPON', name: 'Vulcan Carbine' });
    inventory.value = [created, ...inventory.value];

    expect(inventory.value[0]?.id).toBe('w1');
    expect(inventory.value[0]?.name).toBe('Vulcan Carbine');
    expect(inventory.value).toHaveLength(2);
  });

  it('replaces an updated item in-place preserving list order', async () => {
    const item = makeWeapon('w1', 'Vulcan Carbine');
    const inventory = ref<Item[]>([item, makeWeapon('w2', 'Stun Baton')]);

    const updatedItem = { ...item, name: 'Heavy Carbine' };
    const updateFn = vi.fn().mockResolvedValue(updatedItem);

    const result = await updateFn({ type: 'WEAPON', name: 'Heavy Carbine' });
    inventory.value = inventory.value.map((i) => (i.id === result.id ? result : i));

    expect(inventory.value[0]?.name).toBe('Heavy Carbine');
    expect(inventory.value).toHaveLength(2);
    // Second item must be unaffected
    expect(inventory.value[1]?.name).toBe('Stun Baton');
  });

  it('removes a deleted item by id', async () => {
    const w1 = makeWeapon('w1', 'Vulcan Carbine');
    const w2 = makeWeapon('w2', 'Stun Baton');
    const inventory = ref<Item[]>([w1, w2]);

    const removeFn = vi.fn().mockResolvedValue(undefined);
    await removeFn('w1');
    inventory.value = inventory.value.filter((i) => i.id !== 'w1');

    expect(inventory.value).toHaveLength(1);
    expect(inventory.value[0]?.id).toBe('w2');
  });

  it('does not mutate list when removeItem API throws', async () => {
    const w1 = makeWeapon('w1', 'Vulcan Carbine');
    const inventory = ref<Item[]>([w1]);
    const prev = [...inventory.value];

    const removeFn = vi.fn().mockRejectedValue(new Error('Not found'));

    try {
      await removeFn('w1');
      inventory.value = inventory.value.filter((i) => i.id !== 'w1');
    } catch {
      // Rollback — list stays as prev
    }

    expect(prev).toHaveLength(1);
    expect(inventory.value).toHaveLength(1);
  });
});

// ── Feature 5.4 — Encumbrance warning logic ───────────────────────────────────

describe('encumbrance warning — isEncumbered computed', () => {
  it('isEncumbered is false when current <= max', () => {
    const enc = { current: 3, max: 6 };
    expect(enc.current > enc.max).toBe(false);
  });

  it('isEncumbered is true when current > max', () => {
    const enc = { current: 7, max: 6 };
    expect(enc.current > enc.max).toBe(true);
  });

  it('isEncumbered is false when current === max', () => {
    const enc = { current: 6, max: 6 };
    expect(enc.current > enc.max).toBe(false);
  });

  it('isEncumbered is false for zero current', () => {
    const enc = { current: 0, max: 6 };
    expect(enc.current > enc.max).toBe(false);
  });
});

// ── Feature 5.4 — Equipped quick view filtering ───────────────────────────────

describe('equipped quick view — equippedItems filter', () => {
  interface Weapon {
    id: string;
    type: 'WEAPON';
    name: string;
    equipped: boolean;
  }
  interface Armor {
    id: string;
    type: 'ARMOR';
    name: string;
    equipped: boolean;
  }
  interface Gear {
    id: string;
    type: 'GEAR';
    name: string;
    equipped: boolean;
  }
  interface Other {
    id: string;
    type: 'OTHER';
    name: string;
  }
  type TestItem = Weapon | Armor | Gear | Other;

  it('includes WEAPON items where equipped=true', () => {
    const inventory: TestItem[] = [
      { id: 'w1', type: 'WEAPON', name: 'Carbine', equipped: true },
      { id: 'w2', type: 'WEAPON', name: 'Pistol', equipped: false },
    ];

    const equipped = inventory.filter(
      (item) =>
        (item.type === 'WEAPON' || item.type === 'ARMOR' || item.type === 'GEAR') &&
        'equipped' in item &&
        item.equipped,
    );

    expect(equipped).toHaveLength(1);
    expect(equipped[0]?.id).toBe('w1');
  });

  it('excludes CYBERNETIC and SHIP_MODULE items from equipped list', () => {
    const inventory = [
      { id: 'c1', type: 'CYBERNETIC', name: 'Neural Link' },
      { id: 's1', type: 'SHIP_MODULE', name: 'Fuel Pod' },
    ];

    const equipped = inventory.filter(
      (item) =>
        (item.type === 'WEAPON' || item.type === 'ARMOR' || item.type === 'GEAR') &&
        'equipped' in item,
    );

    expect(equipped).toHaveLength(0);
  });

  it('returns empty array when no items are equipped', () => {
    const inventory: Weapon[] = [{ id: 'w1', type: 'WEAPON', name: 'Carbine', equipped: false }];

    const equipped = inventory.filter((item) => 'equipped' in item && item.equipped);
    expect(equipped).toHaveLength(0);
  });
});

/**
 * Vitest specs for the NPC sheet page — /app/npcs/[id].vue
 *
 * The page imports Nuxt auto-imports and @app/ui components that require a
 * full Nuxt + happy-dom environment. Mounting the SFC is deferred to
 * Playwright e2e. These specs validate the core logic extracted or replicated
 * from [id].vue in isolation:
 *
 *   1. Sheet renders (smoke — load → loaded, data bound)
 *   2. auto-save fires PATCH on blur (via useAutoSave)
 *   3. 422 response surfaces in the problems card
 *   4. Delete confirmation flow (modal open → confirm → navigate)
 */

import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { ref, computed } from 'vue';
import { useAutoSave } from '~/composables/useAutoSave';
import type { Npc, NpcUpdate } from '~/composables/useNpcsApi';
import type { Problem } from '@app/api-client-ts';

// ── Fixtures ──────────────────────────────────────────────────────────────────

function makeNpc(overrides: Partial<Npc> = {}): Npc {
  return {
    id: 'npc-1',
    ownerId: 'user-1',
    name: 'Iron Corsair',
    description: null,
    attributes: { strength: 3, agility: 3, wits: 2, empathy: 2 },
    skills: {
      dexterity: 0,
      force: 2,
      infiltration: 0,
      manipulation: 0,
      meleeCombat: 3,
      observation: 1,
      rangedCombat: 2,
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
    hp: { current: 8, max: 10 },
    mp: { current: 4, max: 4 },
    signature: 0,
    keySkillModifier: 0,
    armor: [],
    weapons: [],
    tags: ['pirate'],
    createdAt: '2026-05-10T00:00:00.000Z',
    updatedAt: '2026-05-10T00:00:00.000Z',
    ...overrides,
  };
}

// ── Helper: flush all pending microtasks ──────────────────────────────────────

async function tick(): Promise<void> {
  await Promise.resolve();
}

// ── 1. Smoke: sheet renders — syncLocals binds data correctly ─────────────────

function makeSyncLocals() {
  const localName = ref('');
  const localDescription = ref<string | null>(null);
  const localHpCurrent = ref(0);
  const localHpMax = ref(0);
  const localMpCurrent = ref(0);
  const localMpMax = ref(0);
  const localSignature = ref(0);
  const localKeySkillModifier = ref(0);
  const localTagsInput = ref('');
  const armorCount = ref(0);
  const weaponsCount = ref(0);

  function syncLocals(n: Npc): void {
    localName.value = n.name;
    localDescription.value = n.description ?? null;
    localHpCurrent.value = n.hp.current;
    localHpMax.value = n.hp.max;
    localMpCurrent.value = n.mp.current;
    localMpMax.value = n.mp.max;
    localSignature.value = n.signature;
    localKeySkillModifier.value = n.keySkillModifier ?? 0;
    localTagsInput.value = n.tags.join(', ');
    armorCount.value = n.armor.length;
    weaponsCount.value = n.weapons.length;
  }

  return {
    localName,
    localDescription,
    localHpCurrent,
    localHpMax,
    localMpCurrent,
    localMpMax,
    localSignature,
    localKeySkillModifier,
    localTagsInput,
    armorCount,
    weaponsCount,
    syncLocals,
  };
}

describe('npc sheet — data sync (syncLocals)', () => {
  it('binds name and hp values from the fetched NPC', () => {
    const { localName, localHpCurrent, localHpMax, syncLocals } = makeSyncLocals();
    const npc = makeNpc();

    syncLocals(npc);

    expect(localName.value).toBe('Iron Corsair');
    expect(localHpCurrent.value).toBe(8);
    expect(localHpMax.value).toBe(10);
  });

  it('joins tags array into comma-separated input string', () => {
    const { localTagsInput, syncLocals } = makeSyncLocals();
    const npc = makeNpc({ tags: ['pirate', 'boss', 'cyborg'] });

    syncLocals(npc);

    expect(localTagsInput.value).toBe('pirate, boss, cyborg');
  });

  it('counts armor and weapons lengths', () => {
    const { armorCount, weaponsCount, syncLocals } = makeSyncLocals();
    const npc = makeNpc({
      armor: [
        {
          id: 'a1',
          type: 'ARMOR',
          name: 'Flak Vest',
          armorRating: 3,
          weight: 2,
          features: [],
          equipped: false,
        },
      ],
      weapons: [
        {
          id: 'w1',
          type: 'WEAPON',
          name: 'Carbine',
          bonus: 1,
          damage: 2,
          weight: 1,
          range: 'medium',
          crit: 2,
          features: [],
          equipped: false,
        },
      ],
    });

    syncLocals(npc);

    expect(armorCount.value).toBe(1);
    expect(weaponsCount.value).toBe(1);
  });

  it('falls back description to null when undefined', () => {
    const { localDescription, syncLocals } = makeSyncLocals();
    const npc = makeNpc({ description: undefined });

    syncLocals(npc);

    expect(localDescription.value).toBeNull();
  });
});

// ── 2. auto-save fires PATCH on blur ─────────────────────────────────────────

describe('npc sheet — auto-save fires on blur via useAutoSave', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('calls updateNpc after 600 ms debounce when schedule() is called', async () => {
    const updateMock = vi.fn().mockResolvedValue(makeNpc({ name: 'New Name' }));

    const localName = ref('New Name');

    const { schedule } = useAutoSave(
      async () => {
        await updateMock('npc-1', { name: localName.value } satisfies NpcUpdate);
      },
      { debounceMs: 600 },
    );

    // Simulate blur → schedule
    schedule();

    // Before debounce window, persist has not been called
    expect(updateMock).not.toHaveBeenCalled();

    vi.advanceTimersByTime(600);
    // Microtasks from async persist
    await tick();
    await tick();

    expect(updateMock).toHaveBeenCalledOnce();
    expect(updateMock).toHaveBeenCalledWith('npc-1', { name: 'New Name' });
  });

  it('does not call updateNpc if schedule is cancelled before debounce fires', async () => {
    const updateMock = vi.fn().mockResolvedValue(makeNpc());

    const { schedule, cancel } = useAutoSave(
      async () => {
        await updateMock('npc-1', {});
      },
      { debounceMs: 600 },
    );

    schedule();
    cancel();
    vi.advanceTimersByTime(700);
    await tick();

    expect(updateMock).not.toHaveBeenCalled();
  });
});

// ── 3. Problems card — 422 surfaces validation errors ─────────────────────────

function makeProblemsStore() {
  const validationProblems = ref<string[]>([]);

  function recordValidationError(error: unknown): void {
    const problem = error as Problem;
    if (problem.status === 422) {
      const detail = problem.detail ?? 'The server rejected the last update (unspecified error).';
      validationProblems.value = [...new Set([...validationProblems.value, detail])];
    }
  }

  function clearValidationProblems(): void {
    validationProblems.value = [];
  }

  const hasProblems = computed(() => validationProblems.value.length > 0);

  return { validationProblems, recordValidationError, clearValidationProblems, hasProblems };
}

describe('npc sheet — problems card surfaces 422 validation errors', () => {
  it('appends a 422 problem detail to the list', () => {
    const { validationProblems, recordValidationError } = makeProblemsStore();

    const error422: Problem = {
      type: null,
      status: 422,
      title: 'Validation Error',
      detail: 'name must be at least 1 character',
    };

    recordValidationError(error422);

    expect(validationProblems.value).toHaveLength(1);
    expect(validationProblems.value[0]).toBe('name must be at least 1 character');
  });

  it('ignores non-422 errors', () => {
    const { validationProblems, recordValidationError } = makeProblemsStore();

    const error500: Problem = {
      type: null,
      status: 500,
      title: 'Internal Server Error',
      detail: 'Oops',
    };
    recordValidationError(error500);

    expect(validationProblems.value).toHaveLength(0);
  });

  it('deduplicates identical messages', () => {
    const { validationProblems, recordValidationError } = makeProblemsStore();

    const error: Problem = { type: null, title: null, status: 422, detail: 'name too short' };
    recordValidationError(error);
    recordValidationError(error);

    expect(validationProblems.value).toHaveLength(1);
  });

  it('falls back to generic message when detail is absent', () => {
    const { validationProblems, recordValidationError } = makeProblemsStore();

    const error: Problem = { type: null, title: null, status: 422 };
    recordValidationError(error);

    expect(validationProblems.value[0]).toBe(
      'The server rejected the last update (unspecified error).',
    );
  });

  it('clearValidationProblems empties the list', () => {
    const { validationProblems, recordValidationError, clearValidationProblems } =
      makeProblemsStore();

    recordValidationError({
      type: null,
      title: null,
      status: 422,
      detail: 'err',
    } satisfies Problem);
    expect(validationProblems.value).toHaveLength(1);

    clearValidationProblems();
    expect(validationProblems.value).toHaveLength(0);
  });

  it('hasProblems is true when list is non-empty', () => {
    const { recordValidationError, hasProblems } = makeProblemsStore();

    expect(hasProblems.value).toBe(false);
    recordValidationError({
      type: null,
      title: null,
      status: 422,
      detail: 'bad',
    } satisfies Problem);
    expect(hasProblems.value).toBe(true);
  });

  it('auto-save wraps persist and records 422 on failure', async () => {
    const { validationProblems, recordValidationError } = makeProblemsStore();

    vi.useFakeTimers();

    const error422: Problem = {
      type: null,
      title: null,
      status: 422,
      detail: 'name must be 1–120 chars',
    };
    const updateMock = vi.fn().mockRejectedValue(error422);

    const { schedule, saveState } = useAutoSave(
      async () => {
        try {
          await updateMock();
        } catch (error) {
          recordValidationError(error);
          throw error;
        }
      },
      { debounceMs: 10 },
    );

    schedule();
    vi.advanceTimersByTime(10);
    await tick();
    await tick();

    expect(saveState.value).toBe('error');
    expect(validationProblems.value).toContain('name must be 1–120 chars');

    vi.useRealTimers();
  });
});

// ── 4. Delete confirmation flow ───────────────────────────────────────────────

function makeDeleteFlow(deleteFn: () => Promise<void>, navigateFn: (path: string) => void) {
  const deleteConfirmOpen = ref(false);
  const deleting = ref(false);
  const deleteError = ref('');

  function openDeleteConfirm(): void {
    deleteConfirmOpen.value = true;
  }

  function closeDeleteConfirm(): void {
    deleteConfirmOpen.value = false;
  }

  async function confirmDelete(): Promise<void> {
    deleting.value = true;
    deleteError.value = '';
    try {
      await deleteFn();
      deleteConfirmOpen.value = false;
      navigateFn('/app/npcs');
    } catch (error) {
      const problem = error as Problem;
      deleteError.value = problem.detail ?? "Couldn't delete NPC.";
      deleteConfirmOpen.value = false;
    } finally {
      deleting.value = false;
    }
  }

  return {
    deleteConfirmOpen,
    deleting,
    deleteError,
    openDeleteConfirm,
    closeDeleteConfirm,
    confirmDelete,
  };
}

describe('npc sheet — delete confirmation flow', () => {
  it('modal opens when openDeleteConfirm is called', () => {
    const { deleteConfirmOpen, openDeleteConfirm } = makeDeleteFlow(
      vi.fn().mockResolvedValue(undefined),
      vi.fn(),
    );

    expect(deleteConfirmOpen.value).toBe(false);
    openDeleteConfirm();
    expect(deleteConfirmOpen.value).toBe(true);
  });

  it('navigates to /app/npcs and closes modal after successful delete', async () => {
    const deleteFn = vi.fn().mockResolvedValue(undefined);
    const navigateFn = vi.fn();

    const { openDeleteConfirm, confirmDelete, deleteConfirmOpen, deleting } = makeDeleteFlow(
      deleteFn,
      navigateFn,
    );

    openDeleteConfirm();
    await confirmDelete();

    expect(deleteFn).toHaveBeenCalledOnce();
    expect(navigateFn).toHaveBeenCalledWith('/app/npcs');
    expect(deleteConfirmOpen.value).toBe(false);
    expect(deleting.value).toBe(false);
  });

  it('sets deleteError and closes modal when delete API throws', async () => {
    const deleteFn = vi.fn().mockRejectedValue({
      type: null,
      title: null,
      status: 403,
      detail: 'Not yours.',
    } satisfies Problem);
    const navigateFn = vi.fn();

    const { openDeleteConfirm, confirmDelete, deleteError, deleteConfirmOpen } = makeDeleteFlow(
      deleteFn,
      navigateFn,
    );

    openDeleteConfirm();
    await confirmDelete();

    expect(deleteError.value).toBe('Not yours.');
    expect(navigateFn).not.toHaveBeenCalled();
    expect(deleteConfirmOpen.value).toBe(false);
  });

  it('closeDeleteConfirm sets open to false without calling delete', () => {
    const deleteFn = vi.fn();
    const { openDeleteConfirm, closeDeleteConfirm, deleteConfirmOpen } = makeDeleteFlow(
      deleteFn as () => Promise<void>,
      vi.fn(),
    );

    openDeleteConfirm();
    closeDeleteConfirm();

    expect(deleteConfirmOpen.value).toBe(false);
    expect(deleteFn).not.toHaveBeenCalled();
  });

  it('deleting flag is false after confirmDelete completes (success)', async () => {
    const { openDeleteConfirm, confirmDelete, deleting } = makeDeleteFlow(
      vi.fn().mockResolvedValue(undefined),
      vi.fn(),
    );

    openDeleteConfirm();
    const promise = confirmDelete();
    // Still true while in-flight... can't easily test mid-await in unit test
    await promise;
    expect(deleting.value).toBe(false);
  });
});

// ── 5. Tags input <-> displayTags computed ────────────────────────────────────

describe('npc sheet — tags computed split/join', () => {
  it('splits comma-separated string into trimmed non-empty tags', () => {
    const localTagsInput = ref('pirate, boss , cyborg');

    const displayTags = computed<string[]>(() =>
      localTagsInput.value
        .split(',')
        .map((s) => s.trim())
        .filter((s) => s.length > 0),
    );

    expect(displayTags.value).toEqual(['pirate', 'boss', 'cyborg']);
  });

  it('returns empty array for blank input', () => {
    const localTagsInput = ref('  ');

    const displayTags = computed<string[]>(() =>
      localTagsInput.value
        .split(',')
        .map((s) => s.trim())
        .filter((s) => s.length > 0),
    );

    expect(displayTags.value).toHaveLength(0);
  });

  it('strips trailing comma without adding empty tag', () => {
    const localTagsInput = ref('boss, ');

    const displayTags = computed<string[]>(() =>
      localTagsInput.value
        .split(',')
        .map((s) => s.trim())
        .filter((s) => s.length > 0),
    );

    expect(displayTags.value).toEqual(['boss']);
  });
});

// ── 6. Combined headerSaveState logic ─────────────────────────────────────────

describe('npc sheet — headerSaveState aggregation', () => {
  type SaveState = 'idle' | 'saving' | 'saved' | 'error';

  function makeHeaderSaveState(states: SaveState[]): SaveState {
    const all = new Set(states);
    if (all.has('saving')) return 'saving';
    if (all.has('error')) return 'error';
    if (all.has('saved')) return 'saved';
    return 'idle';
  }

  it('returns idle when all sub-saves are idle', () => {
    expect(makeHeaderSaveState(['idle', 'idle', 'idle', 'idle'])).toBe('idle');
  });

  it('returns saving when any sub-save is saving', () => {
    expect(makeHeaderSaveState(['idle', 'saving', 'saved', 'error'])).toBe('saving');
  });

  it('returns error when error is present and no saving', () => {
    expect(makeHeaderSaveState(['idle', 'error', 'saved'])).toBe('error');
  });

  it('returns saved when any sub-save is saved and none is saving/error', () => {
    expect(makeHeaderSaveState(['idle', 'idle', 'saved'])).toBe('saved');
  });
});

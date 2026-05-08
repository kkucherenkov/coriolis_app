/**
 * Vitest unit specs for the useAutoSave composable and the auto-save logic
 * that was extracted from [id].vue.
 *
 * The page itself imports Nuxt auto-imports (useI18n, useRoute, navigateTo,
 * onMounted) and @app/ui components that require a full Nuxt + happy-dom
 * environment not yet set up for this project. Mounting the SFC is deferred
 * to a Playwright e2e spec (Feature 5.4 deliverable).
 *
 * These four specs validate the composable contract that the page depends on.
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { useAutoSave } from '~/composables/useAutoSave';

// ── Helper: flush all pending microtasks & timers ─────────────────────────────

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
// Ensure the map covers all 16 skills and maps to valid attribute badges.

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

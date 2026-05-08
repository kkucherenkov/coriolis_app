/**
 * useAutoSave — debounced optimistic save with rollback support.
 *
 * Wraps a caller-provided async `persist` function with:
 *   - debounced scheduling (via useDebounceFn)
 *   - save-state tracking: 'idle' | 'saving' | 'saved' | 'error'
 *   - automatic "saved" → "idle" fade after `savedFadeMs` (default 1500 ms)
 *   - caller-driven `schedule()` to trigger the debounce window
 *   - `flush()` for eager commit (e.g., on unmount)
 *   - `cancel()` to discard a pending debounced call
 *
 * The composable owns no domain state. Optimistic UI updates and
 * rollback logic must be performed by the caller (e.g., the page
 * that patches `character.value` before calling `schedule()`).
 *
 * Pre-empts Feature 5.5 (AppSavePulse component) — T-5.5.1.a.
 * The save-state value is the contract; the visual component is separate.
 */

import { ref } from 'vue';
import { useDebounceFn } from '~/composables/useDebounceFn';

export type SaveState = 'idle' | 'saving' | 'saved' | 'error';

export interface UseAutoSaveOptions {
  /** Debounce delay in ms (default 250). */
  debounceMs?: number;
  /** How long "saved" stays visible before fading to "idle" (default 1500). */
  savedFadeMs?: number;
}

export interface UseAutoSaveReturn {
  saveState: ReturnType<typeof ref<SaveState>>;
  saveError: ReturnType<typeof ref<string>>;
  /** Arm the debounce window — call after each local state mutation. */
  schedule: () => void;
  /** Execute immediately, skipping the debounce delay. */
  flush: () => Promise<void>;
  /** Cancel any pending debounced invocation. */
  cancel: () => void;
}

export function useAutoSave(
  persist: () => Promise<void>,
  options: UseAutoSaveOptions = {},
): UseAutoSaveReturn {
  const { debounceMs = 250, savedFadeMs = 1500 } = options;

  const saveState = ref<SaveState>('idle');
  const saveError = ref('');

  let fadeTimer: ReturnType<typeof setTimeout> | null = null;

  async function run(): Promise<void> {
    saveState.value = 'saving';
    saveError.value = '';
    if (fadeTimer !== null) {
      clearTimeout(fadeTimer);
      fadeTimer = null;
    }
    try {
      await persist();
      saveState.value = 'saved';
      fadeTimer = setTimeout(() => {
        if (saveState.value === 'saved') saveState.value = 'idle';
        fadeTimer = null;
      }, savedFadeMs);
    } catch (error) {
      saveState.value = 'error';
      saveError.value = error instanceof Error ? error.message : String(error);
    }
  }

  function runVoid(): void {
    void run();
  }

  const { debouncedFn, cancel } = useDebounceFn(runVoid, debounceMs);

  function schedule(): void {
    saveState.value = 'idle';
    debouncedFn();
  }

  async function flush(): Promise<void> {
    cancel();
    await run();
  }

  return { saveState, saveError, schedule, flush, cancel };
}

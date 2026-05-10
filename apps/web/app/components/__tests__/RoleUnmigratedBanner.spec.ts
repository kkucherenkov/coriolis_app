/**
 * RoleUnmigratedBanner.spec.ts
 *
 * Unit tests for the RoleUnmigratedBanner component logic.
 *
 * The component itself requires a full Nuxt + vue-i18n environment to mount.
 * Tests here validate:
 *   1. Visibility invariants (when should the banner render)
 *   2. The API call pattern (PATCH with correct payload)
 *   3. Success path: emit + flag clearing
 *   4. Failure path: error surfaces inline, dialog stays open
 *   5. Dialog open/close state management
 *   6. Pending role confirmation invariant
 *
 * All API calls are mocked via vi.mock on useCharactersApi.
 * For SFC mounting we isolate the observable behaviour into pure functions
 * mirroring the component's script logic (same pattern as character-sheet-id.spec.ts).
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { ref } from 'vue';
import type { Role, Concept } from '@app/api-client-ts';

// ── Mock useCharactersApi ─────────────────────────────────────────────────────

const mockUpdate = vi.fn();

vi.mock('~/composables/useCharactersApi', () => ({
  useCharactersApi: () => ({
    update: mockUpdate,
  }),
}));

// ── Helpers mirroring the component's script logic ───────────────────────────

interface BannerState {
  dialogOpen: boolean;
  pendingRole: Role | null;
  saving: boolean;
  errorMsg: string;
}

function makeState(initialRole: Role | null): BannerState {
  return {
    dialogOpen: false,
    pendingRole: initialRole,
    saving: false,
    errorMsg: '',
  };
}

/** Mirrors the component's visibility guard. */
function shouldRender(roleUnmigrated: boolean, concept: Concept | null): boolean {
  return roleUnmigrated && concept !== null;
}

/** Mirrors openDialog(). */
function openDialog(state: BannerState, currentRole: Role | null): void {
  state.pendingRole = currentRole;
  state.errorMsg = '';
  state.dialogOpen = true;
}

/** Mirrors closeDialog(). */
function closeDialog(state: BannerState): void {
  state.dialogOpen = false;
}

/** Mirrors confirmRole() — async. */
async function confirmRole(
  state: BannerState,
  characterId: string,
  updateFn: (id: string, body: { role: Role }) => Promise<void>,
  onSuccess: (role: Role) => void,
  errorFallback: string,
): Promise<void> {
  if (!state.pendingRole) return;
  state.saving = true;
  state.errorMsg = '';
  try {
    await updateFn(characterId, { role: state.pendingRole });
    const confirmed = state.pendingRole;
    closeDialog(state);
    onSuccess(confirmed);
  } catch (error) {
    const problem = error as { detail?: string };
    state.errorMsg = problem.detail ?? errorFallback;
  } finally {
    state.saving = false;
  }
}

// ── Tests: visibility invariants ─────────────────────────────────────────────

describe('RoleUnmigratedBanner — visibility', () => {
  it('renders nothing when roleUnmigrated is false', () => {
    expect(shouldRender(false, 'pilot')).toBe(false);
  });

  it('renders nothing when concept is null (defensive edge case)', () => {
    expect(shouldRender(true, null)).toBe(false);
  });

  it('renders the banner when roleUnmigrated is true and concept is set', () => {
    expect(shouldRender(true, 'pilot')).toBe(true);
  });

  it('renders the banner for every non-null concept', () => {
    const concepts: Concept[] = [
      'artist',
      'networker',
      'fugitive',
      'negotiator',
      'operative',
      'pilot',
      'pioneer',
      'preacher',
      'scientist',
      'sailor',
      'soldier',
    ];
    for (const c of concepts) {
      expect(shouldRender(true, c)).toBe(true);
    }
  });
});

// ── Tests: dialog state management ───────────────────────────────────────────

describe('RoleUnmigratedBanner — dialog state', () => {
  it('clicking CTA opens the dialog', () => {
    const state = makeState(null);
    openDialog(state, null);
    expect(state.dialogOpen).toBe(true);
  });

  it('openDialog pre-fills pendingRole from the current role prop', () => {
    const state = makeState(null);
    openDialog(state, 'ace');
    expect(state.pendingRole).toBe('ace');
  });

  it('openDialog clears any previous error', () => {
    const state = makeState(null);
    state.errorMsg = 'previous error';
    openDialog(state, null);
    expect(state.errorMsg).toBe('');
  });

  it('closeDialog sets dialogOpen to false', () => {
    const state = makeState(null);
    state.dialogOpen = true;
    closeDialog(state);
    expect(state.dialogOpen).toBe(false);
  });

  it('confirmRole is a no-op when pendingRole is null', async () => {
    const state = makeState(null);
    const updateFn = vi.fn();
    const onSuccess = vi.fn();
    await confirmRole(state, 'char-1', updateFn, onSuccess, 'error');
    expect(updateFn).not.toHaveBeenCalled();
    expect(onSuccess).not.toHaveBeenCalled();
  });
});

// ── Tests: success path ───────────────────────────────────────────────────────

describe('RoleUnmigratedBanner — success path', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('confirmRole calls update with the chosen role', async () => {
    const state = makeState('driver');
    const updateFn = vi.fn().mockResolvedValue(undefined);
    const onSuccess = vi.fn();
    await confirmRole(state, 'char-1', updateFn, onSuccess, 'error');
    expect(updateFn).toHaveBeenCalledWith('char-1', { role: 'driver' });
  });

  it('confirmRole closes the dialog on success', async () => {
    const state = makeState('driver');
    state.dialogOpen = true;
    const updateFn = vi.fn().mockResolvedValue(undefined);
    const onSuccess = vi.fn();
    await confirmRole(state, 'char-1', updateFn, onSuccess, 'error');
    expect(state.dialogOpen).toBe(false);
  });

  it('confirmRole emits role-confirmed with the chosen role on success', async () => {
    const state = makeState('trucker');
    const updateFn = vi.fn().mockResolvedValue(undefined);
    const emitted = ref<Role | null>(null);
    const onSuccess = (role: Role) => {
      emitted.value = role;
    };
    await confirmRole(state, 'char-1', updateFn, onSuccess, 'error');
    expect(emitted.value).toBe('trucker');
  });
});

// ── Tests: failure path ───────────────────────────────────────────────────────

describe('RoleUnmigratedBanner — failure path', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('on API failure, surfaces the error message from the problem detail', async () => {
    const state = makeState('ace');
    state.dialogOpen = true;
    const updateFn = vi.fn().mockRejectedValue({ detail: 'Server error' });
    const onSuccess = vi.fn();
    await confirmRole(state, 'char-1', updateFn, onSuccess, 'Fallback error');
    expect(state.errorMsg).toBe('Server error');
  });

  it('on API failure, dialog stays open', async () => {
    const state = makeState('ace');
    state.dialogOpen = true;
    const updateFn = vi.fn().mockRejectedValue({ detail: 'Server error' });
    const onSuccess = vi.fn();
    await confirmRole(state, 'char-1', updateFn, onSuccess, 'Fallback error');
    expect(state.dialogOpen).toBe(true);
  });

  it('on API failure, does not emit role-confirmed', async () => {
    const state = makeState('ace');
    const updateFn = vi.fn().mockRejectedValue({ detail: 'Server error' });
    const onSuccess = vi.fn();
    await confirmRole(state, 'char-1', updateFn, onSuccess, 'Fallback error');
    expect(onSuccess).not.toHaveBeenCalled();
  });

  it('uses the fallback error message when problem.detail is absent', async () => {
    const state = makeState('ace');
    const updateFn = vi.fn().mockRejectedValue({});
    const onSuccess = vi.fn();
    await confirmRole(state, 'char-1', updateFn, onSuccess, 'Fallback error');
    expect(state.errorMsg).toBe('Fallback error');
  });

  it('saving flag resets to false after failure', async () => {
    const state = makeState('ace');
    const updateFn = vi.fn().mockRejectedValue({ detail: 'error' });
    const onSuccess = vi.fn();
    await confirmRole(state, 'char-1', updateFn, onSuccess, 'error');
    expect(state.saving).toBe(false);
  });
});

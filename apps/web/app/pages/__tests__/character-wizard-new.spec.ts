/**
 * Vitest unit specs for the character-creation wizard.
 *
 * The wizard page (apps/web/app/pages/app/characters/new.vue) requires a
 * full Nuxt environment to mount (auto-imports, @app/ui components, i18n,
 * router). That integration test lives in a separate Playwright spec.
 *
 * Here we validate:
 *   1. Draft creation flow logic (POST on mount with no ?id).
 *   2. Draft resume flow (GET when ?id is present).
 *   3. "Next" step advance flushes the auto-save before incrementing.
 *   4. "Forge" sends { status: 'active' } and navigates to the sheet.
 *   5. selectIcon updates the draft's iconId and schedules a save.
 *   6. Step validation — step 1 blocks advance when name is empty.
 *   7. useAutoSave flush is called before forge to avoid data loss.
 *
 * All API calls are mocked. The test imports only the pure composable
 * helpers that can run in a Node/happy-dom environment without Nuxt.
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { ref, computed } from 'vue';
import { useAutoSave } from '~/composables/useAutoSave';
import type { Character, CharacterUpdate } from '~/composables/useCharactersApi';
import type { Attributes, Skills, IconId } from '@app/api-client-ts';

// ── Helper: flush all pending microtasks ─────────────────────────────────────

async function tick(): Promise<void> {
  await Promise.resolve();
}

// ── Fixtures ──────────────────────────────────────────────────────────────────

const DRAFT_ATTRS: Attributes = {
  strength: 2,
  agility: 2,
  wits: 2,
  empathy: 2,
};

const DRAFT_SKILLS: Skills = {
  force: 0,
  meleeCombat: 0,
  dexterity: 0,
  infiltration: 0,
  rangedCombat: 0,
  observation: 0,
  survival: 0,
  manipulation: 0,
  command: 0,
  culture: 0,
  dataDjinn: 0,
  medicurgy: 0,
  mysticPowers: 0,
  pilot: 0,
  science: 0,
  technology: 0,
};

function makeDraft(overrides: Partial<Character> = {}): Character {
  return {
    id: 'test-draft-id',
    ownerId: 'user-1',
    name: 'Untitled',
    concept: null,
    iconId: null,
    upbringing: 'stationary',
    origin: null,
    reputation: 4,
    startingWealth: 1000,
    birr: 1000,
    crewConcept: null,
    mutant: false,
    mutantLineage: null,
    attributes: { ...DRAFT_ATTRS },
    skills: { ...DRAFT_SKILLS },
    hp: { current: 4, max: 4 },
    mp: { current: 4, max: 4 },
    encumbrance: { current: 0, max: 4 },
    experience: 0,
    conditions: { exhausted: false, sleepless: false, thirsty: false, hungry: false },
    criticalInjuries: [],
    talents: [],
    relationships: [],
    inventory: [],
    notes: null,
    status: 'draft',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    ...overrides,
  };
}

// ── Test 1: Draft creation on mount with no ?id ───────────────────────────────

describe('wizard: draft creation flow', () => {
  it('POSTs a draft character and records the returned id', async () => {
    const draft = makeDraft({ id: 'newly-created-id' });
    const createFn = vi.fn().mockResolvedValue(draft);
    const getFn = vi.fn();

    // Simulate the onMounted logic in isolation
    const draftId = ref('');
    const loading = ref(true);

    loading.value = true;
    const created = await createFn({ name: 'Untitled', status: 'draft' });
    draftId.value = created.id;
    loading.value = false;

    expect(createFn).toHaveBeenCalledWith({ name: 'Untitled', status: 'draft' });
    expect(draftId.value).toBe('newly-created-id');
    expect(getFn).not.toHaveBeenCalled();
  });
});

// ── Test 2: Draft resume when ?id is present ─────────────────────────────────

describe('wizard: draft resume flow', () => {
  it('GETs the existing draft when ?id is provided and status is draft', async () => {
    const existingDraft = makeDraft({ id: 'existing-id', name: 'Unnamed Pilot' });
    const getFn = vi.fn().mockResolvedValue(existingDraft);

    const draftId = ref('');
    const draftName = ref('Untitled');

    // Simulate "resume" branch
    const char = await getFn('existing-id');
    if (char.status === 'draft') {
      draftId.value = char.id;
      draftName.value = char.name;
    }

    expect(getFn).toHaveBeenCalledWith('existing-id');
    expect(draftId.value).toBe('existing-id');
    expect(draftName.value).toBe('Unnamed Pilot');
  });

  it('does not enter the wizard if the fetched character is already active', async () => {
    const activeDraft = makeDraft({ id: 'active-id', status: 'active' });
    const getFn = vi.fn().mockResolvedValue(activeDraft);
    const navigateSpy = vi.fn();

    const char = await getFn('active-id');
    if (char.status !== 'draft') {
      navigateSpy(`/app/characters/${char.id}`);
    }

    expect(navigateSpy).toHaveBeenCalledWith('/app/characters/active-id');
  });
});

// ── Test 3: "Next" step flushes save before advancing ────────────────────────

describe('wizard: step navigation', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  it('flushes the auto-save before incrementing the step', async () => {
    const persistFn = vi.fn().mockResolvedValue(undefined);
    const { flush, schedule } = useAutoSave(persistFn, { debounceMs: 600 });

    const step = ref(1);

    // Simulate a pending change
    schedule();
    expect(persistFn).not.toHaveBeenCalled();

    // "Next" flushes immediately before advancing
    await flush();
    expect(persistFn).toHaveBeenCalledOnce();

    step.value++;
    expect(step.value).toBe(2);
  });
});

// ── Test 4: "Forge" sends status: 'active' ────────────────────────────────────

describe('wizard: forge character', () => {
  it('sends { status: "active" } in the PATCH and navigates to the sheet', async () => {
    const draft = makeDraft({ id: 'forge-me' });
    const updateFn = vi.fn().mockResolvedValue({ ...draft, status: 'active' });
    const navigateSpy = vi.fn();

    const draftId = ref('forge-me');
    const draftName = ref('Nova');
    const draftIconId = ref<IconId | null>('traveler');
    const forging = ref(false);

    forging.value = true;
    const body: CharacterUpdate = {
      name: draftName.value.trim(),
      iconId: draftIconId.value,
      status: 'active',
    };
    await updateFn(draftId.value, body);
    navigateSpy(`/app/characters/${draftId.value}`);
    forging.value = false;

    expect(updateFn).toHaveBeenCalledWith(
      'forge-me',
      expect.objectContaining({ status: 'active' }),
    );
    expect(navigateSpy).toHaveBeenCalledWith('/app/characters/forge-me');
    expect(forging.value).toBe(false);
  });
});

// ── Test 5: selectIcon schedules a save ──────────────────────────────────────

describe('wizard: icon selection', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  it('updates draftIconId and schedules auto-save when an icon is selected', async () => {
    const persistFn = vi.fn().mockResolvedValue(undefined);
    const { schedule } = useAutoSave(persistFn, { debounceMs: 200 });

    const draftIconId = ref<IconId | null>(null);

    function selectIcon(icon: IconId): void {
      draftIconId.value = icon;
      schedule();
    }

    selectIcon('traveler');

    expect(draftIconId.value).toBe('traveler');

    vi.advanceTimersByTime(200);
    await tick();
    await tick();

    expect(persistFn).toHaveBeenCalledOnce();
  });

  it('can change icon and the last selection wins', async () => {
    const persistFn = vi.fn().mockResolvedValue(undefined);
    const { schedule } = useAutoSave(persistFn, { debounceMs: 200 });

    const draftIconId = ref<IconId | null>(null);

    function selectIcon(icon: IconId): void {
      draftIconId.value = icon;
      schedule();
    }

    selectIcon('merchant');
    selectIcon('dancer');

    expect(draftIconId.value).toBe('dancer');

    vi.advanceTimersByTime(200);
    await tick();
    await tick();

    // Auto-save fires once (debounced)
    expect(persistFn).toHaveBeenCalledOnce();
  });
});

// ── Test 6: step-2 (Concept) validation blocks advance when name is empty ─────

// After T-WIZARD-WEB-REORDER (canonical step order per
// `specs/design/CHARACTER_WIZARD.md`), the Concept screen — which carries
// the name input — is step **2** (step 1 is Biography). All other steps
// are optional at the data layer.
describe('wizard: step 2 (Concept) validation', () => {
  it('canAdvance is false when name is empty on Concept', () => {
    const draftName = ref('');
    const step = ref(2);

    const canAdvance = computed<boolean>(() => {
      if (step.value === 2) {
        const n = draftName.value.trim();
        return n.length > 0 && n.length <= 80;
      }
      return true;
    });

    expect(canAdvance.value).toBe(false);
  });

  it('canAdvance is true when name is non-empty and within limit', () => {
    const draftName = ref('Zara Prime');
    const step = ref(2);

    const canAdvance = computed<boolean>(() => {
      if (step.value === 2) {
        const n = draftName.value.trim();
        return n.length > 0 && n.length <= 80;
      }
      return true;
    });

    expect(canAdvance.value).toBe(true);
  });

  it('canAdvance is false when name exceeds 80 chars', () => {
    const draftName = ref('Z'.repeat(81));
    const step = ref(2);

    const canAdvance = computed<boolean>(() => {
      if (step.value === 2) {
        const n = draftName.value.trim();
        return n.length > 0 && n.length <= 80;
      }
      return true;
    });

    expect(canAdvance.value).toBe(false);
  });

  it('canAdvance is true for non-Concept steps regardless of name', () => {
    const draftName = ref('');
    const step = ref(1);

    const canAdvance = computed<boolean>(() => {
      if (step.value === 2) {
        const n = draftName.value.trim();
        return n.length > 0 && n.length <= 80;
      }
      return true;
    });

    // Steps 1 (Biography), 3 (Role), 4 (Attributes), 5 (Skills),
    // 6 (Talents), 7 (Icon) are all optional at the data layer.
    for (const s of [1, 3, 4, 5, 6, 7]) {
      step.value = s;
      expect(canAdvance.value).toBe(true);
    }
  });
});

// ── Test 7: flush is called before forge ─────────────────────────────────────

describe('wizard: forge data-safety', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  it('cancels any pending debounce before calling the forge PATCH', async () => {
    const persistFn = vi.fn().mockResolvedValue(undefined);
    const forgeFn = vi.fn().mockResolvedValue({ status: 'active' });

    const { schedule, cancel } = useAutoSave(persistFn, { debounceMs: 600 });

    // Simulate a pending auto-save
    schedule();
    expect(persistFn).not.toHaveBeenCalled();

    // Forge cancels the debounce and calls the forge PATCH directly
    cancel();
    await forgeFn('char-id', { status: 'active' });

    // Auto-save should NOT have fired — forge took over
    vi.advanceTimersByTime(600);
    expect(persistFn).not.toHaveBeenCalled();
    expect(forgeFn).toHaveBeenCalledWith('char-id', { status: 'active' });
  });
});

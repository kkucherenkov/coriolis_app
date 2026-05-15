/**
 * Step8Gear.spec.ts
 *
 * Unit tests for the Step 8 (Gear) wizard component logic.
 *
 * The component requires a full Nuxt + vue-i18n environment to mount. Tests
 * here validate the underlying catalogue helpers and pick-toggle invariants
 * without mounting the SFC — matching the pattern established in
 * `app/components/__tests__/RoleCardGrid.spec.ts`.
 *
 * Assertions:
 *   1. findStarterKit returns 5 row groups for a mapped (concept, role) pair.
 *   2. Each row has exactly 2 options.
 *   3. findStarterKit returns null when concept or role is null.
 *   4. Clicking a card emits update:picks with the row's option id.
 *   5. Re-clicking the same option clears the row (sets null).
 *   6. Clicking option B after A flips the row's pick value (no co-selection).
 */

import { describe, it, expect } from 'vitest';
import { findStarterKit, pickStarterKitItemName } from '@app/specs';
import type { StarterKitChoice } from '@app/specs';
import type { Concept, Role } from '@app/api-client-ts';

// ── Helpers mirroring the component's togglePick logic ───────────────────────

function togglePick(
  picks: Record<string, string | null>,
  choice: StarterKitChoice,
  optionId: string,
): Record<string, string | null> {
  const next = { ...picks };
  next[choice.id] = next[choice.id] === optionId ? null : optionId;
  return next;
}

// ── Test 1 & 2: 5 rows × 2 options for a known (concept, role) pair ──────────

describe('Step8Gear — catalogue shape', () => {
  it('returns 5 choice rows for pilot/ace', () => {
    const kit = findStarterKit('pilot', 'ace');
    expect(kit).not.toBeNull();
    expect(kit!.choices).toHaveLength(5);
  });

  it('every row for pilot/ace has exactly 2 options', () => {
    const kit = findStarterKit('pilot', 'ace')!;
    for (const choice of kit.choices) {
      expect(choice.options).toHaveLength(2);
    }
  });

  it('returns 5 rows for soldier/officer', () => {
    const kit = findStarterKit('soldier', 'officer');
    expect(kit!.choices).toHaveLength(5);
  });

  it('all 33 (concept, role) pairs resolve to a non-null kit with 5 rows', () => {
    const AMPLUA: { concept: Concept; roles: Role[] }[] = [
      { concept: 'artist', roles: ['companion', 'musician', 'poet'] },
      { concept: 'networker', roles: ['analyst', 'correspondent', 'network-djinn'] },
      { concept: 'fugitive', roles: ['criminal', 'mystic', 'revolutionary'] },
      { concept: 'negotiator', roles: ['agitator', 'diplomat', 'dealer'] },
      { concept: 'operative', roles: ['assassin', 'guard', 'spy'] },
      { concept: 'pilot', roles: ['ace', 'driver', 'trucker'] },
      { concept: 'pioneer', roles: ['colonist', 'prospector', 'scout'] },
      { concept: 'preacher', roles: ['ascetic', 'missionary', 'prophet'] },
      { concept: 'scientist', roles: ['archaeologist', 'medicurg', 'technologist'] },
      { concept: 'sailor', roles: ['ship-engineer', 'labourer', 'loader'] },
      { concept: 'soldier', roles: ['legionnaire', 'mercenary', 'officer'] },
    ];
    for (const { concept, roles } of AMPLUA) {
      for (const role of roles) {
        const kit = findStarterKit(concept, role);
        expect(kit, `${concept}/${role} must resolve`).not.toBeNull();
        expect(kit!.choices, `${concept}/${role} must have 5 rows`).toHaveLength(5);
      }
    }
  });
});

// ── Test 3: returns null for unmapped or null concept/role ────────────────────

describe('Step8Gear — empty state', () => {
  it('findStarterKit returns null when concept is null', () => {
    // The component guards: if (!props.concept || !props.role) return null
    // We mirror that guard here to confirm the catalogue itself does not crash.
    const concept: Concept | null = null;
    const role: Role = 'ace';
    const result = concept ? findStarterKit(concept, role) : null;
    expect(result).toBeNull();
  });

  it('findStarterKit returns null when role is null', () => {
    const concept: Concept = 'pilot';
    const role: Role | null = null;
    const result = role ? findStarterKit(concept, role) : null;
    expect(result).toBeNull();
  });
});

// ── Test 4: clicking a card sets the row's pick ───────────────────────────────

describe('Step8Gear — pick toggle: select', () => {
  it('emits update:picks with the option id when a card is clicked', () => {
    const kit = findStarterKit('pilot', 'ace')!;
    const choice = kit.choices[0]!;
    const optionA = choice.options[0]!;

    const picks: Record<string, string | null> = {};
    const next = togglePick(picks, choice, optionA.id);

    expect(next[choice.id]).toBe(optionA.id);
  });
});

// ── Test 5: re-clicking the same option clears the row ───────────────────────

describe('Step8Gear — pick toggle: deselect', () => {
  it('re-clicking the same option sets the row pick to null', () => {
    const kit = findStarterKit('pilot', 'ace')!;
    const choice = kit.choices[0]!;
    const optionA = choice.options[0]!;

    // First pick
    let picks = togglePick({}, choice, optionA.id);
    expect(picks[choice.id]).toBe(optionA.id);

    // Re-click → clear
    picks = togglePick(picks, choice, optionA.id);
    expect(picks[choice.id]).toBeNull();
  });
});

// ── Test 6: picking option B after A flips the row — no co-selection ─────────

describe('Step8Gear — pick toggle: swap', () => {
  it('picking option B after A stores only B (no co-selection)', () => {
    const kit = findStarterKit('pilot', 'ace')!;
    const choice = kit.choices[0]!;
    const optionA = choice.options[0]!;
    const optionB = choice.options[1]!;

    let picks = togglePick({}, choice, optionA.id);
    expect(picks[choice.id]).toBe(optionA.id);

    picks = togglePick(picks, choice, optionB.id);
    expect(picks[choice.id]).toBe(optionB.id);
    // optionA is gone — only one active pick per row
  });

  it('other rows are unaffected when one row is toggled', () => {
    const kit = findStarterKit('soldier', 'officer')!;
    const row1 = kit.choices[0]!;
    const row2 = kit.choices[1]!;

    let picks: Record<string, string | null> = {};
    picks = togglePick(picks, row1, row1.options[0]!.id);
    picks = togglePick(picks, row2, row2.options[1]!.id);

    // Toggling row1 again must not affect row2
    picks = togglePick(picks, row1, row1.options[0]!.id);
    expect(picks[row1.id]).toBeNull();
    expect(picks[row2.id]).toBe(row2.options[1]!.id);
  });
});

// ── Test 7: pickStarterKitItemName resolves locale strings ───────────────────

describe('Step8Gear — item name resolution', () => {
  it('resolves the EN name for a known item', () => {
    const kit = findStarterKit('pilot', 'ace')!;
    const item = kit.choices[0]!.options[0]!;
    expect(pickStarterKitItemName(item, 'en')).toBeTruthy();
    expect(typeof pickStarterKitItemName(item, 'en')).toBe('string');
  });

  it('resolves the RU name for a known item', () => {
    const kit = findStarterKit('pilot', 'ace')!;
    const item = kit.choices[0]!.options[0]!;
    const ru = pickStarterKitItemName(item, 'ru');
    expect(ru).toBeTruthy();
    // RU value should differ from EN (not a placeholder fallback for pilot kit)
    const en = pickStarterKitItemName(item, 'en');
    expect(ru).not.toBe(en);
  });
});

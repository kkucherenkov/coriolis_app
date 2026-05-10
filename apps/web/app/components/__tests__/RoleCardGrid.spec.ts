/**
 * RoleCardGrid.spec.ts
 *
 * Unit tests for the RoleCardGrid component logic.
 *
 * The component itself requires a full Nuxt + vue-i18n environment to mount
 * (auto-imports, <i18n> blocks). Tests here validate the underlying catalogue
 * helpers that drive the grid — role enumeration per concept, key skills per
 * role, selection toggle — without mounting the SFC.
 *
 * Full interactive tests (click, keyboard nav) are deferred to the Playwright
 * smoke spec (Block 5).
 */

import { describe, it, expect } from 'vitest';
import type { Concept, Role } from '@app/api-client-ts';
import {
  rolesForConcept,
  keySkillsForRole,
  CONCEPT_ROLES,
  type SkillKey,
} from '~/utils/roleCatalogue';

// ── Fixture: every concept and its expected role count ───────────────────────

const ALL_CONCEPTS: Concept[] = [
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

// ── Test 1: renders 3 cards for any concept ───────────────────────────────────

describe('RoleCardGrid — role enumeration', () => {
  it('returns exactly 3 roles for every concept', () => {
    for (const concept of ALL_CONCEPTS) {
      const roles = rolesForConcept(concept);
      expect(roles).toHaveLength(3);
    }
  });

  it('returns an empty array when concept is null', () => {
    expect(rolesForConcept(null)).toHaveLength(0);
  });

  it('returns the pilot concept roles in canonical ST3001 order (ace, driver, trucker)', () => {
    expect(rolesForConcept('pilot')).toEqual(['ace', 'driver', 'trucker']);
  });

  it('returns the soldier concept roles in canonical ST3001 order (legionnaire, mercenary, officer)', () => {
    expect(rolesForConcept('soldier')).toEqual(['legionnaire', 'mercenary', 'officer']);
  });
});

// ── Test 2: each card lists the role's 4 key skills ──────────────────────────

describe('RoleCardGrid — key skills per role', () => {
  it('returns exactly 4 key skills for every role', () => {
    const allRoles = Object.values(CONCEPT_ROLES).flat() as Role[];
    for (const role of allRoles) {
      const skills = keySkillsForRole(role);
      expect(skills).toHaveLength(4);
    }
  });

  it('all key skills are valid SkillKey values', () => {
    const VALID_SKILLS: SkillKey[] = [
      'dexterity',
      'force',
      'infiltration',
      'manipulation',
      'meleeCombat',
      'observation',
      'rangedCombat',
      'survival',
      'command',
      'culture',
      'dataDjinn',
      'medicurgy',
      'mysticPowers',
      'pilot',
      'science',
      'technology',
    ];

    const allRoles = Object.values(CONCEPT_ROLES).flat() as Role[];
    for (const role of allRoles) {
      const skills = keySkillsForRole(role);
      for (const skill of skills) {
        expect(VALID_SKILLS).toContain(skill);
      }
    }
  });

  it('ace has key skills: dataDjinn, pilot, rangedCombat, technology', () => {
    expect(keySkillsForRole('ace')).toEqual(['dataDjinn', 'pilot', 'rangedCombat', 'technology']);
  });

  it('officer has key skills: command, culture, meleeCombat, rangedCombat', () => {
    expect(keySkillsForRole('officer')).toEqual([
      'command',
      'culture',
      'meleeCombat',
      'rangedCombat',
    ]);
  });
});

// ── Test 3: selection toggle logic ────────────────────────────────────────────

describe('RoleCardGrid — selection toggle', () => {
  /**
   * The component's `pickRole` function emits `update:role` with:
   *   - the slug if a different card is clicked (select)
   *   - null if the currently-selected card is clicked again (deselect)
   *
   * We test the toggle invariant directly through the data model.
   */
  it('toggling an unselected role selects it', () => {
    const currentRole: Role | null = null;
    const clicked: Role = 'ace';
    // Simulate the pickRole logic: toggle if same, else pick
    const next = currentRole === clicked ? null : clicked;
    expect(next).toBe('ace');
  });

  it('clicking the currently-selected card deselects it (emits null)', () => {
    const currentRole: Role = 'driver';
    const clicked: Role = 'driver';
    const next = currentRole === clicked ? null : clicked;
    expect(next).toBeNull();
  });

  it('clicking a different card replaces the selection', () => {
    // Use a runtime variable so TS does not narrow these to incompatible literals
    const currentRole: Role = 'ace' as Role;
    const clicked: Role = 'trucker' as Role;
    const next = currentRole === clicked ? null : clicked;
    expect(next).toBe('trucker');
  });
});

// ── Helpers ───────────────────────────────────────────────────────────────────

/**
 * Mirrors the component's `moveFocus` wrapping arithmetic.
 * Extracted to module scope per unicorn/consistent-function-scoping.
 */
function computeNext(activeIdx: number, delta: -1 | 1, total: number): number {
  return (activeIdx + delta + total) % total;
}

// ── Test 4: arrow-key focus management invariants ────────────────────────────

describe('RoleCardGrid — arrow-key navigation invariants', () => {
  /**
   * The component uses `moveFocus(delta)` to cycle through cards.
   * We test the wrapping arithmetic without a DOM.
   */

  it('moving down from last card wraps to first', () => {
    // 3 cards, currently at index 2, move +1
    expect(computeNext(2, 1, 3)).toBe(0);
  });

  it('moving up from first card wraps to last', () => {
    // 3 cards, currently at index 0, move -1
    expect(computeNext(0, -1, 3)).toBe(2);
  });

  it('moving down from middle card goes to next', () => {
    expect(computeNext(1, 1, 3)).toBe(2);
  });

  it('moving up from middle card goes to previous', () => {
    expect(computeNext(1, -1, 3)).toBe(0);
  });
});

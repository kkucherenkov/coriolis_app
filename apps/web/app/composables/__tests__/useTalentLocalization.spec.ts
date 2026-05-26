/**
 * Unit tests for useTalentLocalization.
 *
 * Tests the two resolution paths:
 *   1. Catalog-id path  — `talent.name` is a slug like `personal-menacing`
 *      (written by the wizard when it seeds talents from the catalog). Must
 *      work for ALL kinds, including `personal`.
 *   2. Fuzzy name path  — `talent.name` is a localized catalog name stored
 *      from the session locale at forge time. Must be skipped for `personal`
 *      to preserve user-edited free-form rows.
 *   3. Free-form rows   — neither path matches → raw `talent.name` passes through.
 *
 * `useI18n` is a Nuxt / vue-i18n auto-import; outside of Nuxt runtime it
 * must be mocked so vitest can resolve it.
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { ref } from 'vue';
import type { Talent } from '@app/api-client-ts';

// ── Stub useI18n global (Nuxt auto-import — not a real module import) ──────────
// In Nuxt, `useI18n` is injected as a global by the i18n module. Outside the
// Nuxt runtime (plain vitest) the global does not exist. `vi.stubGlobal` places
// a controlled implementation into the global scope so the composable under test
// can call it without the full Nuxt boot.

const mockLocale = ref('en');

vi.stubGlobal('useI18n', () => ({ locale: mockLocale }));

import { useTalentLocalization } from '~/composables/useTalentLocalization';

// ── Helpers ───────────────────────────────────────────────────────────────────

function makeTalent(overrides: Partial<Talent> = {}): Talent {
  return {
    id: 'some-uuid',
    name: 'personal-menacing',
    description: '',
    kind: 'personal',
    rank: 1,
    acquiredAt: '2026-01-01T00:00:00.000Z',
    ...overrides,
  };
}

// ── Tests ─────────────────────────────────────────────────────────────────────

describe('useTalentLocalization', () => {
  beforeEach(() => {
    mockLocale.value = 'en';
  });

  describe('Path 1: catalog-id resolution', () => {
    it('resolves a personal talent stored as a catalog id (en)', () => {
      const { displayTalentName } = useTalentLocalization();
      const talent = makeTalent({ name: 'personal-menacing', kind: 'personal' });
      // catalog entry for personal-menacing has en name "Menacing"
      expect(displayTalentName(talent)).toBe('Menacing');
    });

    it('resolves a personal talent stored as a catalog id (ru)', () => {
      mockLocale.value = 'ru';
      const { displayTalentName } = useTalentLocalization();
      const talent = makeTalent({ name: 'personal-menacing', kind: 'personal' });
      expect(displayTalentName(talent)).not.toBe('personal-menacing');
      expect(displayTalentName(talent).length).toBeGreaterThan(0);
    });

    it('resolves a crew talent stored as a catalog id', () => {
      const { displayTalentName } = useTalentLocalization();
      // crew-nose-for-birrs is a catalog crew talent
      const talent = makeTalent({ name: 'crew-nose-for-birrs', kind: 'crew' });
      expect(displayTalentName(talent)).not.toBe('crew-nose-for-birrs');
    });

    it('does NOT resolve when id kind mismatches the talent kind', () => {
      const { displayTalentName } = useTalentLocalization();
      // personal-menacing is kind:personal; if stored on a crew row, no id match
      const talent = makeTalent({ name: 'personal-menacing', kind: 'crew' });
      // Falls through to name-based lookup (which also won't find it), returns raw slug
      expect(displayTalentName(talent)).toBe('personal-menacing');
    });
  });

  describe('Path 2: fuzzy name resolution (non-personal only)', () => {
    it('resolves a crew talent stored by its English name to ru locale', () => {
      mockLocale.value = 'ru';
      const { displayTalentName } = useTalentLocalization();
      // "crew-nose-for-birrs" — name and description must match the catalog exactly
      // (case-insensitive, whitespace-trimmed) for the fuzzy path to fire.
      const talent = makeTalent({
        name: 'Nose for Birrs',
        kind: 'crew',
        description:
          '+2 to Manipulation when haggling. Once per session for the whole crew, not per character.',
      });
      // Should resolve to the ru name "Нюх на бирры", not the stored en name
      const result = displayTalentName(talent);
      expect(result).toBe('Нюх на бирры');
    });

    it('leaves personal talent with a user-edited free-form name unchanged', () => {
      const { displayTalentName } = useTalentLocalization();
      // A name that is neither a catalog id nor a catalog localized name
      const talent = makeTalent({ name: 'My Custom Power', kind: 'personal' });
      expect(displayTalentName(talent)).toBe('My Custom Power');
    });
  });

  describe('Path 3: free-form fallthrough', () => {
    it('returns raw name when neither id nor name matches the catalog', () => {
      const { displayTalentName } = useTalentLocalization();
      const talent = makeTalent({ name: 'Completely Unknown Talent', kind: 'crew' });
      expect(displayTalentName(talent)).toBe('Completely Unknown Talent');
    });

    it('returns raw description when the talent is user-edited (description differs from catalog)', () => {
      const { displayTalentDescription } = useTalentLocalization();
      const talent = makeTalent({
        name: 'Nose for Birrs',
        kind: 'crew',
        description: 'Player has edited this description to something custom.',
      });
      expect(displayTalentDescription(talent)).toBe(
        'Player has edited this description to something custom.',
      );
    });
  });
});

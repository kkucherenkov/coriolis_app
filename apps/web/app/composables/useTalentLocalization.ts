/**
 * Locale-aware rendering for talents persisted on the character sheet.
 *
 * The DB stores a talent's name + description as plain strings in whichever
 * locale was active at forge time (the wizard copies the catalog text out of
 * `@app/specs` into the row). When the player later switches their i18n
 * locale, the bare DB strings cannot follow — the Talent table has no
 * `catalogId` column, so a heavier migration was deferred (see done.md
 * follow-up note on T-2026-05-09-005).
 *
 * This composable bridges the gap by matching the stored name/description
 * back to the catalog at render time. A row qualifies for localised
 * rendering only when both fields match a single catalog entry across any
 * supported locale — that lets us preserve user edits exactly: rename or
 * rewrite either field and the row falls through to the stored values.
 *
 * `kind: 'personal'` rows are always user-authored (the wizard never auto-
 * seeds a personal talent — the player picks one from the menu and the row
 * is later free-form editable), so we skip the catalog lookup entirely.
 *
 * Used by both the editable character sheet (`[id].vue`) and the public
 * read-only viewer (`AppShareViewer`).
 */
import { findCatalogTalentByName, pickLocalized } from '@app/specs';
import type { Talent } from '@app/api-client-ts';

const CATALOG_LOCALES = ['en', 'ru', 'uk', 'el'] as const;

function normalizeForCatalogMatch(s: string): string {
  return s.trim().toLowerCase();
}

export interface TalentLocalization {
  displayTalentName: (talent: Talent) => string;
  displayTalentDescription: (talent: Talent) => string;
}

export function useTalentLocalization(): TalentLocalization {
  const { locale } = useI18n();

  // Returned as arrow functions so consumers can safely destructure them
  // — `@typescript-eslint/unbound-method` flags `function`-declared methods
  // pulled off an object as potentially losing their `this`. None of these
  // helpers reference `this`, so arrow form is both correct and lint-clean.
  const catalogMatchFor = (talent: Talent): { name: string; description: string } | null => {
    if (talent.kind === 'personal') return null;
    const entry = findCatalogTalentByName(talent.name, talent.kind);
    if (!entry) return null;
    const descNorm = normalizeForCatalogMatch(talent.description);
    const editedDescription = !CATALOG_LOCALES.some(
      (l) => normalizeForCatalogMatch(entry.description[l]) === descNorm,
    );
    if (editedDescription) return null;
    return {
      name: pickLocalized(entry.name, locale.value),
      description: pickLocalized(entry.description, locale.value),
    };
  };

  const displayTalentName = (talent: Talent): string =>
    catalogMatchFor(talent)?.name ?? talent.name;

  const displayTalentDescription = (talent: Talent): string =>
    catalogMatchFor(talent)?.description ?? talent.description;

  return { displayTalentName, displayTalentDescription };
}

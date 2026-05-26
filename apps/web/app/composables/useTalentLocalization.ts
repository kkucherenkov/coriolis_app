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
import { findCatalogTalentById, findCatalogTalentByName, pickLocalized } from '@app/specs';
import type { CatalogLocale } from '@app/specs';
import type { Talent } from '@app/api-client-ts';

// Track the catalog's active locale set. Keep this in sync with
// `CatalogLocale` in `packages/specs/src/talents.ts` — drifting will surface
// as a TS error on the `entry.description[l]` access below, not a runtime bug.
const CATALOG_LOCALES = ['en', 'ru'] as const satisfies readonly CatalogLocale[];

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
    // Path 1: exact catalog-id match (unambiguous — applies to ALL kinds,
    // including personal). The wizard stores catalog ids when it seeds talents
    // from the catalog, so `talent.name` may hold a slug like
    // `personal-menacing` rather than a localized name. An id-match is
    // unambiguous and skips description verification: the description was also
    // seeded from the catalog and may likewise be stored as a localized string
    // from a different locale.
    // kind must match: an id from a different kind (e.g. `personal-menacing`
    // stored on a crew row by accident) is not a valid resolution — fall through
    // to the name-based lookup below.
    const byId = findCatalogTalentById(talent.name);
    if (byId?.kind === talent.kind) {
      return {
        name: pickLocalized(byId.name, locale.value),
        description: pickLocalized(byId.description, locale.value),
      };
    }

    // Path 2: name-based fuzzy match. Only for non-personal kinds because
    // personal talent rows are free-form editable after wizard creation — a
    // name collision with the catalog would incorrectly translate user text.
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

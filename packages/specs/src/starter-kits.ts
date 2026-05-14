/**
 * Coriolis ST3001 — starter-kit catalogue (per amplua + role).
 *
 * Single source of truth for the wizard Step 8 (Gear) picker. Both
 * `apps/web` and `apps/mobile` consume this module via the `@app/specs`
 * workspace barrel and drive the per-amplua picker locally — the
 * backend stays unaware of the catalogue and only sees individual
 * `POST /api/v1/characters/{id}/items` requests for each chosen item.
 *
 * ## Architectural decision (T-WIZARD-GEAR-BACKEND-DERIVE)
 *
 * We chose **option (b)** from the open question in
 * `specs/design/CHARACTER_WIZARD.md` §3.8: the client renders the
 * per-amplua picker reading this static catalogue. The alternative —
 * server-computed starter packs on activation — was rejected for v1
 * because:
 *
 *   1. Coriolis starter kits are tied to the printed rulebook (ST3001).
 *      They change at the cadence of game printings, not deploys.
 *   2. Server-side derivation would need a seeded `starter_kit` table,
 *      a migration to populate it, and an admin tool to keep it in sync
 *      with the rulebook. That's a lot of plumbing for static content.
 *   3. The wizard flow is per-character: a single player POSTing 5-8
 *      items at activation is well within the existing items API. No
 *      new endpoint is needed.
 *   4. Client-side rendering keeps the catalogue free to evolve (item
 *      copy tweaks, localisations) without backend release cycles.
 *
 * Trade-offs accepted:
 *
 *   - **No server-side validation** that the player picked "canonical"
 *     items — the wizard UX is the gate. A future hardening pass can
 *     add an optional `Character.starterKitFingerprint` field that the
 *     server stores for audit + reproducibility.
 *   - **Three client embeddings** (web TS, mobile Dart, dart codegen
 *     for the SDK) all need the same source. Mobile reads the catalogue
 *     via a generated Dart constants file produced from this TS module
 *     in a follow-up bundler step.
 *
 * ## Data sourcing
 *
 * This file ships a SCHEMA + a single stub entry (Pilot / Ace) to
 * exercise the contract. Populating the rest of the catalogue from
 * ST3001 ch.4 amplua tables is tracked as a follow-up task
 * `T-WIZARD-GEAR-CATALOGUE-FILL` and depends on the rulebook reference
 * memory (`coriolis-rulebook-ru.md`).
 *
 * ## Catalogue shape
 *
 * Each (concept, role) pair maps to a `StarterKit` with:
 *
 *   - `fixed[]` — items every character of that kit receives
 *     unconditionally (e.g. uniform, ID card).
 *   - `choices[]` — choice groups in canonical rulebook order. Each
 *     group has 1+ `options[]`; the player picks exactly one.
 *
 * `StarterKitItem.itemTemplate` is a partial `ItemCreate` body that
 * the wizard wraps in the appropriate `ItemCreate` discriminator
 * (weapon / armor / gear / cybernetic / other) before POSTing.
 */
import type { components } from './openapi-types.js';

import type { CatalogLocale, LocalizedString } from './talents.js';
export type { CatalogLocale, LocalizedString } from './talents.js';

type Concept = components['schemas']['Concept'];
type Role = components['schemas']['Role'];

/** Discriminator value for the wire-form `ItemCreate` one-of branch. */
export type StarterKitItemKind = 'WEAPON' | 'ARMOR' | 'GEAR' | 'CYBERNETIC' | 'OTHER';

/**
 * Shape-shape: a partial `ItemCreate` body the wizard POSTs per pick.
 *
 * The wizard hydrates the missing fields (per discriminator) at
 * activation time. We deliberately keep this type loose — strongly
 * typing per-discriminator at the catalogue layer would tie us to the
 * one-of generator output and trip on every spec regen.
 */
export interface StarterKitItemTemplate {
  readonly kind: StarterKitItemKind;
  /**
   * Display + persistence name. The wizard does NOT localise on the
   * wire — `Item.name` is the source of truth across locales — so the
   * picker shows `name[locale]` but POSTs the user's UI locale value
   * as-is.
   */
  readonly name: LocalizedString;
  /**
   * Optional partial of the per-discriminator fields. The wizard knows
   * the full schema (via the SDK) and fills the rest with safe
   * defaults (e.g. `equipped: false`, `quantity: 1`).
   */
  readonly fields?: Readonly<Record<string, unknown>>;
}

export interface StarterKitItem {
  /** Stable kebab-case id; used for test selectors + i18n + telemetry. */
  readonly id: string;
  readonly template: StarterKitItemTemplate;
}

export interface StarterKitChoice {
  /** Stable kebab-case id within the kit (e.g. `sidearm`, `outfit`). */
  readonly id: string;
  readonly label: LocalizedString;
  readonly options: ReadonlyArray<StarterKitItem>;
  /**
   * Optional: number of items the player picks from this group. Defaults
   * to 1. Some ST3001 rows allow multi-pick (e.g. "choose two utility
   * items").
   */
  readonly pickCount?: number;
}

export interface StarterKit {
  readonly concept: Concept;
  readonly role: Role;
  /** Items every character of this kit receives (no choice). */
  readonly fixed: ReadonlyArray<StarterKitItem>;
  /** Choice groups in rulebook order; the player picks per group. */
  readonly choices: ReadonlyArray<StarterKitChoice>;
}

// ── Stub catalogue ──────────────────────────────────────────────────────────
//
// One example entry to exercise the schema. The follow-up
// `T-WIZARD-GEAR-CATALOGUE-FILL` populates the remaining 32 (concept ×
// role) pairs from ST3001 ch.4 amplua tables.

const STUB_PILOT_ACE: StarterKit = {
  concept: 'pilot',
  role: 'ace',
  fixed: [
    {
      id: 'pilot-suit',
      template: {
        kind: 'ARMOR',
        name: {
          en: 'Light flight suit',
          ru: 'Лёгкий лётный комбинезон',
          uk: '[uk-todo] Light flight suit',
          el: '[el-todo] Light flight suit',
        },
      },
    },
  ],
  choices: [
    {
      id: 'sidearm',
      label: {
        en: 'Sidearm',
        ru: 'Личное оружие',
        uk: '[uk-todo] Sidearm',
        el: '[el-todo] Sidearm',
      },
      options: [
        {
          id: 'sidearm-emp-pistol',
          template: {
            kind: 'WEAPON',
            name: {
              en: 'EMP pistol',
              ru: 'ЭМИ-пистолет',
              uk: '[uk-todo] EMP pistol',
              el: '[el-todo] EMP pistol',
            },
          },
        },
        {
          id: 'sidearm-acclerator',
          template: {
            kind: 'WEAPON',
            name: {
              en: 'Accelerator pistol',
              ru: 'Пистолет-ускоритель',
              uk: '[uk-todo] Accelerator pistol',
              el: '[el-todo] Accelerator pistol',
            },
          },
        },
      ],
    },
  ],
};

export const STARTER_KIT_CATALOG: ReadonlyArray<StarterKit> = Object.freeze([STUB_PILOT_ACE]);

/**
 * Returns the starter kit for [concept, role], or `null` if no entry
 * exists yet. v1 catalogue is intentionally sparse — see
 * `T-WIZARD-GEAR-CATALOGUE-FILL`.
 */
export function findStarterKit(concept: Concept, role: Role): StarterKit | null {
  return STARTER_KIT_CATALOG.find((k) => k.concept === concept && k.role === role) ?? null;
}

/**
 * Resolves the user-visible label of a starter kit item for [locale],
 * falling back through the `[locale]-todo` placeholders if a real
 * translation hasn't landed yet. Mirrors the helper in `talents.ts`.
 */
export function pickStarterKitItemName(item: StarterKitItem, locale: CatalogLocale): string {
  const raw = item.template.name[locale];
  if (!raw) return item.template.name.en;
  return raw;
}

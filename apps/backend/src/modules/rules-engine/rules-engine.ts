/**
 * WHY this file exists:
 * Pure, stateless Coriolis rules-engine functions. No I/O, no DI, no NestJS
 * decorators. These are the canonical formulas — a house-rule change is a
 * single edit here.
 *
 * Formulas are sourced from PRD §5.2 and §10:
 *
 *   HP max    = STR + AGI          (PRD §5.2: "HP max = STR + AGI")
 *   MP max    = WIT + EMP          (PRD §5.2: "MP max = WIT + EMP")
 *   Enc max   = STR × 2            (PRD §5.2: "Encumbrance limit = STR × 2")
 *   Enc cur   = sum of item weights (PRD §5.3: weight in slots, CYBERNETIC uses
 *                                    systemStrain not weight — PRD does not
 *                                    explicitly state cybs are exempt, but the
 *                                    schema stores cyb-specific fields in `data`
 *                                    while `weight` remains on the common
 *                                    fields; we sum `weight` for all items
 *                                    including CYBERNETIC because the Item
 *                                    schema always carries `weight: number`.
 *                                    If a cybernetic has weight 0 it does not
 *                                    add encumbrance. Assumption documented.)
 *   Push      = not exhausted AND roll not already pushed (PRD §10)
 */

import type { ItemReadModel } from '../characters/domain/character.ports';

// --------------- Character creation budgets ---------------

/**
 * Coriolis core book ch.2, tables 2.2 and 2.4. A character's upbringing
 * (Воспитание) determines the number of attribute / skill points available
 * at creation, the starting reputation, and the starting wealth in birrs.
 */
export type Upbringing = 'plebeian' | 'stationary' | 'aristocrat';

export interface UpbringingBudget {
  /** Pool of attribute points to distribute across STR/AGI/WIT/EMP. */
  attributes: number;
  /** Pool of skill points to distribute across the 16 skills. */
  skills: number;
  /** Starting reputation value (mutable during play). */
  reputation: number;
  /** Starting wealth in birrs (immutable historical record). */
  startingWealth: number;
}

export const UPBRINGING_BUDGETS: Readonly<Record<Upbringing, UpbringingBudget>> = Object.freeze({
  plebeian: { attributes: 15, skills: 8, reputation: 2, startingWealth: 500 },
  stationary: { attributes: 14, skills: 10, reputation: 4, startingWealth: 1000 },
  aristocrat: { attributes: 13, skills: 12, reputation: 6, startingWealth: 5000 },
});

/**
 * Coriolis core book ch.2 — character archetypes (амплуа). Each concept
 * has:
 *   - one **key attribute**, capped at 5 instead of 4 at creation;
 *   - a set of **key skills** (union of the 3 roles' key skills — see
 *     CONCEPT_ROLES for the per-role breakdown), capped at 3 instead of 1
 *     at creation;
 *   - a **reputation modifier** added to the upbringing baseline.
 *
 * Skills mapped from the Russian rulebook to the project's 16-skill
 * schema (PRD §5.2):
 *   влияние→manipulation, мудрость→culture, проворство→dexterity,
 *   наблюдательность→observation, скрытность→infiltration,
 *   инфомантия→dataDjinn, ближний бой→meleeCombat, стрельба→rangedCombat,
 *   выживание→survival, лидерство→command, сила→force, медикургия→medicurgy,
 *   психомистицизм→mysticPowers, пилотирование→pilot, наука→science,
 *   технология→technology.
 */
export type Concept =
  | 'artist'
  | 'networker'
  | 'fugitive'
  | 'negotiator'
  | 'operative'
  | 'pilot'
  | 'pioneer'
  | 'preacher'
  | 'scientist'
  | 'sailor'
  | 'soldier';

// --------------- Role types ---------------

/**
 * One of 33 canonical roles (роли) across the 11 amplua.
 * Three roles per amplua per ГЛАВА 2 «АМПЛУА И РОЛИ» ST3001.
 */
export type Role =
  | 'companion'
  | 'musician'
  | 'poet'
  | 'analyst'
  | 'correspondent'
  | 'network-djinn'
  | 'criminal'
  | 'mystic'
  | 'revolutionary'
  | 'agitator'
  | 'diplomat'
  | 'dealer'
  | 'assassin'
  | 'guard'
  | 'spy'
  | 'ace'
  | 'driver'
  | 'trucker'
  | 'colonist'
  | 'prospector'
  | 'scout'
  | 'ascetic'
  | 'missionary'
  | 'prophet'
  | 'archaeologist'
  | 'medicurg'
  | 'technologist'
  | 'ship-engineer'
  | 'labourer'
  | 'loader'
  | 'legionnaire'
  | 'mercenary'
  | 'officer';

export interface RoleData {
  /** Russian display name (ГЛАВА 2). UI clients should localise via i18n. */
  ru: string;
  /** Exactly 4 key skills — narrows the amplua's union per ГЛАВА 2. */
  keySkills: readonly [SkillKey, SkillKey, SkillKey, SkillKey];
}

/** Helper to create a RoleData entry with a strongly-typed 4-tuple. */
function rd(ru: string, s1: SkillKey, s2: SkillKey, s3: SkillKey, s4: SkillKey): RoleData {
  return { ru, keySkills: [s1, s2, s3, s4] as const };
}

/**
 * Canonical role data per amplua per role, sourced verbatim from
 * ГЛАВА 2 «АМПЛУА И РОЛИ» ST3001 Russian rulebook.
 * Single source of truth — CONCEPT_KEYS.keySkills is derived from here.
 */
export const CONCEPT_ROLES: Readonly<Record<Concept, Readonly<Record<string, RoleData>>>> =
  Object.freeze({
    artist: Object.freeze({
      companion: rd('Компаньон', 'manipulation', 'culture', 'dexterity', 'observation'),
      musician: rd('Музыкант', 'manipulation', 'culture', 'infiltration', 'observation'),
      poet: rd('Поэт', 'manipulation', 'culture', 'dexterity', 'infiltration'),
    }),
    networker: Object.freeze({
      analyst: rd('Аналитик', 'dataDjinn', 'culture', 'manipulation', 'science'),
      correspondent: rd('Корреспондент', 'culture', 'manipulation', 'infiltration', 'observation'),
      'network-djinn': rd('Сетевой джинн', 'dataDjinn', 'manipulation', 'observation', 'science'),
    }),
    fugitive: Object.freeze({
      criminal: rd('Преступник', 'force', 'meleeCombat', 'dexterity', 'infiltration'),
      mystic: rd('Мистик', 'manipulation', 'mysticPowers', 'dexterity', 'infiltration'),
      revolutionary: rd('Революционер', 'rangedCombat', 'dexterity', 'observation', 'survival'),
    }),
    negotiator: Object.freeze({
      agitator: rd('Агитатор', 'dataDjinn', 'force', 'manipulation', 'culture'),
      diplomat: rd('Дипломат', 'command', 'culture', 'manipulation', 'meleeCombat'),
      dealer: rd('Делец', 'culture', 'manipulation', 'observation', 'pilot'),
    }),
    operative: Object.freeze({
      assassin: rd('Ассасин', 'infiltration', 'dexterity', 'meleeCombat', 'rangedCombat'),
      guard: rd('Стражник', 'force', 'meleeCombat', 'rangedCombat', 'observation'),
      spy: rd('Шпион', 'dataDjinn', 'manipulation', 'infiltration', 'rangedCombat'),
    }),
    pilot: Object.freeze({
      ace: rd('Ас', 'dataDjinn', 'pilot', 'rangedCombat', 'technology'),
      driver: rd('Водитель', 'force', 'pilot', 'rangedCombat', 'survival'),
      trucker: rd('Дальнобойщик', 'dataDjinn', 'force', 'pilot', 'technology'),
    }),
    pioneer: Object.freeze({
      colonist: rd('Колонист', 'force', 'dexterity', 'rangedCombat', 'survival'),
      prospector: rd('Старатель', 'pilot', 'technology', 'science', 'survival'),
      scout: rd('Скаут', 'infiltration', 'rangedCombat', 'observation', 'survival'),
    }),
    preacher: Object.freeze({
      ascetic: rd('Аскет', 'force', 'culture', 'dexterity', 'science'),
      missionary: rd('Миссионер', 'culture', 'manipulation', 'dexterity', 'survival'),
      prophet: rd('Пророк', 'force', 'culture', 'manipulation', 'observation'),
    }),
    scientist: Object.freeze({
      archaeologist: rd('Археолог', 'culture', 'observation', 'science', 'survival'),
      medicurg: rd('Медикург', 'medicurgy', 'manipulation', 'observation', 'science'),
      technologist: rd('Технологик', 'force', 'technology', 'observation', 'science'),
    }),
    sailor: Object.freeze({
      'ship-engineer': rd('Бортинженер', 'dataDjinn', 'force', 'observation', 'technology'),
      labourer: rd('Разнорабочий', 'force', 'manipulation', 'dexterity', 'culture'),
      loader: rd('Грузчик', 'force', 'meleeCombat', 'dexterity', 'technology'),
    }),
    soldier: Object.freeze({
      legionnaire: rd('Легионер', 'force', 'meleeCombat', 'rangedCombat', 'survival'),
      mercenary: rd('Наёмник', 'meleeCombat', 'dexterity', 'observation', 'rangedCombat'),
      officer: rd('Офицер', 'command', 'culture', 'meleeCombat', 'rangedCombat'),
    }),
  });

/**
 * The three canonical role slugs per amplua, in the canonical order from
 * ГЛАВА 2. The first entry is the default role used by backfill migrations.
 */
export const ROLE_BY_CONCEPT: Readonly<Record<Concept, readonly Role[]>> = Object.freeze(
  Object.fromEntries(
    (Object.keys(CONCEPT_ROLES) as Concept[]).map(
      (c) => [c, Object.keys(CONCEPT_ROLES[c]) as Role[]] as const,
    ),
  ) as unknown as Record<Concept, readonly Role[]>,
);

/**
 * Reverse lookup: given a role slug, returns its amplua.
 * Useful for validating that a role belongs to the character's concept.
 */
export const CONCEPT_BY_ROLE: Readonly<Record<Role, Concept>> = Object.freeze(
  Object.fromEntries(
    (Object.keys(CONCEPT_ROLES) as Concept[]).flatMap((c) =>
      Object.keys(CONCEPT_ROLES[c]).map((role) => [role, c]),
    ),
  ) as Record<Role, Concept>,
);

/** Returns the 4 key skills for the given role. */
export function getRoleKeySkills(role: Role): readonly SkillKey[] {
  const concept = CONCEPT_BY_ROLE[role];
  // Both lookups are always defined for valid Role values (CONCEPT_ROLES is
  // the single source of truth and CONCEPT_BY_ROLE is derived from it).
  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- derived from CONCEPT_ROLES, always present
  return CONCEPT_ROLES[concept][role]!.keySkills;
}

/**
 * Returns the first canonical role for a concept — used by the migration
 * backfill so existing characters get a deterministic, canon-respectful
 * default. Order follows ГЛАВА 2 exactly (see CONCEPT_ROLES).
 */
export function defaultRoleForConcept(concept: Concept): Role {
  // ROLE_BY_CONCEPT always has exactly 3 entries per concept (derived from
  // CONCEPT_ROLES), so index [0] is always defined.
  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- 3 roles per concept, index 0 always present
  return ROLE_BY_CONCEPT[concept][0]!;
}

export type AttributeKey = 'strength' | 'agility' | 'wits' | 'empathy';

export type SkillKey =
  | 'dexterity'
  | 'force'
  | 'infiltration'
  | 'manipulation'
  | 'meleeCombat'
  | 'observation'
  | 'rangedCombat'
  | 'survival'
  | 'command'
  | 'culture'
  | 'dataDjinn'
  | 'medicurgy'
  | 'mysticPowers'
  | 'pilot'
  | 'science'
  | 'technology';

export interface ConceptKeys {
  /** Capped at 5 instead of 4 at creation. */
  keyAttribute: AttributeKey;
  /**
   * Union of all three roles' key skills for this amplua — each capped at 3
   * instead of 1 at creation. Derived automatically from CONCEPT_ROLES so
   * there is a single source of truth. For role-specific skill caps (tighter
   * set of exactly 4), use getRoleKeySkills(role) instead.
   */
  keySkills: readonly SkillKey[];
  /** Added to `UPBRINGING_BUDGETS[u].reputation`. */
  reputationModifier: number;
}

/** Derives the union of key skills across all three roles for a concept. */
function deriveConceptKeySkills(concept: Concept): readonly SkillKey[] {
  const roles = CONCEPT_ROLES[concept];
  return [...new Set(Object.values(roles).flatMap((r) => [...r.keySkills]))];
}

export const CONCEPT_KEYS: Readonly<Record<Concept, ConceptKeys>> = Object.freeze({
  artist: {
    keyAttribute: 'empathy',
    keySkills: deriveConceptKeySkills('artist'),
    reputationModifier: 1,
  },
  networker: {
    keyAttribute: 'wits',
    keySkills: deriveConceptKeySkills('networker'),
    reputationModifier: 0,
  },
  fugitive: {
    keyAttribute: 'empathy',
    keySkills: deriveConceptKeySkills('fugitive'),
    reputationModifier: -2,
  },
  negotiator: {
    keyAttribute: 'empathy',
    keySkills: deriveConceptKeySkills('negotiator'),
    reputationModifier: 1,
  },
  operative: {
    keyAttribute: 'agility',
    keySkills: deriveConceptKeySkills('operative'),
    reputationModifier: 0,
  },
  pilot: {
    keyAttribute: 'agility',
    keySkills: deriveConceptKeySkills('pilot'),
    reputationModifier: 0,
  },
  pioneer: {
    keyAttribute: 'wits',
    keySkills: deriveConceptKeySkills('pioneer'),
    reputationModifier: 0,
  },
  preacher: {
    keyAttribute: 'empathy',
    keySkills: deriveConceptKeySkills('preacher'),
    reputationModifier: 1,
  },
  scientist: {
    keyAttribute: 'wits',
    keySkills: deriveConceptKeySkills('scientist'),
    reputationModifier: 1,
  },
  sailor: {
    keyAttribute: 'strength',
    keySkills: deriveConceptKeySkills('sailor'),
    reputationModifier: -1,
  },
  soldier: {
    keyAttribute: 'agility',
    keySkills: deriveConceptKeySkills('soldier'),
    reputationModifier: -1,
  },
});

/**
 * Coriolis core book ch.2 §АМПЛУА КОМАНДЫ — five canonical crews. The team
 * picks one at character creation; all heroes in the campaign share it.
 * Members of the crew share access to one crew talent (one of the three the
 * crew amplua offers); on each character's sheet that talent is recorded as
 * `kind: crew`.
 */
export type CrewConcept = 'free-trader' | 'mercenary' | 'explorer' | 'agents' | 'pilgrim';

/**
 * Discriminator for `Talent.kind`. Each character has at most one of each
 * non-`personal` kind at creation; further talents acquired during play are
 * always `personal`. `iconGift` is auto-derived from the character's icon
 * (one talent per icon — see `@app/specs#getIconGiftByIconId`).
 */
export type TalentKind = 'personal' | 'crew' | 'iconGift' | 'stigma';

/**
 * Sum of attribute values, used for budget validation.
 * Per ch.2 every attribute must be 2..4 (or 5 for the amplua's key attribute,
 * enforced in Block 2). Sum must not exceed UPBRINGING_BUDGETS[u].attributes.
 */
export function sumAttributes(attrs: Record<string, number>): number {
  return Object.values(attrs).reduce((s, v) => s + v, 0);
}

/**
 * Sum of skill values, used for budget validation.
 * Per ch.2 sum must not exceed UPBRINGING_BUDGETS[u].skills.
 */
export function sumSkills(skills: Record<string, number>): number {
  return Object.values(skills).reduce((s, v) => s + v, 0);
}

// --------------- HP ---------------

/**
 * PRD §5.2: "HP max = STR + AGI"
 *
 * Attribute range is 1–5 (PRD §5.2), so valid output range is 2–10.
 */
export function computeHpMax(strength: number, agility: number): number {
  return strength + agility;
}

// --------------- MP ---------------

/**
 * PRD §5.2: "MP max = WIT + EMP"
 *
 * Attribute range is 1–5 (PRD §5.2), so valid output range is 2–10.
 */
export function computeMpMax(wits: number, empathy: number): number {
  return wits + empathy;
}

// --------------- Encumbrance ---------------

/**
 * PRD §5.2: "Encumbrance limit = STR × 2"
 *
 * Attribute range is 1–5, so valid output range is 2–10.
 */
export function computeEncumbranceMax(strength: number): number {
  return strength * 2;
}

/**
 * PRD §5.3: Encumbrance is the sum of weights of items.
 *
 * Assumption (PRD does not explicitly exempt CYBERNETIC from weight):
 * All items carry `weight: number` on the common payload stored in `data`.
 * We sum the `weight` field across all items. If a CYBERNETIC item has
 * `weight: 0` in its stored data, it contributes zero encumbrance. This is
 * consistent with the schema where `weight` is a common field for every
 * item type. Phase 2 (Feature 5.4) can add exemption logic if rule-book
 * research confirms cybs are always weight-free.
 *
 * Items without a `weight` field in data are treated as 0 (defensive).
 */
export function computeEncumbranceCurrent(items: ItemReadModel[]): number {
  let total = 0;
  for (const item of items) {
    const data = item as Record<string, unknown>;
    const weight = typeof data['weight'] === 'number' ? data['weight'] : 0;
    total += weight;
  }
  return total;
}

// --------------- Condition dice-pool penalty ---------------

/**
 * PRD §5.3 / Epic 5 Feature 5.3 T-5.3.1.d:
 * Each active condition reduces the dice pool by 1.
 * The four conditions are: exhausted, sleepless, thirsty, hungry.
 * Result is clamped to 0 — the pool can never go negative.
 *
 * ConditionFlags schema: packages/specs/openapi/openapi.yaml#/components/schemas/ConditionFlags
 */
export interface ConditionFlags {
  exhausted: boolean;
  sleepless: boolean;
  thirsty: boolean;
  hungry: boolean;
}

export function applyConditions(conditions: ConditionFlags, basePool: number): number {
  const active =
    (conditions.exhausted ? 1 : 0) +
    (conditions.sleepless ? 1 : 0) +
    (conditions.thirsty ? 1 : 0) +
    (conditions.hungry ? 1 : 0);
  return Math.max(0, basePool - active);
}

// --------------- Push eligibility ---------------

export type CanPushResult = { ok: true } | { ok: false; reason: 'ALREADY_PUSHED' | 'EXHAUSTED' };

/**
 * PRD §10: A roll can be pushed if:
 *   1. The character is not Exhausted (Exhausted blocks push).
 *   2. The roll has not already been pushed (one push per roll).
 *
 * Only the `exhausted` condition flag blocks push; sleepless / thirsty / hungry
 * do not (PRD §10 explicitly singles out Exhausted).
 *
 * Returns `{ ok: true }` when the push is allowed, or `{ ok: false, reason }`
 * with a machine-readable code when it is blocked.
 */
export function canPush(
  roll: { pushed: boolean },
  conditions: { exhausted: boolean },
): CanPushResult {
  if (roll.pushed) return { ok: false, reason: 'ALREADY_PUSHED' };
  if (conditions.exhausted) return { ok: false, reason: 'EXHAUSTED' };
  return { ok: true };
}

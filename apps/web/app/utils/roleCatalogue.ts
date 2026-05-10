/**
 * Coriolis web role catalogue — pure data, no I/O, no NestJS.
 *
 * Mirrors apps/backend/src/modules/rules-engine/rules-engine.ts
 * (CONCEPT_ROLES) one-for-one. Maintained separately because the web tree
 * is independent of the backend tree at runtime; the only shared edge is
 * @app/api-client-ts. A drift test (roleCatalogue.spec.ts) asserts that
 * every Role value from the regenerated TS client is covered here.
 *
 * Source: ST3001 ГЛАВА 2 «АМПЛУА И РОЛИ».
 */

import type { Concept, Role } from '@app/api-client-ts';

/**
 * The 16 canonical skill keys, matching the backend's SkillKey type
 * (rules-engine.ts) and the OpenAPI schema.
 */
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

/** The 4 canonical key skills for a given role (ST3001 ch.2). */
export type RoleKeySkills = readonly [SkillKey, SkillKey, SkillKey, SkillKey];

// --------------- Concept → Roles ---------------

/**
 * Concept → ordered triple of roles in the canonical ST3001 sequence.
 * Order matches ГЛАВА 2 table order and determines UI render order.
 */
export const CONCEPT_ROLES: Readonly<Record<Concept, readonly [Role, Role, Role]>> = Object.freeze({
  artist: ['companion', 'musician', 'poet'],
  networker: ['analyst', 'correspondent', 'network-djinn'],
  fugitive: ['criminal', 'mystic', 'revolutionary'],
  negotiator: ['agitator', 'diplomat', 'dealer'],
  operative: ['assassin', 'guard', 'spy'],
  pilot: ['ace', 'driver', 'trucker'],
  pioneer: ['colonist', 'prospector', 'scout'],
  preacher: ['ascetic', 'missionary', 'prophet'],
  scientist: ['archaeologist', 'medicurg', 'technologist'],
  sailor: ['ship-engineer', 'labourer', 'loader'],
  soldier: ['legionnaire', 'mercenary', 'officer'],
} as const);

// --------------- Role → Key Skills ---------------

/**
 * Role → its 4 canonical key skills (ST3001 ch.2 «КЛЮЧЕВЫЕ НАВЫКИ»).
 * All 33 entries are populated verbatim from the rulebook table.
 */
export const ROLE_KEY_SKILLS: Readonly<Record<Role, RoleKeySkills>> = Object.freeze({
  // artist
  companion: ['manipulation', 'culture', 'dexterity', 'observation'] as const,
  musician: ['manipulation', 'culture', 'infiltration', 'observation'] as const,
  poet: ['manipulation', 'culture', 'dexterity', 'infiltration'] as const,
  // networker
  analyst: ['dataDjinn', 'culture', 'manipulation', 'science'] as const,
  correspondent: ['culture', 'manipulation', 'infiltration', 'observation'] as const,
  'network-djinn': ['dataDjinn', 'manipulation', 'observation', 'science'] as const,
  // fugitive
  criminal: ['force', 'meleeCombat', 'dexterity', 'infiltration'] as const,
  mystic: ['manipulation', 'mysticPowers', 'dexterity', 'infiltration'] as const,
  revolutionary: ['rangedCombat', 'dexterity', 'observation', 'survival'] as const,
  // negotiator
  agitator: ['dataDjinn', 'force', 'manipulation', 'culture'] as const,
  diplomat: ['command', 'culture', 'manipulation', 'meleeCombat'] as const,
  dealer: ['culture', 'manipulation', 'observation', 'pilot'] as const,
  // operative
  assassin: ['infiltration', 'dexterity', 'meleeCombat', 'rangedCombat'] as const,
  guard: ['force', 'meleeCombat', 'rangedCombat', 'observation'] as const,
  spy: ['dataDjinn', 'manipulation', 'infiltration', 'rangedCombat'] as const,
  // pilot
  ace: ['dataDjinn', 'pilot', 'rangedCombat', 'technology'] as const,
  driver: ['force', 'pilot', 'rangedCombat', 'survival'] as const,
  trucker: ['dataDjinn', 'force', 'pilot', 'technology'] as const,
  // pioneer
  colonist: ['force', 'dexterity', 'rangedCombat', 'survival'] as const,
  prospector: ['pilot', 'technology', 'science', 'survival'] as const,
  scout: ['infiltration', 'rangedCombat', 'observation', 'survival'] as const,
  // preacher
  ascetic: ['force', 'culture', 'dexterity', 'science'] as const,
  missionary: ['culture', 'manipulation', 'dexterity', 'survival'] as const,
  prophet: ['force', 'culture', 'manipulation', 'observation'] as const,
  // scientist
  archaeologist: ['culture', 'observation', 'science', 'survival'] as const,
  medicurg: ['medicurgy', 'manipulation', 'observation', 'science'] as const,
  technologist: ['force', 'technology', 'observation', 'science'] as const,
  // sailor
  'ship-engineer': ['dataDjinn', 'force', 'observation', 'technology'] as const,
  labourer: ['force', 'manipulation', 'dexterity', 'culture'] as const,
  loader: ['force', 'meleeCombat', 'dexterity', 'technology'] as const,
  // soldier
  legionnaire: ['force', 'meleeCombat', 'rangedCombat', 'survival'] as const,
  mercenary: ['meleeCombat', 'dexterity', 'observation', 'rangedCombat'] as const,
  officer: ['command', 'culture', 'meleeCombat', 'rangedCombat'] as const,
} satisfies Record<Role, RoleKeySkills>);

// --------------- Reverse lookup: Role → Concept ---------------

/**
 * Role → its parent concept. Derived at module load from CONCEPT_ROLES.
 * Used for validation: the wire already rejects ROLE_CONCEPT_MISMATCH, but
 * this gives client-side components an early guard without a network call.
 */
export const CONCEPT_BY_ROLE: Readonly<Record<Role, Concept>> = Object.freeze(
  Object.fromEntries(
    (Object.keys(CONCEPT_ROLES) as Concept[]).flatMap((concept) =>
      CONCEPT_ROLES[concept].map((role) => [role, concept] as const),
    ),
  ) as Record<Role, Concept>,
);

// --------------- Helper functions ---------------

/**
 * Returns the 3 canonical roles for a concept in ST3001 order.
 * Returns an empty array when concept is null (convenience for
 * components that hold a nullable selection state).
 */
export function rolesForConcept(concept: Concept | null): readonly Role[] {
  return concept ? CONCEPT_ROLES[concept] : [];
}

/**
 * Returns the 4 canonical key skills for a role.
 * Throws on an unknown role string — catches typos in component code early.
 * (The wire already rejects invalid roles, so this is a dev-time guard.)
 */
export function keySkillsForRole(role: Role): RoleKeySkills {
  // Callers may pass `unknown as Role` (e.g. deserialised wire data that
  // bypassed validation). The lookup is typed as Record<Role,…> so TS sees
  // the condition as always-false for well-typed inputs — that's intentional:
  // the guard fires only when a non-canonical string is cast to Role.

  const skills = (ROLE_KEY_SKILLS as Record<string, RoleKeySkills | undefined>)[role];
  if (!skills) throw new Error(`Unknown role: ${role}`);
  return skills;
}

/**
 * Returns the concept that owns a role.
 * Throws on an unknown role string (same defensive rationale as above).
 */
export function conceptForRole(role: Role): Concept {
  // Same defensive pattern: guard fires only when a non-canonical string is
  // cast to Role — TypeScript cannot model that at the call site.
  const concept = (CONCEPT_BY_ROLE as Record<string, Concept | undefined>)[role];
  if (!concept) throw new Error(`Unknown role: ${role}`);
  return concept;
}

// Re-export for consumers that only pull from this module.

export { type Concept, type Role } from '@app/api-client-ts';

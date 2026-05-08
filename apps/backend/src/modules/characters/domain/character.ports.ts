/**
 * WHY this file exists:
 * Port interfaces decouple the domain/application layer from Prisma.
 * Handlers inject ICharacterRepo by token (CHARACTER_REPO); the Prisma adapter
 * in infra/ implements the interface. This allows unit tests to swap in vi.fn()
 * mocks without bootstrapping a database.
 *
 * Read models are scoped to use-case needs: list projection omits heavy nested
 * arrays; full projection includes inventory, talents, relationships, injuries.
 */

// ---- Value types matching OpenAPI schema ----

export interface Attributes {
  strength: number;
  agility: number;
  wits: number;
  empathy: number;
}

export const DEFAULT_ATTRIBUTES: Attributes = {
  strength: 2,
  agility: 2,
  wits: 2,
  empathy: 2,
};

export interface Skills {
  dexterity: number;
  force: number;
  infiltration: number;
  manipulation: number;
  meleeCombat: number;
  observation: number;
  rangedCombat: number;
  survival: number;
  command: number;
  culture: number;
  dataDjinn: number;
  medicurgy: number;
  mysticPowers: number;
  pilot: number;
  science: number;
  technology: number;
}

export const DEFAULT_SKILLS: Skills = {
  dexterity: 0,
  force: 0,
  infiltration: 0,
  manipulation: 0,
  meleeCombat: 0,
  observation: 0,
  rangedCombat: 0,
  survival: 0,
  command: 0,
  culture: 0,
  dataDjinn: 0,
  medicurgy: 0,
  mysticPowers: 0,
  pilot: 0,
  science: 0,
  technology: 0,
};

export const DEFAULT_CONDITIONS: ConditionFlags = {
  exhausted: false,
  sleepless: false,
  thirsty: false,
  hungry: false,
};

export interface ConditionFlags {
  exhausted: boolean;
  sleepless: boolean;
  thirsty: boolean;
  hungry: boolean;
}

export type IconId =
  | 'lady-of-tears'
  | 'traveler'
  | 'messenger'
  | 'merchant'
  | 'dancer'
  | 'gambler'
  | 'judge'
  | 'faceless-one'
  | 'deckhand';

export type RelationshipKind = 'ally' | 'rival' | 'family' | 'mentor' | 'debtor' | 'creditor';
export type CriticalInjurySeverity = 'LIGHT' | 'SEVERE' | 'CRITICAL';
export type ItemType = 'WEAPON' | 'ARMOR' | 'GEAR' | 'CYBERNETIC' | 'SHIP_MODULE' | 'OTHER';

export interface TalentReadModel {
  id: string;
  name: string;
  description: string;
  rank: number;
  acquiredAt: string; // ISO-8601
}

export interface RelationshipReadModel {
  id: string;
  targetName: string;
  kind: RelationshipKind;
  notes: string | null;
}

export interface CriticalInjuryReadModel {
  id: string;
  name: string;
  severity: CriticalInjurySeverity;
  effect: string;
  acquiredAt: string; // ISO-8601
}

export interface ItemReadModel {
  id: string;
  type: ItemType;
  // type-specific payload merged at the read layer
  [key: string]: unknown;
}

/**
 * Full character read model — returned by get, create, update, duplicate, export.
 * Derived fields (hp.max, mp.max, encumbrance.max) are placeholder constants
 * until Story 3.2.2 (rules-engine) ships.
 */
export interface CharacterReadModel {
  id: string;
  ownerId: string;
  name: string;
  concept: string | null;
  iconId: IconId | null;
  attributes: Attributes;
  skills: Skills;
  hp: {
    current: number;
    /** TODO(rules-engine, T-3.2.2): replace with computeHpMax(strength, agility) */
    max: number;
  };
  mp: {
    current: number;
    /** TODO(rules-engine, T-3.2.2): replace with computeMpMax(wits, empathy) */
    max: number;
  };
  encumbrance: {
    /** TODO(rules-engine, T-3.2.2): replace with sum of equipped item weights */
    current: number;
    /** TODO(rules-engine, T-3.2.2): replace with computeEncumbrance(strength) */
    max: number;
  };
  experience: number;
  conditions: ConditionFlags;
  criticalInjuries: CriticalInjuryReadModel[];
  talents: TalentReadModel[];
  relationships: RelationshipReadModel[];
  inventory: ItemReadModel[];
  notes: string | null;
  createdAt: string; // ISO-8601
  updatedAt: string; // ISO-8601
}

/**
 * Lightweight summary for list endpoint — avoids over-fetching nested arrays.
 */
export interface CharacterListItem {
  id: string;
  ownerId: string;
  name: string;
  concept: string | null;
  iconId: IconId | null;
  hp: { current: number; max: number };
  mp: { current: number; max: number };
  conditions: ConditionFlags;
  createdAt: string;
  updatedAt: string;
}

export const CHARACTER_REPO = Symbol('CHARACTER_REPO');

export interface ListCharactersOptions {
  ownerId: string;
  limit: number;
  cursor?: string;
}

export interface ICharacterRepo {
  findActiveById(id: string): Promise<CharacterReadModel | null>;

  /**
   * Find a character by id without the ownership check (used by guards
   * to verify ownership before dispatching commands).
   */
  findOwnerIdById(id: string): Promise<{ ownerId: string } | null>;

  list(opts: ListCharactersOptions): Promise<{ items: CharacterListItem[]; nextCursor: string | null }>;

  create(data: {
    ownerId: string;
    name: string;
    concept?: string | null;
    iconId?: IconId | null;
    attributes: Attributes;
    skills: Skills;
    hpCurrent: number;
    mpCurrent: number;
    experience: number;
    conditions: ConditionFlags;
    notes?: string | null;
  }): Promise<CharacterReadModel>;

  update(
    id: string,
    data: Partial<{
      name: string;
      concept: string | null;
      iconId: IconId | null;
      attributes: Attributes;
      skills: Skills;
      hpCurrent: number;
      mpCurrent: number;
      experience: number;
      conditions: ConditionFlags;
      criticalInjuries: Array<{
        name: string;
        severity: CriticalInjurySeverity;
        effect: string;
        acquiredAt: string;
      }>;
      notes: string | null;
    }>,
  ): Promise<CharacterReadModel>;

  delete(id: string): Promise<void>;
}

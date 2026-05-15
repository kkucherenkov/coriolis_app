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

export type Upbringing = 'plebeian' | 'stationary' | 'aristocrat';

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

export type CrewConcept = 'free-trader' | 'mercenary' | 'explorer' | 'agents' | 'pilgrim';

export type MutantLineage = 'zirba' | 'shingura' | 'nerida';

export type TalentKind = 'personal' | 'crew' | 'iconGift' | 'stigma';

/**
 * Lifecycle state of a character.
 * Matches the OpenAPI enum `draft | active` (lowercase wire) and maps
 * to the Prisma enum DRAFT | ACTIVE (UPPERCASE DB).
 */
export type CharacterStatus = 'draft' | 'active';

export type RelationshipKind = 'ally' | 'rival' | 'family' | 'mentor' | 'debtor' | 'creditor';
export type CriticalInjurySeverity = 'LIGHT' | 'SEVERE' | 'CRITICAL';
export type ItemType = 'WEAPON' | 'ARMOR' | 'GEAR' | 'CYBERNETIC' | 'SHIP_MODULE' | 'OTHER';

export interface TalentReadModel {
  id: string;
  kind: TalentKind;
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
  concept: Concept | null;
  /**
   * Canonical role within the chosen amplua (ГЛАВА 2 «АМПЛУА И РОЛИ»).
   * Null for drafts that pre-date role-tracking and for new drafts where the
   * user hasn't picked a role yet.
   */
  role: string | null;
  /**
   * True when `role` was set by the canon-alignment backfill migration rather
   * than by an explicit user pick. The wizard re-prompts for a role on the
   * next edit when this is true; once the user confirms, the handler clears
   * the flag.
   */
  roleUnmigrated: boolean;
  iconId: IconId | null;
  upbringing: Upbringing;
  origin: string | null;
  reputation: number;
  startingWealth: number;
  /**
   * Current spendable birr balance (the character's wallet). Seeded as
   * `birr = startingWealth` on the wizard's draft → active forge
   * transition; while `status: 'draft'` the handler keeps `birr` in
   * lockstep with `startingWealth` so changing `upbringing` does not
   * strand a stale balance. Mutable via PATCH only after activation —
   * draft writes are rejected with `BIRR_DRAFT_IMMUTABLE`.
   */
  birr: number;
  crewConcept: CrewConcept | null;
  mutant: boolean;
  mutantLineage: MutantLineage | null;
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
  /** Lifecycle state: 'draft' (wizard-in-progress) or 'active' (published). */
  status: CharacterStatus;
  createdAt: string; // ISO-8601
  updatedAt: string; // ISO-8601
}

export const CHARACTER_REPO = Symbol('CHARACTER_REPO');

export interface ListCharactersOptions {
  ownerId: string;
  limit: number;
  cursor?: string;
  /** When true, both draft and active characters are returned. Default: false (active only). */
  includeDrafts?: boolean;
}

export interface ICharacterRepo {
  /**
   * Find a character by id regardless of status (used by update, get-one, export).
   * Returns null if not found.
   */
  findActiveById(id: string): Promise<CharacterReadModel | null>;

  /**
   * Find a character by id without the ownership check (used by guards
   * to verify ownership before dispatching commands).
   */
  findOwnerIdById(id: string): Promise<{ ownerId: string } | null>;

  /**
   * Returns full `CharacterReadModel` objects per the OpenAPI contract
   * (`CharacterList.items: $ref: Character`). The list endpoint and the
   * single-character endpoint share the same projection.
   */
  list(
    opts: ListCharactersOptions,
  ): Promise<{ items: CharacterReadModel[]; nextCursor: string | null }>;

  create(data: {
    ownerId: string;
    name: string;
    concept?: Concept | null;
    /** Canonical role within the chosen amplua. Null until the wizard picks one. */
    role?: string | null;
    /** True only when set by the backfill migration; false for explicit user picks. */
    roleUnmigrated?: boolean;
    iconId?: IconId | null;
    upbringing: Upbringing;
    origin?: string | null;
    reputation: number;
    startingWealth: number;
    /** Current wallet balance. The handler seeds this from `startingWealth`. */
    birr: number;
    crewConcept?: CrewConcept | null;
    mutant?: boolean;
    mutantLineage?: MutantLineage | null;
    attributes: Attributes;
    skills: Skills;
    hpCurrent: number;
    mpCurrent: number;
    experience: number;
    conditions: ConditionFlags;
    notes?: string | null;
    /** Talents recorded at character creation (e.g. iconGift auto-derived from icon). */
    talents?: { kind: TalentKind; name: string; description: string; rank?: number }[];
    /** Lifecycle state. Defaults to 'active' when omitted. */
    status?: CharacterStatus;
  }): Promise<CharacterReadModel>;

  update(
    id: string,
    data: Partial<{
      name: string;
      concept: Concept | null;
      /** Canonical role within the chosen amplua. */
      role: string | null;
      /** Cleared (set to false) when the user explicitly picks a role. */
      roleUnmigrated: boolean;
      iconId: IconId | null;
      upbringing: Upbringing;
      origin: string | null;
      reputation: number;
      /** Current wallet balance — only writable while status is 'active'. */
      birr: number;
      crewConcept: CrewConcept | null;
      mutant: boolean;
      mutantLineage: MutantLineage | null;
      attributes: Attributes;
      skills: Skills;
      hpCurrent: number;
      mpCurrent: number;
      experience: number;
      conditions: ConditionFlags;
      criticalInjuries: {
        name: string;
        severity: CriticalInjurySeverity;
        effect: string;
        acquiredAt: string;
      }[];
      notes: string | null;
      /** Status transition. Only draft → active is permitted at the handler layer. */
      status: CharacterStatus;
    }>,
  ): Promise<CharacterReadModel>;

  /**
   * Delete abandoned drafts older than the provided cutoff date.
   * Returns the number of rows deleted.
   */
  deleteAbandonedDrafts(cutoff: Date): Promise<number>;

  delete(id: string): Promise<void>;
}

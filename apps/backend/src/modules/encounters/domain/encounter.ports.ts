/**
 * WHY this file exists:
 * Port interfaces decouple the application layer from Prisma.
 * Handlers inject IEncounterRepo by token (ENCOUNTER_REPO).
 * The Prisma adapter in infra/ implements the interface.
 * Unit tests swap in vi.fn() mocks without bootstrapping a database.
 *
 * EncounterReadModel matches the OpenAPI Encounter schema exactly.
 * status uses lowercase wire values ('setup' | 'active' | 'ended') — conversion
 * from Prisma uppercase enum happens in the infra mapper.
 */

export type EncounterStatus = 'setup' | 'active' | 'ended';

export interface EncounterReadModel {
  id: string;
  gameSessionId: string;
  name: string;
  notes: string | null;
  status: EncounterStatus;
  round: number;
  activeCombatantId: string | null;
  createdAt: string; // ISO-8601
  updatedAt: string; // ISO-8601
}

export interface EncounterListOptions {
  gameSessionId: string;
  limit: number;
  cursor?: string;
  status?: EncounterStatus;
}

export interface EncounterCreateData {
  gameSessionId: string;
  name: string;
  notes?: string | null;
}

export interface EncounterUpdateData {
  name?: string;
  notes?: string | null;
  status?: EncounterStatus;
  round?: number;
  activeCombatantId?: string | null;
}

export const ENCOUNTER_REPO = Symbol('ENCOUNTER_REPO');

export interface IEncounterRepo {
  findById(id: string): Promise<EncounterReadModel | null>;

  list(
    opts: EncounterListOptions,
  ): Promise<{ items: EncounterReadModel[]; nextCursor: string | null }>;

  create(data: EncounterCreateData): Promise<EncounterReadModel>;

  update(id: string, data: EncounterUpdateData): Promise<EncounterReadModel>;

  delete(id: string): Promise<void>;
}

// --------------- Initiative transactions ---------------

export interface CombatantInitiativePatch {
  id: string;
  initiative: number;
  turnOrder: number;
}

export interface RollInitiativeData {
  encounterId: string;
  combatantPatches: CombatantInitiativePatch[];
  /** New encounter state after roll */
  activeCombatantId: string;
}

export interface ReorderInitiativeData {
  encounterId: string;
  /** Ordered list of combatant ids; index = new turnOrder */
  orderedIds: string[];
}

export interface AdvanceTurnData {
  encounterId: string;
  activeCombatantId: string;
  round: number;
}

/** Rolled/reordered combatant read model (includes initiative fields) */
export interface InitiativeRollResult {
  round: number;
  combatants: import('../../combatants/domain/combatant.ports').CombatantReadModel[];
}

export interface TurnAdvanceResult {
  activeCombatantId: string;
  round: number;
  isNewRound: boolean;
}

export const INITIATIVE_REPO = Symbol('INITIATIVE_REPO');

export interface IInitiativeRepo {
  /**
   * Atomically: updates all combatant initiative/turnOrder fields,
   * transitions encounter setup→active, sets round=1 and activeCombatantId.
   * Returns combatants sorted by turnOrder asc.
   */
  rollInitiative(data: RollInitiativeData): Promise<InitiativeRollResult>;

  /**
   * Atomically: reassigns turnOrder to match orderedIds array positions.
   * Does NOT touch initiative, activeCombatantId, or round.
   * Returns combatants sorted by new turnOrder asc.
   */
  reorderInitiative(data: ReorderInitiativeData): Promise<InitiativeRollResult>;

  /**
   * Atomically: advances activeCombatantId and optionally increments round.
   */
  advanceTurn(data: AdvanceTurnData): Promise<void>;
}

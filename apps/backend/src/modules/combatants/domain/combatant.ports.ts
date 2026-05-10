/**
 * WHY this file exists:
 * Port interfaces decouple the application layer from Prisma.
 * Handlers inject ICombatantRepo by token (COMBATANT_REPO).
 * The Prisma adapter in infra/ implements the interface.
 * Unit tests swap in vi.fn() mocks without bootstrapping a database.
 *
 * CombatantReadModel matches the OpenAPI Combatant schema exactly.
 * combatantType uses lowercase wire values ('pc' | 'npc') — conversion
 * from Prisma uppercase enum happens in the infra mapper.
 *
 * CombatantCountPort is a minimal interface used by the encounters module
 * to check hasCombatants without creating a circular dependency between
 * the two bounded contexts. The encounters module imports only this token;
 * the combatants module provides the implementation.
 */

export type CombatantTypeValue = 'pc' | 'npc';

/** Snapshot stored inside the Combatant row for Block 4 initiative tie-breaking. */
export interface PcSnapshot {
  attributes: {
    strength: number;
    agility: number;
    wits: number;
    empathy: number;
  };
  skills: Record<string, number>;
  hpMax: number;
}

export interface NpcSnapshot {
  attributes: {
    strength: number;
    agility: number;
    wits: number;
    empathy: number;
  };
  skills: Record<string, number>;
  hpMax: number;
  signature: number;
}

export interface CombatantReadModel {
  id: string;
  encounterId: string;
  combatantType: CombatantTypeValue;
  sourceId: string; // characterId or npcId
  displayName: string;
  initiative: number | null;
  turnOrder: number | null;
  hpCurrent: number;
  hpMax: number;
  armor: number;
  signature: number;
  statusFlags: string[];
  notes: string | null;
  createdAt: string; // ISO-8601
  updatedAt: string; // ISO-8601
}

export interface CombatantCreateData {
  encounterId: string;
  combatantType: CombatantTypeValue;
  characterId?: string;
  npcId?: string;
  displayName: string;
  hpCurrent: number;
  hpMax: number;
  armor: number;
  signature: number;
  notes?: string | null;
  pcSnapshot?: PcSnapshot;
  npcSnapshot?: NpcSnapshot;
}

export interface CombatantUpdateData {
  displayName?: string;
  hpCurrent?: number;
  armor?: number;
  signature?: number;
  statusFlags?: string[];
  notes?: string | null;
  // Block 4 initiative fields — set only by initiative handlers
  initiative?: number | null;
  turnOrder?: number | null;
}

export const COMBATANT_REPO = Symbol('COMBATANT_REPO');

export interface ICombatantRepo {
  findById(id: string): Promise<CombatantReadModel | null>;

  listByEncounter(encounterId: string): Promise<CombatantReadModel[]>;

  create(data: CombatantCreateData): Promise<CombatantReadModel>;

  update(id: string, data: CombatantUpdateData): Promise<CombatantReadModel>;

  delete(id: string): Promise<void>;

  countByEncounter(encounterId: string): Promise<number>;
}

/**
 * Minimal port used by the encounters module to count combatants
 * without depending on the full ICombatantRepo interface.
 * Lives here (in combatant.ports.ts) but is provided by CombatantRepo.
 */
export const COMBATANT_COUNT = Symbol('COMBATANT_COUNT');

export interface ICombatantCount {
  countByEncounter(encounterId: string): Promise<number>;
}

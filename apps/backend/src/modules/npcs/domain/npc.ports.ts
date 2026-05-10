/**
 * WHY this file exists:
 * Port interfaces decouple the application layer from Prisma.
 * Handlers inject INpcRepo by token (NPC_REPO).
 * The Prisma adapter in infra/ implements the interface.
 * Unit tests swap in vi.fn() mocks without bootstrapping a database.
 *
 * NpcReadModel matches the OpenAPI Npc schema exactly.
 * attributes and skills are stored as JSON columns on the DB side;
 * on the wire they are typed objects.
 */

export interface NpcAttributes {
  strength: number;
  agility: number;
  wits: number;
  empathy: number;
}

export interface NpcSkills {
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

export interface NpcItemArmor {
  type: 'armor';
  name: string;
  armorRating: number;
  weight?: number | null;
  features?: string[] | null;
  equipped?: boolean | null;
  [key: string]: unknown;
}

export interface NpcItemWeapon {
  type: 'weapon';
  name: string;
  damage: number;
  range?: string | null;
  bonus?: number | null;
  crit?: number | null;
  weight?: number | null;
  features?: string[] | null;
  equipped?: boolean | null;
  [key: string]: unknown;
}

export interface NpcReadModel {
  id: string;
  ownerId: string;
  name: string;
  description: string | null;
  attributes: NpcAttributes;
  skills: NpcSkills;
  hp: { current: number; max: number };
  mp: { current: number; max: number };
  signature: number;
  keySkillModifier: number;
  armor: NpcItemArmor[];
  weapons: NpcItemWeapon[];
  tags: string[];
  createdAt: string; // ISO-8601
  updatedAt: string; // ISO-8601
}

export interface NpcListOptions {
  ownerId: string;
  limit: number;
  cursor?: string;
}

export interface NpcCreateData {
  ownerId: string;
  name: string;
  description?: string | null;
  attributes: NpcAttributes;
  skills: NpcSkills;
  hpCurrent: number;
  hpMax: number;
  mpCurrent: number;
  mpMax: number;
  signature: number;
  keySkillModifier: number;
  armor: NpcItemArmor[];
  weapons: NpcItemWeapon[];
  tags: string[];
}

export interface NpcUpdateData {
  name?: string;
  description?: string | null;
  attributes?: NpcAttributes;
  skills?: NpcSkills;
  hpCurrent?: number;
  hpMax?: number;
  mpCurrent?: number;
  mpMax?: number;
  signature?: number;
  keySkillModifier?: number;
  armor?: NpcItemArmor[];
  weapons?: NpcItemWeapon[];
  tags?: string[];
}

export const NPC_REPO = Symbol('NPC_REPO');

export interface INpcRepo {
  findById(id: string): Promise<NpcReadModel | null>;

  list(opts: NpcListOptions): Promise<{ items: NpcReadModel[]; nextCursor: string | null }>;

  create(data: NpcCreateData): Promise<NpcReadModel>;

  update(id: string, data: NpcUpdateData): Promise<NpcReadModel>;

  delete(id: string): Promise<void>;

  duplicate(sourceId: string, ownerId: string, newName: string): Promise<NpcReadModel>;

  listNamesByPrefix(ownerId: string, prefix: string): Promise<string[]>;
}

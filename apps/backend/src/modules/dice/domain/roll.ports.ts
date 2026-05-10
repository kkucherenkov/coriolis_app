/**
 * WHY this file exists:
 * Port interfaces and read models for the dice bounded context.
 * Handlers inject IRollRepo by token; the Prisma adapter in infra/ implements
 * the interface. This allows unit tests to swap in vi.fn() mocks without a DB.
 */

/**
 * Roll discriminator per ST3001 ГЛАВА 3 §«Вознесение молитв».
 * Only `skill` rolls can be pushed. The five canonical values mirror
 * the OpenAPI RollKind enum.
 */
export type RollKind = 'skill' | 'save' | 'trauma' | 'initiative' | 'darkness';

export const ROLL_KINDS: readonly RollKind[] = [
  'skill',
  'save',
  'trauma',
  'initiative',
  'darkness',
] as const;

/** Narrows an arbitrary string to RollKind; falls back to 'skill' on unknown values. */
export function toRollKind(value: string): RollKind {
  return (ROLL_KINDS as readonly string[]).includes(value)
    ? (value as RollKind)
    : 'skill';
}

export interface RollReadModel {
  id: string;
  characterId: string;
  gameSessionId: string | null;
  label: string;
  pool: number;
  dice: number[];
  hits: number;
  pushed: boolean;
  kind: RollKind;
  createdAt: string; // ISO-8601
}

export const ROLL_REPO = Symbol('ROLL_REPO');

export interface IRollRepo {
  create(data: {
    characterId: string;
    gameSessionId: string | null;
    label: string;
    pool: number;
    dice: number[];
    hits: number;
    kind: RollKind;
  }): Promise<RollReadModel>;

  findById(id: string): Promise<RollReadModel | null>;

  /**
   * Persist the pushed state of a roll after a push reroll.
   * Returns the updated read model.
   */
  push(id: string, dice: number[], hits: number): Promise<RollReadModel>;

  /**
   * Returns the most recent `limit` rolls for a character, ordered by
   * createdAt descending.
   */
  listByCharacterId(characterId: string, limit: number): Promise<RollReadModel[]>;
}

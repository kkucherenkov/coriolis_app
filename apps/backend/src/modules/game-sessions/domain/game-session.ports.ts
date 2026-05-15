/**
 * WHY this file exists:
 * Port interfaces decouple the application layer from Prisma.
 * Handlers inject IGameSessionRepo by token (GAME_SESSION_REPO).
 * The Prisma adapter in infra/ implements the interface.
 * Unit tests swap in vi.fn() mocks without bootstrapping a database.
 *
 * Read models match the OpenAPI GameSession schema exactly.
 * characterIds is assembled by the repo from the join table.
 */

import type { MembershipReadModel } from '../../memberships/domain/membership.ports';

export type GameSessionStatus = 'active' | 'archived';

export interface GameSessionReadModel {
  id: string;
  ownerId: string;
  name: string;
  description: string | null;
  status: GameSessionStatus;
  dpCount: number;
  characterIds: string[]; // deprecated, removed in Stream E
  memberships: MembershipReadModel[];
  shipId: string | null;
  createdAt: string; // ISO-8601
  updatedAt: string; // ISO-8601
}

export interface ListGameSessionsOptions {
  ownerId: string;
  limit: number;
  cursor?: string;
  /** When provided, filter sessions by this status. */
  status?: GameSessionStatus;
}

export const GAME_SESSION_REPO = Symbol('GAME_SESSION_REPO');

export interface IGameSessionRepo {
  findById(id: string): Promise<GameSessionReadModel | null>;

  list(
    opts: ListGameSessionsOptions,
  ): Promise<{ items: GameSessionReadModel[]; nextCursor: string | null }>;

  create(data: {
    ownerId: string;
    name: string;
    description?: string | null;
    shipId?: string | null;
  }): Promise<GameSessionReadModel>;

  update(
    id: string,
    data: Partial<{
      name: string;
      description: string | null;
      status: GameSessionStatus;
      shipId: string | null;
    }>,
  ): Promise<GameSessionReadModel>;

  delete(id: string): Promise<void>;

  /**
   * Assigns a character to a session. Idempotent — if already assigned, no
   * duplicate row is created. Returns the updated session read model.
   */
  assignCharacter(gameSessionId: string, characterId: string): Promise<GameSessionReadModel>;

  /**
   * Removes a character from a session. Silently succeeds if not assigned.
   */
  unassignCharacter(gameSessionId: string, characterId: string): Promise<void>;
}

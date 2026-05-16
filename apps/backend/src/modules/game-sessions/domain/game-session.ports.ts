/**
 * WHY this file exists:
 * Port interfaces decouple the application layer from Prisma.
 * Handlers inject IGameSessionRepo by token (GAME_SESSION_REPO).
 * The Prisma adapter in infra/ implements the interface.
 * Unit tests swap in vi.fn() mocks without bootstrapping a database.
 *
 * Read models match the OpenAPI GameSession schema exactly. As of Phase 8
 * Stream E, `GameSessionMembership` is the only source of truth for "who
 * is at this table" — the legacy `characterIds` array + the GM-only
 * assign/unassign join endpoints were dropped.
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
}

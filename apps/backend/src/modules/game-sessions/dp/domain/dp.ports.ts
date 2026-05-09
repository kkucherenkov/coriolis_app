/**
 * WHY this file exists:
 * Port interfaces for the DP sub-context. Handlers inject IDpRepo by the
 * DP_REPO token. The Prisma adapter in infra/ implements the interface.
 * Unit tests swap in vi.fn() mocks without bootstrapping a database.
 *
 * DpSource mirrors the Prisma enum and the OpenAPI DpSource schema.
 */

export type DpSource = 'GM_MANUAL' | 'ROLL_PUSH' | 'SYSTEM';

export interface DpEventReadModel {
  id: string;
  gameSessionId: string;
  delta: number;
  reason: string | null;
  source: DpSource;
  rollId: string | null;
  createdAt: string; // ISO-8601
}

export interface UpdateDpOptions {
  gameSessionId: string;
  delta: number;
  reason?: string | null;
  source: DpSource;
  /** Set when source === 'ROLL_PUSH'. */
  rollId?: string | null;
}

export interface ListDpEventsOptions {
  gameSessionId: string;
  limit: number;
  cursor?: string;
}

export const DP_REPO = Symbol('DP_REPO');

export interface IDpRepo {
  /**
   * Atomically increments/decrements dpCount on the GameSession and inserts
   * a DpEvent row in the same transaction. Returns the updated dpCount.
   *
   * Validates: dpCount + delta >= 0 is enforced at the handler layer before
   * calling this method, but the repo also uses `increment` so the DB is
   * authoritative.
   */
  applyDelta(opts: UpdateDpOptions): Promise<number>;

  listEvents(
    opts: ListDpEventsOptions,
  ): Promise<{ items: DpEventReadModel[]; nextCursor: string | null }>;
}

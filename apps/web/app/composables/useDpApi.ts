/**
 * useDpApi — Darkness Points HTTP layer for apps/web (Phase 4 Feature 7.3).
 *
 * Each adjustment is atomic on the server: the same transaction inserts a
 * `DpEvent` audit row and updates `GameSession.dpCount`. The HTTP response
 * returns the new session payload so the UI can patch its counter without
 * a follow-up GET; the audit list lives at the sibling endpoint and is
 * always GM-only.
 *
 * Permission model (mirrored from `apps/backend/src/modules/game-sessions/dp`):
 *   - Positive delta from a player → 403 GAME_SESSION_NOT_OWNER (only the
 *     GM owner — or the internal roll-push pipeline — may add).
 *   - Negative delta from anyone but the owner → 403.
 *   - Below-zero result → 422 DP_BELOW_ZERO.
 *   - Zero delta → 422 DP_INVALID_DELTA.
 *
 * API surface:
 *   POST /api/v1/game-sessions/{id}/dp        → adjustDp
 *   GET  /api/v1/game-sessions/{id}/dp/events → listDpEvents
 */

import { adjustDp, listDpEvents } from '@app/api-client-ts';
import type { GameSession, DpEvent, DpAdjustment, Problem } from '@app/api-client-ts';

export interface ListDpEventsOptions {
  limit?: number;
  cursor?: string;
}

export interface ListDpEventsResult {
  items: readonly DpEvent[];
  nextCursor: string | null;
}

export interface DpApiClient {
  adjust(sessionId: string, body: DpAdjustment): Promise<GameSession>;
  listEvents(sessionId: string, options?: ListDpEventsOptions): Promise<ListDpEventsResult>;
}

export function useDpApi(): DpApiClient {
  return {
    async adjust(sessionId, body) {
      const res = await adjustDp({ path: { id: sessionId }, body });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async listEvents(sessionId, options) {
      const res = await listDpEvents({ path: { id: sessionId }, query: options });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return { items: res.data.items, nextCursor: res.data.nextCursor };
    },
  };
}

export type { DpEvent, DpAdjustment, DpSource } from '@app/api-client-ts';

/**
 * useRollsApi — dice-roll HTTP layer for apps/web (Phase 4 Feature 7.1).
 *
 * Server holds the RNG; the client only describes what to roll and
 * displays the result. The push mechanic (PATCH /rolls/{id}/push) returns
 * the same `Roll` shape with non-six dice replaced and `pushed: true` —
 * the response is authoritative; never re-roll locally.
 *
 * API surface:
 *   POST  /api/v1/characters/{id}/rolls           → createRoll
 *   GET   /api/v1/characters/{id}/rolls?limit=50  → listRolls
 *   PATCH /api/v1/rolls/{id}/push                 → pushRoll
 *
 * Errors are thrown as the raw `Problem` object (RFC 9457). Callers
 * inspect `problem.status` / `problem.detail` for inline error
 * messaging — `pushRoll` in particular surfaces 422
 * `ROLL_NOT_PUSHABLE` when the roll was already pushed or the
 * character is exhausted.
 */

import { createRoll, listRolls, pushRoll } from '@app/api-client-ts';
import type { Roll, RollCreate, Problem } from '@app/api-client-ts';

export interface RollsApiClient {
  createRoll(characterId: string, body: RollCreate): Promise<Roll>;
  listRolls(characterId: string, limit?: number): Promise<readonly Roll[]>;
  pushRoll(rollId: string): Promise<Roll>;
}

export function useRollsApi(): RollsApiClient {
  return {
    async createRoll(characterId, body) {
      const res = await createRoll({ path: { id: characterId }, body });
      // WHY: SDK returns Problem plain object (RFC 9457), not an Error subclass.
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async listRolls(characterId, limit = 50) {
      const res = await listRolls({ path: { id: characterId }, query: { limit } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data.items;
    },

    async pushRoll(rollId) {
      const res = await pushRoll({ path: { id: rollId } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },
  };
}

// Note: `Problem` is re-exported by `useTalentsApi.ts`; Nuxt auto-import
// would warn on duplicate symbols if we re-exported it here too. Callers
// that already import from this composable can pull `Problem` from the
// auto-import or from `@app/api-client-ts` directly.
export type { Roll, RollCreate } from '@app/api-client-ts';

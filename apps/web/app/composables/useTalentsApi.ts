/**
 * useTalentsApi — talent-specific HTTP layer for apps/web.
 *
 * Kept as a sibling composable (not added to useCharactersApi.ts) to keep
 * useCharactersApi.ts under the ~250-line limit per module convention.
 *
 * API surface:
 *   POST   /api/v1/characters/{id}/talents  → addTalent
 *   PATCH  /api/v1/talents/{id}             → updateTalent
 *   DELETE /api/v1/talents/{id}             → removeTalent
 *
 * Errors are thrown as the raw `Problem` object (RFC 9457). Callers inspect
 * `problem.status` / `problem.detail` for inline error messaging.
 */

import { addCharacterTalent, updateTalent, deleteTalent } from '@app/api-client-ts';
import type { Talent, TalentCreate, TalentUpdate, Problem } from '@app/api-client-ts';

export interface TalentsApiClient {
  addTalent(characterId: string, body: TalentCreate): Promise<Talent>;
  updateTalent(talentId: string, body: TalentUpdate): Promise<Talent>;
  removeTalent(talentId: string): Promise<void>;
}

export function useTalentsApi(): TalentsApiClient {
  return {
    async addTalent(characterId, body) {
      const res = await addCharacterTalent({ path: { id: characterId }, body });
      // WHY: SDK returns Problem plain object (RFC 9457), not an Error subclass.
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async updateTalent(talentId, body) {
      const res = await updateTalent({ path: { id: talentId }, body });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async removeTalent(talentId) {
      const res = await deleteTalent({ path: { id: talentId } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
    },
  };
}

export type { Talent, TalentCreate, TalentUpdate, Problem } from '@app/api-client-ts';

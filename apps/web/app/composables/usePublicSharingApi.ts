/**
 * usePublicSharingApi — public (no-auth) HTTP layer for share-link endpoints.
 *
 * Only the read path is needed on the web client. No auth token is sent.
 * Errors are thrown as the raw `Problem` object (RFC 9457) so callers can
 * inspect `problem.status` to distinguish 404 / 410 / 5xx.
 *
 * Status semantics:
 *   200  — character payload returned.
 *   404  — slug unknown / never existed.
 *   410  — slug existed but was revoked or expired.
 *   5xx  — backend transient error.
 */

import { getPublicCharacter } from '@app/api-client-ts';
import type { Character, Problem } from '@app/api-client-ts';

export interface PublicSharingApiClient {
  getCharacter(slug: string): Promise<Character>;
}

export function usePublicSharingApi(): PublicSharingApiClient {
  return {
    async getCharacter(slug) {
      const res = await getPublicCharacter({ path: { slug } });
      // WHY: the generated SDK returns a Problem plain object (RFC 9457), not an
      // Error subclass. Callers inspect `problem.status` to route 404 vs 410
      // to the appropriate UI state. Same pattern as useCharactersApi.
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },
  };
}

// Problem is not re-exported here — it is already exposed via useTalentsApi.ts.
// Re-exporting it from multiple composables triggers Nuxt's "Duplicated imports"
// warning in the auto-import scanner.
export type { Character } from '@app/api-client-ts';

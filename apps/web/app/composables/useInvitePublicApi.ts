/**
 * useInvitePublicApi — public invite HTTP layer for apps/web (Phase 11 Stream B).
 *
 * Covers the two public/auth invite endpoints:
 *   GET  /api/v1/invites/:token/preview  — no auth required
 *   POST /api/v1/invites/:token/accept   — auth required
 *
 * Errors are thrown as the raw `Problem` object (RFC 9457). Callers
 * inspect `problem.status` / `problem.detail` for inline messaging.
 */

import { getInvitePreview, acceptInvite } from '@app/api-client-ts';
import type { InvitePreview, AcceptInviteResponse, Problem } from '@app/api-client-ts';

export interface InvitePublicApiClient {
  getPreview(token: string): Promise<InvitePreview>;
  accept(token: string, characterId?: string | null): Promise<AcceptInviteResponse>;
}

export function useInvitePublicApi(): InvitePublicApiClient {
  return {
    async getPreview(token) {
      const res = await getInvitePreview({ path: { token } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      // data is always present when error is absent; cast avoids the generated
      // SDK's ThrowOnError-conditional undefined union.
      return res.data as InvitePreview;
    },

    async accept(token, characterId) {
      const res = await acceptInvite({
        path: { token },
        body: { characterId: characterId ?? null },
      });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data as AcceptInviteResponse;
    },
  };
}

export type { InvitePreview, AcceptInviteResponse } from '@app/api-client-ts';

/**
 * useMyMembershipsApi — caller's membership HTTP layer for apps/web (Phase 11 Stream B).
 *
 * API surface:
 *   GET    /api/v1/me/memberships                          → list
 *   DELETE /api/v1/game-sessions/{id}/members/{membershipId} → leave
 *
 * Errors are thrown as the raw `Problem` object (RFC 9457). Callers
 * inspect `problem.status` / `problem.detail` for inline messaging.
 */

import { getMyMemberships, removeMembership } from '@app/api-client-ts';
import type { MyMembershipSummary, Problem } from '@app/api-client-ts';

export interface MyMembershipsApiClient {
  list(): Promise<MyMembershipSummary[]>;
  leave(gameSessionId: string, membershipId: string): Promise<void>;
}

export function useMyMembershipsApi(): MyMembershipsApiClient {
  return {
    async list() {
      const res = await getMyMemberships({});
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      // data is always present when error is absent; cast avoids the generated
      // SDK's ThrowOnError-conditional undefined union.
      return (res.data as { items: MyMembershipSummary[] }).items;
    },

    async leave(gameSessionId, membershipId) {
      const res = await removeMembership({
        path: { id: gameSessionId, membershipId },
      });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
    },
  };
}

export type { MyMembershipSummary } from '@app/api-client-ts';

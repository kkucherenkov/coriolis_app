/**
 * useInviteApi — invite HTTP layer for apps/web (Phase 8 Stream A).
 *
 * API surface:
 *   GET    /api/v1/game-sessions/{id}/invite         → getMetadata
 *   POST   /api/v1/game-sessions/{id}/invite/rotate  → rotate  (returns InviteRotated)
 *   DELETE /api/v1/game-sessions/{id}/invite         → revoke
 */

import { getInviteMetadata, rotateInvite, revokeInvite } from '@app/api-client-ts';
import type { InviteMetadata, InviteRotated, Problem } from '@app/api-client-ts';

export interface InviteApiClient {
  getMetadata(sessionId: string): Promise<InviteMetadata>;
  rotate(sessionId: string): Promise<InviteRotated>;
  revoke(sessionId: string): Promise<void>;
}

export function useInviteApi(): InviteApiClient {
  return {
    async getMetadata(sessionId) {
      const res = await getInviteMetadata({ path: { id: sessionId } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async rotate(sessionId) {
      const res = await rotateInvite({ path: { id: sessionId } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async revoke(sessionId) {
      const res = await revokeInvite({ path: { id: sessionId } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
    },
  };
}

export type { InviteMetadata, InviteRotated } from '@app/api-client-ts';

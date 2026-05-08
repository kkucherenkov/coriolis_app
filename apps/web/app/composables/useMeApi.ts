/**
 * useMeApi — /api/v1/me HTTP layer for apps/web.
 *
 * All calls to the authenticated-user profile endpoint go through this
 * composable. Internally delegates to the generated `@app/api-client-ts`
 * SDK functions. Errors are thrown as the raw `Problem` object (RFC 9457)
 * so callers can inspect `problem.status`, `problem.detail`, etc.
 *
 * Re-exports `Me` and `MeUpdate` so pages import from one place.
 */

import { getMe, updateMe, deleteMe } from '@app/api-client-ts';
import type { Me, MeUpdate, Problem } from '@app/api-client-ts';

export type { Me, MeUpdate, Problem };

export interface MeApiClient {
  get(): Promise<Me>;
  update(body: MeUpdate): Promise<Me>;
  deleteMe(): Promise<void>;
}

export function useMeApi(): MeApiClient {
  return {
    async get() {
      const res = await getMe();
      if (res.error) throw res.error as Problem;
      if (!res.data) throw new Error('Empty response from getMe');
      return res.data;
    },

    async update(body) {
      const res = await updateMe({ body });
      if (res.error) throw res.error as Problem;
      if (!res.data) throw new Error('Empty response from updateMe');
      return res.data;
    },

    async deleteMe() {
      const res = await deleteMe();
      if (res.error) throw res.error as Problem;
    },
  };
}

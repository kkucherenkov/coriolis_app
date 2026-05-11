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

import { getMe, updateMe, deleteMe, exportMe } from '@app/api-client-ts';
import type { Me, MeUpdate, Problem } from '@app/api-client-ts';

export interface MeApiClient {
  get(): Promise<Me>;
  update(body: MeUpdate): Promise<Me>;
  deleteMe(): Promise<void>;
  /**
   * Returns the response as a Blob plus the filename suggested by the
   * server (parsed from Content-Disposition). The download trigger is
   * the caller's responsibility.
   */
  exportMe(): Promise<{ blob: Blob; filename: string }>;
}

const DEFAULT_EXPORT_FILENAME = 'coriolis-export.json';

function parseFilename(header: string | undefined): string {
  if (!header) return DEFAULT_EXPORT_FILENAME;
  // Backend currently sends `filename="..."` (RFC 6266 quoted form). Match the
  // unquoted form too so a future proxy or middleware rewrite doesn't silently
  // collapse us to the default.
  const match = /filename="([^"]+)"|filename=([^;\s]+)/.exec(header);
  return match?.[1] ?? match?.[2] ?? DEFAULT_EXPORT_FILENAME;
}

export function useMeApi(): MeApiClient {
  return {
    async get() {
      const res = await getMe();
      // WHY: the generated SDK returns a Problem plain object (RFC 9457), not an
      // Error subclass. A typed ApiProblemError wrapper is a separate refactor.
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async update(body) {
      const res = await updateMe({ body });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async deleteMe() {
      const res = await deleteMe();
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
    },

    async exportMe() {
      const res = await exportMe({ parseAs: 'blob' });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      const blob = res.data as unknown as Blob;
      const filename = parseFilename(res.response.headers.get('Content-Disposition') ?? undefined);
      return { blob, filename };
    },
  };
}

export { type Me, type MeUpdate, type Problem } from '@app/api-client-ts';

/**
 * useNpcsApi — NPC HTTP layer for apps/web (Phase 6 T-2026-05-10-008).
 *
 * NPCs are owned by the authenticated GM user. Each NPC has a name,
 * optional description, stat block (attributes, skills, hp, mp),
 * armor/weapon arrays, and free-form categorisation tags.
 *
 * API surface:
 *   GET    /api/v1/npcs                     → listNpcs
 *   POST   /api/v1/npcs                     → createNpc
 *   GET    /api/v1/npcs/{id}                → getNpc
 *   PATCH  /api/v1/npcs/{id}                → updateNpc
 *   DELETE /api/v1/npcs/{id}                → deleteNpc
 *   POST   /api/v1/npcs/{id}/duplicate      → duplicateNpc
 *
 * Errors are thrown as the raw `Problem` object (RFC 9457). Callers
 * inspect `problem.status` / `problem.detail` for inline messaging.
 */

import {
  listNpcs,
  createNpc,
  getNpc,
  updateNpc,
  deleteNpc,
  duplicateNpc,
} from '@app/api-client-ts';
import type { Problem } from '@app/api-client-ts';

export interface ListNpcsOptions {
  limit?: number;
  cursor?: string;
  tag?: string;
}

export interface ListNpcsResult {
  items: readonly Npc[];
  nextCursor: string | null;
}

export interface NpcsApiClient {
  list(opts?: ListNpcsOptions): Promise<ListNpcsResult>;
  get(id: string): Promise<Npc>;
  create(body: NpcCreate): Promise<Npc>;
  update(id: string, body: NpcUpdate): Promise<Npc>;
  delete(id: string): Promise<void>;
  duplicate(id: string): Promise<Npc>;
}

export function useNpcsApi(): NpcsApiClient {
  return {
    async list(opts) {
      const res = await listNpcs({ query: opts });
      // WHY: the generated SDK returns a Problem plain object (RFC 9457), not an
      // Error subclass. Callers depend on `problem.status` / `problem.detail`
      // being present on the caught value. A typed ApiProblemError wrapper is a
      // separate refactor; until then we suppress the linter rule.
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return { items: res.data.items, nextCursor: res.data.nextCursor };
    },

    async get(id) {
      const res = await getNpc({ path: { id } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async create(body) {
      const res = await createNpc({ body });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async update(id, body) {
      const res = await updateNpc({ path: { id }, body });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async delete(id) {
      const res = await deleteNpc({ path: { id } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
    },

    async duplicate(id) {
      const res = await duplicateNpc({ path: { id } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },
  };
}

export type { Npc, NpcCreate, NpcUpdate, NpcList } from '@app/api-client-ts';

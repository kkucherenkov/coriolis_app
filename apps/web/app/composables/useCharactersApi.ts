/**
 * useCharactersApi — character-specific HTTP layer for apps/web.
 *
 * All character CRUD calls from pages must go through this composable.
 * Internally delegates to the generated `@app/api-client-ts` SDK functions.
 * The SDK's default singleton client is used; its base URL can be overridden
 * via a Nuxt plugin that calls `client.setConfig(...)` at app boot.
 *
 * Errors are thrown as the raw `Problem` object (RFC 9457) so callers can
 * inspect `problem.status`, `problem.detail`, etc.
 */

import {
  listCharacters,
  createCharacter,
  getCharacter,
  updateCharacter,
  deleteCharacter,
} from '@app/api-client-ts';
import type { Character, CharacterList, CharacterUpdate, Problem } from '@app/api-client-ts';

export interface CharactersApiClient {
  list(opts?: { limit?: number }): Promise<CharacterList>;
  get(id: string): Promise<Character>;
  create(body: { name: string }): Promise<Character>;
  update(id: string, body: CharacterUpdate): Promise<Character>;
  delete(id: string): Promise<void>;
}

export function useCharactersApi(): CharactersApiClient {
  return {
    async list(opts) {
      const res = await listCharacters({
        query: opts?.limit !== undefined ? { limit: opts.limit } : undefined,
      });
      // WHY: the generated SDK returns a Problem plain object (RFC 9457), not an
      // Error subclass. Callers depend on `problem.status` / `problem.detail`
      // being present on the caught value. A typed ApiProblemError wrapper is a
      // separate refactor (Epic 5.x); until then we suppress the linter rule.
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async get(id) {
      const res = await getCharacter({ path: { id } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async create(body) {
      const res = await createCharacter({ body });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async update(id, body) {
      const res = await updateCharacter({ path: { id }, body });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async delete(id) {
      const res = await deleteCharacter({ path: { id } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
    },
  };
}

export {
  type Character,
  type CharacterList,
  type CharacterUpdate,
  type Problem,
} from '@app/api-client-ts';

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
import type {
  Character,
  CharacterList,
  CharacterUpdate,
  Problem,
} from '@app/api-client-ts';

export type { Character, CharacterList, CharacterUpdate, Problem };

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
      if (res.error) throw res.error as Problem;
      if (!res.data) throw new Error('Empty response from listCharacters');
      return res.data;
    },

    async get(id) {
      const res = await getCharacter({ path: { id } });
      if (res.error) throw res.error as Problem;
      if (!res.data) throw new Error('Empty response from getCharacter');
      return res.data;
    },

    async create(body) {
      const res = await createCharacter({ body });
      if (res.error) throw res.error as Problem;
      if (!res.data) throw new Error('Empty response from createCharacter');
      return res.data;
    },

    async update(id, body) {
      const res = await updateCharacter({ path: { id }, body });
      if (res.error) throw res.error as Problem;
      if (!res.data) throw new Error('Empty response from updateCharacter');
      return res.data;
    },

    async delete(id) {
      const res = await deleteCharacter({ path: { id } });
      if (res.error) throw res.error as Problem;
    },
  };
}

/**
 * useGameSessionsApi — game-session HTTP layer for apps/web (Phase 4
 * Feature 7.2).
 *
 * GameSessions are owned by a GM and host the live state for a play
 * session: a Darkness Points counter, the assigned PCs, and the audit
 * trail of DP adjustments. Players join via the GM assigning their
 * character (POST /game-sessions/{id}/characters); the actual DP +
 * roll-pushed events are layered in Block 4 / 5.
 *
 * API surface:
 *   GET    /api/v1/game-sessions                            → listSessions
 *   POST   /api/v1/game-sessions                            → createSession
 *   GET    /api/v1/game-sessions/{id}                       → getSession
 *   PATCH  /api/v1/game-sessions/{id}                       → updateSession
 *   DELETE /api/v1/game-sessions/{id}                       → deleteSession
 *   POST   /api/v1/game-sessions/{id}/characters            → assignCharacter
 *   DELETE /api/v1/game-sessions/{id}/characters/{charId}   → unassignCharacter
 *
 * Errors are thrown as the raw `Problem` object (RFC 9457). Callers
 * inspect `problem.status` / `problem.detail` for inline messaging.
 */

import {
  listGameSessions,
  createGameSession,
  getGameSession,
  updateGameSession,
  deleteGameSession,
  assignCharacterToSession,
  unassignCharacterFromSession,
} from '@app/api-client-ts';
import type {
  GameSession,
  GameSessionCreate,
  GameSessionUpdate,
  GameSessionStatus,
  Problem,
} from '@app/api-client-ts';

export interface ListSessionsOptions {
  status?: GameSessionStatus;
  limit?: number;
  cursor?: string;
}

export interface ListSessionsResult {
  items: readonly GameSession[];
  nextCursor: string | null;
}

export interface GameSessionsApiClient {
  listSessions(options?: ListSessionsOptions): Promise<ListSessionsResult>;
  createSession(body: GameSessionCreate): Promise<GameSession>;
  getSession(id: string): Promise<GameSession>;
  updateSession(id: string, body: GameSessionUpdate): Promise<GameSession>;
  deleteSession(id: string): Promise<void>;
  assignCharacter(sessionId: string, characterId: string): Promise<void>;
  unassignCharacter(sessionId: string, characterId: string): Promise<void>;
}

export function useGameSessionsApi(): GameSessionsApiClient {
  return {
    async listSessions(options) {
      const res = await listGameSessions({ query: options });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return { items: res.data.items, nextCursor: res.data.nextCursor };
    },

    async createSession(body) {
      const res = await createGameSession({ body });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async getSession(id) {
      const res = await getGameSession({ path: { id } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async updateSession(id, body) {
      const res = await updateGameSession({ path: { id }, body });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async deleteSession(id) {
      const res = await deleteGameSession({ path: { id } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
    },

    async assignCharacter(sessionId, characterId) {
      const res = await assignCharacterToSession({
        path: { id: sessionId },
        body: { characterId },
      });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
    },

    async unassignCharacter(sessionId, characterId) {
      const res = await unassignCharacterFromSession({
        path: { id: sessionId, characterId },
      });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
    },
  };
}

export type {
  GameSession,
  GameSessionCreate,
  GameSessionUpdate,
  GameSessionStatus,
} from '@app/api-client-ts';

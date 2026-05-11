/**
 * useEncountersApi — Encounter HTTP layer for apps/web (Phase 6 T-2026-05-10-008 Block 3).
 *
 * Encounters are scoped to a game session and owned by the GM. Each
 * encounter has a name, optional GM notes, and a state machine:
 *   setup → active → ended
 *
 * API surface:
 *   GET    /api/v1/game-sessions/{sessionId}/encounters   → list
 *   POST   /api/v1/game-sessions/{sessionId}/encounters   → create
 *   GET    /api/v1/encounters/{id}                        → get
 *   PATCH  /api/v1/encounters/{id}                        → update
 *   DELETE /api/v1/encounters/{id}                        → remove
 *   GET    /api/v1/encounters/{id}/combatants             → listCombatants
 *
 * Errors are thrown as the raw `Problem` object (RFC 9457). Callers
 * inspect `problem.status` / `problem.detail` for inline messaging.
 */

import {
  listEncounters,
  createEncounter,
  getEncounter,
  updateEncounter,
  deleteEncounter,
  listCombatants,
  rollInitiative,
  advanceTurn,
} from '@app/api-client-ts';
import type {
  Encounter,
  EncounterCreate,
  EncounterStatus,
  EncounterUpdate,
  Combatant,
  InitiativeRollResult,
  TurnAdvanceResult,
  Problem,
} from '@app/api-client-ts';

export interface ListEncountersOptions {
  limit?: number;
  cursor?: string;
  status?: EncounterStatus;
}

export interface ListEncountersResult {
  items: readonly Encounter[];
  nextCursor: string | null;
}

export interface ListCombatantsResult {
  items: readonly Combatant[];
}

export interface EncountersApiClient {
  list(sessionId: string, opts?: ListEncountersOptions): Promise<ListEncountersResult>;
  get(id: string): Promise<Encounter>;
  create(sessionId: string, body: EncounterCreate): Promise<Encounter>;
  update(id: string, patch: EncounterUpdate): Promise<Encounter>;
  remove(id: string): Promise<void>;
  listCombatants(encounterId: string): Promise<ListCombatantsResult>;
  /**
   * Roll initiative for all combatants; transitions encounter setup → active.
   * Returns combatants in new turnOrder and the starting round (always 1).
   */
  rollInitiative(encounterId: string): Promise<InitiativeRollResult>;
  /**
   * Advance to the next combatant's turn. Returns the new activeCombatantId,
   * current round, and whether a new round just started.
   */
  advanceTurn(encounterId: string): Promise<TurnAdvanceResult>;
}

export function useEncountersApi(): EncountersApiClient {
  return {
    async list(sessionId, opts) {
      const res = await listEncounters({ path: { sessionId }, query: opts });
      // WHY: the generated SDK returns a Problem plain object (RFC 9457), not an
      // Error subclass. Callers depend on `problem.status` / `problem.detail`
      // being present on the caught value.
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return { items: res.data.items, nextCursor: res.data.nextCursor };
    },

    async get(id) {
      const res = await getEncounter({ path: { id } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async create(sessionId, body) {
      const res = await createEncounter({ path: { sessionId }, body });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async update(id, patch) {
      const res = await updateEncounter({ path: { id }, body: patch });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async remove(id) {
      const res = await deleteEncounter({ path: { id } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
    },

    async listCombatants(encounterId) {
      const res = await listCombatants({ path: { id: encounterId } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return { items: res.data.items };
    },

    async rollInitiative(encounterId) {
      const res = await rollInitiative({ path: { id: encounterId } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async advanceTurn(encounterId) {
      const res = await advanceTurn({ path: { id: encounterId } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },
  };
}

export type {
  Encounter,
  EncounterCreate,
  EncounterList,
  EncounterStatus,
  EncounterUpdate,
  Combatant,
  InitiativeRollResult,
  TurnAdvanceResult,
} from '@app/api-client-ts';

/**
 * useCombatantsApi — Combatant HTTP layer for apps/web (Phase 6 T-2026-05-10-008 Block 4).
 *
 * Combatants belong to an encounter and are sourced from either a PC
 * (Character) or an NPC. Status flags are free-form string[]; canonical
 * tags ('incapacitated', 'prone', 'covered') receive special rendering
 * in the UI, but the composable is agnostic — it round-trips whatever
 * the server returns.
 *
 * API surface:
 *   GET    /api/v1/encounters/{id}/combatants        → listCombatants
 *   POST   /api/v1/encounters/{id}/combatants        → addCombatant
 *   PATCH  /api/v1/combatants/{id}                   → updateCombatant
 *   DELETE /api/v1/combatants/{id}                   → deleteCombatant
 *   PATCH  /api/v1/encounters/{id}/initiative        → reorderInitiative
 *
 * reorder() exists here but is NOT dispatched by any UI in Block 4 —
 * Block 5 wires the drag-to-reorder path to this method.
 *
 * Errors are thrown as the raw `Problem` object (RFC 9457). Callers
 * inspect `problem.status` / `problem.detail` for inline messaging.
 */

import {
  listCombatants,
  addCombatant,
  updateCombatant,
  deleteCombatant,
  reorderInitiative,
} from '@app/api-client-ts';
import type {
  Combatant,
  CombatantCreate,
  CombatantUpdate,
  CombatantUpdateWritable,
  Problem,
} from '@app/api-client-ts';

export interface CombatantSource {
  kind: 'pc' | 'npc';
  id: string;
}

export interface CombatantListResult {
  items: readonly Combatant[];
}

export interface CombatantsApiClient {
  list(encounterId: string): Promise<CombatantListResult>;
  add(encounterId: string, source: CombatantSource, displayName?: string): Promise<Combatant>;
  update(combatantId: string, patch: CombatantUpdateWritable): Promise<Combatant>;
  remove(combatantId: string): Promise<void>;
  /**
   * Reorder combatants in turn order.
   * NOTE: not dispatched from UI in Block 4 — Block 5 connects drag reorder.
   */
  reorder(encounterId: string, orderedIds: string[]): Promise<void>;
}

export function useCombatantsApi(): CombatantsApiClient {
  return {
    async list(encounterId): Promise<CombatantListResult> {
      const res = await listCombatants({ path: { id: encounterId } });
      // WHY: the generated SDK returns a Problem plain object (RFC 9457), not an
      // Error subclass. Callers depend on `problem.status` / `problem.detail`.
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return { items: res.data.items };
    },

    async add(encounterId, source, displayName) {
      const body: CombatantCreate = {
        combatantType: source.kind,
        sourceId: source.id,
        ...(displayName ? { displayName } : {}),
      };
      const res = await addCombatant({ path: { id: encounterId }, body });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async update(combatantId: string, patch: CombatantUpdateWritable) {
      const res = await updateCombatant({ path: { id: combatantId }, body: patch });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async remove(combatantId) {
      const res = await deleteCombatant({ path: { id: combatantId } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
    },

    async reorder(encounterId, orderedIds) {
      const res = await reorderInitiative({
        path: { id: encounterId },
        body: { combatantIds: orderedIds },
      });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
    },
  };
}

export type {
  CombatantCreate,
  CombatantUpdate,
  CombatantUpdateWritable,
} from '@app/api-client-ts';

/**
 * useShipCrewApi — crew assignment HTTP layer for apps/web (Phase 5 T-2026-05-10-005 Block 4).
 *
 * Wraps the generated `assignCrew` / `unassignCrew` SDK calls behind a typed
 * interface.  Move semantics live entirely on the backend: re-assigning a
 * character already serving on the same ship to a vacant position moves them.
 * `CREW_POSITION_TAKEN` (400) only fires when the target position is held by a
 * *different* character.
 *
 * API surface:
 *   POST   /api/v1/ships/{id}/crew            → assignCrew   → 201 CrewSlot
 *   DELETE /api/v1/ships/{id}/crew/{characterId} → unassignCrew → 204
 *
 * Errors are thrown as the raw `Problem` object (RFC 9457). Callers inspect
 * `problem.status` / `problem.detail` for inline messaging.
 */

import { assignCrew, unassignCrew } from '@app/api-client-ts';
import type { Problem } from '@app/api-client-ts';

export interface AssignCrewBody {
  position: CrewPosition;
  characterId: string;
}

export interface ShipCrewApiClient {
  assign(shipId: string, body: AssignCrewBody): Promise<CrewSlot>;
  unassign(shipId: string, characterId: string): Promise<void>;
}

export function useShipCrewApi(): ShipCrewApiClient {
  return {
    async assign(shipId, body) {
      const res = await assignCrew({ path: { id: shipId }, body });
      // WHY: the generated SDK returns a Problem plain object (RFC 9457), not an
      // Error subclass. Callers depend on `problem.status` / `problem.detail`
      // being present on the caught value. A typed ApiProblemError wrapper is a
      // separate refactor; until then we suppress the linter rule.
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async unassign(shipId, characterId) {
      const res = await unassignCrew({ path: { id: shipId, characterId } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
    },
  };
}

export type { CrewSlot, CrewPosition } from '@app/api-client-ts';
// AssignCrewRequest is not a named type in the generated client —
// the body shape is inlined in AssignCrewData. Re-export AssignCrewBody as the
// canonical request type for consumers.
export type { AssignCrewBody as AssignCrewRequest };

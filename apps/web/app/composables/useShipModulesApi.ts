/**
 * useShipModulesApi — module HTTP layer for apps/web (Phase 5 T-2026-05-10-005 Block 3).
 *
 * Ship modules are sub-resources of a ship. Each module has a discriminated
 * `slot` field that determines which additional fields are present:
 *   WEAPON  → weaponBonus / weaponRange / weaponDamage / weaponCritThreshold
 *   TORPEDO → torpedoCount / mineCount
 *   HOLD    → cargoTons / concealed
 *   SENSOR  → detectionBonus
 *   OTHER   → no extra fields (covers BRIDGE / REACTOR / DRIVE / COMMS / etc.)
 *
 * API surface:
 *   POST   /api/v1/ships/{id}/modules    → addShipModule   → 201 ShipModule
 *   PATCH  /api/v1/ship-modules/{id}    → updateShipModule → 200 ShipModule
 *   DELETE /api/v1/ship-modules/{id}    → deleteShipModule → 204
 *
 * Errors are thrown as the raw `Problem` object (RFC 9457). Callers
 * inspect `problem.status` / `problem.detail` for inline messaging.
 *
 * BRIDGE / REACTOR / DRIVE modules are seeded server-side and protected
 * against deletion at the API level (422 SHIP_MODULE_MANDATORY). The UI
 * hides the Delete button for those slots to prevent the call entirely.
 */

import { addShipModule, updateShipModule, deleteShipModule } from '@app/api-client-ts';
import type { Problem } from '@app/api-client-ts';

export interface ShipModulesApiClient {
  addModule(shipId: string, body: ShipModuleCreate): Promise<ShipModule>;
  updateModule(moduleId: string, body: ShipModuleUpdate): Promise<ShipModule>;
  deleteModule(moduleId: string): Promise<void>;
}

export function useShipModulesApi(): ShipModulesApiClient {
  return {
    async addModule(shipId, body) {
      const res = await addShipModule({ path: { id: shipId }, body });
      // WHY: the generated SDK returns a Problem plain object (RFC 9457), not an
      // Error subclass. Callers depend on `problem.status` / `problem.detail`
      // being present on the caught value. A typed ApiProblemError wrapper is a
      // separate refactor; until then we suppress the linter rule.
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async updateModule(moduleId, body) {
      const res = await updateShipModule({ path: { id: moduleId }, body });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async deleteModule(moduleId) {
      const res = await deleteShipModule({ path: { id: moduleId } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
    },
  };
}

export type {
  ShipModule,
  ShipModuleCreate,
  ShipModuleUpdate,
  ShipModuleSlot,
  ShipWeaponRange,
} from '@app/api-client-ts';

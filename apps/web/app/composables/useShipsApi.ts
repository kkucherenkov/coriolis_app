/**
 * useShipsApi — ship HTTP layer for apps/web (Phase 5 T-2026-05-10-005).
 *
 * Ships are owned by the authenticated user. Each ship has a class
 * (20 canonical values per ST3001 ГЛАВА 7 Table 7.4), a base stat block
 * (hull, energy, armor, maneuverability, signature, speed), a list of
 * installed modules, and a crew roster.
 *
 * API surface:
 *   GET    /api/v1/ships                     → listShips
 *   POST   /api/v1/ships                     → createShip
 *   GET    /api/v1/ships/{id}                → getShip
 *   PATCH  /api/v1/ships/{id}                → updateShip
 *   DELETE /api/v1/ships/{id}                → deleteShip
 *   POST   /api/v1/ships/{id}/duplicate      → duplicateShip
 *
 * Errors are thrown as the raw `Problem` object (RFC 9457). Callers
 * inspect `problem.status` / `problem.detail` for inline messaging.
 */

import {
  listShips,
  createShip,
  getShip,
  updateShip,
  deleteShip,
  duplicateShip,
} from '@app/api-client-ts';
import type { Problem } from '@app/api-client-ts';

export interface ListShipsOptions {
  limit?: number;
  cursor?: string;
}

export interface ListShipsResult {
  items: readonly Ship[];
  nextCursor: string | null;
}

export interface ShipsApiClient {
  list(opts?: ListShipsOptions): Promise<ListShipsResult>;
  get(id: string): Promise<Ship>;
  create(body: ShipCreate): Promise<Ship>;
  update(id: string, body: ShipUpdate): Promise<Ship>;
  delete(id: string): Promise<void>;
  duplicate(id: string): Promise<Ship>;
}

export function useShipsApi(): ShipsApiClient {
  return {
    async list(opts) {
      const res = await listShips({ query: opts });
      // WHY: the generated SDK returns a Problem plain object (RFC 9457), not an
      // Error subclass. Callers depend on `problem.status` / `problem.detail`
      // being present on the caught value. A typed ApiProblemError wrapper is a
      // separate refactor; until then we suppress the linter rule.
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return { items: res.data.items, nextCursor: res.data.nextCursor };
    },

    async get(id) {
      const res = await getShip({ path: { id } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async create(body) {
      const res = await createShip({ body });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async update(id, body) {
      const res = await updateShip({ path: { id }, body });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async delete(id) {
      const res = await deleteShip({ path: { id } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
    },

    async duplicate(id) {
      const res = await duplicateShip({ path: { id } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },
  };
}

export type { Ship, ShipCreate, ShipUpdate, ShipClass } from '@app/api-client-ts';

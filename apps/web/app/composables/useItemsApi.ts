/**
 * useItemsApi — item-specific HTTP layer for apps/web.
 *
 * Kept as a sibling composable (not added to useCharactersApi.ts) to keep
 * useCharactersApi.ts under the ~250-line limit per module convention.
 *
 * API surface:
 *   POST   /api/v1/characters/{id}/items  → addItem
 *   PATCH  /api/v1/items/{id}             → updateItem
 *   DELETE /api/v1/items/{id}             → removeItem
 *
 * Errors are thrown as the raw `Problem` object (RFC 9457). Callers inspect
 * `problem.status` / `problem.detail` for inline error messaging.
 */

import { addCharacterItem, updateItem, deleteItem } from '@app/api-client-ts';
import type { Item, ItemCreate, ItemUpdate, Problem } from '@app/api-client-ts';

export interface ItemsApiClient {
  addItem(characterId: string, body: ItemCreate): Promise<Item>;
  updateItem(itemId: string, body: ItemUpdate): Promise<Item>;
  removeItem(itemId: string): Promise<void>;
}

export function useItemsApi(): ItemsApiClient {
  return {
    async addItem(characterId, body) {
      const res = await addCharacterItem({ path: { id: characterId }, body });
      // WHY: SDK returns Problem plain object (RFC 9457), not an Error subclass.
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async updateItem(itemId, body) {
      const res = await updateItem({ path: { id: itemId }, body });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },

    async removeItem(itemId) {
      const res = await deleteItem({ path: { id: itemId } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
    },
  };
}

// Problem is intentionally not re-exported here — it is already exposed via
// useTalentsApi.ts. Re-exporting it from both composables triggers Nuxt's
// "Duplicated imports" warning in the auto-import scanner.
export type { Item, ItemCreate, ItemUpdate } from '@app/api-client-ts';
export type {
  ItemWeapon,
  ItemArmor,
  ItemGear,
  ItemCybernetic,
  ItemShipModule,
  ItemOther,
  ItemWeaponCreate,
  ItemArmorCreate,
  ItemGearCreate,
  ItemCyberneticCreate,
  ItemShipModuleCreate,
  ItemOtherCreate,
  ItemWeaponUpdate,
  ItemArmorUpdate,
  ItemGearUpdate,
  ItemCyberneticUpdate,
  ItemShipModuleUpdate,
  ItemOtherUpdate,
  ItemRangeEnum,
  ItemSlotType,
} from '@app/api-client-ts';

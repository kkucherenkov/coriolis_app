import type { ItemReadModel, ItemType } from '../../domain/character.ports';

export const ITEM_REPO = Symbol('ITEM_REPO');

export interface IItemRepo {
  findById(id: string): Promise<(ItemReadModel & { characterId: string }) | null>;
  findOwnerCharacterId(itemId: string): Promise<{ characterId: string } | null>;

  create(data: {
    characterId: string;
    type: ItemType;
    payload: Record<string, unknown>;
  }): Promise<ItemReadModel & { characterId: string }>;

  update(
    id: string,
    payload: Record<string, unknown>,
  ): Promise<ItemReadModel & { characterId: string }>;

  delete(id: string): Promise<void>;
}

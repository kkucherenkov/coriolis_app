import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ItemNotFoundError, ItemNotOwnedError } from '../domain/item.errors';

import { DeleteItemCommand } from './delete-item.command';
import { DeleteItemHandler } from './delete-item.handler';

import type { ICharacterRepo, ItemReadModel } from '../../domain/character.ports';
import type { IItemRepo } from '../domain/item.ports';

function makeCharacterRepo(): ICharacterRepo {
  return {
    findActiveById: vi.fn(),
    findOwnerIdById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    deleteAbandonedDrafts: vi.fn(),
    delete: vi.fn(),
  };
}

function makeItemRepo(): IItemRepo {
  return {
    findById: vi.fn(),
    findOwnerCharacterId: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
  };
}

function makeItem(
  overrides: Partial<ItemReadModel & { characterId: string }> = {},
): ItemReadModel & { characterId: string } {
  return {
    id: 'item-1',
    type: 'GEAR',
    characterId: 'char-1',
    name: 'Toolkit',
    weight: 1,
    quantity: 1,
    ...overrides,
  };
}

describe('DeleteItemHandler', () => {
  let characterRepo: ICharacterRepo;
  let itemRepo: IItemRepo;
  let handler: DeleteItemHandler;

  beforeEach(() => {
    characterRepo = makeCharacterRepo();
    itemRepo = makeItemRepo();
    handler = new DeleteItemHandler(itemRepo, characterRepo);
  });

  it('deletes an item when the caller owns the parent character', async () => {
    vi.mocked(itemRepo.findById).mockResolvedValue(makeItem());
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    vi.mocked(itemRepo.delete).mockResolvedValue(undefined);

    await expect(
      handler.execute(new DeleteItemCommand('item-1', 'user-1')),
    ).resolves.toBeUndefined();
    expect(itemRepo.delete).toHaveBeenCalledWith('item-1');
  });

  it('throws ItemNotFoundError when item does not exist', async () => {
    vi.mocked(itemRepo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new DeleteItemCommand('missing', 'user-1')),
    ).rejects.toBeInstanceOf(ItemNotFoundError);
    expect(itemRepo.delete).not.toHaveBeenCalled();
  });

  it('throws ItemNotOwnedError when caller does not own the parent character', async () => {
    vi.mocked(itemRepo.findById).mockResolvedValue(makeItem());
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'other-user' });

    await expect(handler.execute(new DeleteItemCommand('item-1', 'user-1'))).rejects.toBeInstanceOf(
      ItemNotOwnedError,
    );
    expect(itemRepo.delete).not.toHaveBeenCalled();
  });

  it('returns ItemNotOwnedError with 403 status', async () => {
    vi.mocked(itemRepo.findById).mockResolvedValue(makeItem());
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'other' });

    await expect(handler.execute(new DeleteItemCommand('item-1', 'user-1'))).rejects.toMatchObject({
      status: 403,
      code: 'ITEM_NOT_OWNED',
    });
  });
});

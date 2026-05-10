import { beforeEach, describe, expect, it, vi } from 'vitest';

import { CharacterNotFoundError, CharacterNotOwnedError } from '../../domain/character.errors';

import { AddItemCommand, AddItemDto } from './add-item.command';
import { AddItemHandler } from './add-item.handler';

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

describe('AddItemHandler', () => {
  let characterRepo: ICharacterRepo;
  let itemRepo: IItemRepo;
  let handler: AddItemHandler;

  beforeEach(() => {
    characterRepo = makeCharacterRepo();
    itemRepo = makeItemRepo();
    handler = new AddItemHandler(characterRepo, itemRepo);
  });

  it('creates an item on a character owned by the caller', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    const created = makeItem();
    vi.mocked(itemRepo.create).mockResolvedValue(created);

    const dto = Object.assign(new AddItemDto(), {
      type: 'GEAR' as const,
      name: 'Toolkit',
      weight: 1,
      quantity: 1,
    });

    const result = await handler.execute(new AddItemCommand('char-1', 'user-1', dto));

    expect(result).toEqual(created);
    expect(itemRepo.create).toHaveBeenCalledWith(
      expect.objectContaining({ characterId: 'char-1', type: 'GEAR' }),
    );
  });

  it('throws CharacterNotFoundError when character does not exist', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue(null);

    const dto = Object.assign(new AddItemDto(), {
      type: 'OTHER' as const,
      name: 'Thing',
      weight: 0,
    });

    await expect(
      handler.execute(new AddItemCommand('missing', 'user-1', dto)),
    ).rejects.toBeInstanceOf(CharacterNotFoundError);
    expect(itemRepo.create).not.toHaveBeenCalled();
  });

  it('throws CharacterNotOwnedError when character belongs to another user', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'other-user' });

    const dto = Object.assign(new AddItemDto(), {
      type: 'OTHER' as const,
      name: 'Thing',
      weight: 0,
    });

    await expect(
      handler.execute(new AddItemCommand('char-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(CharacterNotOwnedError);
    expect(itemRepo.create).not.toHaveBeenCalled();
  });

  it('passes WEAPON type with correct payload', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    const weaponItem = makeItem({
      type: 'WEAPON',
      name: 'Laser Pistol',
      damage: 2,
      range: 'medium',
      bonus: 0,
      crit: 2,
      weight: 1,
      features: [],
      equipped: false,
    });
    vi.mocked(itemRepo.create).mockResolvedValue(weaponItem);

    const dto = Object.assign(new AddItemDto(), {
      type: 'WEAPON' as const,
      name: 'Laser Pistol',
      damage: 2,
      range: 'medium',
      bonus: 0,
      crit: 2,
      weight: 1,
      features: [],
      equipped: false,
    });

    const result = await handler.execute(new AddItemCommand('char-1', 'user-1', dto));

    expect(result.type).toBe('WEAPON');
  });

  it('rejects legacy range value "short" (narrowed to 4-band canonical enum)', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });

    const dto = Object.assign(new AddItemDto(), {
      type: 'WEAPON' as const,
      name: 'Old Pistol',
      damage: 2,
      range: 'short', // legacy 5-band value — must be rejected
      bonus: 0,
      crit: 2,
      weight: 1,
      features: [],
      equipped: false,
    });

    // validate() from class-validator should reject the dto when range is a legacy slug
    const { validate } = await import('class-validator');
    const errors = await validate(dto);
    const rangeError = errors.find((e) => e.property === 'range');
    expect(rangeError).toBeDefined();
    expect(itemRepo.create).not.toHaveBeenCalled();
  });
});

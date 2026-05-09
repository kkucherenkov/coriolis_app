import { describe, it, expect, vi, beforeEach } from 'vitest';

import {
  CharacterNotFoundError,
  CharacterNotOwnedError,
} from '../../characters/domain/character.errors';

import { ListRollsQuery } from './list-rolls.query';
import { ListRollsHandler } from './list-rolls.handler';

import type { ICharacterRepo } from '../../characters/domain/character.ports';
import type { IRollRepo, RollReadModel } from '../domain/roll.ports';

function makeRoll(overrides: Partial<RollReadModel> = {}): RollReadModel {
  return {
    id: 'roll_01',
    characterId: 'char_01',
    gameSessionId: null,
    label: 'Pilot',
    pool: 3,
    dice: [2, 4, 6],
    hits: 1,
    pushed: false,
    createdAt: '2026-05-09T12:00:00Z',
    ...overrides,
  };
}

function makeHandler(): {
  handler: ListRollsHandler;
  characterRepo: ICharacterRepo;
  rollRepo: IRollRepo;
} {
  const characterRepo = {
    findOwnerIdById: vi.fn(),
    findActiveById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    deleteAbandonedDrafts: vi.fn(),
    delete: vi.fn(),
  } as unknown as ICharacterRepo;

  const rollRepo = {
    create: vi.fn(),
    findById: vi.fn(),
    push: vi.fn(),
    listByCharacterId: vi.fn(),
  } as unknown as IRollRepo;

  const handler = new ListRollsHandler(characterRepo, rollRepo);
  return { handler, characterRepo, rollRepo };
}

describe('ListRollsHandler', () => {
  let handler: ListRollsHandler;
  let characterRepo: ICharacterRepo;
  let rollRepo: IRollRepo;

  beforeEach(() => {
    ({ handler, characterRepo, rollRepo } = makeHandler());
  });

  it('returns last N rolls ordered newest-first', async () => {
    const rolls = [
      makeRoll({ id: 'roll_03', createdAt: '2026-05-09T14:00:00Z' }),
      makeRoll({ id: 'roll_02', createdAt: '2026-05-09T13:00:00Z' }),
      makeRoll({ id: 'roll_01', createdAt: '2026-05-09T12:00:00Z' }),
    ];
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(rollRepo.listByCharacterId).mockResolvedValue(rolls);

    const result = await handler.execute(new ListRollsQuery('user_01', 'char_01', 50));

    expect(result.items).toHaveLength(3);
    expect(result.items[0]?.id).toBe('roll_03');
    expect(result.items[2]?.id).toBe('roll_01');
  });

  it('passes the limit to the repo', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(rollRepo.listByCharacterId).mockResolvedValue([]);

    await handler.execute(new ListRollsQuery('user_01', 'char_01', 10));

    expect(rollRepo.listByCharacterId).toHaveBeenCalledWith('char_01', 10);
  });

  it('respects default limit of 50', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(rollRepo.listByCharacterId).mockResolvedValue([]);

    await handler.execute(new ListRollsQuery('user_01', 'char_01', 50));

    expect(rollRepo.listByCharacterId).toHaveBeenCalledWith('char_01', 50);
  });

  it('returns empty items when no rolls exist', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(rollRepo.listByCharacterId).mockResolvedValue([]);

    const result = await handler.execute(new ListRollsQuery('user_01', 'char_01', 50));

    expect(result.items).toEqual([]);
  });

  it('throws CharacterNotFoundError when character does not exist', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue(null);

    await expect(
      handler.execute(new ListRollsQuery('user_01', 'char_missing', 50)),
    ).rejects.toBeInstanceOf(CharacterNotFoundError);
  });

  it('throws CharacterNotOwnedError when caller does not own the character', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_other' });

    await expect(
      handler.execute(new ListRollsQuery('user_01', 'char_01', 50)),
    ).rejects.toBeInstanceOf(CharacterNotOwnedError);
  });
});

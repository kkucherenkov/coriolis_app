import { beforeEach, describe, expect, it, vi } from 'vitest';

import { DEFAULT_CONDITIONS } from '../domain/character.ports';

import { ListCharactersQuery } from './list-characters.query';
import { ListCharactersHandler } from './list-characters.handler';

import type { ICharacterRepo, CharacterListItem } from '../domain/character.ports';

function makeRepo(): ICharacterRepo {
  return {
    findActiveById: vi.fn(),
    findOwnerIdById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
  };
}

function makeListItem(overrides: Partial<CharacterListItem> = {}): CharacterListItem {
  return {
    id: 'char-1',
    ownerId: 'user-1',
    name: 'Kalim',
    concept: null,
    iconId: null,
    hp: { current: 14, max: 14 },
    mp: { current: 10, max: 10 },
    conditions: { ...DEFAULT_CONDITIONS },
    createdAt: '2026-01-15T00:00:00.000Z',
    updatedAt: '2026-01-15T00:00:00.000Z',
    ...overrides,
  };
}

describe('ListCharactersHandler', () => {
  let repo: ICharacterRepo;
  let handler: ListCharactersHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new ListCharactersHandler(repo);
  });

  it('returns paginated list of characters', async () => {
    const items = [makeListItem(), makeListItem({ id: 'char-2', name: 'Hassan' })];
    vi.mocked(repo.list).mockResolvedValue({ items, nextCursor: null });

    const result = await handler.execute(new ListCharactersQuery('user-1', 20));

    expect(result.items).toHaveLength(2);
    expect(result.nextCursor).toBeNull();
    expect(repo.list).toHaveBeenCalledWith({ ownerId: 'user-1', limit: 20, cursor: undefined });
  });

  it('passes cursor to repo', async () => {
    vi.mocked(repo.list).mockResolvedValue({ items: [], nextCursor: null });

    await handler.execute(new ListCharactersQuery('user-1', 10, 'cursor-abc'));

    expect(repo.list).toHaveBeenCalledWith({ ownerId: 'user-1', limit: 10, cursor: 'cursor-abc' });
  });

  it('returns nextCursor when more pages exist', async () => {
    vi.mocked(repo.list).mockResolvedValue({ items: [makeListItem()], nextCursor: 'next-cursor' });

    const result = await handler.execute(new ListCharactersQuery('user-1', 20));

    expect(result.nextCursor).toBe('next-cursor');
  });

  it('returns empty list when no characters exist', async () => {
    vi.mocked(repo.list).mockResolvedValue({ items: [], nextCursor: null });

    const result = await handler.execute(new ListCharactersQuery('user-1', 20));

    expect(result.items).toHaveLength(0);
    expect(result.nextCursor).toBeNull();
  });

  it('scopes query to ownerId', async () => {
    vi.mocked(repo.list).mockResolvedValue({ items: [], nextCursor: null });

    await handler.execute(new ListCharactersQuery('specific-user', 5));

    expect(repo.list).toHaveBeenCalledWith(
      expect.objectContaining({ ownerId: 'specific-user' }),
    );
  });
});

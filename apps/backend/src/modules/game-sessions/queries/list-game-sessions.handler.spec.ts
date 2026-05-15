/**
 * Unit tests for ListGameSessionsHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ListGameSessionsQuery } from './list-game-sessions.query';
import { ListGameSessionsHandler } from './list-game-sessions.handler';

import type { GameSessionReadModel, IGameSessionRepo } from '../domain/game-session.ports';

function makeRepo(): IGameSessionRepo {
  return {
    findById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
    assignCharacter: vi.fn(),
    unassignCharacter: vi.fn(),
  };
}

function makeSession(id: string, ownerId: string): GameSessionReadModel {
  return {
    id,
    ownerId,
    name: `Session ${id}`,
    description: null,
    status: 'active',
    dpCount: 0,
    characterIds: [],
    memberships: [],
    shipId: null,
    createdAt: '2026-05-09T10:00:00.000Z',
    updatedAt: '2026-05-09T10:00:00.000Z',
  };
}

describe('ListGameSessionsHandler', () => {
  let repo: IGameSessionRepo;
  let handler: ListGameSessionsHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new ListGameSessionsHandler(repo);
  });

  it('returns sessions scoped to the caller (owner-scoped)', async () => {
    const sessions = [makeSession('gs-1', 'user-1'), makeSession('gs-2', 'user-1')];
    vi.mocked(repo.list).mockResolvedValue({ items: sessions, nextCursor: null });

    const result = await handler.execute(new ListGameSessionsQuery('user-1', 20));

    expect(repo.list).toHaveBeenCalledWith(expect.objectContaining({ ownerId: 'user-1' }));
    expect(result.items).toHaveLength(2);
    expect(result.nextCursor).toBeNull();
  });

  it('passes status filter to repo', async () => {
    vi.mocked(repo.list).mockResolvedValue({ items: [], nextCursor: null });

    await handler.execute(new ListGameSessionsQuery('user-1', 20, undefined, 'archived'));

    expect(repo.list).toHaveBeenCalledWith(expect.objectContaining({ status: 'archived' }));
  });

  it('passes cursor for pagination', async () => {
    vi.mocked(repo.list).mockResolvedValue({ items: [], nextCursor: null });

    await handler.execute(new ListGameSessionsQuery('user-1', 10, 'cursor-abc'));

    expect(repo.list).toHaveBeenCalledWith(
      expect.objectContaining({ cursor: 'cursor-abc', limit: 10 }),
    );
  });
});

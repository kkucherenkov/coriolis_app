/**
 * Unit tests for DeleteGameSessionHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { GameSessionNotFoundError, GameSessionNotOwnerError } from '../domain/game-session.errors';

import { DeleteGameSessionCommand } from './delete-game-session.command';
import { DeleteGameSessionHandler } from './delete-game-session.handler';

import type { GameSessionReadModel, IGameSessionRepo } from '../domain/game-session.ports';

function makeRepo(): IGameSessionRepo {
  return {
    findById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
  };
}

function makeSession(overrides: Partial<GameSessionReadModel> = {}): GameSessionReadModel {
  return {
    id: 'gs-1',
    ownerId: 'user-1',
    name: 'The Long Night',
    description: null,
    status: 'active',
    dpCount: 0,
    memberships: [],
    shipId: null,
    createdAt: '2026-05-09T10:00:00.000Z',
    updatedAt: '2026-05-09T10:00:00.000Z',
    ...overrides,
  };
}

describe('DeleteGameSessionHandler', () => {
  let repo: IGameSessionRepo;
  let handler: DeleteGameSessionHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new DeleteGameSessionHandler(repo);
  });

  it('deletes session owned by the caller', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeSession());
    vi.mocked(repo.delete).mockResolvedValue(undefined);

    await handler.execute(new DeleteGameSessionCommand('gs-1', 'user-1'));

    expect(repo.delete).toHaveBeenCalledWith('gs-1');
  });

  it('throws GameSessionNotFoundError when session does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new DeleteGameSessionCommand('gs-1', 'user-1')),
    ).rejects.toBeInstanceOf(GameSessionNotFoundError);
    expect(repo.delete).not.toHaveBeenCalled();
  });

  it('throws GameSessionNotOwnerError when caller is not the owner', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeSession({ ownerId: 'other-user' }));

    await expect(
      handler.execute(new DeleteGameSessionCommand('gs-1', 'user-1')),
    ).rejects.toBeInstanceOf(GameSessionNotOwnerError);
    expect(repo.delete).not.toHaveBeenCalled();
  });
});

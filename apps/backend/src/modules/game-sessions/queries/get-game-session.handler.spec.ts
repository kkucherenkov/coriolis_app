/**
 * Unit tests for GetGameSessionHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { GameSessionNotFoundError, GameSessionNotOwnerError } from '../domain/game-session.errors';

import { GetGameSessionQuery } from './get-game-session.query';
import { GetGameSessionHandler } from './get-game-session.handler';

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

function makeSession(overrides: Partial<GameSessionReadModel> = {}): GameSessionReadModel {
  return {
    id: 'gs-1',
    ownerId: 'user-1',
    name: 'The Long Night',
    description: null,
    status: 'active',
    dpCount: 0,
    characterIds: [],
    shipId: null,
    createdAt: '2026-05-09T10:00:00.000Z',
    updatedAt: '2026-05-09T10:00:00.000Z',
    ...overrides,
  };
}

describe('GetGameSessionHandler', () => {
  let repo: IGameSessionRepo;
  let handler: GetGameSessionHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new GetGameSessionHandler(repo);
  });

  it('returns the session for the owner', async () => {
    const session = makeSession();
    vi.mocked(repo.findById).mockResolvedValue(session);

    const result = await handler.execute(new GetGameSessionQuery('gs-1', 'user-1'));

    expect(result).toEqual(session);
  });

  it('throws GameSessionNotFoundError when session does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new GetGameSessionQuery('gs-missing', 'user-1')),
    ).rejects.toBeInstanceOf(GameSessionNotFoundError);
  });

  it('throws GameSessionNotOwnerError when caller does not own the session', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeSession({ ownerId: 'other-user' }));

    await expect(handler.execute(new GetGameSessionQuery('gs-1', 'user-1'))).rejects.toBeInstanceOf(
      GameSessionNotOwnerError,
    );
  });

  it('returns session with assigned characterIds', async () => {
    const session = makeSession({ characterIds: ['char-1', 'char-2'] });
    vi.mocked(repo.findById).mockResolvedValue(session);

    const result = await handler.execute(new GetGameSessionQuery('gs-1', 'user-1'));

    expect(result.characterIds).toEqual(['char-1', 'char-2']);
  });
});

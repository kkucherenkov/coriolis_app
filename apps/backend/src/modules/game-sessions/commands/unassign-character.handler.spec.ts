/**
 * Unit tests for UnassignCharacterHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { GameSessionNotFoundError, GameSessionNotOwnerError } from '../domain/game-session.errors';

import { UnassignCharacterCommand } from './unassign-character.command';
import { UnassignCharacterHandler } from './unassign-character.handler';

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
    characterIds: ['char-1'],
    memberships: [],
    shipId: null,
    createdAt: '2026-05-09T10:00:00.000Z',
    updatedAt: '2026-05-09T10:00:00.000Z',
    ...overrides,
  };
}

describe('UnassignCharacterHandler', () => {
  let repo: IGameSessionRepo;
  let handler: UnassignCharacterHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new UnassignCharacterHandler(repo);
  });

  it('unassigns a character from the session', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeSession());
    vi.mocked(repo.unassignCharacter).mockResolvedValue(undefined);

    await handler.execute(new UnassignCharacterCommand('gs-1', 'user-1', 'char-1'));

    expect(repo.unassignCharacter).toHaveBeenCalledWith('gs-1', 'char-1');
  });

  it('throws GameSessionNotFoundError when session does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new UnassignCharacterCommand('gs-1', 'user-1', 'char-1')),
    ).rejects.toBeInstanceOf(GameSessionNotFoundError);
    expect(repo.unassignCharacter).not.toHaveBeenCalled();
  });

  it('throws GameSessionNotOwnerError when caller does not own the session', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeSession({ ownerId: 'other-user' }));

    await expect(
      handler.execute(new UnassignCharacterCommand('gs-1', 'user-1', 'char-1')),
    ).rejects.toBeInstanceOf(GameSessionNotOwnerError);
    expect(repo.unassignCharacter).not.toHaveBeenCalled();
  });

  it('silently succeeds when character was not assigned', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeSession({ characterIds: [] }));
    vi.mocked(repo.unassignCharacter).mockResolvedValue(undefined);

    await expect(
      handler.execute(new UnassignCharacterCommand('gs-1', 'user-1', 'char-99')),
    ).resolves.toBeUndefined();
  });
});

/**
 * Unit tests for AssignCharacterHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  CharacterNotOwnedError,
  GameSessionNotFoundError,
  GameSessionNotOwnerError,
} from '../domain/game-session.errors';

import { AssignCharacterCommand } from './assign-character.command';
import { AssignCharacterHandler } from './assign-character.handler';

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
    memberships: [],
    shipId: null,
    createdAt: '2026-05-09T10:00:00.000Z',
    updatedAt: '2026-05-09T10:00:00.000Z',
    ...overrides,
  };
}

describe('AssignCharacterHandler', () => {
  let repo: IGameSessionRepo;
  let handler: AssignCharacterHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new AssignCharacterHandler(repo);
  });

  it('assigns a character and returns the updated session with characterIds', async () => {
    const updated = makeSession({ characterIds: ['char-1'] });
    vi.mocked(repo.findById).mockResolvedValue(makeSession());
    vi.mocked(repo.assignCharacter).mockResolvedValue(updated);

    const result = await handler.execute(new AssignCharacterCommand('gs-1', 'user-1', 'char-1'));

    expect(result.characterIds).toContain('char-1');
    expect(repo.assignCharacter).toHaveBeenCalledWith('gs-1', 'char-1');
  });

  it('throws GameSessionNotFoundError when session does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new AssignCharacterCommand('gs-1', 'user-1', 'char-1')),
    ).rejects.toBeInstanceOf(GameSessionNotFoundError);
    expect(repo.assignCharacter).not.toHaveBeenCalled();
  });

  it('throws GameSessionNotOwnerError when caller does not own the session', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeSession({ ownerId: 'other-user' }));

    await expect(
      handler.execute(new AssignCharacterCommand('gs-1', 'user-1', 'char-1')),
    ).rejects.toBeInstanceOf(GameSessionNotOwnerError);
    expect(repo.assignCharacter).not.toHaveBeenCalled();
  });

  it('throws CharacterNotOwnedError when character does not belong to the caller', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeSession());
    vi.mocked(repo.assignCharacter).mockRejectedValue(new CharacterNotOwnedError('char-foreign'));

    await expect(
      handler.execute(new AssignCharacterCommand('gs-1', 'user-1', 'char-foreign')),
    ).rejects.toBeInstanceOf(CharacterNotOwnedError);
  });

  it('is idempotent — returns same session when character is already assigned', async () => {
    const withChar = makeSession({ characterIds: ['char-1'] });
    vi.mocked(repo.findById).mockResolvedValue(withChar);
    vi.mocked(repo.assignCharacter).mockResolvedValue(withChar);

    const result = await handler.execute(new AssignCharacterCommand('gs-1', 'user-1', 'char-1'));

    expect(result.characterIds).toEqual(['char-1']);
    expect(repo.assignCharacter).toHaveBeenCalledOnce();
  });
});

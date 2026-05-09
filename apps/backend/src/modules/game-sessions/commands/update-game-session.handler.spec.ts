/**
 * Unit tests for UpdateGameSessionHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  GameSessionNameEmptyError,
  GameSessionNameTooLongError,
  GameSessionNotFoundError,
  GameSessionNotOwnerError,
} from '../domain/game-session.errors';

import { UpdateGameSessionCommand, UpdateGameSessionDto } from './update-game-session.command';
import { UpdateGameSessionHandler } from './update-game-session.handler';

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

function makeDto(overrides: Partial<UpdateGameSessionDto> = {}): UpdateGameSessionDto {
  return Object.assign(new UpdateGameSessionDto(), overrides);
}

describe('UpdateGameSessionHandler', () => {
  let repo: IGameSessionRepo;
  let handler: UpdateGameSessionHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new UpdateGameSessionHandler(repo);
  });

  it('throws GameSessionNotFoundError when session does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(
        new UpdateGameSessionCommand('gs-1', 'user-1', makeDto({ name: 'New Name' })),
      ),
    ).rejects.toBeInstanceOf(GameSessionNotFoundError);
    expect(repo.update).not.toHaveBeenCalled();
  });

  it('throws GameSessionNotOwnerError when caller is not the owner', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeSession({ ownerId: 'other-user' }));

    await expect(
      handler.execute(
        new UpdateGameSessionCommand('gs-1', 'user-1', makeDto({ name: 'New Name' })),
      ),
    ).rejects.toBeInstanceOf(GameSessionNotOwnerError);
    expect(repo.update).not.toHaveBeenCalled();
  });

  it('updates the name successfully', async () => {
    const updated = makeSession({ name: 'New Name' });
    vi.mocked(repo.findById).mockResolvedValue(makeSession());
    vi.mocked(repo.update).mockResolvedValue(updated);

    const result = await handler.execute(
      new UpdateGameSessionCommand('gs-1', 'user-1', makeDto({ name: 'New Name' })),
    );

    expect(result.name).toBe('New Name');
    expect(repo.update).toHaveBeenCalledWith('gs-1', expect.objectContaining({ name: 'New Name' }));
  });

  it('archives a session (active → archived)', async () => {
    const archived = makeSession({ status: 'archived' });
    vi.mocked(repo.findById).mockResolvedValue(makeSession());
    vi.mocked(repo.update).mockResolvedValue(archived);

    const result = await handler.execute(
      new UpdateGameSessionCommand('gs-1', 'user-1', makeDto({ status: 'archived' })),
    );

    expect(result.status).toBe('archived');
  });

  it('un-archives a session (archived → active)', async () => {
    const active = makeSession({ status: 'active' });
    vi.mocked(repo.findById).mockResolvedValue(makeSession({ status: 'archived' }));
    vi.mocked(repo.update).mockResolvedValue(active);

    const result = await handler.execute(
      new UpdateGameSessionCommand('gs-1', 'user-1', makeDto({ status: 'active' })),
    );

    expect(result.status).toBe('active');
  });

  it('throws GameSessionNameEmptyError when name is empty', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeSession());

    await expect(
      handler.execute(new UpdateGameSessionCommand('gs-1', 'user-1', makeDto({ name: '  ' }))),
    ).rejects.toBeInstanceOf(GameSessionNameEmptyError);
  });

  it('throws GameSessionNameTooLongError when name exceeds 80 chars', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeSession());

    await expect(
      handler.execute(
        new UpdateGameSessionCommand('gs-1', 'user-1', makeDto({ name: 'x'.repeat(81) })),
      ),
    ).rejects.toBeInstanceOf(GameSessionNameTooLongError);
  });
});

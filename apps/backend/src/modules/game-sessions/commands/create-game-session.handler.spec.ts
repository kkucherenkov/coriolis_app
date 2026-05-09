/**
 * Unit tests for CreateGameSessionHandler.
 * Repo is a vi.fn() mock — no NestJS or Prisma bootstrapping.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  GameSessionNameEmptyError,
  GameSessionNameTooLongError,
} from '../domain/game-session.errors';

import { CreateGameSessionCommand, CreateGameSessionDto } from './create-game-session.command';
import { CreateGameSessionHandler } from './create-game-session.handler';

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

function makeDto(overrides: Partial<CreateGameSessionDto> = {}): CreateGameSessionDto {
  return Object.assign(new CreateGameSessionDto(), { name: 'The Long Night', ...overrides });
}

describe('CreateGameSessionHandler', () => {
  let repo: IGameSessionRepo;
  let handler: CreateGameSessionHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new CreateGameSessionHandler(repo);
  });

  it('creates a session with default status active and dpCount 0', async () => {
    const session = makeSession();
    vi.mocked(repo.create).mockResolvedValue(session);

    const result = await handler.execute(new CreateGameSessionCommand('user-1', makeDto()));

    expect(result).toEqual(session);
    expect(result.status).toBe('active');
    expect(result.dpCount).toBe(0);
    expect(result.characterIds).toEqual([]);
  });

  it('passes name, description and shipId to repo.create', async () => {
    vi.mocked(repo.create).mockResolvedValue(
      makeSession({ description: 'desc', shipId: 'ship-1' }),
    );

    await handler.execute(
      new CreateGameSessionCommand('user-1', makeDto({ description: 'desc', shipId: 'ship-1' })),
    );

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ name: 'The Long Night', description: 'desc', shipId: 'ship-1' }),
    );
  });

  it('trims whitespace from name', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeSession());

    await handler.execute(
      new CreateGameSessionCommand('user-1', makeDto({ name: '  The Long Night  ' })),
    );

    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ name: 'The Long Night' }));
  });

  it('throws GameSessionNameEmptyError for empty name', async () => {
    await expect(
      handler.execute(new CreateGameSessionCommand('user-1', makeDto({ name: '' }))),
    ).rejects.toBeInstanceOf(GameSessionNameEmptyError);
    expect(repo.create).not.toHaveBeenCalled();
  });

  it('throws GameSessionNameEmptyError with code GAME_SESSION_NAME_EMPTY', async () => {
    await expect(
      handler.execute(new CreateGameSessionCommand('user-1', makeDto({ name: '  ' }))),
    ).rejects.toMatchObject({ code: 'GAME_SESSION_NAME_EMPTY', status: 400 });
  });

  it('throws GameSessionNameTooLongError when name exceeds 80 chars', async () => {
    await expect(
      handler.execute(new CreateGameSessionCommand('user-1', makeDto({ name: 'a'.repeat(81) }))),
    ).rejects.toBeInstanceOf(GameSessionNameTooLongError);
    expect(repo.create).not.toHaveBeenCalled();
  });

  it('accepts name of exactly 80 characters', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeSession({ name: 'a'.repeat(80) }));

    await expect(
      handler.execute(new CreateGameSessionCommand('user-1', makeDto({ name: 'a'.repeat(80) }))),
    ).resolves.toBeDefined();
  });

  it('defaults description to null when not provided', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeSession());

    await handler.execute(new CreateGameSessionCommand('user-1', makeDto()));

    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ description: null }));
  });
});

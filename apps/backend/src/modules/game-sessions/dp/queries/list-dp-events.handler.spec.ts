/**
 * Unit tests for ListDpEventsHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  GameSessionNotFoundError,
  GameSessionNotOwnerError,
} from '../../domain/game-session.errors';
import { ListDpEventsQuery } from './list-dp-events.query';
import { ListDpEventsHandler } from './list-dp-events.handler';

import type { GameSessionReadModel, IGameSessionRepo } from '../../domain/game-session.ports';
import type { DpEventReadModel, IDpRepo } from '../domain/dp.ports';

function makeSessionRepo(): IGameSessionRepo {
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

function makeDpRepo(): IDpRepo {
  return {
    applyDelta: vi.fn(),
    listEvents: vi.fn(),
  };
}

function makeSession(overrides: Partial<GameSessionReadModel> = {}): GameSessionReadModel {
  return {
    id: 'gs-1',
    ownerId: 'user-gm',
    name: 'The Long Night',
    description: null,
    status: 'active',
    dpCount: 3,
    characterIds: [],
    shipId: null,
    createdAt: '2026-05-09T10:00:00.000Z',
    updatedAt: '2026-05-09T10:00:00.000Z',
    ...overrides,
  };
}

function makeDpEvent(overrides: Partial<DpEventReadModel> = {}): DpEventReadModel {
  return {
    id: 'dpe-1',
    gameSessionId: 'gs-1',
    delta: 1,
    reason: 'Roll pushed',
    source: 'ROLL_PUSH',
    rollId: 'roll-1',
    createdAt: '2026-05-09T10:01:00.000Z',
    ...overrides,
  };
}

describe('ListDpEventsHandler', () => {
  let sessionRepo: IGameSessionRepo;
  let dpRepo: IDpRepo;
  let handler: ListDpEventsHandler;

  beforeEach(() => {
    sessionRepo = makeSessionRepo();
    dpRepo = makeDpRepo();
    handler = new ListDpEventsHandler(sessionRepo, dpRepo);
  });

  it('returns events ordered newest-first', async () => {
    const events = [makeDpEvent({ id: 'dpe-2' }), makeDpEvent({ id: 'dpe-1' })];
    vi.mocked(sessionRepo.findById).mockResolvedValue(makeSession());
    vi.mocked(dpRepo.listEvents).mockResolvedValue({ items: events, nextCursor: null });

    const result = await handler.execute(new ListDpEventsQuery('gs-1', 'user-gm', 20));

    expect(result.items).toHaveLength(2);
    expect(result.nextCursor).toBeNull();
    expect(dpRepo.listEvents).toHaveBeenCalledWith({
      gameSessionId: 'gs-1',
      limit: 20,
      cursor: undefined,
    });
  });

  it('throws GAME_SESSION_NOT_FOUND when session does not exist', async () => {
    vi.mocked(sessionRepo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new ListDpEventsQuery('gs-missing', 'user-gm', 20)),
    ).rejects.toBeInstanceOf(GameSessionNotFoundError);
    expect(dpRepo.listEvents).not.toHaveBeenCalled();
  });

  it('throws GAME_SESSION_NOT_OWNER when caller is not the GM', async () => {
    vi.mocked(sessionRepo.findById).mockResolvedValue(makeSession({ ownerId: 'other-gm' }));

    await expect(
      handler.execute(new ListDpEventsQuery('gs-1', 'user-gm', 20)),
    ).rejects.toBeInstanceOf(GameSessionNotOwnerError);
    expect(dpRepo.listEvents).not.toHaveBeenCalled();
  });

  it('passes cursor to the repo', async () => {
    vi.mocked(sessionRepo.findById).mockResolvedValue(makeSession());
    vi.mocked(dpRepo.listEvents).mockResolvedValue({ items: [], nextCursor: null });

    await handler.execute(new ListDpEventsQuery('gs-1', 'user-gm', 10, 'cursor-xyz'));

    expect(dpRepo.listEvents).toHaveBeenCalledWith({
      gameSessionId: 'gs-1',
      limit: 10,
      cursor: 'cursor-xyz',
    });
  });
});

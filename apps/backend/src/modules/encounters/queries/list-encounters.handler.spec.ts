/**
 * Unit tests for ListEncountersHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { EncounterAccessDeniedError, EncounterNotFoundError } from '../domain/encounter.errors';

import { ListEncountersQuery } from './list-encounters.query';
import { ListEncountersHandler } from './list-encounters.handler';

import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type { EncounterReadModel, IEncounterRepo } from '../domain/encounter.ports';

function makeRepo(): IEncounterRepo {
  return {
    findById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
  };
}

function makeAccess(): IGameSessionAccess {
  return {
    isOwner: vi.fn(),
    isMember: vi.fn(),
    getOwnerId: vi.fn(),
  };
}

function makeEncounter(overrides: Partial<EncounterReadModel> = {}): EncounterReadModel {
  return {
    id: 'enc-1',
    gameSessionId: 'gs-1',
    name: 'Ambush',
    notes: null,
    status: 'setup',
    round: 0,
    activeCombatantId: null,
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
    ...overrides,
  };
}

describe('ListEncountersHandler', () => {
  let repo: IEncounterRepo;
  let access: IGameSessionAccess;
  let handler: ListEncountersHandler;

  beforeEach(() => {
    repo = makeRepo();
    access = makeAccess();
    handler = new ListEncountersHandler(repo, access);
    vi.mocked(access.getOwnerId).mockResolvedValue('user-1');
    vi.mocked(repo.list).mockResolvedValue({ items: [], nextCursor: null });
  });

  it('returns encounter list for GM owner', async () => {
    const items = [makeEncounter()];
    vi.mocked(repo.list).mockResolvedValue({ items, nextCursor: null });

    const result = await handler.execute(new ListEncountersQuery('gs-1', 'user-1', 20));

    expect(result.items).toHaveLength(1);
    expect(result.nextCursor).toBeNull();
  });

  it('passes cursor to repo', async () => {
    await handler.execute(new ListEncountersQuery('gs-1', 'user-1', 20, 'cursor-abc'));

    expect(repo.list).toHaveBeenCalledWith(expect.objectContaining({ cursor: 'cursor-abc' }));
  });

  it('passes status filter to repo', async () => {
    await handler.execute(new ListEncountersQuery('gs-1', 'user-1', 20, undefined, 'active'));

    expect(repo.list).toHaveBeenCalledWith(expect.objectContaining({ status: 'active' }));
  });

  it('throws EncounterNotFoundError when session does not exist', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue(null);

    await expect(
      handler.execute(new ListEncountersQuery('gs-missing', 'user-1', 20)),
    ).rejects.toBeInstanceOf(EncounterNotFoundError);
    expect(repo.list).not.toHaveBeenCalled();
  });

  it('throws EncounterAccessDeniedError when caller is not GM owner', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue('owner-1');

    await expect(
      handler.execute(new ListEncountersQuery('gs-1', 'other-user', 20)),
    ).rejects.toBeInstanceOf(EncounterAccessDeniedError);
    expect(repo.list).not.toHaveBeenCalled();
  });

  it('EncounterAccessDeniedError has status 403', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue('owner-1');

    await expect(
      handler.execute(new ListEncountersQuery('gs-1', 'other-user', 20)),
    ).rejects.toMatchObject({ code: 'ENCOUNTER_ACCESS_DENIED', status: 403 });
  });

  it('returns empty list when session has no encounters', async () => {
    const result = await handler.execute(new ListEncountersQuery('gs-1', 'user-1', 20));

    expect(result.items).toHaveLength(0);
    expect(result.nextCursor).toBeNull();
  });
});

/**
 * Unit tests for GetEncounterHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { EncounterAccessDeniedError, EncounterNotFoundError } from '../domain/encounter.errors';

import { GetEncounterQuery } from './get-encounter.query';
import { GetEncounterHandler } from './get-encounter.handler';

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

describe('GetEncounterHandler', () => {
  let repo: IEncounterRepo;
  let access: IGameSessionAccess;
  let handler: GetEncounterHandler;

  beforeEach(() => {
    repo = makeRepo();
    access = makeAccess();
    handler = new GetEncounterHandler(repo, access);
    vi.mocked(access.getOwnerId).mockResolvedValue('user-1');
  });

  it('returns encounter when caller is GM owner', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());

    const result = await handler.execute(new GetEncounterQuery('enc-1', 'user-1'));

    expect(result.id).toBe('enc-1');
    expect(result.status).toBe('setup');
  });

  it('throws EncounterNotFoundError when encounter does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new GetEncounterQuery('enc-missing', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterNotFoundError);
  });

  it('throws EncounterNotFoundError when session no longer exists', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(access.getOwnerId).mockResolvedValue(null);

    await expect(handler.execute(new GetEncounterQuery('enc-1', 'user-1'))).rejects.toBeInstanceOf(
      EncounterNotFoundError,
    );
  });

  it('throws EncounterAccessDeniedError when caller is not GM owner', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(access.getOwnerId).mockResolvedValue('owner-1');

    await expect(
      handler.execute(new GetEncounterQuery('enc-1', 'other-user')),
    ).rejects.toBeInstanceOf(EncounterAccessDeniedError);
  });

  it('EncounterAccessDeniedError has status 403', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(access.getOwnerId).mockResolvedValue('owner-1');

    await expect(
      handler.execute(new GetEncounterQuery('enc-1', 'other-user')),
    ).rejects.toMatchObject({ code: 'ENCOUNTER_ACCESS_DENIED', status: 403 });
  });
});

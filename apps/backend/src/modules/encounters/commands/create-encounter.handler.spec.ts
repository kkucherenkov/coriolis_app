/**
 * Unit tests for CreateEncounterHandler.
 * Repo and GameSessionAccess are vi.fn() mocks — no NestJS or Prisma.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { EncounterAccessDeniedError, EncounterNotFoundError } from '../domain/encounter.errors';

import { CreateEncounterCommand, CreateEncounterDto } from './create-encounter.command';
import { CreateEncounterHandler } from './create-encounter.handler';

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
    name: 'Ambush at Dock 7',
    notes: null,
    status: 'setup',
    round: 0,
    activeCombatantId: null,
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
    ...overrides,
  };
}

function makeDto(overrides: Partial<CreateEncounterDto> = {}): CreateEncounterDto {
  return Object.assign(new CreateEncounterDto(), { name: 'Ambush at Dock 7', ...overrides });
}

describe('CreateEncounterHandler', () => {
  let repo: IEncounterRepo;
  let access: IGameSessionAccess;
  let handler: CreateEncounterHandler;

  beforeEach(() => {
    repo = makeRepo();
    access = makeAccess();
    handler = new CreateEncounterHandler(repo, access);
  });

  it('creates an encounter when caller is GM owner', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue('user-1');
    vi.mocked(repo.create).mockResolvedValue(makeEncounter());

    const result = await handler.execute(new CreateEncounterCommand('gs-1', 'user-1', makeDto()));

    expect(repo.create).toHaveBeenCalledWith({
      gameSessionId: 'gs-1',
      name: 'Ambush at Dock 7',
      notes: null,
    });
    expect(result.status).toBe('setup');
    expect(result.round).toBe(0);
    expect(result.activeCombatantId).toBeNull();
  });

  it('trims whitespace from name', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue('user-1');
    vi.mocked(repo.create).mockResolvedValue(makeEncounter({ name: 'Ambush' }));

    await handler.execute(
      new CreateEncounterCommand('gs-1', 'user-1', makeDto({ name: '  Ambush  ' })),
    );

    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ name: 'Ambush' }));
  });

  it('passes notes to repo', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue('user-1');
    vi.mocked(repo.create).mockResolvedValue(makeEncounter({ notes: 'Watch the flanks' }));

    await handler.execute(
      new CreateEncounterCommand('gs-1', 'user-1', makeDto({ notes: 'Watch the flanks' })),
    );

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ notes: 'Watch the flanks' }),
    );
  });

  it('throws EncounterNotFoundError when session does not exist', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue(null);

    await expect(
      handler.execute(new CreateEncounterCommand('gs-missing', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(EncounterNotFoundError);
    expect(repo.create).not.toHaveBeenCalled();
  });

  it('throws EncounterAccessDeniedError when caller is not GM owner', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue('owner-1');

    await expect(
      handler.execute(new CreateEncounterCommand('gs-1', 'other-user', makeDto())),
    ).rejects.toBeInstanceOf(EncounterAccessDeniedError);
    expect(repo.create).not.toHaveBeenCalled();
  });

  it('EncounterAccessDeniedError has status 403', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue('owner-1');

    await expect(
      handler.execute(new CreateEncounterCommand('gs-1', 'other-user', makeDto())),
    ).rejects.toMatchObject({ code: 'ENCOUNTER_ACCESS_DENIED', status: 403 });
  });
});

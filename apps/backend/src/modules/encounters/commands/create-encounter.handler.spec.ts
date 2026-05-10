/**
 * Unit tests for CreateEncounterHandler.
 * Repo, GameSessionAccess, CombatantRepo, and CombatPublisher are vi.fn() mocks — no NestJS or Prisma.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { EncounterAccessDeniedError, EncounterNotFoundError } from '../domain/encounter.errors';

import { CreateEncounterCommand, CreateEncounterDto } from './create-encounter.command';
import { CreateEncounterHandler } from './create-encounter.handler';

import type { ICombatantRepo, CombatantReadModel } from '../../combatants/domain/combatant.ports';
import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type { EncounterReadModel, IEncounterRepo } from '../domain/encounter.ports';
import type { ICombatPublisher } from '../infra/combat.publisher';

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

function makeCombatantRepo(): ICombatantRepo {
  return {
    findById: vi.fn(),
    listByEncounter: vi.fn().mockResolvedValue([]),
    listByEncounterWithSnapshot: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
    countByEncounter: vi.fn(),
  };
}

function makeCombatPublisher(): ICombatPublisher {
  return { publishUpdated: vi.fn().mockResolvedValue(undefined) };
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
  let combatantRepo: ICombatantRepo;
  let combatPublisher: ICombatPublisher;
  let handler: CreateEncounterHandler;

  beforeEach(() => {
    repo = makeRepo();
    access = makeAccess();
    combatantRepo = makeCombatantRepo();
    combatPublisher = makeCombatPublisher();
    handler = new CreateEncounterHandler(repo, access, combatantRepo, combatPublisher);
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

  it('calls combatPublisher.publishUpdated after successful create', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue('user-1');
    const enc = makeEncounter();
    vi.mocked(repo.create).mockResolvedValue(enc);
    const combatants: CombatantReadModel[] = [];
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue(combatants);

    await handler.execute(new CreateEncounterCommand('gs-1', 'user-1', makeDto()));

    expect(combatPublisher.publishUpdated).toHaveBeenCalledWith('gs-1', enc, combatants);
  });

  it('publish failure does not break the flow — returns encounter normally', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue('user-1');
    const enc = makeEncounter();
    vi.mocked(repo.create).mockResolvedValue(enc);
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([]);
    vi.mocked(combatPublisher.publishUpdated).mockRejectedValueOnce(new Error('Centrifugo down'));

    const result = await handler.execute(new CreateEncounterCommand('gs-1', 'user-1', makeDto()));

    expect(result).toEqual(enc);
  });
});

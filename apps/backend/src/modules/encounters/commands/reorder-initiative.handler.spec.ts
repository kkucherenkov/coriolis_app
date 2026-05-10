/**
 * Unit tests for ReorderInitiativeHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  EncounterAccessDeniedError,
  EncounterInvalidStatusError,
  EncounterNotFoundError,
  InitiativeUnknownCombatantError,
} from '../domain/encounter.errors';

import { ReorderInitiativeCommand, ReorderInitiativeDto } from './reorder-initiative.command';
import { ReorderInitiativeHandler } from './reorder-initiative.handler';

import type { ICombatantRepo, CombatantReadModel } from '../../combatants/domain/combatant.ports';
import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type {
  EncounterReadModel,
  IEncounterRepo,
  IInitiativeRepo,
  InitiativeRollResult,
} from '../domain/encounter.ports';
import type { ICombatPublisher } from '../infra/combat.publisher';

// --------------- Helpers ---------------

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
    listByEncounter: vi.fn(),
    listByEncounterWithSnapshot: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
    countByEncounter: vi.fn(),
  };
}

function makeInitiativeRepo(): IInitiativeRepo {
  return {
    rollInitiative: vi.fn(),
    reorderInitiative: vi.fn(),
    advanceTurn: vi.fn(),
  };
}

function makeCombatPublisher(): ICombatPublisher {
  return { publishUpdated: vi.fn().mockResolvedValue(undefined) };
}

function makeEncounter(overrides: Partial<EncounterReadModel> = {}): EncounterReadModel {
  return {
    id: 'enc-1',
    gameSessionId: 'gs-1',
    name: 'Ambush',
    notes: null,
    status: 'active',
    round: 1,
    activeCombatantId: 'cb-1',
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
    ...overrides,
  };
}

function makeCombatant(id: string): CombatantReadModel {
  return {
    id,
    encounterId: 'enc-1',
    combatantType: 'pc',
    sourceId: `char-${id}`,
    displayName: `Fighter ${id}`,
    initiative: 5,
    turnOrder: 0,
    hpCurrent: 4,
    hpMax: 4,
    armor: 0,
    signature: 0,
    statusFlags: [],
    notes: null,
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
  };
}

function makeDto(combatantIds: string[]): ReorderInitiativeDto {
  const dto = new ReorderInitiativeDto();
  dto.combatantIds = combatantIds;
  return dto;
}

function makeReorderResult(ids: string[]): InitiativeRollResult {
  return {
    round: 1,
    combatants: ids.map((id) => makeCombatant(id)),
  };
}

// --------------- Tests ---------------

describe('ReorderInitiativeHandler', () => {
  let repo: IEncounterRepo;
  let access: IGameSessionAccess;
  let combatantRepo: ICombatantRepo;
  let initiativeRepo: IInitiativeRepo;
  let combatPublisher: ICombatPublisher;
  let handler: ReorderInitiativeHandler;

  beforeEach(() => {
    repo = makeRepo();
    access = makeAccess();
    combatantRepo = makeCombatantRepo();
    initiativeRepo = makeInitiativeRepo();
    combatPublisher = makeCombatPublisher();
    handler = new ReorderInitiativeHandler(
      repo,
      access,
      combatantRepo,
      initiativeRepo,
      combatPublisher,
    );

    vi.mocked(access.getOwnerId).mockResolvedValue('user-1');
  });

  it('throws EncounterNotFoundError when encounter does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new ReorderInitiativeCommand('enc-missing', 'user-1', makeDto(['cb-1']))),
    ).rejects.toBeInstanceOf(EncounterNotFoundError);
  });

  it('throws EncounterNotFoundError when session not found', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(access.getOwnerId).mockResolvedValue(null);

    await expect(
      handler.execute(new ReorderInitiativeCommand('enc-1', 'user-1', makeDto(['cb-1']))),
    ).rejects.toBeInstanceOf(EncounterNotFoundError);
  });

  it('throws EncounterAccessDeniedError when caller is not owner', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(access.getOwnerId).mockResolvedValue('owner-1');

    await expect(
      handler.execute(new ReorderInitiativeCommand('enc-1', 'other-user', makeDto(['cb-1']))),
    ).rejects.toBeInstanceOf(EncounterAccessDeniedError);
  });

  it('throws EncounterInvalidStatusError when status is setup', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'setup' }));

    await expect(
      handler.execute(new ReorderInitiativeCommand('enc-1', 'user-1', makeDto(['cb-1']))),
    ).rejects.toBeInstanceOf(EncounterInvalidStatusError);
  });

  it('throws EncounterInvalidStatusError when status is ended', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'ended' }));

    await expect(
      handler.execute(new ReorderInitiativeCommand('enc-1', 'user-1', makeDto(['cb-1']))),
    ).rejects.toBeInstanceOf(EncounterInvalidStatusError);
  });

  it('throws InitiativeDuplicateError with the duplicate id in detail', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([
      makeCombatant('cb-1'),
      makeCombatant('cb-2'),
    ]);

    await expect(
      handler.execute(new ReorderInitiativeCommand('enc-1', 'user-1', makeDto(['cb-1', 'cb-1']))),
    ).rejects.toMatchObject({
      code: 'INITIATIVE_DUPLICATE',
      detail: expect.stringContaining('cb-1'),
    });
  });

  it('throws InitiativeUnknownCombatantError for id not in encounter', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([
      makeCombatant('cb-1'),
      makeCombatant('cb-2'),
    ]);

    await expect(
      handler.execute(
        new ReorderInitiativeCommand('enc-1', 'user-1', makeDto(['cb-1', 'cb-unknown'])),
      ),
    ).rejects.toBeInstanceOf(InitiativeUnknownCombatantError);
  });

  it('throws InitiativeIncompleteError with the missing id in detail', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([
      makeCombatant('cb-1'),
      makeCombatant('cb-2'),
    ]);

    await expect(
      handler.execute(new ReorderInitiativeCommand('enc-1', 'user-1', makeDto(['cb-1']))),
    ).rejects.toMatchObject({
      code: 'INITIATIVE_INCOMPLETE',
      detail: expect.stringContaining('cb-2'),
    });
  });

  it('happy path: calls reorderInitiative with the supplied order', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([
      makeCombatant('cb-1'),
      makeCombatant('cb-2'),
    ]);
    const reorderResult = makeReorderResult(['cb-2', 'cb-1']);
    vi.mocked(initiativeRepo.reorderInitiative).mockResolvedValue(reorderResult);

    const result = await handler.execute(
      new ReorderInitiativeCommand('enc-1', 'user-1', makeDto(['cb-2', 'cb-1'])),
    );

    expect(initiativeRepo.reorderInitiative).toHaveBeenCalledWith({
      encounterId: 'enc-1',
      orderedIds: ['cb-2', 'cb-1'],
    });
    expect(result.round).toBe(1);
  });

  it('does not touch activeCombatantId, round, or initiative (only reorderInitiative called)', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([
      makeCombatant('cb-1'),
      makeCombatant('cb-2'),
    ]);
    vi.mocked(initiativeRepo.reorderInitiative).mockResolvedValue(
      makeReorderResult(['cb-2', 'cb-1']),
    );

    await handler.execute(
      new ReorderInitiativeCommand('enc-1', 'user-1', makeDto(['cb-2', 'cb-1'])),
    );

    // rollInitiative and advanceTurn must not be called
    expect(initiativeRepo.rollInitiative).not.toHaveBeenCalled();
    expect(initiativeRepo.advanceTurn).not.toHaveBeenCalled();
    expect(repo.update).not.toHaveBeenCalled();
  });

  it('calls combatPublisher.publishUpdated after successful reorder', async () => {
    const enc = makeEncounter();
    vi.mocked(repo.findById).mockResolvedValueOnce(enc); // initial load
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([
      makeCombatant('cb-1'),
      makeCombatant('cb-2'),
    ]);
    const reorderResult = makeReorderResult(['cb-2', 'cb-1']);
    vi.mocked(initiativeRepo.reorderInitiative).mockResolvedValue(reorderResult);
    vi.mocked(repo.findById).mockResolvedValueOnce(enc); // post-commit re-fetch

    await handler.execute(
      new ReorderInitiativeCommand('enc-1', 'user-1', makeDto(['cb-2', 'cb-1'])),
    );

    expect(combatPublisher.publishUpdated).toHaveBeenCalledWith(
      'gs-1',
      enc,
      reorderResult.combatants,
    );
  });

  it('publish failure does not break the flow — returns reorder result normally', async () => {
    vi.mocked(repo.findById).mockResolvedValueOnce(makeEncounter()); // initial load
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([
      makeCombatant('cb-1'),
      makeCombatant('cb-2'),
    ]);
    const reorderResult = makeReorderResult(['cb-2', 'cb-1']);
    vi.mocked(initiativeRepo.reorderInitiative).mockResolvedValue(reorderResult);
    vi.mocked(repo.findById).mockResolvedValueOnce(makeEncounter()); // post-commit re-fetch
    vi.mocked(combatPublisher.publishUpdated).mockRejectedValueOnce(new Error('Centrifugo down'));

    const result = await handler.execute(
      new ReorderInitiativeCommand('enc-1', 'user-1', makeDto(['cb-2', 'cb-1'])),
    );

    expect(result).toEqual(reorderResult);
  });
});

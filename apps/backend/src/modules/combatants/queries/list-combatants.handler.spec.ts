/**
 * Unit tests for ListCombatantsHandler.
 * All I/O is mocked — no Prisma, no NestJS bootstrap.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  EncounterAccessDeniedError,
  EncounterNotFoundError,
} from '../../encounters/domain/encounter.errors';

import { ListCombatantsQuery } from './list-combatants.query';
import { ListCombatantsHandler } from './list-combatants.handler';

import type { IGameSessionAccess } from '../../encounters/domain/game-session-access.ports';
import type { EncounterReadModel, IEncounterRepo } from '../../encounters/domain/encounter.ports';
import type { CombatantReadModel, ICombatantRepo } from '../domain/combatant.ports';

// --------------- Factory helpers ---------------

function makeEncounterRepo(): IEncounterRepo {
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
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
    countByEncounter: vi.fn(),
  };
}

function makeEncounter(overrides: Partial<EncounterReadModel> = {}): EncounterReadModel {
  return {
    id: 'enc-1',
    gameSessionId: 'gs-1',
    name: 'Test Encounter',
    notes: null,
    status: 'setup',
    round: 0,
    activeCombatantId: null,
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
    ...overrides,
  };
}

function makeCombatant(overrides: Partial<CombatantReadModel> = {}): CombatantReadModel {
  return {
    id: 'comb-1',
    encounterId: 'enc-1',
    combatantType: 'npc',
    sourceId: 'npc-1',
    displayName: 'Khorredian Guard',
    initiative: null,
    turnOrder: null,
    hpCurrent: 6,
    hpMax: 6,
    armor: 3,
    signature: 2,
    statusFlags: [],
    notes: null,
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
    ...overrides,
  };
}

// --------------- Tests ---------------

describe('ListCombatantsHandler', () => {
  let encounterRepo: IEncounterRepo;
  let access: IGameSessionAccess;
  let combatantRepo: ICombatantRepo;
  let handler: ListCombatantsHandler;

  beforeEach(() => {
    encounterRepo = makeEncounterRepo();
    access = makeAccess();
    combatantRepo = makeCombatantRepo();
    handler = new ListCombatantsHandler(encounterRepo, access, combatantRepo);

    vi.mocked(access.getOwnerId).mockResolvedValue('user-1');
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([]);
  });

  it('throws EncounterNotFoundError when encounter does not exist', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new ListCombatantsQuery('enc-missing', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterNotFoundError);
    expect(combatantRepo.listByEncounter).not.toHaveBeenCalled();
  });

  it('throws EncounterNotFoundError when game session has no owner (orphan)', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue(null);

    await expect(
      handler.execute(new ListCombatantsQuery('enc-1', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterNotFoundError);
    expect(combatantRepo.listByEncounter).not.toHaveBeenCalled();
  });

  it('throws EncounterAccessDeniedError when caller is not GM owner', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue('other-user');

    await expect(
      handler.execute(new ListCombatantsQuery('enc-1', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterAccessDeniedError);
    expect(combatantRepo.listByEncounter).not.toHaveBeenCalled();
  });

  it('ENCOUNTER_NOT_OWNED has status 403', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue('other-user');

    await expect(handler.execute(new ListCombatantsQuery('enc-1', 'user-1'))).rejects.toMatchObject(
      { code: 'ENCOUNTER_ACCESS_DENIED', status: 403 },
    );
  });

  it('returns empty list when encounter has no combatants', async () => {
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([]);

    const result = await handler.execute(new ListCombatantsQuery('enc-1', 'user-1'));

    expect(result.items).toHaveLength(0);
    expect(combatantRepo.listByEncounter).toHaveBeenCalledWith('enc-1');
  });

  it('returns combatants ordered by repo (turnOrder ASC, createdAt ASC)', async () => {
    const comb1 = makeCombatant({ id: 'comb-1', turnOrder: 0 });
    const comb2 = makeCombatant({ id: 'comb-2', turnOrder: 1 });
    // Repo returns them in correct order already — handler just passes through
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([comb1, comb2]);

    const result = await handler.execute(new ListCombatantsQuery('enc-1', 'user-1'));

    expect(result.items).toHaveLength(2);
    expect(result.items[0]!.id).toBe('comb-1');
    expect(result.items[1]!.id).toBe('comb-2');
  });

  it('returns combatants with null turnOrder before initiative roll', async () => {
    const comb1 = makeCombatant({ id: 'comb-1', turnOrder: null });
    const comb2 = makeCombatant({
      id: 'comb-2',
      combatantType: 'pc',
      sourceId: 'char-1',
      turnOrder: null,
    });
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([comb1, comb2]);

    const result = await handler.execute(new ListCombatantsQuery('enc-1', 'user-1'));

    expect(result.items).toHaveLength(2);
    expect(result.items[0]!.turnOrder).toBeNull();
    expect(result.items[1]!.turnOrder).toBeNull();
  });

  it('passes encounterId to repo correctly', async () => {
    await handler.execute(new ListCombatantsQuery('enc-42', 'user-1'));

    expect(encounterRepo.findById).toHaveBeenCalledWith('enc-42');
    expect(combatantRepo.listByEncounter).toHaveBeenCalledWith('enc-42');
  });

  it('returns items with correct shape', async () => {
    const comb = makeCombatant({
      id: 'comb-1',
      combatantType: 'pc',
      sourceId: 'char-1',
      displayName: 'Zara',
      hpCurrent: 3,
      hpMax: 4,
      armor: 2,
      signature: 0,
      statusFlags: ['broken'],
    });
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([comb]);

    const result = await handler.execute(new ListCombatantsQuery('enc-1', 'user-1'));

    const item = result.items[0]!;
    expect(item.id).toBe('comb-1');
    expect(item.combatantType).toBe('pc');
    expect(item.sourceId).toBe('char-1');
    expect(item.hpCurrent).toBe(3);
    expect(item.hpMax).toBe(4);
    expect(item.statusFlags).toEqual(['broken']);
  });
});

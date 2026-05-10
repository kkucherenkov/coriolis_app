/**
 * Unit tests for DeleteCombatantHandler.
 * All I/O is mocked — no Prisma, no NestJS bootstrap.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { CombatantNotFoundError, EncounterLockedForCombatError } from '../domain/combatant.errors';

import { DeleteCombatantCommand } from './delete-combatant.command';
import { DeleteCombatantHandler } from './delete-combatant.handler';

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
    listByEncounterWithSnapshot: vi.fn(),
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

describe('DeleteCombatantHandler', () => {
  let combatantRepo: ICombatantRepo;
  let encounterRepo: IEncounterRepo;
  let access: IGameSessionAccess;
  let handler: DeleteCombatantHandler;

  beforeEach(() => {
    combatantRepo = makeCombatantRepo();
    encounterRepo = makeEncounterRepo();
    access = makeAccess();
    handler = new DeleteCombatantHandler(combatantRepo, encounterRepo, access);

    vi.mocked(access.getOwnerId).mockResolvedValue('user-1');
    vi.mocked(combatantRepo.findById).mockResolvedValue(makeCombatant());
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(combatantRepo.delete).mockResolvedValue(undefined);
  });

  it('deletes combatant when encounter is in setup status', async () => {
    await handler.execute(new DeleteCombatantCommand('comb-1', 'user-1'));

    expect(combatantRepo.delete).toHaveBeenCalledWith('comb-1');
  });

  it('throws CombatantNotFoundError when combatant does not exist', async () => {
    vi.mocked(combatantRepo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new DeleteCombatantCommand('comb-missing', 'user-1')),
    ).rejects.toBeInstanceOf(CombatantNotFoundError);
    expect(combatantRepo.delete).not.toHaveBeenCalled();
  });

  it('throws CombatantNotFoundError when encounter is gone', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new DeleteCombatantCommand('comb-1', 'user-1')),
    ).rejects.toBeInstanceOf(CombatantNotFoundError);
    expect(combatantRepo.delete).not.toHaveBeenCalled();
  });

  it('returns 404 (CombatantNotFoundError) when caller is not owner — does not leak existence', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue('other-user');

    await expect(
      handler.execute(new DeleteCombatantCommand('comb-1', 'user-1')),
    ).rejects.toBeInstanceOf(CombatantNotFoundError);
    expect(combatantRepo.delete).not.toHaveBeenCalled();
  });

  it('returns 404 when game session owner is null — does not leak existence', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue(null);

    await expect(
      handler.execute(new DeleteCombatantCommand('comb-1', 'user-1')),
    ).rejects.toBeInstanceOf(CombatantNotFoundError);
    expect(combatantRepo.delete).not.toHaveBeenCalled();
  });

  it('throws EncounterLockedForCombatError when encounter is active', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter({ status: 'active' }));

    await expect(
      handler.execute(new DeleteCombatantCommand('comb-1', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterLockedForCombatError);
    expect(combatantRepo.delete).not.toHaveBeenCalled();
  });

  it('throws EncounterLockedForCombatError when encounter is ended', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter({ status: 'ended' }));

    await expect(
      handler.execute(new DeleteCombatantCommand('comb-1', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterLockedForCombatError);
    expect(combatantRepo.delete).not.toHaveBeenCalled();
  });

  it('ENCOUNTER_LOCKED_FOR_COMBAT has status 422', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter({ status: 'active' }));

    await expect(
      handler.execute(new DeleteCombatantCommand('comb-1', 'user-1')),
    ).rejects.toMatchObject({ code: 'ENCOUNTER_LOCKED_FOR_COMBAT', status: 422 });
  });

  it('allows deleting the active combatant (onDelete:SetNull on Encounter handles FK)', async () => {
    // The encounter has activeCombatantId pointing to this combatant.
    // The Prisma schema has onDelete:SetNull on Encounter.activeCombatant relation.
    // The handler delegates to repo.delete; Prisma cascades the FK to null atomically.
    vi.mocked(encounterRepo.findById).mockResolvedValue(
      makeEncounter({ activeCombatantId: 'comb-1' }),
    );

    await handler.execute(new DeleteCombatantCommand('comb-1', 'user-1'));

    expect(combatantRepo.delete).toHaveBeenCalledWith('comb-1');
  });

  it('COMBATANT_NOT_FOUND has status 404', async () => {
    vi.mocked(combatantRepo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new DeleteCombatantCommand('comb-missing', 'user-1')),
    ).rejects.toMatchObject({ code: 'COMBATANT_NOT_FOUND', status: 404 });
  });
});

/**
 * Unit tests for UpdateCombatantHandler.
 * All I/O is mocked — no Prisma, no NestJS bootstrap.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { CombatantNotFoundError, EncounterEndedError } from '../domain/combatant.errors';

import { UpdateCombatantCommand, UpdateCombatantDto } from './update-combatant.command';
import { UpdateCombatantHandler } from './update-combatant.handler';

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

function makeDto(overrides: Partial<UpdateCombatantDto> = {}): UpdateCombatantDto {
  return Object.assign(new UpdateCombatantDto(), overrides);
}

// --------------- Tests ---------------

describe('UpdateCombatantHandler', () => {
  let combatantRepo: ICombatantRepo;
  let encounterRepo: IEncounterRepo;
  let access: IGameSessionAccess;
  let handler: UpdateCombatantHandler;

  beforeEach(() => {
    combatantRepo = makeCombatantRepo();
    encounterRepo = makeEncounterRepo();
    access = makeAccess();
    handler = new UpdateCombatantHandler(combatantRepo, encounterRepo, access);

    vi.mocked(access.getOwnerId).mockResolvedValue('user-1');
    vi.mocked(combatantRepo.findById).mockResolvedValue(makeCombatant());
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter());
  });

  it('throws CombatantNotFoundError when combatant does not exist', async () => {
    vi.mocked(combatantRepo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new UpdateCombatantCommand('comb-missing', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(CombatantNotFoundError);
    expect(combatantRepo.update).not.toHaveBeenCalled();
  });

  it('throws CombatantNotFoundError when encounter is gone', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new UpdateCombatantCommand('comb-1', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(CombatantNotFoundError);
    expect(combatantRepo.update).not.toHaveBeenCalled();
  });

  it('returns 404 (CombatantNotFoundError) when caller is not owner — does not leak existence', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue('other-user');

    await expect(
      handler.execute(new UpdateCombatantCommand('comb-1', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(CombatantNotFoundError);
    expect(combatantRepo.update).not.toHaveBeenCalled();
  });

  it('returns 404 when game session owner is null — does not leak existence', async () => {
    vi.mocked(access.getOwnerId).mockResolvedValue(null);

    await expect(
      handler.execute(new UpdateCombatantCommand('comb-1', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(CombatantNotFoundError);
    expect(combatantRepo.update).not.toHaveBeenCalled();
  });

  it('throws EncounterEndedError when encounter is ended', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(
      makeEncounter({ status: 'ended', id: 'enc-1' }),
    );

    await expect(
      handler.execute(new UpdateCombatantCommand('comb-1', 'user-1', makeDto({ hpCurrent: 3 }))),
    ).rejects.toBeInstanceOf(EncounterEndedError);
    expect(combatantRepo.update).not.toHaveBeenCalled();
  });

  it('ENCOUNTER_ENDED has status 422', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter({ status: 'ended' }));

    await expect(
      handler.execute(new UpdateCombatantCommand('comb-1', 'user-1', makeDto({ hpCurrent: 3 }))),
    ).rejects.toMatchObject({ code: 'ENCOUNTER_ENDED', status: 422 });
  });

  it('updates hpCurrent in setup status', async () => {
    const updated = makeCombatant({ hpCurrent: 2 });
    vi.mocked(combatantRepo.update).mockResolvedValue(updated);

    const result = await handler.execute(
      new UpdateCombatantCommand('comb-1', 'user-1', makeDto({ hpCurrent: 2 })),
    );

    expect(combatantRepo.update).toHaveBeenCalledWith(
      'comb-1',
      expect.objectContaining({ hpCurrent: 2 }),
    );
    expect(result.hpCurrent).toBe(2);
  });

  it('updates hpCurrent in active status', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter({ status: 'active' }));
    const updated = makeCombatant({ hpCurrent: 0 });
    vi.mocked(combatantRepo.update).mockResolvedValue(updated);

    await handler.execute(
      new UpdateCombatantCommand('comb-1', 'user-1', makeDto({ hpCurrent: 0 })),
    );

    expect(combatantRepo.update).toHaveBeenCalledWith(
      'comb-1',
      expect.objectContaining({ hpCurrent: 0 }),
    );
  });

  it('allows hpCurrent to go negative (no clamp per CT3001)', async () => {
    const updated = makeCombatant({ hpCurrent: -2 });
    vi.mocked(combatantRepo.update).mockResolvedValue(updated);

    await handler.execute(
      new UpdateCombatantCommand('comb-1', 'user-1', makeDto({ hpCurrent: -2 })),
    );

    expect(combatantRepo.update).toHaveBeenCalledWith(
      'comb-1',
      expect.objectContaining({ hpCurrent: -2 }),
    );
  });

  it('allows hpCurrent to exceed hpMax (no cap per spec)', async () => {
    const updated = makeCombatant({ hpCurrent: 10, hpMax: 6 });
    vi.mocked(combatantRepo.update).mockResolvedValue(updated);

    await handler.execute(
      new UpdateCombatantCommand('comb-1', 'user-1', makeDto({ hpCurrent: 10 })),
    );

    expect(combatantRepo.update).toHaveBeenCalledWith(
      'comb-1',
      expect.objectContaining({ hpCurrent: 10 }),
    );
  });

  it('updates statusFlags', async () => {
    const updated = makeCombatant({ statusFlags: ['broken'] });
    vi.mocked(combatantRepo.update).mockResolvedValue(updated);

    await handler.execute(
      new UpdateCombatantCommand('comb-1', 'user-1', makeDto({ statusFlags: ['broken'] })),
    );

    expect(combatantRepo.update).toHaveBeenCalledWith(
      'comb-1',
      expect.objectContaining({ statusFlags: ['broken'] }),
    );
  });

  it('updates displayName', async () => {
    const updated = makeCombatant({ displayName: 'Elite Guard' });
    vi.mocked(combatantRepo.update).mockResolvedValue(updated);

    await handler.execute(
      new UpdateCombatantCommand('comb-1', 'user-1', makeDto({ displayName: 'Elite Guard' })),
    );

    expect(combatantRepo.update).toHaveBeenCalledWith(
      'comb-1',
      expect.objectContaining({ displayName: 'Elite Guard' }),
    );
  });

  it('updates notes to null (explicit null clears)', async () => {
    const updated = makeCombatant({ notes: null });
    vi.mocked(combatantRepo.update).mockResolvedValue(updated);

    await handler.execute(new UpdateCombatantCommand('comb-1', 'user-1', makeDto({ notes: null })));

    expect(combatantRepo.update).toHaveBeenCalledWith(
      'comb-1',
      expect.objectContaining({ notes: null }),
    );
  });

  it('does NOT forward initiative in patch (Block 4 only)', async () => {
    vi.mocked(combatantRepo.update).mockResolvedValue(makeCombatant());

    await handler.execute(
      new UpdateCombatantCommand('comb-1', 'user-1', makeDto({ hpCurrent: 3 })),
    );

    expect(combatantRepo.update).toHaveBeenCalledWith(
      'comb-1',
      expect.not.objectContaining({ initiative: expect.anything() }),
    );
  });

  it('does NOT forward turnOrder in patch (Block 4 only)', async () => {
    vi.mocked(combatantRepo.update).mockResolvedValue(makeCombatant());

    await handler.execute(
      new UpdateCombatantCommand('comb-1', 'user-1', makeDto({ hpCurrent: 3 })),
    );

    expect(combatantRepo.update).toHaveBeenCalledWith(
      'comb-1',
      expect.not.objectContaining({ turnOrder: expect.anything() }),
    );
  });

  it('no-op patch (empty dto) calls update with empty payload', async () => {
    vi.mocked(combatantRepo.update).mockResolvedValue(makeCombatant());

    await handler.execute(new UpdateCombatantCommand('comb-1', 'user-1', makeDto()));

    expect(combatantRepo.update).toHaveBeenCalledWith('comb-1', {});
  });
});

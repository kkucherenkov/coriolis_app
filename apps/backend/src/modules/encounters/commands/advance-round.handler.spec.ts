/**
 * Unit tests for AdvanceRoundHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  EncounterAccessDeniedError,
  EncounterInitiativeNotRolledError,
  EncounterInvalidStatusError,
  EncounterNotFoundError,
} from '../domain/encounter.errors';

import { AdvanceRoundCommand } from './advance-round.command';
import { AdvanceRoundHandler } from './advance-round.handler';

import type { ICombatantRepo, CombatantReadModel } from '../../combatants/domain/combatant.ports';
import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type {
  EncounterReadModel,
  IEncounterRepo,
  IInitiativeRepo,
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
    round: 2,
    activeCombatantId: 'cb-2',
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
    ...overrides,
  };
}

function makeCombatant(id: string, turnOrder: number): CombatantReadModel {
  return {
    id,
    encounterId: 'enc-1',
    combatantType: 'pc',
    sourceId: `char-${id}`,
    displayName: `Fighter ${id}`,
    initiative: 5,
    turnOrder,
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

// --------------- Tests ---------------

describe('AdvanceRoundHandler', () => {
  let repo: IEncounterRepo;
  let access: IGameSessionAccess;
  let combatantRepo: ICombatantRepo;
  let initiativeRepo: IInitiativeRepo;
  let combatPublisher: ICombatPublisher;
  let handler: AdvanceRoundHandler;

  beforeEach(() => {
    repo = makeRepo();
    access = makeAccess();
    combatantRepo = makeCombatantRepo();
    initiativeRepo = makeInitiativeRepo();
    combatPublisher = makeCombatPublisher();
    handler = new AdvanceRoundHandler(repo, access, combatantRepo, initiativeRepo, combatPublisher);

    vi.mocked(access.getOwnerId).mockResolvedValue('user-1');
    vi.mocked(initiativeRepo.advanceTurn).mockResolvedValue(undefined);
  });

  it('throws EncounterNotFoundError when encounter does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new AdvanceRoundCommand('enc-missing', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterNotFoundError);
  });

  it('throws EncounterNotFoundError when session not found', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(access.getOwnerId).mockResolvedValue(null);

    await expect(
      handler.execute(new AdvanceRoundCommand('enc-1', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterNotFoundError);
  });

  it('throws EncounterAccessDeniedError when caller is not owner', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(access.getOwnerId).mockResolvedValue('owner-1');

    await expect(
      handler.execute(new AdvanceRoundCommand('enc-1', 'other-user')),
    ).rejects.toBeInstanceOf(EncounterAccessDeniedError);
  });

  it('throws EncounterInvalidStatusError when status is setup', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'setup' }));

    await expect(
      handler.execute(new AdvanceRoundCommand('enc-1', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterInvalidStatusError);
  });

  it('throws EncounterInvalidStatusError when status is ended', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'ended' }));

    await expect(
      handler.execute(new AdvanceRoundCommand('enc-1', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterInvalidStatusError);
  });

  it('throws EncounterInitiativeNotRolledError when activeCombatantId is null', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ activeCombatantId: null }));

    await expect(
      handler.execute(new AdvanceRoundCommand('enc-1', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterInitiativeNotRolledError);
  });

  it('throws EncounterInitiativeNotRolledError when combatants list is empty (defensive)', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ activeCombatantId: 'cb-1' }));
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([]);

    await expect(
      handler.execute(new AdvanceRoundCommand('enc-1', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterInitiativeNotRolledError);
  });

  it('increments round, resets to turnOrder[0], isNewRound=true', async () => {
    vi.mocked(repo.findById).mockResolvedValue(
      makeEncounter({ activeCombatantId: 'cb-2', round: 2 }),
    );
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([
      makeCombatant('cb-1', 0),
      makeCombatant('cb-2', 1),
      makeCombatant('cb-3', 2),
    ]);

    const result = await handler.execute(new AdvanceRoundCommand('enc-1', 'user-1'));

    expect(result.activeCombatantId).toBe('cb-1');
    expect(result.round).toBe(3);
    expect(result.isNewRound).toBe(true);
    expect(initiativeRepo.advanceTurn).toHaveBeenCalledWith({
      encounterId: 'enc-1',
      activeCombatantId: 'cb-1',
      round: 3,
    });
  });

  it('calls combatPublisher.publishUpdated after successful advance', async () => {
    vi.mocked(repo.findById).mockResolvedValueOnce(
      makeEncounter({ activeCombatantId: 'cb-2', round: 2 }),
    ); // initial load
    const combatants = [makeCombatant('cb-1', 0), makeCombatant('cb-2', 1)];
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue(combatants);
    const updatedEncounter = makeEncounter({ activeCombatantId: 'cb-1', round: 3 });
    vi.mocked(repo.findById).mockResolvedValueOnce(updatedEncounter); // post-commit re-fetch

    await handler.execute(new AdvanceRoundCommand('enc-1', 'user-1'));

    expect(combatPublisher.publishUpdated).toHaveBeenCalledOnce();
    expect(combatPublisher.publishUpdated).toHaveBeenCalledWith(
      'gs-1',
      updatedEncounter,
      combatants,
    );
  });

  it('publish failure does not break the flow — returns TurnAdvanceResult normally', async () => {
    vi.mocked(repo.findById).mockResolvedValueOnce(
      makeEncounter({ activeCombatantId: 'cb-2', round: 1 }),
    ); // initial load
    vi.mocked(combatantRepo.listByEncounter).mockResolvedValue([
      makeCombatant('cb-1', 0),
      makeCombatant('cb-2', 1),
    ]);
    vi.mocked(repo.findById).mockResolvedValueOnce(
      makeEncounter({ activeCombatantId: 'cb-1', round: 2 }),
    ); // post-commit re-fetch
    vi.mocked(combatPublisher.publishUpdated).mockRejectedValueOnce(new Error('Centrifugo down'));

    const result = await handler.execute(new AdvanceRoundCommand('enc-1', 'user-1'));

    expect(result.activeCombatantId).toBe('cb-1');
    expect(result.round).toBe(2);
    expect(result.isNewRound).toBe(true);
  });
});

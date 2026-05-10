/**
 * Unit tests for RollInitiativeHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  EncounterAccessDeniedError,
  EncounterInvalidTransitionError,
  EncounterNoCombatantsError,
  EncounterNotFoundError,
} from '../domain/encounter.errors';

import { RollInitiativeCommand } from './roll-initiative.command';
import { RollInitiativeHandler } from './roll-initiative.handler';

import type {
  ICombatantRepo,
  CombatantReadModel,
  CombatantWithSnapshot,
} from '../../combatants/domain/combatant.ports';
import type { IGameSessionAccess } from '../domain/game-session-access.ports';
import type {
  EncounterReadModel,
  IEncounterRepo,
  IInitiativeRepo,
  InitiativeRollResult,
  RollInitiativeData,
} from '../domain/encounter.ports';
import type { ICombatPublisher } from '../infra/combat.publisher';

// Mock crypto so we control the dice roll
const mockRandomInt = vi.fn<() => number>().mockReturnValue(5);
vi.mock('node:crypto', () => ({
  randomInt: (..._args: unknown[]) => mockRandomInt(),
}));

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
    status: 'setup',
    round: 0,
    activeCombatantId: null,
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
    ...overrides,
  };
}

function makeCombatant(
  id: string,
  overrides: Partial<CombatantReadModel> = {},
): CombatantReadModel {
  return {
    id,
    encounterId: 'enc-1',
    combatantType: 'pc',
    sourceId: `char-${id}`,
    displayName: `Fighter ${id}`,
    initiative: null,
    turnOrder: null,
    hpCurrent: 4,
    hpMax: 4,
    armor: 0,
    signature: 0,
    statusFlags: [],
    notes: null,
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
    ...overrides,
  };
}

function makeCombatantWithSnapshot(
  id: string,
  agility = 2,
  combatantType: 'pc' | 'npc' = 'pc',
  createdAt = '2026-05-10T10:00:00.000Z',
): CombatantWithSnapshot {
  const combatant = makeCombatant(id, { combatantType, createdAt });
  if (combatantType === 'pc') {
    return {
      combatant,
      pcSnapshot: {
        attributes: { strength: 2, agility, wits: 2, empathy: 2 },
        skills: {},
        hpMax: 4,
      },
      npcSnapshot: null,
    };
  }
  return {
    combatant,
    pcSnapshot: null,
    npcSnapshot: {
      attributes: { strength: 2, agility, wits: 2, empathy: 2 },
      skills: {},
      hpMax: 4,
      signature: 0,
    },
  };
}

function makeRollResult(combatantIds: string[]): InitiativeRollResult {
  return {
    round: 1,
    combatants: combatantIds.map((id, i) => makeCombatant(id, { initiative: 5, turnOrder: i })),
  };
}

// --------------- Tests ---------------

describe('RollInitiativeHandler', () => {
  let repo: IEncounterRepo;
  let access: IGameSessionAccess;
  let combatantRepo: ICombatantRepo;
  let initiativeRepo: IInitiativeRepo;
  let combatPublisher: ICombatPublisher;
  let handler: RollInitiativeHandler;

  beforeEach(() => {
    vi.resetAllMocks();
    mockRandomInt.mockReturnValue(5);

    repo = makeRepo();
    access = makeAccess();
    combatantRepo = makeCombatantRepo();
    initiativeRepo = makeInitiativeRepo();
    combatPublisher = makeCombatPublisher();
    handler = new RollInitiativeHandler(
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
      handler.execute(new RollInitiativeCommand('enc-missing', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterNotFoundError);
  });

  it('throws EncounterNotFoundError when session not found (getOwnerId returns null)', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(access.getOwnerId).mockResolvedValue(null);

    await expect(
      handler.execute(new RollInitiativeCommand('enc-1', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterNotFoundError);
  });

  it('throws EncounterAccessDeniedError when caller is not owner', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(access.getOwnerId).mockResolvedValue('owner-1');

    await expect(
      handler.execute(new RollInitiativeCommand('enc-1', 'other-user')),
    ).rejects.toBeInstanceOf(EncounterAccessDeniedError);
  });

  it('throws EncounterInvalidTransitionError when status is active', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'active' }));

    await expect(
      handler.execute(new RollInitiativeCommand('enc-1', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterInvalidTransitionError);
  });

  it('throws EncounterInvalidTransitionError when status is ended', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'ended' }));

    await expect(
      handler.execute(new RollInitiativeCommand('enc-1', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterInvalidTransitionError);
  });

  it('throws EncounterNoCombatantsError when encounter has no combatants', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeEncounter({ status: 'setup' }));
    vi.mocked(combatantRepo.listByEncounterWithSnapshot).mockResolvedValue([]);

    await expect(
      handler.execute(new RollInitiativeCommand('enc-1', 'user-1')),
    ).rejects.toBeInstanceOf(EncounterNoCombatantsError);
  });

  it('assigns turnOrder 0..N-1 and sets activeCombatantId to first', async () => {
    mockRandomInt.mockReturnValue(5);

    vi.mocked(repo.findById).mockResolvedValueOnce(makeEncounter()); // initial load (setup)
    const combatants = [makeCombatantWithSnapshot('cb-1'), makeCombatantWithSnapshot('cb-2')];
    vi.mocked(combatantRepo.listByEncounterWithSnapshot).mockResolvedValue(combatants);
    const rollResult = makeRollResult(['cb-1', 'cb-2']);
    vi.mocked(initiativeRepo.rollInitiative).mockResolvedValue(rollResult);
    vi.mocked(repo.findById).mockResolvedValueOnce(makeEncounter({ status: 'active', round: 1 })); // post-commit re-fetch

    await handler.execute(new RollInitiativeCommand('enc-1', 'user-1'));

    expect(initiativeRepo.rollInitiative).toHaveBeenCalledWith(
      expect.objectContaining({
        encounterId: 'enc-1',
        combatantPatches: expect.arrayContaining([
          expect.objectContaining({ turnOrder: 0 }),
          expect.objectContaining({ turnOrder: 1 }),
        ]),
      }),
    );
  });

  it('sets encounter to active with round=1', async () => {
    mockRandomInt.mockReturnValue(7);

    vi.mocked(repo.findById).mockResolvedValueOnce(makeEncounter()); // initial load
    vi.mocked(combatantRepo.listByEncounterWithSnapshot).mockResolvedValue([
      makeCombatantWithSnapshot('cb-1'),
    ]);
    const rollResult = makeRollResult(['cb-1']);
    vi.mocked(initiativeRepo.rollInitiative).mockResolvedValue(rollResult);
    vi.mocked(repo.findById).mockResolvedValueOnce(makeEncounter({ status: 'active', round: 1 })); // post-commit re-fetch

    const result = await handler.execute(new RollInitiativeCommand('enc-1', 'user-1'));

    expect(result.round).toBe(1);
    expect(initiativeRepo.rollInitiative).toHaveBeenCalledWith(
      expect.objectContaining({ activeCombatantId: 'cb-1' }),
    );
  });

  it('rerolls d6 to break a tie before assigning turnOrder (ST3001 ГЛАВА 5)', async () => {
    // Initial roll: both combatants get 4 → tied. Reroll pass: cb-a → 6, cb-b → 2.
    mockRandomInt
      .mockReturnValueOnce(4) // cb-a initial
      .mockReturnValueOnce(4) // cb-b initial
      .mockReturnValueOnce(6) // cb-a reroll
      .mockReturnValueOnce(2); // cb-b reroll

    vi.mocked(repo.findById).mockResolvedValueOnce(makeEncounter()); // initial load
    const combatants = [makeCombatantWithSnapshot('cb-a'), makeCombatantWithSnapshot('cb-b')];
    vi.mocked(combatantRepo.listByEncounterWithSnapshot).mockResolvedValue(combatants);
    vi.mocked(initiativeRepo.rollInitiative).mockResolvedValue(makeRollResult(['cb-a', 'cb-b']));
    vi.mocked(repo.findById).mockResolvedValueOnce(makeEncounter({ status: 'active', round: 1 })); // post-commit re-fetch

    await handler.execute(new RollInitiativeCommand('enc-1', 'user-1'));

    const calls = vi.mocked(initiativeRepo.rollInitiative).mock.calls;
    const callData = calls[0]?.[0] as RollInitiativeData;
    const cbAPatch = callData.combatantPatches.find((p) => p.id === 'cb-a');
    const cbBPatch = callData.combatantPatches.find((p) => p.id === 'cb-b');
    // cb-a re-rolled to 6, cb-b to 2 → cb-a goes first.
    expect(cbAPatch?.initiative).toBe(6);
    expect(cbBPatch?.initiative).toBe(2);
    expect(cbAPatch?.turnOrder).toBe(0);
    expect(cbBPatch?.turnOrder).toBe(1);
  });

  it('rolls a d6 (1..6 inclusive) per ST3001 ГЛАВА 5', async () => {
    mockRandomInt.mockReturnValue(3);

    vi.mocked(repo.findById).mockResolvedValueOnce(makeEncounter()); // initial load
    vi.mocked(combatantRepo.listByEncounterWithSnapshot).mockResolvedValue([
      makeCombatantWithSnapshot('cb-1'),
    ]);
    vi.mocked(initiativeRepo.rollInitiative).mockResolvedValue(makeRollResult(['cb-1']));
    vi.mocked(repo.findById).mockResolvedValueOnce(makeEncounter({ status: 'active', round: 1 })); // post-commit re-fetch

    await handler.execute(new RollInitiativeCommand('enc-1', 'user-1'));

    const calls = vi.mocked(initiativeRepo.rollInitiative).mock.calls;
    const callData = calls[0]?.[0] as RollInitiativeData;
    expect(callData.combatantPatches[0]?.initiative).toBeGreaterThanOrEqual(1);
    expect(callData.combatantPatches[0]?.initiative).toBeLessThanOrEqual(6);
  });

  it('calls combatPublisher.publishUpdated after successful roll', async () => {
    vi.mocked(repo.findById).mockResolvedValueOnce(makeEncounter()); // initial load
    vi.mocked(combatantRepo.listByEncounterWithSnapshot).mockResolvedValue([
      makeCombatantWithSnapshot('cb-1'),
    ]);
    const rollResult = makeRollResult(['cb-1']);
    vi.mocked(initiativeRepo.rollInitiative).mockResolvedValue(rollResult);
    const activeEncounter = makeEncounter({ status: 'active', round: 1 });
    vi.mocked(repo.findById).mockResolvedValueOnce(activeEncounter); // post-commit re-fetch

    await handler.execute(new RollInitiativeCommand('enc-1', 'user-1'));

    expect(combatPublisher.publishUpdated).toHaveBeenCalledWith(
      'gs-1',
      activeEncounter,
      rollResult.combatants,
    );
  });

  it('publish failure does not break the flow — returns roll result normally', async () => {
    vi.mocked(repo.findById).mockResolvedValueOnce(makeEncounter()); // initial load
    vi.mocked(combatantRepo.listByEncounterWithSnapshot).mockResolvedValue([
      makeCombatantWithSnapshot('cb-1'),
    ]);
    const rollResult = makeRollResult(['cb-1']);
    vi.mocked(initiativeRepo.rollInitiative).mockResolvedValue(rollResult);
    vi.mocked(repo.findById).mockResolvedValueOnce(makeEncounter({ status: 'active', round: 1 })); // post-commit re-fetch
    vi.mocked(combatPublisher.publishUpdated).mockRejectedValueOnce(new Error('Centrifugo down'));

    const result = await handler.execute(new RollInitiativeCommand('enc-1', 'user-1'));

    expect(result).toEqual(rollResult);
  });
});

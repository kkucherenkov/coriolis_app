/**
 * Unit tests for AddCombatantHandler.
 * All I/O is mocked — no Prisma, no NestJS bootstrap.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  EncounterAccessDeniedError,
  EncounterNotFoundError,
} from '../../encounters/domain/encounter.errors';
import {
  CombatantDuplicateError,
  CombatantSourceNotFoundError,
  CombatantSourceNotOwnedError,
  EncounterLockedForCombatError,
} from '../domain/combatant.errors';

import { AddCombatantCommand, AddCombatantDto } from './add-combatant.command';
import { AddCombatantHandler } from './add-combatant.handler';

import type { IGameSessionAccess } from '../../encounters/domain/game-session-access.ports';
import type { EncounterReadModel, IEncounterRepo } from '../../encounters/domain/encounter.ports';
import type { ICombatantRepo, CombatantReadModel } from '../domain/combatant.ports';
import type { ISourceLookup, SourceCharacter, SourceNpc } from '../domain/source-lookup.ports';

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

function makeSourceLookup(): ISourceLookup {
  return {
    findCharacterById: vi.fn(),
    findNpcById: vi.fn(),
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

function makeCharacter(overrides: Partial<SourceCharacter> = {}): SourceCharacter {
  return {
    id: 'char-1',
    ownerId: 'user-1',
    name: 'Zara al-Khatib',
    hpCurrent: 4,
    hpMax: 4,
    armor: 2,
    signature: 0,
    attributes: { strength: 2, agility: 2, wits: 2, empathy: 2 },
    skills: { dexterity: 1, force: 0, rangedCombat: 1 },
    ...overrides,
  };
}

function makeNpc(overrides: Partial<SourceNpc> = {}): SourceNpc {
  return {
    id: 'npc-1',
    ownerId: 'user-1',
    name: 'Khorredian Guard',
    hpCurrent: 6,
    hpMax: 6,
    armor: 3,
    signature: 2,
    attributes: { strength: 3, agility: 2, wits: 2, empathy: 1 },
    skills: { rangedCombat: 2, meleeCombat: 1 },
    ...overrides,
  };
}

function makeCombatant(overrides: Partial<CombatantReadModel> = {}): CombatantReadModel {
  return {
    id: 'comb-1',
    encounterId: 'enc-1',
    combatantType: 'pc',
    sourceId: 'char-1',
    displayName: 'Zara al-Khatib',
    initiative: null,
    turnOrder: null,
    hpCurrent: 4,
    hpMax: 4,
    armor: 2,
    signature: 0,
    statusFlags: [],
    notes: null,
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
    ...overrides,
  };
}

function makeDto(overrides: Partial<AddCombatantDto> = {}): AddCombatantDto {
  return Object.assign(new AddCombatantDto(), {
    combatantType: 'pc',
    sourceId: 'char-1',
    ...overrides,
  });
}

// --------------- Tests ---------------

describe('AddCombatantHandler', () => {
  let encounterRepo: IEncounterRepo;
  let access: IGameSessionAccess;
  let combatantRepo: ICombatantRepo;
  let sourceLookup: ISourceLookup;
  let handler: AddCombatantHandler;

  beforeEach(() => {
    encounterRepo = makeEncounterRepo();
    access = makeAccess();
    combatantRepo = makeCombatantRepo();
    sourceLookup = makeSourceLookup();
    handler = new AddCombatantHandler(encounterRepo, access, combatantRepo, sourceLookup);

    vi.mocked(access.getOwnerId).mockResolvedValue('user-1');
  });

  it('throws EncounterNotFoundError when encounter does not exist', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new AddCombatantCommand('enc-missing', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(EncounterNotFoundError);
  });

  it('throws EncounterNotFoundError when game session no longer has owner', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(access.getOwnerId).mockResolvedValue(null);

    await expect(
      handler.execute(new AddCombatantCommand('enc-1', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(EncounterNotFoundError);
  });

  it('throws EncounterAccessDeniedError when caller is not GM owner', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(access.getOwnerId).mockResolvedValue('other-user');

    await expect(
      handler.execute(new AddCombatantCommand('enc-1', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(EncounterAccessDeniedError);
  });

  it('throws EncounterLockedForCombatError when encounter is active', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter({ status: 'active' }));

    await expect(
      handler.execute(new AddCombatantCommand('enc-1', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(EncounterLockedForCombatError);
    expect(combatantRepo.create).not.toHaveBeenCalled();
  });

  it('throws EncounterLockedForCombatError when encounter is ended', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter({ status: 'ended' }));

    await expect(
      handler.execute(new AddCombatantCommand('enc-1', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(EncounterLockedForCombatError);
    expect(combatantRepo.create).not.toHaveBeenCalled();
  });

  it('ENCOUNTER_LOCKED_FOR_COMBAT has status 422', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter({ status: 'active' }));

    await expect(
      handler.execute(new AddCombatantCommand('enc-1', 'user-1', makeDto())),
    ).rejects.toMatchObject({ code: 'ENCOUNTER_LOCKED_FOR_COMBAT', status: 422 });
  });

  it('throws CombatantSourceNotFoundError when character does not exist', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(sourceLookup.findCharacterById).mockResolvedValue(null);

    await expect(
      handler.execute(
        new AddCombatantCommand(
          'enc-1',
          'user-1',
          makeDto({ combatantType: 'pc', sourceId: 'char-missing' }),
        ),
      ),
    ).rejects.toBeInstanceOf(CombatantSourceNotFoundError);
  });

  it('throws CombatantSourceNotFoundError when npc does not exist', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(sourceLookup.findNpcById).mockResolvedValue(null);

    await expect(
      handler.execute(
        new AddCombatantCommand(
          'enc-1',
          'user-1',
          makeDto({ combatantType: 'npc', sourceId: 'npc-missing' }),
        ),
      ),
    ).rejects.toBeInstanceOf(CombatantSourceNotFoundError);
  });

  it('throws CombatantSourceNotOwnedError when character is owned by another user', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(sourceLookup.findCharacterById).mockResolvedValue(
      makeCharacter({ ownerId: 'other' }),
    );

    await expect(
      handler.execute(new AddCombatantCommand('enc-1', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(CombatantSourceNotOwnedError);
  });

  it('throws CombatantSourceNotOwnedError when npc is owned by another user', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(sourceLookup.findNpcById).mockResolvedValue(makeNpc({ ownerId: 'other' }));

    await expect(
      handler.execute(
        new AddCombatantCommand(
          'enc-1',
          'user-1',
          makeDto({ combatantType: 'npc', sourceId: 'npc-1' }),
        ),
      ),
    ).rejects.toBeInstanceOf(CombatantSourceNotOwnedError);
  });

  it('creates PC combatant with snapshot and copies name when displayName omitted', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(sourceLookup.findCharacterById).mockResolvedValue(makeCharacter());
    vi.mocked(combatantRepo.create).mockResolvedValue(makeCombatant());

    await handler.execute(new AddCombatantCommand('enc-1', 'user-1', makeDto()));

    expect(combatantRepo.create).toHaveBeenCalledWith(
      expect.objectContaining({
        combatantType: 'pc',
        characterId: 'char-1',
        displayName: 'Zara al-Khatib',
        hpCurrent: 4,
        hpMax: 4,
        armor: 2,
        signature: 0,
        pcSnapshot: expect.objectContaining({ hpMax: 4 }),
      }),
    );
  });

  it('uses custom displayName when provided', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(sourceLookup.findCharacterById).mockResolvedValue(makeCharacter());
    vi.mocked(combatantRepo.create).mockResolvedValue(
      makeCombatant({ displayName: 'The Chosen One' }),
    );

    await handler.execute(
      new AddCombatantCommand('enc-1', 'user-1', makeDto({ displayName: 'The Chosen One' })),
    );

    expect(combatantRepo.create).toHaveBeenCalledWith(
      expect.objectContaining({ displayName: 'The Chosen One' }),
    );
  });

  it('creates NPC combatant with snapshot', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(sourceLookup.findNpcById).mockResolvedValue(makeNpc());
    vi.mocked(combatantRepo.create).mockResolvedValue(
      makeCombatant({
        combatantType: 'npc',
        sourceId: 'npc-1',
        displayName: 'Khorredian Guard',
        hpMax: 6,
        armor: 3,
        signature: 2,
      }),
    );

    await handler.execute(
      new AddCombatantCommand(
        'enc-1',
        'user-1',
        makeDto({ combatantType: 'npc', sourceId: 'npc-1' }),
      ),
    );

    expect(combatantRepo.create).toHaveBeenCalledWith(
      expect.objectContaining({
        combatantType: 'npc',
        npcId: 'npc-1',
        displayName: 'Khorredian Guard',
        hpMax: 6,
        armor: 3,
        signature: 2,
        npcSnapshot: expect.objectContaining({ hpMax: 6, signature: 2 }),
      }),
    );
  });

  it('snapshot semantics: mutating character after add does not change combatant', async () => {
    // The snapshot is built at add-time from the source entity.
    // If the source is mutated later, the combatant retains its snapshot.
    const character = makeCharacter({ hpCurrent: 4, hpMax: 4 });
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(sourceLookup.findCharacterById).mockResolvedValue(character);

    let capturedData: Parameters<ICombatantRepo['create']>[0] | undefined;
    vi.mocked(combatantRepo.create).mockImplementation(async (data) => {
      capturedData = data;
      return makeCombatant();
    });

    await handler.execute(new AddCombatantCommand('enc-1', 'user-1', makeDto()));

    // Simulate post-add character mutation
    character.hpCurrent = 0;
    character.hpMax = 8;

    // The captured snapshot should still have the original hpMax
    expect(capturedData?.pcSnapshot?.hpMax).toBe(4);
    expect(capturedData?.hpMax).toBe(4);
  });

  it('propagates CombatantDuplicateError from repo (same character added twice)', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(sourceLookup.findCharacterById).mockResolvedValue(makeCharacter());
    vi.mocked(combatantRepo.create).mockRejectedValue(new CombatantDuplicateError('pc', 'char-1'));

    await expect(
      handler.execute(new AddCombatantCommand('enc-1', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(CombatantDuplicateError);
  });

  it('COMBATANT_DUPLICATE has status 422', async () => {
    vi.mocked(encounterRepo.findById).mockResolvedValue(makeEncounter());
    vi.mocked(sourceLookup.findCharacterById).mockResolvedValue(makeCharacter());
    vi.mocked(combatantRepo.create).mockRejectedValue(new CombatantDuplicateError('pc', 'char-1'));

    await expect(
      handler.execute(new AddCombatantCommand('enc-1', 'user-1', makeDto())),
    ).rejects.toMatchObject({ code: 'COMBATANT_DUPLICATE', status: 422 });
  });
});

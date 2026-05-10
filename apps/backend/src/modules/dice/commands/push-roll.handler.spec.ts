import { describe, it, expect, vi, beforeEach } from 'vitest';

import {
  CharacterNotFoundError,
  CharacterNotOwnedError,
} from '../../characters/domain/character.errors';
import { RollNotFoundError, RollNotPushableError } from '../domain/roll.errors';

import { PushRollCommand } from './push-roll.command';
import { PushRollHandler } from './push-roll.handler';

import type { ICharacterRepo, CharacterReadModel } from '../../characters/domain/character.ports';
import type { IRollRepo, RollReadModel } from '../domain/roll.ports';

const BASE_CONDITIONS = { exhausted: false, sleepless: false, thirsty: false, hungry: false };

const MOCK_CHARACTER: CharacterReadModel = {
  id: 'char_01',
  ownerId: 'user_01',
  name: 'Tariq',
  concept: null,
  iconId: null,
  upbringing: 'plebeian',
  origin: null,
  reputation: 2,
  startingWealth: 500,
  crewConcept: null,
  mutant: false,
  mutantLineage: null,
  attributes: { strength: 3, agility: 3, wits: 3, empathy: 3 },
  skills: {
    dexterity: 0,
    force: 0,
    infiltration: 0,
    manipulation: 0,
    meleeCombat: 0,
    observation: 0,
    rangedCombat: 0,
    survival: 0,
    command: 0,
    culture: 0,
    dataDjinn: 0,
    medicurgy: 0,
    mysticPowers: 0,
    pilot: 3,
    science: 0,
    technology: 0,
  },
  hp: { current: 6, max: 6 },
  mp: { current: 6, max: 6 },
  encumbrance: { current: 0, max: 6 },
  experience: 0,
  conditions: BASE_CONDITIONS,
  criticalInjuries: [],
  talents: [],
  relationships: [],
  inventory: [],
  notes: null,
  status: 'active',
  createdAt: '2026-05-09T10:00:00Z',
  updatedAt: '2026-05-09T10:00:00Z',
};

const MOCK_ROLL_FRESH: RollReadModel = {
  id: 'roll_01',
  characterId: 'char_01',
  gameSessionId: null,
  label: 'Pilot · Evade',
  pool: 4,
  dice: [1, 3, 6, 2],
  hits: 1,
  pushed: false,
  createdAt: '2026-05-09T12:00:00Z',
};

const MOCK_ROLL_PUSHED: RollReadModel = {
  ...MOCK_ROLL_FRESH,
  dice: [4, 6, 6, 5],
  hits: 2,
  pushed: true,
};

function makeHandler(): {
  handler: PushRollHandler;
  characterRepo: ICharacterRepo;
  rollRepo: IRollRepo;
  eventBus: { publish: ReturnType<typeof vi.fn> };
} {
  const characterRepo = {
    findOwnerIdById: vi.fn(),
    findActiveById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    deleteAbandonedDrafts: vi.fn(),
    delete: vi.fn(),
  } as unknown as ICharacterRepo;

  const rollRepo = {
    create: vi.fn(),
    findById: vi.fn(),
    push: vi.fn(),
    listByCharacterId: vi.fn(),
  } as unknown as IRollRepo;

  const eventBus = { publish: vi.fn() };

  const handler = new PushRollHandler(characterRepo, rollRepo, eventBus as never);
  return { handler, characterRepo, rollRepo, eventBus };
}

describe('PushRollHandler', () => {
  let handler: PushRollHandler;
  let characterRepo: ICharacterRepo;
  let rollRepo: IRollRepo;
  let eventBus: { publish: ReturnType<typeof vi.fn> };

  beforeEach(() => {
    ({ handler, characterRepo, rollRepo, eventBus } = makeHandler());
  });

  it('pushes a fresh roll: rerolls non-6 dice and sets pushed=true', async () => {
    vi.mocked(rollRepo.findById).mockResolvedValue(MOCK_ROLL_FRESH);
    vi.mocked(characterRepo.findActiveById).mockResolvedValue(MOCK_CHARACTER);
    vi.mocked(rollRepo.push).mockResolvedValue(MOCK_ROLL_PUSHED);

    const result = await handler.execute(new PushRollCommand('user_01', 'roll_01'));

    expect(result.pushed).toBe(true);
    const pushCall = vi.mocked(rollRepo.push).mock.calls[0];
    // The 6 at index 2 must be preserved
    expect(pushCall?.[1][2]).toBe(6);
    // Other dice may change (randomly) but array length stays the same
    expect(pushCall?.[1]).toHaveLength(4);
  });

  it('emits RollPushedEvent after push with correct payload', async () => {
    vi.mocked(rollRepo.findById).mockResolvedValue(MOCK_ROLL_FRESH);
    vi.mocked(characterRepo.findActiveById).mockResolvedValue(MOCK_CHARACTER);
    vi.mocked(rollRepo.push).mockResolvedValue(MOCK_ROLL_PUSHED);

    await handler.execute(new PushRollCommand('user_01', 'roll_01'));

    expect(eventBus.publish).toHaveBeenCalledOnce();
    const evt = eventBus.publish.mock.calls[0]?.[0] as { rollId: string; characterId: string };
    expect(evt.rollId).toBe('roll_01');
    expect(evt.characterId).toBe('char_01');
  });

  it('throws RollNotFoundError when the roll does not exist', async () => {
    vi.mocked(rollRepo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new PushRollCommand('user_01', 'roll_missing')),
    ).rejects.toBeInstanceOf(RollNotFoundError);
  });

  it('throws CharacterNotFoundError when owning character does not exist', async () => {
    vi.mocked(rollRepo.findById).mockResolvedValue(MOCK_ROLL_FRESH);
    vi.mocked(characterRepo.findActiveById).mockResolvedValue(null);

    await expect(handler.execute(new PushRollCommand('user_01', 'roll_01'))).rejects.toBeInstanceOf(
      CharacterNotFoundError,
    );
  });

  it('throws CharacterNotOwnedError when caller does not own the character', async () => {
    vi.mocked(rollRepo.findById).mockResolvedValue(MOCK_ROLL_FRESH);
    vi.mocked(characterRepo.findActiveById).mockResolvedValue({
      ...MOCK_CHARACTER,
      ownerId: 'user_other',
    });

    await expect(handler.execute(new PushRollCommand('user_01', 'roll_01'))).rejects.toBeInstanceOf(
      CharacterNotOwnedError,
    );
  });

  it('throws RollNotPushableError (ALREADY_PUSHED) when roll has already been pushed', async () => {
    vi.mocked(rollRepo.findById).mockResolvedValue({ ...MOCK_ROLL_FRESH, pushed: true });
    vi.mocked(characterRepo.findActiveById).mockResolvedValue(MOCK_CHARACTER);

    const err = await handler
      .execute(new PushRollCommand('user_01', 'roll_01'))
      .catch((error: unknown) => error);

    expect(err).toBeInstanceOf(RollNotPushableError);
    expect((err as RollNotPushableError).code).toBe('ROLL_NOT_PUSHABLE');
  });

  it('throws RollNotPushableError (EXHAUSTED) when character is exhausted', async () => {
    vi.mocked(rollRepo.findById).mockResolvedValue(MOCK_ROLL_FRESH);
    vi.mocked(characterRepo.findActiveById).mockResolvedValue({
      ...MOCK_CHARACTER,
      conditions: { ...BASE_CONDITIONS, exhausted: true },
    });

    const err = await handler
      .execute(new PushRollCommand('user_01', 'roll_01'))
      .catch((error: unknown) => error);

    expect(err).toBeInstanceOf(RollNotPushableError);
    expect((err as RollNotPushableError).code).toBe('ROLL_NOT_PUSHABLE');
  });

  // -------------------------------------------------------------------------
  // T-2026-05-10-010 Block C: pushing a Ноль кубиков roll keeps the
  // double-six success rule (ГЛАВА 3 line 161). The push rerolls the non-6
  // die; hits stays 0 unless both post-push dice are 6.
  // -------------------------------------------------------------------------

  it('pushes a zero-pool roll and applies the Ноль кубиков success rule', async () => {
    const ZERO_POOL_FRESH: RollReadModel = {
      ...MOCK_ROLL_FRESH,
      pool: 0,
      dice: [6, 1],
      hits: 0,
    };
    vi.mocked(rollRepo.findById).mockResolvedValue(ZERO_POOL_FRESH);
    vi.mocked(characterRepo.findActiveById).mockResolvedValue(MOCK_CHARACTER);
    vi.mocked(rollRepo.push).mockImplementation(async (_id, dice, hits) => ({
      ...ZERO_POOL_FRESH,
      dice,
      hits,
      pushed: true,
    }));

    const result = await handler.execute(new PushRollCommand('user_01', 'roll_01'));

    expect(result.pool).toBe(0);
    expect(result.dice).toHaveLength(2);
    // The first die was a 6 and is preserved by `pushDice`.
    expect(result.dice[0]).toBe(6);
    // Hits = 1 only if the rerolled second die is also a 6.
    const expectedHits = result.dice[1] === 6 ? 1 : 0;
    expect(result.hits).toBe(expectedHits);
  });

  it('does not emit event when push is rejected', async () => {
    vi.mocked(rollRepo.findById).mockResolvedValue({ ...MOCK_ROLL_FRESH, pushed: true });
    vi.mocked(characterRepo.findActiveById).mockResolvedValue(MOCK_CHARACTER);

    await expect(handler.execute(new PushRollCommand('user_01', 'roll_01'))).rejects.toBeInstanceOf(
      RollNotPushableError,
    );

    expect(eventBus.publish).not.toHaveBeenCalled();
  });
});

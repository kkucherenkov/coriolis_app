import { describe, it, expect, vi, beforeEach } from 'vitest';

import {
  CharacterNotFoundError,
  CharacterNotOwnedError,
} from '../../characters/domain/character.errors';

import { CreateRollCommand, CreateRollDto } from './create-roll.command';
import { CreateRollHandler } from './create-roll.handler';

import type { ICharacterRepo } from '../../characters/domain/character.ports';
import type { IRollRepo, RollReadModel } from '../domain/roll.ports';

const MOCK_ROLL: RollReadModel = {
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

function makeHandler(): {
  handler: CreateRollHandler;
  characterRepo: ICharacterRepo;
  rollRepo: IRollRepo;
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

  const handler = new CreateRollHandler(characterRepo, rollRepo);
  return { handler, characterRepo, rollRepo };
}

describe('CreateRollHandler', () => {
  let handler: CreateRollHandler;
  let characterRepo: ICharacterRepo;
  let rollRepo: IRollRepo;

  beforeEach(() => {
    ({ handler, characterRepo, rollRepo } = makeHandler());
  });

  it('creates a roll with correct pool size and returns it', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(rollRepo.create).mockResolvedValue(MOCK_ROLL);

    const dto = new CreateRollDto();
    dto.label = 'Pilot · Evade';
    dto.pool = 4;

    const result = await handler.execute(new CreateRollCommand('user_01', 'char_01', dto));

    expect(result).toEqual(MOCK_ROLL);
    const call = vi.mocked(rollRepo.create).mock.calls[0]?.[0];
    // Server rolled 4 dice
    expect(call?.dice).toHaveLength(4);
    expect(call?.pool).toBe(4);
    expect(call?.characterId).toBe('char_01');
    expect(call?.label).toBe('Pilot · Evade');
  });

  it('stores hits = count of 6s in the rolled dice', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(rollRepo.create).mockImplementation(async (data) => ({
      ...MOCK_ROLL,
      dice: data.dice,
      hits: data.hits,
    }));

    const dto = new CreateRollDto();
    dto.label = 'Force · Grapple';
    dto.pool = 1;

    // Run many times to confirm hits = count(6)
    for (let trial = 0; trial < 20; trial++) {
      const r = await handler.execute(new CreateRollCommand('user_01', 'char_01', dto));
      const sixes = r.dice.filter((d) => d === 6).length;
      expect(r.hits).toBe(sixes);
    }
  });

  it('passes gameSessionId through when provided', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(rollRepo.create).mockResolvedValue({ ...MOCK_ROLL, gameSessionId: 'sess_01' });

    const dto = new CreateRollDto();
    dto.label = 'test';
    dto.pool = 2;
    dto.gameSessionId = 'sess_01';

    await handler.execute(new CreateRollCommand('user_01', 'char_01', dto));

    expect(rollRepo.create).toHaveBeenCalledWith(
      expect.objectContaining({ gameSessionId: 'sess_01' }),
    );
  });

  it('uses gameSessionId=null when not provided', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(rollRepo.create).mockResolvedValue(MOCK_ROLL);

    const dto = new CreateRollDto();
    dto.label = 'test';
    dto.pool = 2;

    await handler.execute(new CreateRollCommand('user_01', 'char_01', dto));

    expect(rollRepo.create).toHaveBeenCalledWith(expect.objectContaining({ gameSessionId: null }));
  });

  it('throws CharacterNotFoundError when character does not exist', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue(null);

    const dto = new CreateRollDto();
    dto.label = 'test';
    dto.pool = 2;

    await expect(
      handler.execute(new CreateRollCommand('user_01', 'char_missing', dto)),
    ).rejects.toBeInstanceOf(CharacterNotFoundError);
  });

  it('throws CharacterNotOwnedError when caller does not own the character', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_other' });

    const dto = new CreateRollDto();
    dto.label = 'test';
    dto.pool = 2;

    await expect(
      handler.execute(new CreateRollCommand('user_01', 'char_01', dto)),
    ).rejects.toBeInstanceOf(CharacterNotOwnedError);
  });
});

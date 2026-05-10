import { describe, it, expect, vi, beforeEach } from 'vitest';

import {
  CharacterNotFoundError,
  CharacterNotOwnedError,
} from '../../characters/domain/character.errors';
import { RollBreakdownMismatchError, RollPoolOutOfRangeError } from '../domain/roll.errors';

import { CreateRollCommand, CreateRollDto, RollBreakdownDto } from './create-roll.command';
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
  kind: 'skill',
  breakdown: null,
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

  // -------------------------------------------------------------------------
  // T-2026-05-10-010 Block C: pool 0..20 + Ноль кубиков (ГЛАВА 3 line 161)
  // -------------------------------------------------------------------------

  it('rolls 2 dice when pool === 0 (Ноль кубиков) and stores them on the row', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(rollRepo.create).mockImplementation(async (data) => ({
      ...MOCK_ROLL,
      pool: data.pool,
      dice: data.dice,
      hits: data.hits,
    }));

    const dto = new CreateRollDto();
    dto.label = 'Pilot · forced landing';
    dto.pool = 0;

    const result = await handler.execute(new CreateRollCommand('user_01', 'char_01', dto));

    expect(result.pool).toBe(0);
    expect(result.dice).toHaveLength(2);
    // Hits is 1 only when both dice are 6, otherwise 0 — never the raw 6-count.
    expect([0, 1]).toContain(result.hits);
    if (result.hits === 1) {
      expect(result.dice).toEqual([6, 6]);
    }
  });

  it('counts a Ноль кубиков success only on a double six', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(rollRepo.create).mockImplementation(async (data) => ({
      ...MOCK_ROLL,
      pool: data.pool,
      dice: data.dice,
      hits: data.hits,
    }));

    const dto = new CreateRollDto();
    dto.label = 'zero-dice trial';
    dto.pool = 0;

    // Run a batch and verify the hits/dice invariant on every outcome.
    for (let trial = 0; trial < 50; trial++) {
      const r = await handler.execute(new CreateRollCommand('user_01', 'char_01', dto));
      const bothSixes = r.dice.length === 2 && r.dice.every((d) => d === 6);
      expect(r.hits).toBe(bothSixes ? 1 : 0);
    }
  });

  it('accepts a 20-die pool at the upper bound', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(rollRepo.create).mockImplementation(async (data) => ({
      ...MOCK_ROLL,
      pool: data.pool,
      dice: data.dice,
      hits: data.hits,
    }));

    const dto = new CreateRollDto();
    dto.label = 'max stack';
    dto.pool = 20;

    const result = await handler.execute(new CreateRollCommand('user_01', 'char_01', dto));

    expect(result.pool).toBe(20);
    expect(result.dice).toHaveLength(20);
  });

  it('rejects pool === 21 (one above the upper bound)', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });

    const dto = new CreateRollDto();
    dto.label = 'too many dice';
    dto.pool = 21;

    await expect(
      handler.execute(new CreateRollCommand('user_01', 'char_01', dto)),
    ).rejects.toBeInstanceOf(RollPoolOutOfRangeError);
  });

  it('rejects negative pool (below the new lower bound of 0)', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });

    const dto = new CreateRollDto();
    dto.label = 'negative pool';
    dto.pool = -1;

    await expect(
      handler.execute(new CreateRollCommand('user_01', 'char_01', dto)),
    ).rejects.toBeInstanceOf(RollPoolOutOfRangeError);
  });

  // -------------------------------------------------------------------------
  // T-2026-05-10-015: RollKind — kind field on create
  // -------------------------------------------------------------------------

  it('defaults kind to skill when not provided (back-compat)', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(rollRepo.create).mockResolvedValue(MOCK_ROLL);

    const dto = new CreateRollDto();
    dto.label = 'skill-default';
    dto.pool = 2;
    // kind not set

    await handler.execute(new CreateRollCommand('user_01', 'char_01', dto));

    expect(rollRepo.create).toHaveBeenCalledWith(expect.objectContaining({ kind: 'skill' }));
  });

  it('persists explicit kind=save when provided', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(rollRepo.create).mockResolvedValue({ ...MOCK_ROLL, kind: 'save' });

    const dto = new CreateRollDto();
    dto.label = 'save roll';
    dto.pool = 3;
    dto.kind = 'save';

    await handler.execute(new CreateRollCommand('user_01', 'char_01', dto));

    expect(rollRepo.create).toHaveBeenCalledWith(expect.objectContaining({ kind: 'save' }));
  });

  // -------------------------------------------------------------------------
  // T-2026-05-10-016: RollBreakdown — persist breakdown + sum-equality guard
  // -------------------------------------------------------------------------

  it('stores breakdown=null when breakdown is not supplied', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(rollRepo.create).mockResolvedValue(MOCK_ROLL);

    const dto = new CreateRollDto();
    dto.label = 'no breakdown';
    dto.pool = 3;
    // breakdown intentionally not set

    await handler.execute(new CreateRollCommand('user_01', 'char_01', dto));

    expect(rollRepo.create).toHaveBeenCalledWith(expect.objectContaining({ breakdown: null }));
  });

  it('stores the breakdown object when breakdown matches pool', async () => {
    const breakdown = new RollBreakdownDto();
    breakdown.attribute = 2;
    breakdown.skill = 1;
    breakdown.gear = 1;
    breakdown.modifier = 0;
    breakdown.helpers = 0;

    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(rollRepo.create).mockResolvedValue({
      ...MOCK_ROLL,
      pool: 4,
      breakdown: { attribute: 2, skill: 1, gear: 1, modifier: 0, helpers: 0 },
    });

    const dto = new CreateRollDto();
    dto.label = 'with breakdown';
    dto.pool = 4;
    dto.breakdown = breakdown;

    await handler.execute(new CreateRollCommand('user_01', 'char_01', dto));

    expect(rollRepo.create).toHaveBeenCalledWith(
      expect.objectContaining({ breakdown: { attribute: 2, skill: 1, gear: 1, modifier: 0, helpers: 0 } }),
    );
  });

  it('throws RollBreakdownMismatchError when breakdown sum ≠ pool', async () => {
    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });

    const breakdown = new RollBreakdownDto();
    breakdown.attribute = 2;
    breakdown.skill = 2;
    breakdown.gear = 0;
    breakdown.modifier = 0;
    breakdown.helpers = 0;
    // sum = 4, pool = 5 → mismatch

    const dto = new CreateRollDto();
    dto.label = 'mismatch';
    dto.pool = 5;
    dto.breakdown = breakdown;

    const err = await handler
      .execute(new CreateRollCommand('user_01', 'char_01', dto))
      .catch((error: unknown) => error);

    expect(err).toBeInstanceOf(RollBreakdownMismatchError);
    const domainErr = err as RollBreakdownMismatchError;
    expect(domainErr.status).toBe(400);
    expect(domainErr.code).toBe('ROLL_BREAKDOWN_MISMATCH');
  });

  it('accepts breakdown sum=0 with pool=0 (zero-dice boundary from T-010 Block C)', async () => {
    const breakdown = new RollBreakdownDto();
    breakdown.attribute = 0;
    breakdown.skill = 0;
    breakdown.gear = 0;
    breakdown.modifier = 0;
    breakdown.helpers = 0;

    vi.mocked(characterRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(rollRepo.create).mockResolvedValue({
      ...MOCK_ROLL,
      pool: 0,
      dice: [3, 5],
      hits: 0,
      breakdown: { attribute: 0, skill: 0, gear: 0, modifier: 0, helpers: 0 },
    });

    const dto = new CreateRollDto();
    dto.label = 'zero-dice with breakdown';
    dto.pool = 0;
    dto.breakdown = breakdown;

    // Must not throw
    const result = await handler.execute(new CreateRollCommand('user_01', 'char_01', dto));

    expect(result.pool).toBe(0);
    expect(rollRepo.create).toHaveBeenCalledWith(
      expect.objectContaining({ breakdown: { attribute: 0, skill: 0, gear: 0, modifier: 0, helpers: 0 } }),
    );
  });
});

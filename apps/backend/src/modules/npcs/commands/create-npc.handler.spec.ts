/**
 * Unit tests for CreateNpcHandler.
 * Repo is a vi.fn() mock — no NestJS or Prisma bootstrapping.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { NpcNameEmptyError, NpcNameTooLongError } from '../domain/npc.errors';

import { CreateNpcCommand, CreateNpcDto } from './create-npc.command';
import { CreateNpcHandler } from './create-npc.handler';

import type { INpcRepo, NpcReadModel } from '../domain/npc.ports';

function makeRepo(): INpcRepo {
  return {
    findById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
    duplicate: vi.fn(),
    listNamesByPrefix: vi.fn(),
  };
}

function makeNpc(overrides: Partial<NpcReadModel> = {}): NpcReadModel {
  return {
    id: 'npc-1',
    ownerId: 'user-1',
    name: 'Pirate Captain',
    description: null,
    attributes: { strength: 2, agility: 2, wits: 2, empathy: 2 },
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
      pilot: 0,
      science: 0,
      technology: 0,
    },
    hp: { current: 4, max: 4 },
    mp: { current: 4, max: 4 },
    signature: 0,
    keySkillModifier: 0,
    armor: [],
    weapons: [],
    tags: [],
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
    ...overrides,
  };
}

function makeDto(overrides: Partial<CreateNpcDto> = {}): CreateNpcDto {
  return Object.assign(new CreateNpcDto(), {
    name: 'Pirate Captain',
    ...overrides,
  });
}

describe('CreateNpcHandler', () => {
  let repo: INpcRepo;
  let handler: CreateNpcHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new CreateNpcHandler(repo);
  });

  it('creates an NPC with default stats when no fields provided', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeNpc());

    await handler.execute(new CreateNpcCommand('user-1', makeDto()));

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({
        ownerId: 'user-1',
        name: 'Pirate Captain',
        hpCurrent: 4,
        hpMax: 4,
        mpCurrent: 4,
        mpMax: 4,
        signature: 0,
        keySkillModifier: 0,
        armor: [],
        weapons: [],
        tags: [],
      }),
    );
  });

  it('applies hp default {current: 4, max: 4} when omitted', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeNpc());

    await handler.execute(new CreateNpcCommand('user-1', makeDto()));

    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ hpCurrent: 4, hpMax: 4 }));
  });

  it('applies mp default {current: 4, max: 4} when omitted', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeNpc());

    await handler.execute(new CreateNpcCommand('user-1', makeDto()));

    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ mpCurrent: 4, mpMax: 4 }));
  });

  it('seeds hpCurrent from hpMax when current not provided', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeNpc({ hp: { current: 8, max: 8 } }));

    await handler.execute(new CreateNpcCommand('user-1', makeDto({ hp: { max: 8 } })));

    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ hpCurrent: 8, hpMax: 8 }));
  });

  it('seeds mpCurrent from mpMax when current not provided', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeNpc({ mp: { current: 6, max: 6 } }));

    await handler.execute(new CreateNpcCommand('user-1', makeDto({ mp: { max: 6 } })));

    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ mpCurrent: 6, mpMax: 6 }));
  });

  it('uses provided hp.current and hp.max', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeNpc({ hp: { current: 3, max: 10 } }));

    await handler.execute(new CreateNpcCommand('user-1', makeDto({ hp: { current: 3, max: 10 } })));

    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ hpCurrent: 3, hpMax: 10 }));
  });

  it('applies default attributes when not provided', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeNpc());

    await handler.execute(new CreateNpcCommand('user-1', makeDto()));

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({
        attributes: { strength: 2, agility: 2, wits: 2, empathy: 2 },
      }),
    );
  });

  it('merges partial attributes with defaults', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeNpc());

    await handler.execute(new CreateNpcCommand('user-1', makeDto({ attributes: { strength: 4 } })));

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({
        attributes: { strength: 4, agility: 2, wits: 2, empathy: 2 },
      }),
    );
  });

  it('applies default skills (all zero) when not provided', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeNpc());

    await handler.execute(new CreateNpcCommand('user-1', makeDto()));

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({
        skills: expect.objectContaining({ rangedCombat: 0, meleeCombat: 0 }),
      }),
    );
  });

  it('trims whitespace from name', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeNpc());

    await handler.execute(new CreateNpcCommand('user-1', makeDto({ name: '  Pirate  ' })));

    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ name: 'Pirate' }));
  });

  it('throws NpcNameEmptyError for empty name', async () => {
    await expect(
      handler.execute(new CreateNpcCommand('user-1', makeDto({ name: '' }))),
    ).rejects.toBeInstanceOf(NpcNameEmptyError);
    expect(repo.create).not.toHaveBeenCalled();
  });

  it('throws NpcNameEmptyError for whitespace-only name', async () => {
    await expect(
      handler.execute(new CreateNpcCommand('user-1', makeDto({ name: '   ' }))),
    ).rejects.toMatchObject({ code: 'NPC_NAME_EMPTY', status: 400 });
  });

  it('throws NpcNameTooLongError for name > 120 chars', async () => {
    await expect(
      handler.execute(new CreateNpcCommand('user-1', makeDto({ name: 'a'.repeat(121) }))),
    ).rejects.toBeInstanceOf(NpcNameTooLongError);
    expect(repo.create).not.toHaveBeenCalled();
  });

  it('accepts name of exactly 120 characters', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeNpc({ name: 'a'.repeat(120) }));

    await expect(
      handler.execute(new CreateNpcCommand('user-1', makeDto({ name: 'a'.repeat(120) }))),
    ).resolves.toBeDefined();
  });

  it('passes signature and keySkillModifier to repo', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeNpc({ signature: -2, keySkillModifier: 1 }));

    await handler.execute(
      new CreateNpcCommand('user-1', makeDto({ signature: -2, keySkillModifier: 1 })),
    );

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ signature: -2, keySkillModifier: 1 }),
    );
  });

  it('passes tags to repo', async () => {
    const tags = ['Pirate', 'Boss'];
    vi.mocked(repo.create).mockResolvedValue(makeNpc({ tags }));

    await handler.execute(new CreateNpcCommand('user-1', makeDto({ tags })));

    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ tags }));
  });

  it('defaults description to null when not provided', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeNpc());

    await handler.execute(new CreateNpcCommand('user-1', makeDto()));

    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ description: null }));
  });
});

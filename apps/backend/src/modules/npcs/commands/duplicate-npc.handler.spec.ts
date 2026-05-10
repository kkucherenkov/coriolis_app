/**
 * Unit tests for DuplicateNpcHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { NpcNotFoundError, NpcNotOwnerError } from '../domain/npc.errors';

import { DuplicateNpcCommand } from './duplicate-npc.command';
import { DuplicateNpcHandler } from './duplicate-npc.handler';

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

describe('DuplicateNpcHandler', () => {
  let repo: INpcRepo;
  let handler: DuplicateNpcHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new DuplicateNpcHandler(repo);
  });

  it('duplicates NPC with "(copy)" suffix when no copy exists', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc());
    vi.mocked(repo.listNamesByPrefix).mockResolvedValue([]);
    vi.mocked(repo.duplicate).mockResolvedValue(
      makeNpc({ id: 'npc-2', name: 'Pirate Captain (copy)' }),
    );

    const result = await handler.execute(new DuplicateNpcCommand('npc-1', 'user-1'));

    expect(repo.duplicate).toHaveBeenCalledWith('npc-1', 'user-1', 'Pirate Captain (copy)');
    expect(result.name).toBe('Pirate Captain (copy)');
  });

  it('uses "(copy 2)" suffix when "(copy)" is already taken', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc());
    vi.mocked(repo.listNamesByPrefix).mockResolvedValue(['Pirate Captain (copy)']);
    vi.mocked(repo.duplicate).mockResolvedValue(makeNpc({ name: 'Pirate Captain (copy 2)' }));

    await handler.execute(new DuplicateNpcCommand('npc-1', 'user-1'));

    expect(repo.duplicate).toHaveBeenCalledWith('npc-1', 'user-1', 'Pirate Captain (copy 2)');
  });

  it('uses "(copy 3)" when "(copy)" and "(copy 2)" are both taken', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc());
    vi.mocked(repo.listNamesByPrefix).mockResolvedValue([
      'Pirate Captain (copy)',
      'Pirate Captain (copy 2)',
    ]);
    vi.mocked(repo.duplicate).mockResolvedValue(makeNpc({ name: 'Pirate Captain (copy 3)' }));

    await handler.execute(new DuplicateNpcCommand('npc-1', 'user-1'));

    expect(repo.duplicate).toHaveBeenCalledWith('npc-1', 'user-1', 'Pirate Captain (copy 3)');
  });

  it('throws NpcNotFoundError when NPC does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new DuplicateNpcCommand('npc-x', 'user-1')),
    ).rejects.toBeInstanceOf(NpcNotFoundError);
    expect(repo.duplicate).not.toHaveBeenCalled();
  });

  it('throws NpcNotOwnerError when caller does not own NPC', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc({ ownerId: 'user-2' }));

    await expect(
      handler.execute(new DuplicateNpcCommand('npc-1', 'user-1')),
    ).rejects.toBeInstanceOf(NpcNotOwnerError);
    expect(repo.duplicate).not.toHaveBeenCalled();
  });

  it('throws NpcNotOwnerError with status 404', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc({ ownerId: 'user-2' }));

    await expect(handler.execute(new DuplicateNpcCommand('npc-1', 'user-1'))).rejects.toMatchObject(
      { status: 404 },
    );
  });

  it('passes the correct prefix to listNamesByPrefix', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc({ name: 'Boss' }));
    vi.mocked(repo.listNamesByPrefix).mockResolvedValue([]);
    vi.mocked(repo.duplicate).mockResolvedValue(makeNpc({ name: 'Boss (copy)' }));

    await handler.execute(new DuplicateNpcCommand('npc-1', 'user-1'));

    expect(repo.listNamesByPrefix).toHaveBeenCalledWith('user-1', 'Boss (copy');
  });
});

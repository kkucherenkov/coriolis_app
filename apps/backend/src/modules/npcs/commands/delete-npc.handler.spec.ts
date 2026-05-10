/**
 * Unit tests for DeleteNpcHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { NpcNotFoundError, NpcNotOwnerError } from '../domain/npc.errors';

import { DeleteNpcCommand } from './delete-npc.command';
import { DeleteNpcHandler } from './delete-npc.handler';

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

describe('DeleteNpcHandler', () => {
  let repo: INpcRepo;
  let handler: DeleteNpcHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new DeleteNpcHandler(repo);
  });

  it('deletes the NPC when caller is the owner', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc());
    vi.mocked(repo.delete).mockResolvedValue();

    await handler.execute(new DeleteNpcCommand('npc-1', 'user-1'));

    expect(repo.delete).toHaveBeenCalledWith('npc-1');
  });

  it('throws NpcNotFoundError when NPC does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(handler.execute(new DeleteNpcCommand('npc-x', 'user-1'))).rejects.toBeInstanceOf(
      NpcNotFoundError,
    );
    expect(repo.delete).not.toHaveBeenCalled();
  });

  it('throws NpcNotOwnerError when caller does not own NPC', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc({ ownerId: 'user-2' }));

    await expect(handler.execute(new DeleteNpcCommand('npc-1', 'user-1'))).rejects.toBeInstanceOf(
      NpcNotOwnerError,
    );
    expect(repo.delete).not.toHaveBeenCalled();
  });

  it('throws NpcNotOwnerError with code NPC_NOT_OWNED and status 404', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc({ ownerId: 'user-2' }));

    await expect(handler.execute(new DeleteNpcCommand('npc-1', 'user-1'))).rejects.toMatchObject({
      code: 'NPC_NOT_OWNED',
      status: 404,
    });
  });
});

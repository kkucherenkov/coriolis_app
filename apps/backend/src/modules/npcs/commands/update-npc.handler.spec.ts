/**
 * Unit tests for UpdateNpcHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { NpcNameEmptyError, NpcNotFoundError, NpcNotOwnerError } from '../domain/npc.errors';

import { UpdateNpcCommand, UpdateNpcDto } from './update-npc.command';
import { UpdateNpcHandler } from './update-npc.handler';

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

describe('UpdateNpcHandler', () => {
  let repo: INpcRepo;
  let handler: UpdateNpcHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new UpdateNpcHandler(repo);
  });

  it('updates name when provided', async () => {
    const npc = makeNpc();
    vi.mocked(repo.findById).mockResolvedValue(npc);
    vi.mocked(repo.update).mockResolvedValue(makeNpc({ name: 'New Name' }));

    const dto = Object.assign(new UpdateNpcDto(), { name: 'New Name' });
    const result = await handler.execute(new UpdateNpcCommand('npc-1', 'user-1', dto));

    expect(repo.update).toHaveBeenCalledWith(
      'npc-1',
      expect.objectContaining({ name: 'New Name' }),
    );
    expect(result.name).toBe('New Name');
  });

  it('trims whitespace from name', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc());
    vi.mocked(repo.update).mockResolvedValue(makeNpc({ name: 'Trimmed' }));

    const dto = Object.assign(new UpdateNpcDto(), { name: '  Trimmed  ' });
    await handler.execute(new UpdateNpcCommand('npc-1', 'user-1', dto));

    expect(repo.update).toHaveBeenCalledWith('npc-1', expect.objectContaining({ name: 'Trimmed' }));
  });

  it('throws NpcNameEmptyError when name is whitespace-only', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc());

    const dto = Object.assign(new UpdateNpcDto(), { name: '   ' });
    await expect(
      handler.execute(new UpdateNpcCommand('npc-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(NpcNameEmptyError);
    expect(repo.update).not.toHaveBeenCalled();
  });

  it('throws NpcNameTooLongError when name exceeds 120 chars', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc());

    const dto = Object.assign(new UpdateNpcDto(), { name: 'a'.repeat(121) });
    await expect(
      handler.execute(new UpdateNpcCommand('npc-1', 'user-1', dto)),
    ).rejects.toMatchObject({
      code: 'NPC_NAME_TOO_LONG',
      status: 400,
    });
  });

  it('throws NpcNotFoundError when NPC does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    const dto = Object.assign(new UpdateNpcDto(), { name: 'X' });
    await expect(
      handler.execute(new UpdateNpcCommand('npc-x', 'user-1', dto)),
    ).rejects.toBeInstanceOf(NpcNotFoundError);
  });

  it('throws NpcNotOwnerError when caller does not own NPC', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc({ ownerId: 'user-2' }));

    const dto = Object.assign(new UpdateNpcDto(), { name: 'X' });
    await expect(
      handler.execute(new UpdateNpcCommand('npc-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(NpcNotOwnerError);
  });

  it('patches hp.current and hp.max independently', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc());
    vi.mocked(repo.update).mockResolvedValue(makeNpc({ hp: { current: 2, max: 8 } }));

    const dto = Object.assign(new UpdateNpcDto(), { hp: { current: 2, max: 8 } });
    await handler.execute(new UpdateNpcCommand('npc-1', 'user-1', dto));

    expect(repo.update).toHaveBeenCalledWith(
      'npc-1',
      expect.objectContaining({ hpCurrent: 2, hpMax: 8 }),
    );
  });

  it('patches signature and keySkillModifier', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc());
    vi.mocked(repo.update).mockResolvedValue(makeNpc({ signature: -3, keySkillModifier: 2 }));

    const dto = Object.assign(new UpdateNpcDto(), { signature: -3, keySkillModifier: 2 });
    await handler.execute(new UpdateNpcCommand('npc-1', 'user-1', dto));

    expect(repo.update).toHaveBeenCalledWith(
      'npc-1',
      expect.objectContaining({ signature: -3, keySkillModifier: 2 }),
    );
  });

  it('replaces armor and weapons arrays entirely', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc());
    const weapons = [{ type: 'weapon', name: 'Sword', damage: 3 }];
    vi.mocked(repo.update).mockResolvedValue(makeNpc({ weapons: weapons as never }));

    const dto = Object.assign(new UpdateNpcDto(), { weapons });
    await handler.execute(new UpdateNpcCommand('npc-1', 'user-1', dto));

    expect(repo.update).toHaveBeenCalledWith('npc-1', expect.objectContaining({ weapons }));
  });

  it('passes tags to repo.update', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc());
    vi.mocked(repo.update).mockResolvedValue(makeNpc({ tags: ['Boss', 'Cyborg'] }));

    const dto = Object.assign(new UpdateNpcDto(), { tags: ['Boss', 'Cyborg'] });
    await handler.execute(new UpdateNpcCommand('npc-1', 'user-1', dto));

    expect(repo.update).toHaveBeenCalledWith(
      'npc-1',
      expect.objectContaining({ tags: ['Boss', 'Cyborg'] }),
    );
  });

  it('does not include fields that were not provided in the patch', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeNpc());
    vi.mocked(repo.update).mockResolvedValue(makeNpc({ name: 'Updated' }));

    const dto = Object.assign(new UpdateNpcDto(), { name: 'Updated' });
    await handler.execute(new UpdateNpcCommand('npc-1', 'user-1', dto));

    const call = vi.mocked(repo.update).mock.calls[0];
    const patch = call?.[1];
    expect(patch).not.toHaveProperty('hpCurrent');
    expect(patch).not.toHaveProperty('tags');
  });
});

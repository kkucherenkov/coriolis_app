/**
 * Unit tests for ListNpcsHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ListNpcsQuery } from './list-npcs.query';
import { ListNpcsHandler } from './list-npcs.handler';

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

function makeNpc(id: string): NpcReadModel {
  return {
    id,
    ownerId: 'user-1',
    name: `NPC ${id}`,
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
  };
}

describe('ListNpcsHandler', () => {
  let repo: INpcRepo;
  let handler: ListNpcsHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new ListNpcsHandler(repo);
  });

  it('returns items and nextCursor from repo', async () => {
    const npcs = [makeNpc('npc-1'), makeNpc('npc-2')];
    vi.mocked(repo.list).mockResolvedValue({ items: npcs, nextCursor: null });

    const result = await handler.execute(new ListNpcsQuery('user-1', 20));

    expect(result.items).toHaveLength(2);
    expect(result.nextCursor).toBeNull();
    expect(repo.list).toHaveBeenCalledWith({ ownerId: 'user-1', limit: 20 });
  });

  it('forwards cursor to repo when provided', async () => {
    vi.mocked(repo.list).mockResolvedValue({ items: [], nextCursor: null });

    await handler.execute(new ListNpcsQuery('user-1', 10, 'npc-cursor'));

    expect(repo.list).toHaveBeenCalledWith({
      ownerId: 'user-1',
      limit: 10,
      cursor: 'npc-cursor',
    });
  });

  it('returns nextCursor when more pages exist', async () => {
    const npcs = [makeNpc('npc-1')];
    vi.mocked(repo.list).mockResolvedValue({ items: npcs, nextCursor: 'npc-1' });

    const result = await handler.execute(new ListNpcsQuery('user-1', 1));

    expect(result.nextCursor).toBe('npc-1');
  });

  it('returns empty items and null cursor when no NPCs exist', async () => {
    vi.mocked(repo.list).mockResolvedValue({ items: [], nextCursor: null });

    const result = await handler.execute(new ListNpcsQuery('user-1', 20));

    expect(result.items).toHaveLength(0);
    expect(result.nextCursor).toBeNull();
  });

  it('does not forward cursor when undefined', async () => {
    vi.mocked(repo.list).mockResolvedValue({ items: [], nextCursor: null });

    await handler.execute(new ListNpcsQuery('user-1', 20, undefined));

    expect(repo.list).toHaveBeenCalledWith({ ownerId: 'user-1', limit: 20 });
  });
});

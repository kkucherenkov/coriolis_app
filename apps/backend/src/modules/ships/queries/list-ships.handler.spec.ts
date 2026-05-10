/**
 * Unit tests for ListShipsHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ListShipsQuery } from './list-ships.query';
import { ListShipsHandler } from './list-ships.handler';

import type { IShipRepo, ShipReadModel } from '../domain/ship.ports';

function makeRepo(): IShipRepo {
  return {
    findById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
    findModuleById: vi.fn(),
    addModule: vi.fn(),
    updateModule: vi.fn(),
    deleteModule: vi.fn(),
    findCrewSlot: vi.fn(),
    findCrewSlotByCharacter: vi.fn(),
    assignCrewSlot: vi.fn(),
    unassignCrewSlot: vi.fn(),
    duplicate: vi.fn(),
    listNamesByPrefix: vi.fn(),
  };
}

function makeShip(id: string): ShipReadModel {
  return {
    id,
    ownerId: 'user-1',
    name: `Ship ${id}`,
    class: 'light-freighter',
    model: null,
    registry: null,
    hull: { current: 6, max: 6 },
    energy: { current: 5, max: 5 },
    armor: 5,
    maneuverability: 0,
    signature: 0,
    speed: 2,
    cargoCapacity: 50,
    modules: [],
    crew: [],
    problems: [],
    history: null,
    notes: null,
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
  };
}

describe('ListShipsHandler', () => {
  let repo: IShipRepo;
  let handler: ListShipsHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new ListShipsHandler(repo);
  });

  it('returns items and nextCursor from repo', async () => {
    const ships = [makeShip('ship-1'), makeShip('ship-2')];
    vi.mocked(repo.list).mockResolvedValue({ items: ships, nextCursor: null });

    const result = await handler.execute(new ListShipsQuery('user-1', 20));

    expect(result.items).toHaveLength(2);
    expect(result.nextCursor).toBeNull();
    expect(repo.list).toHaveBeenCalledWith({ ownerId: 'user-1', limit: 20 });
  });

  it('forwards cursor to repo when provided', async () => {
    vi.mocked(repo.list).mockResolvedValue({ items: [], nextCursor: null });

    await handler.execute(new ListShipsQuery('user-1', 10, 'ship-cursor'));

    expect(repo.list).toHaveBeenCalledWith({
      ownerId: 'user-1',
      limit: 10,
      cursor: 'ship-cursor',
    });
  });

  it('returns nextCursor when more pages exist', async () => {
    const ships = [makeShip('ship-1')];
    vi.mocked(repo.list).mockResolvedValue({ items: ships, nextCursor: 'ship-1' });

    const result = await handler.execute(new ListShipsQuery('user-1', 1));

    expect(result.nextCursor).toBe('ship-1');
  });
});

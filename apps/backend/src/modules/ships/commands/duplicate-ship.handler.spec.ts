/**
 * Unit tests for DuplicateShipHandler.
 * Repo is a vi.fn() mock — no NestJS or Prisma bootstrapping.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ShipNotFoundError, ShipNotOwnerError } from '../domain/ship.errors';

import { DuplicateShipCommand } from './duplicate-ship.command';
import { DuplicateShipHandler } from './duplicate-ship.handler';

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

const CREW_POSITIONS = ['captain', 'pilot', 'sensorOp', 'gunner', 'engineer', 'serviceCrew'];

function makeShip(overrides: Partial<ShipReadModel> = {}): ShipReadModel {
  return {
    id: 'ship-1',
    ownerId: 'user-1',
    name: 'Madara',
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
    modules: [
      { id: 'mod-1', slot: 'BRIDGE', name: 'Bridge', energyUse: 1, data: {} },
      { id: 'mod-2', slot: 'REACTOR', name: 'Reactor', energyUse: 0, data: {} },
      { id: 'mod-3', slot: 'DRIVE', name: 'Drive', energyUse: 2, data: {} },
    ],
    crew: CREW_POSITIONS.map((p) => ({
      position: p as ShipReadModel['crew'][number]['position'],
      assignedCharacterId: null,
    })),
    problems: [],
    history: null,
    notes: null,
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
    ...overrides,
  };
}

function makeCopy(name: string): ShipReadModel {
  return makeShip({
    id: 'ship-copy',
    name,
    modules: [
      { id: 'mod-c1', slot: 'BRIDGE', name: 'Bridge', energyUse: 1, data: {} },
      { id: 'mod-c2', slot: 'REACTOR', name: 'Reactor', energyUse: 0, data: {} },
      { id: 'mod-c3', slot: 'DRIVE', name: 'Drive', energyUse: 2, data: {} },
    ],
    crew: CREW_POSITIONS.map((p) => ({
      position: p as ShipReadModel['crew'][number]['position'],
      assignedCharacterId: null,
    })),
  });
}

describe('DuplicateShipHandler', () => {
  let repo: IShipRepo;
  let handler: DuplicateShipHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new DuplicateShipHandler(repo);
  });

  it('happy path: returns a new ship with "(copy)" suffix and distinct id', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip());
    vi.mocked(repo.listNamesByPrefix).mockResolvedValue([]);
    const copy = makeCopy('Madara (copy)');
    vi.mocked(repo.duplicate).mockResolvedValue(copy);

    const result = await handler.execute(new DuplicateShipCommand('ship-1', 'user-1'));

    expect(result.id).toBe('ship-copy');
    expect(result.name).toBe('Madara (copy)');
    expect(repo.duplicate).toHaveBeenCalledWith('ship-1', 'user-1', 'Madara (copy)');
  });

  it('uses "(copy 2)" when "(copy)" is already taken', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip());
    vi.mocked(repo.listNamesByPrefix).mockResolvedValue(['Madara (copy)']);
    const copy = makeCopy('Madara (copy 2)');
    vi.mocked(repo.duplicate).mockResolvedValue(copy);

    const result = await handler.execute(new DuplicateShipCommand('ship-1', 'user-1'));

    expect(result.name).toBe('Madara (copy 2)');
    expect(repo.duplicate).toHaveBeenCalledWith('ship-1', 'user-1', 'Madara (copy 2)');
  });

  it('uses "(copy 3)" when "(copy)" and "(copy 2)" are both taken', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip());
    vi.mocked(repo.listNamesByPrefix).mockResolvedValue(['Madara (copy)', 'Madara (copy 2)']);
    const copy = makeCopy('Madara (copy 3)');
    vi.mocked(repo.duplicate).mockResolvedValue(copy);

    await handler.execute(new DuplicateShipCommand('ship-1', 'user-1'));

    expect(repo.duplicate).toHaveBeenCalledWith('ship-1', 'user-1', 'Madara (copy 3)');
  });

  it('throws ShipNotFoundError when source ship does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new DuplicateShipCommand('missing-ship', 'user-1')),
    ).rejects.toBeInstanceOf(ShipNotFoundError);

    expect(repo.duplicate).not.toHaveBeenCalled();
  });

  it('throws ShipNotOwnerError when caller does not own the source ship', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip({ ownerId: 'other-user' }));

    await expect(
      handler.execute(new DuplicateShipCommand('ship-1', 'user-1')),
    ).rejects.toBeInstanceOf(ShipNotOwnerError);

    expect(repo.duplicate).not.toHaveBeenCalled();
  });

  it('module count in result matches the source ship modules', async () => {
    const source = makeShip();
    vi.mocked(repo.findById).mockResolvedValue(source);
    vi.mocked(repo.listNamesByPrefix).mockResolvedValue([]);
    const copy = makeCopy('Madara (copy)');
    vi.mocked(repo.duplicate).mockResolvedValue(copy);

    const result = await handler.execute(new DuplicateShipCommand('ship-1', 'user-1'));

    expect(result.modules).toHaveLength(source.modules.length);
  });

  it('crew roster in the copy is fully vacant (all assignedCharacterId null)', async () => {
    vi.mocked(repo.findById).mockResolvedValue(
      makeShip({
        crew: CREW_POSITIONS.map((p) => ({
          position: p as ShipReadModel['crew'][number]['position'],
          assignedCharacterId: 'char-99',
        })),
      }),
    );
    vi.mocked(repo.listNamesByPrefix).mockResolvedValue([]);
    const copy = makeCopy('Madara (copy)');
    vi.mocked(repo.duplicate).mockResolvedValue(copy);

    const result = await handler.execute(new DuplicateShipCommand('ship-1', 'user-1'));

    expect(result.crew.every((s) => s.assignedCharacterId === null)).toBe(true);
  });

  it('passes the prefix to listNamesByPrefix for collision detection', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip({ name: 'Star Runner' }));
    vi.mocked(repo.listNamesByPrefix).mockResolvedValue([]);
    vi.mocked(repo.duplicate).mockResolvedValue(makeCopy('Star Runner (copy)'));

    await handler.execute(new DuplicateShipCommand('ship-1', 'user-1'));

    expect(repo.listNamesByPrefix).toHaveBeenCalledWith('user-1', 'Star Runner (copy');
  });
});

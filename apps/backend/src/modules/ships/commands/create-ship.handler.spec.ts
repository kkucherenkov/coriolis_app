/**
 * Unit tests for CreateShipHandler.
 * Repo is a vi.fn() mock — no NestJS or Prisma bootstrapping.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ShipNameEmptyError, ShipNameTooLongError } from '../domain/ship.errors';

import { CreateShipCommand, CreateShipDto } from './create-ship.command';
import { CreateShipHandler } from './create-ship.handler';

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
    // cargoCapacity is not in ТАБЛИЦА 7.5; it defaults to 0 on create
    // and grows as HOLD modules are added.
    cargoCapacity: 0,
    modules: [],
    crew: [],
    problems: [],
    history: null,
    notes: null,
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
    ...overrides,
  };
}

function makeDto(overrides: Partial<CreateShipDto> = {}): CreateShipDto {
  return Object.assign(new CreateShipDto(), {
    name: 'Madara',
    class: 'light-freighter',
    ...overrides,
  });
}

describe('CreateShipHandler', () => {
  let repo: IShipRepo;
  let handler: CreateShipHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new CreateShipHandler(repo);
  });

  it('creates a ship with class base stats when not overridden', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeShip());

    await handler.execute(new CreateShipCommand('user-1', makeDto()));

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({
        ownerId: 'user-1',
        name: 'Madara',
        class: 'light-freighter',
        // Class III from ТАБЛИЦА 7.5: energyMax=5, hullMax=6, armor=5, speed=2, maneuverability=0, signature=0
        hullMax: 6,
        hullCurrent: 6,
        energyMax: 5,
        energyCurrent: 5,
        armor: 5,
        // cargoCapacity is not a class stat — defaults to 0 on create
        cargoCapacity: 0,
      }),
    );
  });

  it('uses hull override when provided', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeShip({ hull: { current: 3, max: 8 } }));

    await handler.execute(
      new CreateShipCommand('user-1', makeDto({ hull: { current: 3, max: 8 } })),
    );

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ hullCurrent: 3, hullMax: 8 }),
    );
  });

  it('seeds hullCurrent from hullMax override when current not provided', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeShip({ hull: { current: 8, max: 8 } }));

    await handler.execute(new CreateShipCommand('user-1', makeDto({ hull: { max: 8 } })));

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ hullCurrent: 8, hullMax: 8 }),
    );
  });

  it('trims whitespace from name', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeShip());

    await handler.execute(new CreateShipCommand('user-1', makeDto({ name: '  Madara  ' })));

    expect(repo.create).toHaveBeenCalledWith(expect.objectContaining({ name: 'Madara' }));
  });

  it('throws ShipNameEmptyError for empty name', async () => {
    await expect(
      handler.execute(new CreateShipCommand('user-1', makeDto({ name: '' }))),
    ).rejects.toBeInstanceOf(ShipNameEmptyError);
    expect(repo.create).not.toHaveBeenCalled();
  });

  it('throws ShipNameEmptyError for whitespace-only name', async () => {
    await expect(
      handler.execute(new CreateShipCommand('user-1', makeDto({ name: '   ' }))),
    ).rejects.toMatchObject({ code: 'SHIP_NAME_EMPTY', status: 400 });
  });

  it('throws ShipNameTooLongError for name > 80 chars', async () => {
    await expect(
      handler.execute(new CreateShipCommand('user-1', makeDto({ name: 'a'.repeat(81) }))),
    ).rejects.toBeInstanceOf(ShipNameTooLongError);
    expect(repo.create).not.toHaveBeenCalled();
  });

  it('accepts name of exactly 80 characters', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeShip({ name: 'a'.repeat(80) }));

    await expect(
      handler.execute(new CreateShipCommand('user-1', makeDto({ name: 'a'.repeat(80) }))),
    ).resolves.toBeDefined();
  });

  it('uses fighter base stats for fighter class', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeShip({ class: 'fighter' }));

    await handler.execute(
      new CreateShipCommand('user-1', makeDto({ name: 'X-Wing', class: 'fighter' })),
    );

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({
        class: 'fighter',
        // Class I from ТАБЛИЦА 7.5: energyMax=3, hullMax=2, armor=3, speed=4, maneuverability=2, signature=-2
        hullMax: 2,
        energyMax: 3,
        armor: 3,
        speed: 4,
        // cargoCapacity is not a class stat — defaults to 0 on create
        cargoCapacity: 0,
      }),
    );
  });

  it('passes model and registry to repo.create', async () => {
    vi.mocked(repo.create).mockResolvedValue(
      makeShip({ model: 'Helebian III', registry: 'KUA-7741-M' }),
    );

    await handler.execute(
      new CreateShipCommand('user-1', makeDto({ model: 'Helebian III', registry: 'KUA-7741-M' })),
    );

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ model: 'Helebian III', registry: 'KUA-7741-M' }),
    );
  });

  it('defaults model and registry to null when not provided', async () => {
    vi.mocked(repo.create).mockResolvedValue(makeShip());

    await handler.execute(new CreateShipCommand('user-1', makeDto()));

    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({ model: null, registry: null }),
    );
  });
});

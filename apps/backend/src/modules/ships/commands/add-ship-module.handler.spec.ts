/**
 * Unit tests for AddShipModuleHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  ShipModuleSlotInvalidError,
  ShipModuleTypeMismatchError,
  ShipNotFoundError,
  ShipNotOwnerError,
} from '../domain/ship.errors';

import { AddShipModuleCommand, AddShipModuleDto } from './add-ship-module.command';
import { AddShipModuleHandler } from './add-ship-module.handler';

import type { IShipRepo, ShipModuleReadModel, ShipReadModel } from '../domain/ship.ports';

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
    cargoCapacity: 50,
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

function makeModule(overrides: Partial<ShipModuleReadModel> = {}): ShipModuleReadModel {
  return {
    id: 'mod-1',
    slot: 'HOLD',
    name: 'Main Hold',
    energyUse: 0,
    data: { cargoTons: 50, concealed: false },
    ...overrides,
  };
}

function makeDto(overrides: Record<string, unknown> = {}): AddShipModuleDto {
  return Object.assign(new AddShipModuleDto(), {
    slot: 'HOLD',
    name: 'Main Hold',
    energyUse: 0,
    cargoTons: 50,
    concealed: false,
    ...overrides,
  });
}

describe('AddShipModuleHandler', () => {
  let repo: IShipRepo;
  let handler: AddShipModuleHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new AddShipModuleHandler(repo);
  });

  it('adds a HOLD module successfully', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip());
    vi.mocked(repo.addModule).mockResolvedValue(makeModule());

    const result = await handler.execute(
      new AddShipModuleCommand('ship-1', 'user-1', makeDto()),
    );

    expect(repo.addModule).toHaveBeenCalledWith('ship-1', expect.objectContaining({ slot: 'HOLD' }));
    expect(result.slot).toBe('HOLD');
  });

  it('adds a WEAPON module successfully', async () => {
    const weaponModule = makeModule({
      slot: 'WEAPON',
      name: 'Graviton Projector',
      energyUse: 2,
      data: { weaponBonus: 1, weaponRange: 'medium', weaponDamage: 2, weaponCritThreshold: 3 },
    });
    vi.mocked(repo.findById).mockResolvedValue(makeShip());
    vi.mocked(repo.addModule).mockResolvedValue(weaponModule);

    // Build a clean WEAPON DTO — no HOLD fields (makeDto defaults to HOLD)
    const dto = Object.assign(new AddShipModuleDto(), {
      slot: 'WEAPON',
      name: 'Graviton Projector',
      energyUse: 2,
      weaponBonus: 1,
      weaponRange: 'medium',
      weaponDamage: 2,
      weaponCritThreshold: 3,
    });
    const result = await handler.execute(new AddShipModuleCommand('ship-1', 'user-1', dto));
    expect(result.slot).toBe('WEAPON');
  });

  it('throws ShipNotFoundError when ship does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new AddShipModuleCommand('ship-x', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(ShipNotFoundError);
    expect(repo.addModule).not.toHaveBeenCalled();
  });

  it('throws ShipNotOwnerError when caller does not own the ship', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip({ ownerId: 'user-2' }));

    await expect(
      handler.execute(new AddShipModuleCommand('ship-1', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(ShipNotOwnerError);
    expect(repo.addModule).not.toHaveBeenCalled();
  });

  it('throws ShipModuleSlotInvalidError for an unknown slot', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip());

    const dto = makeDto({ slot: 'UNKNOWN' });
    await expect(
      handler.execute(new AddShipModuleCommand('ship-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(ShipModuleSlotInvalidError);
  });

  it('throws ShipModuleTypeMismatchError when weaponBonus is provided for slot HOLD', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip());

    const dto = makeDto({ slot: 'HOLD', weaponBonus: 2 });
    await expect(
      handler.execute(new AddShipModuleCommand('ship-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(ShipModuleTypeMismatchError);
  });
});

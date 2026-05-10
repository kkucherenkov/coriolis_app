/**
 * Unit tests for UpdateShipModuleHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  ShipModuleNotFoundError,
  ShipModuleNotOwnedError,
  ShipModuleTypeMismatchError,
} from '../domain/ship.errors';

import { UpdateShipModuleCommand, UpdateShipModuleDto } from './update-ship-module.command';
import { UpdateShipModuleHandler } from './update-ship-module.handler';

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

function makeModuleRow(
  overrides: Partial<ShipModuleReadModel & { shipId: string }> = {},
): ShipModuleReadModel & { shipId: string } {
  return {
    id: 'mod-1',
    shipId: 'ship-1',
    slot: 'HOLD',
    name: 'Main Hold',
    energyUse: 0,
    data: { cargoTons: 50, concealed: false },
    ...overrides,
  };
}

function makeDto(overrides: Record<string, unknown> = {}): UpdateShipModuleDto {
  return Object.assign(new UpdateShipModuleDto(), overrides);
}

describe('UpdateShipModuleHandler', () => {
  let repo: IShipRepo;
  let handler: UpdateShipModuleHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new UpdateShipModuleHandler(repo);
  });

  it('updates a module name successfully', async () => {
    vi.mocked(repo.findModuleById).mockResolvedValue(makeModuleRow());
    vi.mocked(repo.findById).mockResolvedValue(makeShip());
    vi.mocked(repo.updateModule).mockResolvedValue(makeModuleRow({ name: 'Smuggler Hold' }));

    const result = await handler.execute(
      new UpdateShipModuleCommand(
        'mod-1',
        'user-1',
        makeDto({ slot: 'HOLD', name: 'Smuggler Hold' }),
      ),
    );

    expect(repo.updateModule).toHaveBeenCalledWith(
      'mod-1',
      expect.objectContaining({ name: 'Smuggler Hold' }),
    );
    expect(result.name).toBe('Smuggler Hold');
  });

  it('throws ShipModuleNotFoundError when module does not exist', async () => {
    vi.mocked(repo.findModuleById).mockResolvedValue(null);

    await expect(
      handler.execute(new UpdateShipModuleCommand('mod-x', 'user-1', makeDto({ slot: 'HOLD' }))),
    ).rejects.toBeInstanceOf(ShipModuleNotFoundError);
  });

  it('throws ShipModuleNotOwnedError when caller does not own the parent ship', async () => {
    vi.mocked(repo.findModuleById).mockResolvedValue(makeModuleRow());
    vi.mocked(repo.findById).mockResolvedValue(makeShip({ ownerId: 'user-2' }));

    await expect(
      handler.execute(new UpdateShipModuleCommand('mod-1', 'user-1', makeDto({ slot: 'HOLD' }))),
    ).rejects.toBeInstanceOf(ShipModuleNotOwnedError);
    expect(repo.updateModule).not.toHaveBeenCalled();
  });

  it('throws ShipModuleTypeMismatchError when slot discriminator changes', async () => {
    vi.mocked(repo.findModuleById).mockResolvedValue(makeModuleRow({ slot: 'HOLD' }));
    vi.mocked(repo.findById).mockResolvedValue(makeShip());

    await expect(
      handler.execute(new UpdateShipModuleCommand('mod-1', 'user-1', makeDto({ slot: 'WEAPON' }))),
    ).rejects.toBeInstanceOf(ShipModuleTypeMismatchError);
    expect(repo.updateModule).not.toHaveBeenCalled();
  });
});

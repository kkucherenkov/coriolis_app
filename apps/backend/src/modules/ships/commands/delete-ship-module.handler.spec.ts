/**
 * Unit tests for DeleteShipModuleHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  ShipModuleMandatoryError,
  ShipModuleNotFoundError,
  ShipModuleNotOwnedError,
} from '../domain/ship.errors';

import { DeleteShipModuleCommand } from './delete-ship-module.command';
import { DeleteShipModuleHandler } from './delete-ship-module.handler';

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

function makeModuleRow(
  overrides: Partial<ShipModuleReadModel & { shipId: string }> = {},
): ShipModuleReadModel & { shipId: string } {
  return {
    id: 'mod-1',
    shipId: 'ship-1',
    slot: 'HOLD',
    name: 'Main Hold',
    energyUse: 0,
    data: {},
    ...overrides,
  };
}

describe('DeleteShipModuleHandler', () => {
  let repo: IShipRepo;
  let handler: DeleteShipModuleHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new DeleteShipModuleHandler(repo);
  });

  it('deletes an optional module when caller is the owner', async () => {
    vi.mocked(repo.findModuleById).mockResolvedValue(makeModuleRow({ slot: 'HOLD' }));
    vi.mocked(repo.findById).mockResolvedValue(makeShip());
    vi.mocked(repo.deleteModule).mockResolvedValue(undefined);

    await handler.execute(new DeleteShipModuleCommand('mod-1', 'user-1'));

    expect(repo.deleteModule).toHaveBeenCalledWith('mod-1');
  });

  it('throws ShipModuleNotFoundError when module does not exist', async () => {
    vi.mocked(repo.findModuleById).mockResolvedValue(null);

    await expect(
      handler.execute(new DeleteShipModuleCommand('mod-x', 'user-1')),
    ).rejects.toBeInstanceOf(ShipModuleNotFoundError);
    expect(repo.deleteModule).not.toHaveBeenCalled();
  });

  it('throws ShipModuleNotOwnedError when caller does not own the parent ship', async () => {
    vi.mocked(repo.findModuleById).mockResolvedValue(makeModuleRow());
    vi.mocked(repo.findById).mockResolvedValue(makeShip({ ownerId: 'user-2' }));

    await expect(
      handler.execute(new DeleteShipModuleCommand('mod-1', 'user-1')),
    ).rejects.toBeInstanceOf(ShipModuleNotOwnedError);
    expect(repo.deleteModule).not.toHaveBeenCalled();
  });

  it.each(['BRIDGE', 'REACTOR', 'DRIVE'] as const)(
    'throws ShipModuleMandatoryError for mandatory slot %s',
    async (slot) => {
      vi.mocked(repo.findModuleById).mockResolvedValue(makeModuleRow({ slot }));
      vi.mocked(repo.findById).mockResolvedValue(makeShip());

      await expect(
        handler.execute(new DeleteShipModuleCommand('mod-1', 'user-1')),
      ).rejects.toBeInstanceOf(ShipModuleMandatoryError);
      expect(repo.deleteModule).not.toHaveBeenCalled();
    },
  );
});

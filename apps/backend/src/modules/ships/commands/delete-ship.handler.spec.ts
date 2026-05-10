/**
 * Unit tests for DeleteShipHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ShipNotFoundError, ShipNotOwnerError } from '../domain/ship.errors';

import { DeleteShipCommand } from './delete-ship.command';
import { DeleteShipHandler } from './delete-ship.handler';

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

describe('DeleteShipHandler', () => {
  let repo: IShipRepo;
  let handler: DeleteShipHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new DeleteShipHandler(repo);
  });

  it('deletes the ship when caller is the owner', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip());
    vi.mocked(repo.delete).mockResolvedValue(undefined);

    await handler.execute(new DeleteShipCommand('ship-1', 'user-1'));

    expect(repo.delete).toHaveBeenCalledWith('ship-1');
  });

  it('throws ShipNotFoundError when ship does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new DeleteShipCommand('ship-x', 'user-1')),
    ).rejects.toBeInstanceOf(ShipNotFoundError);
    expect(repo.delete).not.toHaveBeenCalled();
  });

  it('throws ShipNotOwnerError when caller is not the owner', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip({ ownerId: 'user-2' }));

    await expect(
      handler.execute(new DeleteShipCommand('ship-1', 'user-1')),
    ).rejects.toBeInstanceOf(ShipNotOwnerError);
    expect(repo.delete).not.toHaveBeenCalled();
  });

  it('throws ShipNotOwnerError with code SHIP_NOT_OWNED and status 403', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip({ ownerId: 'user-2' }));

    await expect(
      handler.execute(new DeleteShipCommand('ship-1', 'user-1')),
    ).rejects.toMatchObject({ code: 'SHIP_NOT_OWNED', status: 403 });
  });
});

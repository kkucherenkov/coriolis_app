/**
 * Unit tests for GetShipHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ShipNotFoundError, ShipNotOwnerError } from '../domain/ship.errors';

import { GetShipQuery } from './get-ship.query';
import { GetShipHandler } from './get-ship.handler';

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

describe('GetShipHandler', () => {
  let repo: IShipRepo;
  let handler: GetShipHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new GetShipHandler(repo);
  });

  it('returns the ship when caller is the owner', async () => {
    const ship = makeShip();
    vi.mocked(repo.findById).mockResolvedValue(ship);

    const result = await handler.execute(new GetShipQuery('ship-1', 'user-1'));

    expect(result).toEqual(ship);
  });

  it('throws ShipNotFoundError when ship does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(handler.execute(new GetShipQuery('ship-x', 'user-1'))).rejects.toBeInstanceOf(
      ShipNotFoundError,
    );
  });

  it('throws ShipNotOwnerError when caller is not the owner', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip({ ownerId: 'user-2' }));

    await expect(handler.execute(new GetShipQuery('ship-1', 'user-1'))).rejects.toBeInstanceOf(
      ShipNotOwnerError,
    );
  });

  it('throws ShipNotOwnerError with code SHIP_NOT_OWNED and status 403', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip({ ownerId: 'user-2' }));

    await expect(handler.execute(new GetShipQuery('ship-1', 'user-1'))).rejects.toMatchObject({
      code: 'SHIP_NOT_OWNED',
      status: 403,
    });
  });
});

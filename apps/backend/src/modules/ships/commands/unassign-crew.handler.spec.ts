/**
 * Unit tests for UnassignCrewHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ShipNotFoundError, ShipNotOwnerError } from '../domain/ship.errors';

import { UnassignCrewCommand } from './unassign-crew.command';
import { UnassignCrewHandler } from './unassign-crew.handler';

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

describe('UnassignCrewHandler', () => {
  let repo: IShipRepo;
  let handler: UnassignCrewHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new UnassignCrewHandler(repo);
  });

  it('unassigns a character successfully', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip());
    vi.mocked(repo.unassignCrewSlot).mockResolvedValue(undefined);

    await handler.execute(new UnassignCrewCommand('ship-1', 'user-1', 'char-1'));

    expect(repo.unassignCrewSlot).toHaveBeenCalledWith('ship-1', 'char-1');
  });

  it('is idempotent — no error if character not currently assigned', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip());
    vi.mocked(repo.unassignCrewSlot).mockResolvedValue(undefined);

    await expect(
      handler.execute(new UnassignCrewCommand('ship-1', 'user-1', 'char-not-on-ship')),
    ).resolves.toBeUndefined();

    expect(repo.unassignCrewSlot).toHaveBeenCalledWith('ship-1', 'char-not-on-ship');
  });

  it('throws ShipNotFoundError when ship does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new UnassignCrewCommand('ship-x', 'user-1', 'char-1')),
    ).rejects.toBeInstanceOf(ShipNotFoundError);

    expect(repo.unassignCrewSlot).not.toHaveBeenCalled();
  });

  it('throws ShipNotOwnerError when caller does not own the ship', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip({ ownerId: 'user-2' }));

    await expect(
      handler.execute(new UnassignCrewCommand('ship-1', 'user-1', 'char-1')),
    ).rejects.toBeInstanceOf(ShipNotOwnerError);

    expect(repo.unassignCrewSlot).not.toHaveBeenCalled();
  });
});

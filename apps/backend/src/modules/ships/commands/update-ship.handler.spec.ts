/**
 * Unit tests for UpdateShipHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  ShipNameEmptyError,
  ShipNameTooLongError,
  ShipNotFoundError,
  ShipNotOwnerError,
} from '../domain/ship.errors';

import { UpdateShipCommand, UpdateShipDto } from './update-ship.command';
import { UpdateShipHandler } from './update-ship.handler';

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
    updatedAt: '2026-05-10T10:10:00.000Z',
    ...overrides,
  };
}

describe('UpdateShipHandler', () => {
  let repo: IShipRepo;
  let handler: UpdateShipHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new UpdateShipHandler(repo);
  });

  it('throws ShipNotFoundError when ship does not exist', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new UpdateShipCommand('ship-x', 'user-1', new UpdateShipDto())),
    ).rejects.toBeInstanceOf(ShipNotFoundError);
  });

  it('throws ShipNotOwnerError when caller is not the owner', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip({ ownerId: 'user-2' }));

    await expect(
      handler.execute(new UpdateShipCommand('ship-1', 'user-1', new UpdateShipDto())),
    ).rejects.toBeInstanceOf(ShipNotOwnerError);
    expect(repo.update).not.toHaveBeenCalled();
  });

  it('throws ShipNameEmptyError when name is empty string', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip());
    const dto = Object.assign(new UpdateShipDto(), { name: '' });

    await expect(
      handler.execute(new UpdateShipCommand('ship-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(ShipNameEmptyError);
    expect(repo.update).not.toHaveBeenCalled();
  });

  it('throws ShipNameTooLongError when name exceeds 80 chars', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip());
    const dto = Object.assign(new UpdateShipDto(), { name: 'x'.repeat(81) });

    await expect(
      handler.execute(new UpdateShipCommand('ship-1', 'user-1', dto)),
    ).rejects.toBeInstanceOf(ShipNameTooLongError);
  });

  it('updates the name and trims whitespace', async () => {
    const updated = makeShip({ name: 'Narzal' });
    vi.mocked(repo.findById).mockResolvedValue(makeShip());
    vi.mocked(repo.update).mockResolvedValue(updated);

    const dto = Object.assign(new UpdateShipDto(), { name: '  Narzal  ' });
    const result = await handler.execute(new UpdateShipCommand('ship-1', 'user-1', dto));

    expect(result.name).toBe('Narzal');
    expect(repo.update).toHaveBeenCalledWith('ship-1', expect.objectContaining({ name: 'Narzal' }));
  });

  it('replaces the problems list when provided', async () => {
    const problems = ['Hull breach — bay 3', 'Reactor coolant leak'];
    vi.mocked(repo.findById).mockResolvedValue(makeShip());
    vi.mocked(repo.update).mockResolvedValue(makeShip({ problems }));

    const dto = Object.assign(new UpdateShipDto(), { problems });
    await handler.execute(new UpdateShipCommand('ship-1', 'user-1', dto));

    expect(repo.update).toHaveBeenCalledWith('ship-1', expect.objectContaining({ problems }));
  });

  it('updates hull current without touching max', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeShip());
    vi.mocked(repo.update).mockResolvedValue(makeShip({ hull: { current: 3, max: 6 } }));

    const dto = Object.assign(new UpdateShipDto(), { hull: { current: 3 } });
    await handler.execute(new UpdateShipCommand('ship-1', 'user-1', dto));

    expect(repo.update).toHaveBeenCalledWith(
      'ship-1',
      expect.objectContaining({ hullCurrent: 3 }),
    );
    expect(repo.update).toHaveBeenCalledWith(
      'ship-1',
      expect.not.objectContaining({ hullMax: expect.anything() }),
    );
  });
});

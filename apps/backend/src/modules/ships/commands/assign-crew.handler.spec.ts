/**
 * Unit tests for AssignCrewHandler.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  CharacterNotFoundError,
  CharacterNotOwnedError,
  CrewPositionTakenError,
  ShipNotFoundError,
  ShipNotOwnerError,
} from '../domain/ship.errors';

import { AssignCrewCommand, AssignCrewDto } from './assign-crew.command';
import { AssignCrewHandler } from './assign-crew.handler';

import type { ICharacterRepo } from '../../characters/domain/character.ports';
import type { CrewSlotReadModel, IShipRepo, ShipReadModel } from '../domain/ship.ports';

function makeShipRepo(): IShipRepo {
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

function makeCharRepo(): ICharacterRepo {
  return {
    findActiveById: vi.fn(),
    findOwnerIdById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
    deleteAbandonedDrafts: vi.fn(),
  } as unknown as ICharacterRepo;
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

function makeDto(position = 'captain', characterId = 'char-1'): AssignCrewDto {
  return Object.assign(new AssignCrewDto(), { position, characterId });
}

function makeSlot(position: string, characterId: string | null = null): CrewSlotReadModel {
  return { position: position as CrewSlotReadModel['position'], assignedCharacterId: characterId };
}

describe('AssignCrewHandler', () => {
  let shipRepo: IShipRepo;
  let charRepo: ICharacterRepo;
  let handler: AssignCrewHandler;

  beforeEach(() => {
    shipRepo = makeShipRepo();
    charRepo = makeCharRepo();
    handler = new AssignCrewHandler(shipRepo, charRepo);
  });

  it('assigns a character to an empty position', async () => {
    vi.mocked(shipRepo.findById).mockResolvedValue(makeShip());
    vi.mocked(charRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    vi.mocked(shipRepo.findCrewSlotByCharacter).mockResolvedValue(null);
    vi.mocked(shipRepo.findCrewSlot).mockResolvedValue(makeSlot('captain'));
    vi.mocked(shipRepo.assignCrewSlot).mockResolvedValue(makeSlot('captain', 'char-1'));

    const result = await handler.execute(
      new AssignCrewCommand('ship-1', 'user-1', makeDto('captain', 'char-1')),
    );

    expect(shipRepo.assignCrewSlot).toHaveBeenCalledWith('ship-1', 'captain', 'char-1');
    expect(result).toEqual({ position: 'captain', assignedCharacterId: 'char-1' });
  });

  it('returns existing slot when character is re-assigned to same position (idempotent)', async () => {
    vi.mocked(shipRepo.findById).mockResolvedValue(makeShip());
    vi.mocked(charRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    vi.mocked(shipRepo.findCrewSlotByCharacter).mockResolvedValue(makeSlot('captain', 'char-1'));

    const result = await handler.execute(
      new AssignCrewCommand('ship-1', 'user-1', makeDto('captain', 'char-1')),
    );

    expect(shipRepo.assignCrewSlot).not.toHaveBeenCalled();
    expect(result).toEqual({ position: 'captain', assignedCharacterId: 'char-1' });
  });

  it('moves character to a new empty position (clears old slot first)', async () => {
    vi.mocked(shipRepo.findById).mockResolvedValue(makeShip());
    vi.mocked(charRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    vi.mocked(shipRepo.findCrewSlotByCharacter).mockResolvedValue(makeSlot('captain', 'char-1'));
    vi.mocked(shipRepo.findCrewSlot).mockResolvedValue(makeSlot('pilot')); // target is empty
    vi.mocked(shipRepo.assignCrewSlot).mockResolvedValue(makeSlot('pilot', 'char-1'));

    const result = await handler.execute(
      new AssignCrewCommand('ship-1', 'user-1', makeDto('pilot', 'char-1')),
    );

    expect(shipRepo.unassignCrewSlot).toHaveBeenCalledWith('ship-1', 'char-1');
    expect(shipRepo.assignCrewSlot).toHaveBeenCalledWith('ship-1', 'pilot', 'char-1');
    expect(result.position).toBe('pilot');
  });

  it('throws CrewPositionTakenError when moving character to an already-occupied position', async () => {
    vi.mocked(shipRepo.findById).mockResolvedValue(makeShip());
    vi.mocked(charRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    vi.mocked(shipRepo.findCrewSlotByCharacter).mockResolvedValue(makeSlot('captain', 'char-1'));
    vi.mocked(shipRepo.findCrewSlot).mockResolvedValue(makeSlot('pilot', 'char-other'));

    await expect(
      handler.execute(new AssignCrewCommand('ship-1', 'user-1', makeDto('pilot', 'char-1'))),
    ).rejects.toBeInstanceOf(CrewPositionTakenError);

    expect(shipRepo.unassignCrewSlot).not.toHaveBeenCalled();
  });

  it('throws CrewPositionTakenError when target position is already occupied by another character', async () => {
    vi.mocked(shipRepo.findById).mockResolvedValue(makeShip());
    vi.mocked(charRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-1' });
    vi.mocked(shipRepo.findCrewSlotByCharacter).mockResolvedValue(null);
    vi.mocked(shipRepo.findCrewSlot).mockResolvedValue(makeSlot('captain', 'char-other'));

    await expect(
      handler.execute(new AssignCrewCommand('ship-1', 'user-1', makeDto('captain', 'char-1'))),
    ).rejects.toBeInstanceOf(CrewPositionTakenError);
  });

  it('throws ShipNotFoundError when ship does not exist', async () => {
    vi.mocked(shipRepo.findById).mockResolvedValue(null);

    await expect(
      handler.execute(new AssignCrewCommand('ship-x', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(ShipNotFoundError);
  });

  it('throws ShipNotOwnerError when caller does not own the ship', async () => {
    vi.mocked(shipRepo.findById).mockResolvedValue(makeShip({ ownerId: 'user-2' }));

    await expect(
      handler.execute(new AssignCrewCommand('ship-1', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(ShipNotOwnerError);
  });

  it('throws CharacterNotFoundError when character does not exist', async () => {
    vi.mocked(shipRepo.findById).mockResolvedValue(makeShip());
    vi.mocked(charRepo.findOwnerIdById).mockResolvedValue(null);

    await expect(
      handler.execute(new AssignCrewCommand('ship-1', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(CharacterNotFoundError);
  });

  it('throws CharacterNotOwnedError when character is not owned by caller', async () => {
    vi.mocked(shipRepo.findById).mockResolvedValue(makeShip());
    vi.mocked(charRepo.findOwnerIdById).mockResolvedValue({ ownerId: 'user-2' });

    await expect(
      handler.execute(new AssignCrewCommand('ship-1', 'user-1', makeDto())),
    ).rejects.toBeInstanceOf(CharacterNotOwnedError);
  });
});

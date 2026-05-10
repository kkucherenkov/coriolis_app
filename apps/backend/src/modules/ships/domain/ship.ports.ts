/**
 * WHY this file exists:
 * Port interfaces decouple the application layer from Prisma.
 * Handlers inject IShipRepo by token (SHIP_REPO).
 * The Prisma adapter in infra/ implements the interface.
 * Unit tests swap in vi.fn() mocks without bootstrapping a database.
 *
 * Read models match the OpenAPI Ship / CrewSlot / ShipModule schemas exactly.
 * ShipClass values are the kebab-case wire format (Prisma @map handles the DB column).
 */

export type ShipClass =
  | 'fighter'
  | 'shuttle'
  | 'torpedo-boat'
  | 'light-freighter'
  | 'light-passenger'
  | 'courier-yacht'
  | 'clipper'
  | 'patrol-boat'
  | 'gunboat'
  | 'assault-ship'
  | 'blockade-runner'
  | 'pleasure-yacht'
  | 'flying-circus'
  | 'prospector'
  | 'rescue-ship'
  | 'passenger-liner'
  | 'heavy-freighter'
  | 'cruiser'
  | 'destroyer'
  | 'heavy-cruiser';

export type CrewPosition =
  | 'captain'
  | 'pilot'
  | 'sensorOp'
  | 'gunner'
  | 'engineer'
  | 'serviceCrew';

export interface CrewSlotReadModel {
  position: CrewPosition;
  assignedCharacterId: string | null;
}

export interface ShipModuleReadModel {
  id: string;
  slot: string;
  name: string;
  energyUse: number;
  data: Record<string, unknown>;
}

export interface ShipReadModel {
  id: string;
  ownerId: string;
  name: string;
  class: ShipClass;
  model: string | null;
  registry: string | null;
  hull: { current: number; max: number };
  energy: { current: number; max: number };
  armor: number;
  maneuverability: number;
  signature: number;
  speed: number;
  cargoCapacity: number;
  modules: ShipModuleReadModel[];
  crew: CrewSlotReadModel[];
  problems: string[];
  history: string | null;
  notes: string | null;
  createdAt: string; // ISO-8601
  updatedAt: string; // ISO-8601
}

export type ShipModuleSlot =
  | 'BRIDGE'
  | 'REACTOR'
  | 'DRIVE'
  | 'HOLD'
  | 'WEAPON'
  | 'TORPEDO'
  | 'SENSOR'
  | 'COMMS'
  | 'HANGAR'
  | 'QUARTERS'
  | 'MEDICAL'
  | 'WORKSHOP'
  | 'CHAPEL'
  | 'ESCAPE-PODS'
  | 'CRYO'
  | 'DOCKING'
  | 'MINING'
  | 'REPAIR'
  | 'CONCEALED-HOLD'
  | 'PROXY-DECK'
  | 'OTHER';

export type ShipWeaponRange = 'zero' | 'close' | 'medium' | 'long' | 'extreme';

export interface ShipModuleCreateData {
  slot: ShipModuleSlot;
  name: string;
  energyUse: number;
  notes?: string | null;
  data: Record<string, unknown>;
}

export interface ShipModuleUpdateData {
  name?: string;
  energyUse?: number;
  notes?: string | null;
  data?: Record<string, unknown>;
}

export interface ShipListOptions {
  ownerId: string;
  limit: number;
  cursor?: string;
}

export const SHIP_REPO = Symbol('SHIP_REPO');

export interface IShipRepo {
  findById(id: string): Promise<ShipReadModel | null>;

  list(opts: ShipListOptions): Promise<{ items: ShipReadModel[]; nextCursor: string | null }>;

  create(data: {
    ownerId: string;
    name: string;
    class: ShipClass;
    model?: string | null;
    registry?: string | null;
    hullCurrent: number;
    hullMax: number;
    energyCurrent: number;
    energyMax: number;
    armor: number;
    maneuverability: number;
    signature: number;
    speed: number;
    cargoCapacity: number;
    notes?: string | null;
    history?: string | null;
  }): Promise<ShipReadModel>;

  update(
    id: string,
    data: Partial<{
      name: string;
      model: string | null;
      registry: string | null;
      hullCurrent: number;
      hullMax: number;
      energyCurrent: number;
      energyMax: number;
      armor: number;
      maneuverability: number;
      signature: number;
      speed: number;
      problems: string[];
      history: string | null;
      notes: string | null;
    }>,
  ): Promise<ShipReadModel>;

  delete(id: string): Promise<void>;

  findModuleById(moduleId: string): Promise<(ShipModuleReadModel & { shipId: string }) | null>;

  addModule(shipId: string, data: ShipModuleCreateData): Promise<ShipModuleReadModel>;

  updateModule(moduleId: string, data: ShipModuleUpdateData): Promise<ShipModuleReadModel>;

  deleteModule(moduleId: string): Promise<void>;
}

/**
 * WHY this file exists:
 * Handles UpdateShipModuleCommand: resolves ownership via parent ship,
 * guards slot immutability, merges data, persists via IShipRepo.
 */
import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { validateModuleUpdate } from '../domain/ship-module-validation';
import { ShipModuleNotFoundError, ShipModuleNotOwnedError } from '../domain/ship.errors';
import { SHIP_REPO } from '../domain/ship.ports';

import { UpdateShipModuleCommand } from './update-ship-module.command';

import type { ShipModuleReadModel, IShipRepo, ShipModuleSlot } from '../domain/ship.ports';

@CommandHandler(UpdateShipModuleCommand)
export class UpdateShipModuleHandler implements ICommandHandler<
  UpdateShipModuleCommand,
  ShipModuleReadModel
> {
  constructor(@Inject(SHIP_REPO) private readonly repo: IShipRepo) {}

  async execute(command: UpdateShipModuleCommand): Promise<ShipModuleReadModel> {
    const { moduleId, ownerId, dto } = command;

    const module = await this.repo.findModuleById(moduleId);
    if (!module) throw new ShipModuleNotFoundError(moduleId);

    // Ownership check: look up the parent ship
    const ship = await this.repo.findById(module.shipId);
    if (ship?.ownerId !== ownerId) throw new ShipModuleNotOwnedError(moduleId);

    // validateModuleUpdate throws ShipModuleTypeMismatchError if slot changed or foreign fields present

    const validated = validateModuleUpdate(dto, module.slot as ShipModuleSlot);

    // Merge existing data with the validated partial override
    const mergedData = { ...module.data, ...validated.data };

    const patch: import('../domain/ship.ports').ShipModuleUpdateData = {
      ...(validated.name !== undefined && { name: validated.name }),
      ...(validated.energyUse !== undefined && { energyUse: validated.energyUse }),
      ...('notes' in validated && { notes: validated.notes }),
      data: mergedData,
    };

    return this.repo.updateModule(moduleId, patch);
  }
}

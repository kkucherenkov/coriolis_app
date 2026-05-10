/**
 * WHY this file exists:
 * Handles AddShipModuleCommand: validates ownership, validates the slot discriminator,
 * and persists the new module. No Prisma here — only the IShipRepo port.
 */
import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { validateModuleCreate } from '../domain/ship-module-validation';
import { ShipNotFoundError, ShipNotOwnerError } from '../domain/ship.errors';
import { SHIP_REPO } from '../domain/ship.ports';

import { AddShipModuleCommand } from './add-ship-module.command';

import type { ShipModuleReadModel, IShipRepo } from '../domain/ship.ports';

@CommandHandler(AddShipModuleCommand)
export class AddShipModuleHandler implements ICommandHandler<
  AddShipModuleCommand,
  ShipModuleReadModel
> {
  constructor(@Inject(SHIP_REPO) private readonly repo: IShipRepo) {}

  async execute(command: AddShipModuleCommand): Promise<ShipModuleReadModel> {
    const { shipId, ownerId, dto } = command;

    const ship = await this.repo.findById(shipId);
    if (!ship) throw new ShipNotFoundError(shipId);
    if (ship.ownerId !== ownerId) throw new ShipNotOwnerError(shipId);

    // validateModuleCreate throws ShipModuleSlotInvalidError or ShipModuleTypeMismatchError
    const validated = validateModuleCreate(dto);

    return this.repo.addModule(shipId, {
      slot: validated.slot,
      name: validated.name,
      energyUse: validated.energyUse,
      notes: validated.notes,
      data: validated.data,
    });
  }
}

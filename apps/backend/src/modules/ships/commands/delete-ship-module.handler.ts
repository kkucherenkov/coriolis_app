/**
 * WHY this file exists:
 * Handles DeleteShipModuleCommand: checks ownership, guards mandatory slots,
 * then hard-deletes the module via IShipRepo.
 */
import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import {
  ShipModuleMandatoryError,
  ShipModuleNotFoundError,
  ShipModuleNotOwnedError,
} from '../domain/ship.errors';
import { SHIP_REPO } from '../domain/ship.ports';

import { DeleteShipModuleCommand } from './delete-ship-module.command';

import type { IShipRepo, ShipModuleSlot } from '../domain/ship.ports';

const MANDATORY_SLOTS = new Set<ShipModuleSlot>(['BRIDGE', 'REACTOR', 'DRIVE']);

@CommandHandler(DeleteShipModuleCommand)
export class DeleteShipModuleHandler implements ICommandHandler<DeleteShipModuleCommand, void> {
  constructor(@Inject(SHIP_REPO) private readonly repo: IShipRepo) {}

  async execute(command: DeleteShipModuleCommand): Promise<void> {
    const { moduleId, ownerId } = command;

    const module = await this.repo.findModuleById(moduleId);
    if (!module) throw new ShipModuleNotFoundError(moduleId);

    const ship = await this.repo.findById(module.shipId);
    if (ship?.ownerId !== ownerId) throw new ShipModuleNotOwnedError(moduleId);

    if (MANDATORY_SLOTS.has(module.slot as ShipModuleSlot)) { // cast needed: slot is string in read model
      throw new ShipModuleMandatoryError(module.slot);
    }

    await this.repo.deleteModule(moduleId);
  }
}

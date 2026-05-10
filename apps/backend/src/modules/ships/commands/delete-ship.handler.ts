import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { ShipNotFoundError, ShipNotOwnerError } from '../domain/ship.errors';
import { SHIP_REPO } from '../domain/ship.ports';

import { DeleteShipCommand } from './delete-ship.command';

import type { IShipRepo } from '../domain/ship.ports';

@CommandHandler(DeleteShipCommand)
export class DeleteShipHandler implements ICommandHandler<DeleteShipCommand, void> {
  constructor(@Inject(SHIP_REPO) private readonly repo: IShipRepo) {}

  async execute(command: DeleteShipCommand): Promise<void> {
    const { id, ownerId } = command;

    const ship = await this.repo.findById(id);
    if (!ship) throw new ShipNotFoundError(id);
    if (ship.ownerId !== ownerId) throw new ShipNotOwnerError(id);

    await this.repo.delete(id);
  }
}

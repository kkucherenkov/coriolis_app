import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { ShipNameEmptyError, ShipNameTooLongError, ShipNotFoundError, ShipNotOwnerError } from '../domain/ship.errors';
import { SHIP_REPO, ShipReadModel } from '../domain/ship.ports';

import { UpdateShipCommand } from './update-ship.command';

import type { IShipRepo } from '../domain/ship.ports';

@CommandHandler(UpdateShipCommand)
export class UpdateShipHandler implements ICommandHandler<UpdateShipCommand, ShipReadModel> {
  constructor(@Inject(SHIP_REPO) private readonly repo: IShipRepo) {}

  async execute(command: UpdateShipCommand): Promise<ShipReadModel> {
    const { id, ownerId, dto } = command;

    const ship = await this.repo.findById(id);
    if (!ship) throw new ShipNotFoundError(id);
    if (ship.ownerId !== ownerId) throw new ShipNotOwnerError(id);

    if (dto.name !== undefined) {
      if (dto.name.trim() === '') throw new ShipNameEmptyError();
      if (dto.name.length > 80) throw new ShipNameTooLongError();
    }

    const patch: Parameters<IShipRepo['update']>[1] = {};
    if (dto.name !== undefined) patch.name = dto.name.trim();
    if ('model' in dto) patch.model = dto.model ?? null;
    if ('registry' in dto) patch.registry = dto.registry ?? null;
    if (dto.hull?.current !== undefined) patch.hullCurrent = dto.hull.current;
    if (dto.hull?.max !== undefined) patch.hullMax = dto.hull.max;
    if (dto.energy?.current !== undefined) patch.energyCurrent = dto.energy.current;
    if (dto.energy?.max !== undefined) patch.energyMax = dto.energy.max;
    if (dto.armor !== undefined) patch.armor = dto.armor;
    if (dto.maneuverability !== undefined) patch.maneuverability = dto.maneuverability;
    if (dto.signature !== undefined) patch.signature = dto.signature;
    if (dto.speed !== undefined) patch.speed = dto.speed;
    if ('problems' in dto) patch.problems = dto.problems;
    if ('history' in dto) patch.history = dto.history ?? null;
    if ('notes' in dto) patch.notes = dto.notes ?? null;

    return this.repo.update(id, patch);
  }
}

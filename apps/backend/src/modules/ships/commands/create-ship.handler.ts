import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { BASE_STATS_BY_CLASS } from '../../rules-engine/ship-class-table';
import { ShipNameEmptyError, ShipNameTooLongError } from '../domain/ship.errors';
import { SHIP_REPO, ShipReadModel } from '../domain/ship.ports';

import { CreateShipCommand } from './create-ship.command';

import type { IShipRepo } from '../domain/ship.ports';

@CommandHandler(CreateShipCommand)
export class CreateShipHandler implements ICommandHandler<CreateShipCommand, ShipReadModel> {
  constructor(@Inject(SHIP_REPO) private readonly repo: IShipRepo) {}

  async execute(command: CreateShipCommand): Promise<ShipReadModel> {
    const { ownerId, dto } = command;

    // Defence-in-depth — DTO is already validated by ValidationPipe
    if (!dto.name || dto.name.trim() === '') throw new ShipNameEmptyError();
    if (dto.name.length > 80) throw new ShipNameTooLongError();

    const base = BASE_STATS_BY_CLASS[dto.class];

    return this.repo.create({
      ownerId,
      name: dto.name.trim(),
      class: dto.class,
      model: dto.model ?? null,
      registry: dto.registry ?? null,
      hullMax: dto.hull?.max ?? base.hullMax,
      hullCurrent: dto.hull?.current ?? dto.hull?.max ?? base.hullMax,
      energyMax: dto.energy?.max ?? base.energyMax,
      energyCurrent: dto.energy?.current ?? dto.energy?.max ?? base.energyMax,
      armor: dto.armor ?? base.armor,
      maneuverability: dto.maneuverability ?? base.maneuverability,
      signature: dto.signature ?? base.signature,
      speed: dto.speed ?? base.speed,
      cargoCapacity: base.cargoCapacity,
      notes: dto.notes ?? null,
      history: dto.history ?? null,
    });
  }
}

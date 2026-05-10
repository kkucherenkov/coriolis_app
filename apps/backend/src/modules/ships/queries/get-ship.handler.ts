import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { ShipNotFoundError, ShipNotOwnerError } from '../domain/ship.errors';
import { SHIP_REPO, ShipReadModel } from '../domain/ship.ports';

import { GetShipQuery } from './get-ship.query';

import type { IShipRepo } from '../domain/ship.ports';

@QueryHandler(GetShipQuery)
export class GetShipHandler implements IQueryHandler<GetShipQuery, ShipReadModel> {
  constructor(@Inject(SHIP_REPO) private readonly repo: IShipRepo) {}

  async execute(query: GetShipQuery): Promise<ShipReadModel> {
    const { id, ownerId } = query;

    const ship = await this.repo.findById(id);
    if (!ship) throw new ShipNotFoundError(id);
    if (ship.ownerId !== ownerId) throw new ShipNotOwnerError(id);

    return ship;
  }
}

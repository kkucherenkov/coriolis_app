import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { SHIP_REPO, ShipReadModel } from '../domain/ship.ports';

import { ListShipsQuery } from './list-ships.query';

import type { IShipRepo } from '../domain/ship.ports';

export interface ShipListResult {
  items: ShipReadModel[];
  nextCursor: string | null;
}

@QueryHandler(ListShipsQuery)
export class ListShipsHandler implements IQueryHandler<ListShipsQuery, ShipListResult> {
  constructor(@Inject(SHIP_REPO) private readonly repo: IShipRepo) {}

  async execute(query: ListShipsQuery): Promise<ShipListResult> {
    const opts: Parameters<IShipRepo['list']>[0] = {
      ownerId: query.ownerId,
      limit: query.limit,
    };
    if (query.cursor !== undefined) opts.cursor = query.cursor;
    return this.repo.list(opts);
  }
}

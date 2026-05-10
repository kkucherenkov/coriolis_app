/**
 * STUB — Block 5 fills in the real export logic.
 * Returns 501 NOT_IMPLEMENTED so the controller surface is complete and
 * frontends can render the affordance behind a feature flag.
 */
import { QueryHandler, IQueryHandler } from '@nestjs/cqrs';

import { ShipNotImplementedError } from '../domain/ship.errors';

import { GetShipExportQuery } from './get-ship-export.query';

@QueryHandler(GetShipExportQuery)
export class GetShipExportHandler implements IQueryHandler<GetShipExportQuery, never> {
  // eslint-disable-next-line @typescript-eslint/require-await -- stub: always throws 501 until Block 5
  async execute(_query: GetShipExportQuery): Promise<never> {
    throw new ShipNotImplementedError('getShipExport');
  }
}

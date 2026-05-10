/**
 * STUB — Block 5 fills in the real deep-copy logic.
 * Returns 501 NOT_IMPLEMENTED for now so the controller surface is complete
 * and frontends can render the affordance behind a feature flag.
 */
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { ShipNotImplementedError } from '../domain/ship.errors';

import { DuplicateShipCommand } from './duplicate-ship.command';

import type { ShipReadModel } from '../domain/ship.ports';

@CommandHandler(DuplicateShipCommand)
export class DuplicateShipHandler implements ICommandHandler<DuplicateShipCommand, ShipReadModel> {
  // eslint-disable-next-line @typescript-eslint/require-await -- stub: always throws 501 until Block 5
  async execute(_command: DuplicateShipCommand): Promise<ShipReadModel> {
    throw new ShipNotImplementedError('duplicateShip');
  }
}

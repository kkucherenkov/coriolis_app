/**
 * WHY this file exists:
 * Handles UnassignCrewCommand:
 *   1. Verify ship exists and is owned by caller (404 / 403).
 *   2. Clear the character's slot — idempotent, no error if not assigned.
 *
 * No Prisma here — only IShipRepo port.
 */
import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { ShipNotFoundError, ShipNotOwnerError } from '../domain/ship.errors';
import { SHIP_REPO } from '../domain/ship.ports';

import { UnassignCrewCommand } from './unassign-crew.command';

import type { IShipRepo } from '../domain/ship.ports';

@CommandHandler(UnassignCrewCommand)
export class UnassignCrewHandler implements ICommandHandler<UnassignCrewCommand, void> {
  constructor(@Inject(SHIP_REPO) private readonly repo: IShipRepo) {}

  async execute(command: UnassignCrewCommand): Promise<void> {
    const { shipId, ownerId, characterId } = command;

    const ship = await this.repo.findById(shipId);
    if (!ship) throw new ShipNotFoundError(shipId);
    if (ship.ownerId !== ownerId) throw new ShipNotOwnerError(shipId);

    // Idempotent — no error if character not assigned
    await this.repo.unassignCrewSlot(shipId, characterId);
  }
}

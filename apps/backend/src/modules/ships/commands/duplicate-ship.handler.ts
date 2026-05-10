import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { ShipNotFoundError, ShipNotOwnerError } from '../domain/ship.errors';
import { SHIP_REPO } from '../domain/ship.ports';

import { DuplicateShipCommand } from './duplicate-ship.command';

import type { IShipRepo, ShipReadModel } from '../domain/ship.ports';

/**
 * Resolve the copy-suffix name for the new ship.
 *
 * Rules:
 *  - First copy → "<name> (copy)"
 *  - If that is already taken → "<name> (copy 2)", "(copy 3)", …
 *
 * existingNames is the set of names already owned by the caller that start
 * with "<name> (copy".
 */
function resolveCopyName(baseName: string, existingNames: Set<string>): string {
  const first = `${baseName} (copy)`;
  if (!existingNames.has(first)) return first;

  let n = 2;
  while (existingNames.has(`${baseName} (copy ${String(n)})`)) {
    n++;
  }
  return `${baseName} (copy ${String(n)})`;
}

@CommandHandler(DuplicateShipCommand)
export class DuplicateShipHandler implements ICommandHandler<DuplicateShipCommand, ShipReadModel> {
  constructor(@Inject(SHIP_REPO) private readonly repo: IShipRepo) {}

  async execute(command: DuplicateShipCommand): Promise<ShipReadModel> {
    const { id, ownerId } = command;

    const source = await this.repo.findById(id);
    if (!source) throw new ShipNotFoundError(id);
    if (source.ownerId !== ownerId) throw new ShipNotOwnerError(id);

    const prefix = `${source.name} (copy`;
    const takenNames = await this.repo.listNamesByPrefix(ownerId, prefix);
    const newName = resolveCopyName(source.name, new Set(takenNames));

    return this.repo.duplicate(id, ownerId, newName);
  }
}

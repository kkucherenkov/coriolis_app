import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { NpcNotFoundError, NpcNotOwnerError } from '../domain/npc.errors';
import { NPC_REPO } from '../domain/npc.ports';

import { DuplicateNpcCommand } from './duplicate-npc.command';

import type { INpcRepo, NpcReadModel } from '../domain/npc.ports';

/**
 * Resolve the copy-suffix name for the new NPC.
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

@CommandHandler(DuplicateNpcCommand)
export class DuplicateNpcHandler implements ICommandHandler<DuplicateNpcCommand, NpcReadModel> {
  constructor(@Inject(NPC_REPO) private readonly repo: INpcRepo) {}

  async execute(command: DuplicateNpcCommand): Promise<NpcReadModel> {
    const { id, ownerId } = command;

    const source = await this.repo.findById(id);
    if (!source) throw new NpcNotFoundError(id);
    if (source.ownerId !== ownerId) throw new NpcNotOwnerError(id);

    const prefix = `${source.name} (copy`;
    const takenNames = await this.repo.listNamesByPrefix(ownerId, prefix);
    const newName = resolveCopyName(source.name, new Set(takenNames));

    return this.repo.duplicate(id, ownerId, newName);
  }
}

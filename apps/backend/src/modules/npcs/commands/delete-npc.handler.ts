import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { NpcNotFoundError, NpcNotOwnerError } from '../domain/npc.errors';
import { NPC_REPO } from '../domain/npc.ports';

import { DeleteNpcCommand } from './delete-npc.command';

import type { INpcRepo } from '../domain/npc.ports';

@CommandHandler(DeleteNpcCommand)
export class DeleteNpcHandler implements ICommandHandler<DeleteNpcCommand, void> {
  constructor(@Inject(NPC_REPO) private readonly repo: INpcRepo) {}

  async execute(command: DeleteNpcCommand): Promise<void> {
    const { id, ownerId } = command;

    const npc = await this.repo.findById(id);
    if (!npc) throw new NpcNotFoundError(id);
    if (npc.ownerId !== ownerId) throw new NpcNotOwnerError(id);

    await this.repo.delete(id);
  }
}

import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { NpcNotFoundError, NpcNotOwnerError } from '../domain/npc.errors';
import { NPC_REPO } from '../domain/npc.ports';

import { GetNpcQuery } from './get-npc.query';

import type { INpcRepo, NpcReadModel } from '../domain/npc.ports';

@QueryHandler(GetNpcQuery)
export class GetNpcHandler implements IQueryHandler<GetNpcQuery, NpcReadModel> {
  constructor(@Inject(NPC_REPO) private readonly repo: INpcRepo) {}

  async execute(query: GetNpcQuery): Promise<NpcReadModel> {
    const { id, ownerId } = query;

    const npc = await this.repo.findById(id);
    if (!npc) throw new NpcNotFoundError(id);
    if (npc.ownerId !== ownerId) throw new NpcNotOwnerError(id);

    return npc;
  }
}

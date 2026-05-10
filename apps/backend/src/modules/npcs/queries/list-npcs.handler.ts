import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { NPC_REPO } from '../domain/npc.ports';

import { ListNpcsQuery } from './list-npcs.query';

import type { INpcRepo, NpcReadModel } from '../domain/npc.ports';

export interface NpcListResult {
  items: NpcReadModel[];
  nextCursor: string | null;
}

@QueryHandler(ListNpcsQuery)
export class ListNpcsHandler implements IQueryHandler<ListNpcsQuery, NpcListResult> {
  constructor(@Inject(NPC_REPO) private readonly repo: INpcRepo) {}

  async execute(query: ListNpcsQuery): Promise<NpcListResult> {
    const opts: Parameters<INpcRepo['list']>[0] = {
      ownerId: query.ownerId,
      limit: query.limit,
    };
    if (query.cursor !== undefined) opts.cursor = query.cursor;
    return this.repo.list(opts);
  }
}

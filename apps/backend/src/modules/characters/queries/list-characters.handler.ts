import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { CHARACTER_REPO, CharacterListItem } from '../domain/character.ports';

import { ListCharactersQuery } from './list-characters.query';

import type { ICharacterRepo } from '../domain/character.ports';

export interface CharacterListResult {
  items: CharacterListItem[];
  nextCursor: string | null;
}

@QueryHandler(ListCharactersQuery)
export class ListCharactersHandler implements IQueryHandler<
  ListCharactersQuery,
  CharacterListResult
> {
  constructor(@Inject(CHARACTER_REPO) private readonly repo: ICharacterRepo) {}

  async execute(query: ListCharactersQuery): Promise<CharacterListResult> {
    const opts: Parameters<ICharacterRepo['list']>[0] = {
      ownerId: query.ownerId,
      limit: query.limit,
      includeDrafts: query.includeDrafts,
    };
    if (query.cursor !== undefined) {
      opts.cursor = query.cursor;
    }
    return this.repo.list(opts);
  }
}

import { beforeEach, describe, expect, it, vi } from 'vitest';
import { QueryBus } from '@nestjs/cqrs';

import { UserNotFoundError } from '../domain/user.errors';
import { ExportMeQuery } from './export-me.query';
import { ExportMeHandler } from './export-me.handler';

import type { IExportRepo, MeExportUserDto } from '../domain/user.ports';

function makeRepo(): IExportRepo {
  return { loadUserFor: vi.fn() };
}

function makeQueryBus(): QueryBus {
  return { execute: vi.fn() } as unknown as QueryBus;
}

const EMPTY_LIST = { items: [], nextCursor: null };

describe('ExportMeHandler', () => {
  let repo: IExportRepo;
  let queryBus: QueryBus;
  let handler: ExportMeHandler;

  beforeEach(() => {
    repo = makeRepo();
    queryBus = makeQueryBus();
    handler = new ExportMeHandler(repo, queryBus);
  });

  it('returns an envelope with $schemaVersion "1" for an empty account', async () => {
    const user: MeExportUserDto = { id: 'user-1', displayName: null };
    vi.mocked(repo.loadUserFor).mockResolvedValue(user);
    vi.mocked(queryBus.execute).mockResolvedValue(EMPTY_LIST);

    const result = await handler.execute(new ExportMeQuery('user-1'));

    expect(result.$schemaVersion).toBe('1');
    expect(result.user).toEqual(user);
    expect(result.characters).toEqual([]);
    expect(result.ships).toEqual([]);
    expect(result.npcs).toEqual([]);
    expect(result.gameSessions).toEqual([]);
    expect(typeof result.exportedAt).toBe('string');
  });

  it('throws UserNotFoundError when repo.loadUserFor returns null', async () => {
    vi.mocked(repo.loadUserFor).mockResolvedValue(null);

    await expect(handler.execute(new ExportMeQuery('ghost-user'))).rejects.toThrow(
      UserNotFoundError,
    );
    // QueryBus should never be called if the user is not found
    expect(queryBus.execute).not.toHaveBeenCalled();
  });

  it('inlines encounters and combatants into gameSessions', async () => {
    const user: MeExportUserDto = { id: 'user-2', displayName: 'Al-Rashid' };
    vi.mocked(repo.loadUserFor).mockResolvedValue(user);

    const session = { id: 'sess-1', name: 'Session One' };
    const encounter = { id: 'enc-1', name: 'Encounter One' };
    const combatant = { id: 'cbt-1', name: 'Combatant One' };

    vi.mocked(queryBus.execute).mockImplementation((q: { constructor: { name: string } }) => {
      const name = q.constructor.name;
      if (name === 'ListCharactersQuery') return Promise.resolve(EMPTY_LIST);
      if (name === 'ListShipsQuery') return Promise.resolve(EMPTY_LIST);
      if (name === 'ListNpcsQuery') return Promise.resolve(EMPTY_LIST);
      if (name === 'ListGameSessionsQuery')
        return Promise.resolve({ items: [session], nextCursor: null });
      if (name === 'ListEncountersQuery')
        return Promise.resolve({ items: [encounter], nextCursor: null });
      if (name === 'ListCombatantsQuery') return Promise.resolve({ items: [combatant] });
      return Promise.resolve(EMPTY_LIST);
    });

    const result = await handler.execute(new ExportMeQuery('user-2'));

    expect(result.gameSessions).toHaveLength(1);
    const resultSession = result.gameSessions[0] as typeof session & { encounters: unknown[] };
    expect(resultSession.id).toBe('sess-1');
    expect(resultSession.encounters).toHaveLength(1);
    const resultEncounter = resultSession.encounters[0] as typeof encounter & {
      combatants: unknown[];
    };
    expect(resultEncounter.id).toBe('enc-1');
    expect(resultEncounter.combatants).toEqual([combatant]);
  });
});

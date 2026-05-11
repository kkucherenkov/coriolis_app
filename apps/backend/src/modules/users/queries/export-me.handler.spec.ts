import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ExportMeQuery } from './export-me.query';
import { ExportMeHandler } from './export-me.handler';

import type { IExportRepo, MeExportBundle } from '../domain/user.ports';

function makeRepo(): IExportRepo {
  return { loadBundleFor: vi.fn() };
}

function makeBundle(overrides: Partial<MeExportBundle> = {}): MeExportBundle {
  return {
    $schemaVersion: '1',
    exportedAt: '2026-05-11T12:00:00.000Z',
    user: { id: 'user-1', displayName: 'Kalim', locale: 'ru' },
    characters: [],
    ships: [],
    npcs: [],
    gameSessions: [],
    ...overrides,
  };
}

describe('ExportMeHandler', () => {
  let repo: IExportRepo;
  let handler: ExportMeHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new ExportMeHandler(repo);
  });

  it('delegates to the repo and returns the bundle as-is', async () => {
    const bundle = makeBundle({ user: { id: 'user-1', displayName: null, locale: 'en' } });
    vi.mocked(repo.loadBundleFor).mockResolvedValue(bundle);

    const result = await handler.execute(new ExportMeQuery('user-1'));

    expect(result).toBe(bundle);
    expect(repo.loadBundleFor).toHaveBeenCalledWith('user-1');
  });

  it('returns an envelope with $schemaVersion "1" for a known-empty account', async () => {
    vi.mocked(repo.loadBundleFor).mockResolvedValue(makeBundle());

    const result = await handler.execute(new ExportMeQuery('empty-user'));

    expect(result.$schemaVersion).toBe('1');
    expect(result.characters).toEqual([]);
    expect(result.ships).toEqual([]);
    expect(result.npcs).toEqual([]);
    expect(result.gameSessions).toEqual([]);
  });

  it('passes the exact userId through to the repo without massaging', async () => {
    vi.mocked(repo.loadBundleFor).mockResolvedValue(makeBundle());

    await handler.execute(new ExportMeQuery('weird id with spaces and 🦊'));

    expect(repo.loadBundleFor).toHaveBeenCalledWith('weird id with spaces and 🦊');
  });
});

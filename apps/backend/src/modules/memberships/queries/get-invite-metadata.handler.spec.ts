import { beforeEach, describe, expect, it, vi } from 'vitest';

import { GameSessionNotOwnerError } from '../../game-sessions/domain/game-session.errors';

import { GetInviteMetadataQuery } from './get-invite-metadata.query';
import { GetInviteMetadataHandler } from './get-invite-metadata.handler';

import type { IGameSessionInviteRepo } from '../domain/membership.ports';

function makeRepo(): IGameSessionInviteRepo {
  return { assertOwner: vi.fn(), getMetadata: vi.fn(), rotate: vi.fn(), revoke: vi.fn() };
}

describe('GetInviteMetadataHandler', () => {
  let repo: IGameSessionInviteRepo;
  let handler: GetInviteMetadataHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new GetInviteMetadataHandler(repo);
  });

  it('returns inactive when no invite', async () => {
    vi.mocked(repo.getMetadata).mockResolvedValue({ active: false, rotatedAt: null });
    const result = await handler.execute(new GetInviteMetadataQuery('gs-1', 'user-1'));
    expect(result).toEqual({ active: false, rotatedAt: null });
  });

  it('returns active with rotatedAt when there is an invite', async () => {
    vi.mocked(repo.getMetadata).mockResolvedValue({
      active: true,
      rotatedAt: '2026-05-15T10:00:00.000Z',
    });
    const result = await handler.execute(new GetInviteMetadataQuery('gs-1', 'user-1'));
    expect(result.active).toBe(true);
    expect(result.rotatedAt).toBe('2026-05-15T10:00:00.000Z');
  });

  it('refuses non-owner', async () => {
    vi.mocked(repo.assertOwner).mockRejectedValue(new GameSessionNotOwnerError('gs-1'));
    await expect(
      handler.execute(new GetInviteMetadataQuery('gs-1', 'user-X')),
    ).rejects.toBeInstanceOf(GameSessionNotOwnerError);
  });
});

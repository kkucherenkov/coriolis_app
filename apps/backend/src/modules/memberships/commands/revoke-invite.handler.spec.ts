import { beforeEach, describe, expect, it, vi } from 'vitest';

import { GameSessionNotOwnerError } from '../../game-sessions/domain/game-session.errors';

import { RevokeInviteCommand } from './revoke-invite.command';
import { RevokeInviteHandler } from './revoke-invite.handler';

import type { IGameSessionInviteRepo } from '../domain/membership.ports';

function makeRepo(): IGameSessionInviteRepo {
  return {
    assertOwner: vi.fn(),
    getMetadata: vi.fn(),
    rotate: vi.fn(),
    revoke: vi.fn(),
    findSessionByTokenHash: vi.fn(),
  };
}

describe('RevokeInviteHandler', () => {
  let repo: IGameSessionInviteRepo;
  let handler: RevokeInviteHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new RevokeInviteHandler(repo);
  });

  it('asserts owner before revoking', async () => {
    await handler.execute(new RevokeInviteCommand('gs-1', 'user-1'));
    expect(repo.assertOwner).toHaveBeenCalledWith('gs-1', 'user-1');
    expect(repo.revoke).toHaveBeenCalledWith('gs-1');
  });

  it('is idempotent (does not throw on a session with no active invite)', async () => {
    vi.mocked(repo.revoke).mockResolvedValue(undefined);
    await expect(
      handler.execute(new RevokeInviteCommand('gs-1', 'user-1')),
    ).resolves.toBeUndefined();
  });

  it('refuses non-owner', async () => {
    vi.mocked(repo.assertOwner).mockRejectedValue(new GameSessionNotOwnerError('gs-1'));
    await expect(handler.execute(new RevokeInviteCommand('gs-1', 'user-X'))).rejects.toBeInstanceOf(
      GameSessionNotOwnerError,
    );
    expect(repo.revoke).not.toHaveBeenCalled();
  });
});

import { beforeEach, describe, expect, it, vi } from 'vitest';

import { GameSessionNotOwnerError } from '../../game-sessions/domain/game-session.errors';

import { RotateInviteCommand } from './rotate-invite.command';
import { RotateInviteHandler } from './rotate-invite.handler';

import type { AppConfig } from '../../../common/config/app-config';
import type { IGameSessionInviteRepo } from '../domain/membership.ports';

function makeRepo(): IGameSessionInviteRepo {
  return {
    assertOwner: vi.fn(),
    getMetadata: vi.fn(),
    rotate: vi.fn(),
    revoke: vi.fn(),
  };
}

function makeConfig(): Pick<AppConfig, 'webHost'> {
  return { webHost: 'https://app.example.com' };
}

describe('RotateInviteHandler', () => {
  let repo: IGameSessionInviteRepo;
  let handler: RotateInviteHandler;
  let generator: () => string;
  let hasher: (plaintext: string) => string;

  beforeEach(() => {
    repo = makeRepo();
    generator = vi.fn().mockReturnValue('Sl9X3kQpZr8mVtNuY7Hb2C');
    hasher = vi.fn().mockReturnValue('0'.repeat(64));
    handler = new RotateInviteHandler(repo, makeConfig() as AppConfig, generator, hasher);
  });

  it('asserts owner before rotating', async () => {
    vi.mocked(repo.rotate).mockResolvedValue({ rotatedAt: '2026-05-15T10:00:00.000Z' });

    await handler.execute(new RotateInviteCommand('gs-1', 'user-1'));

    expect(repo.assertOwner).toHaveBeenCalledWith('gs-1', 'user-1');
    expect(repo.assertOwner).toHaveBeenCalledBefore(vi.mocked(repo.rotate));
  });

  it('propagates GameSessionNotOwnerError when caller is not owner', async () => {
    vi.mocked(repo.assertOwner).mockRejectedValue(new GameSessionNotOwnerError('gs-1'));

    await expect(handler.execute(new RotateInviteCommand('gs-1', 'user-X'))).rejects.toBeInstanceOf(
      GameSessionNotOwnerError,
    );
    expect(repo.rotate).not.toHaveBeenCalled();
  });

  it('returns the plaintext token + absolute URL exactly once', async () => {
    vi.mocked(repo.rotate).mockResolvedValue({ rotatedAt: '2026-05-15T10:00:00.000Z' });

    const result = await handler.execute(new RotateInviteCommand('gs-1', 'user-1'));

    expect(result).toEqual({
      token: 'Sl9X3kQpZr8mVtNuY7Hb2C',
      url: 'https://app.example.com/app/sessions/join/Sl9X3kQpZr8mVtNuY7Hb2C',
      rotatedAt: '2026-05-15T10:00:00.000Z',
    });
  });

  it('passes the hashed token (not plaintext) to the repo', async () => {
    vi.mocked(repo.rotate).mockResolvedValue({ rotatedAt: '2026-05-15T10:00:00.000Z' });

    await handler.execute(new RotateInviteCommand('gs-1', 'user-1'));

    expect(repo.rotate).toHaveBeenCalledWith('gs-1', '0'.repeat(64), 'user-1');
    expect(hasher).toHaveBeenCalledWith('Sl9X3kQpZr8mVtNuY7Hb2C');
  });
});

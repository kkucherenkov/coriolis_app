import { describe, it, expect, vi, beforeEach } from 'vitest';

import { ShareLinkNotFoundError, ShareLinkNotOwnedError } from '../domain/share-link.errors';

import { RevokeShareLinkCommand } from './revoke-share-link.command';
import { RevokeShareLinkHandler } from './revoke-share-link.handler';

import type { IShareLinkRepo } from '../domain/share-link.ports';

function makeHandler(): { handler: RevokeShareLinkHandler; repo: IShareLinkRepo } {
  const repo = {
    create: vi.fn(),
    findBySlug: vi.fn(),
    findById: vi.fn(),
    findOwnerIdByShareLinkId: vi.fn(),
    listByCharacterId: vi.fn(),
    revoke: vi.fn(),
    findCharacterBySlug: vi.fn(),
    flushViewCounts: vi.fn(),
  } as unknown as IShareLinkRepo;

  const handler = new RevokeShareLinkHandler(repo);
  return { handler, repo };
}

describe('RevokeShareLinkHandler', () => {
  let handler: RevokeShareLinkHandler;
  let repo: IShareLinkRepo;

  beforeEach(() => {
    ({ handler, repo } = makeHandler());
  });

  it('revokes when the caller owns the share link', async () => {
    vi.mocked(repo.findOwnerIdByShareLinkId).mockResolvedValue({ ownerId: 'user_01' });
    vi.mocked(repo.revoke).mockResolvedValue(undefined);

    const command = new RevokeShareLinkCommand('user_01', 'sl_01');
    await handler.execute(command);

    expect(repo.revoke).toHaveBeenCalledWith('sl_01');
  });

  it('throws ShareLinkNotFoundError when link does not exist', async () => {
    vi.mocked(repo.findOwnerIdByShareLinkId).mockResolvedValue(null);

    await expect(handler.execute(new RevokeShareLinkCommand('user_01', 'sl_missing'))).rejects.toBeInstanceOf(
      ShareLinkNotFoundError,
    );
  });

  it('throws ShareLinkNotOwnedError when caller does not own the link', async () => {
    vi.mocked(repo.findOwnerIdByShareLinkId).mockResolvedValue({ ownerId: 'user_other' });

    await expect(handler.execute(new RevokeShareLinkCommand('user_01', 'sl_01'))).rejects.toBeInstanceOf(
      ShareLinkNotOwnedError,
    );
  });
});

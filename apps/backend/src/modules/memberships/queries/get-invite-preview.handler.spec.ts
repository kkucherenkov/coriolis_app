import { beforeEach, describe, expect, it, vi } from 'vitest';

import { InviteNotFoundError } from '../domain/membership.errors';

import { GetInvitePreviewQuery } from './get-invite-preview.query';
import { GetInvitePreviewHandler } from './get-invite-preview.handler';

import type {
  IGameSessionInviteRepo,
  IMembershipRepo,
  InvitePreviewReadModel,
} from '../domain/membership.ports';

const PLAINTEXT = 'Sl9X3kQpZr8mVtNuY7Hb2C';

function makeInviteRepo(): IGameSessionInviteRepo {
  return {
    assertOwner: vi.fn(),
    getMetadata: vi.fn(),
    rotate: vi.fn(),
    revoke: vi.fn(),
    findSessionByTokenHash: vi.fn().mockResolvedValue({
      gameSessionId: 'gs-1',
      sessionName: 'The Mercy of Kua',
      gmUserId: 'gm-user',
    }),
  };
}

function makeMembershipRepo(): IMembershipRepo {
  return {
    listActive: vi.fn(),
    findById: vi.fn(),
    findActiveByUser: vi.fn().mockResolvedValue(null),
    softDelete: vi.fn(),
    setCharacter: vi.fn(),
    insert: vi.fn(),
    findActiveSessionsForUser: vi.fn(),
  };
}

describe('GetInvitePreviewHandler', () => {
  let iRepo: IGameSessionInviteRepo;
  let mRepo: IMembershipRepo;
  let fetchDisplayName: (userId: string) => Promise<string>;
  let handler: GetInvitePreviewHandler;

  beforeEach(() => {
    iRepo = makeInviteRepo();
    mRepo = makeMembershipRepo();
    fetchDisplayName = vi.fn().mockResolvedValue('Kirill GM');
    handler = new GetInvitePreviewHandler(iRepo, mRepo, fetchDisplayName);
  });

  it('throws InviteNotFoundError when token hash has no matching session', async () => {
    vi.mocked(iRepo.findSessionByTokenHash).mockResolvedValue(null);

    await expect(
      handler.execute(new GetInvitePreviewQuery(PLAINTEXT, null)),
    ).rejects.toBeInstanceOf(InviteNotFoundError);
  });

  it('returns preview with alreadyJoined=false for unauthenticated caller', async () => {
    const result = await handler.execute(new GetInvitePreviewQuery(PLAINTEXT, null));

    expect(result).toMatchObject<InvitePreviewReadModel>({
      sessionName: 'The Mercy of Kua',
      gmDisplayName: 'Kirill GM',
      alreadyJoined: false,
    });
    expect(mRepo.findActiveByUser).not.toHaveBeenCalled();
  });

  it('returns alreadyJoined=true when authenticated caller has active membership', async () => {
    vi.mocked(mRepo.findActiveByUser).mockResolvedValue({
      id: 'm-1',
      gameSessionId: 'gs-1',
      userId: 'user-1',
      role: 'player',
      displayName: 'Test',
      characterId: null,
      characterName: null,
      joinedAt: new Date().toISOString(),
      leftAt: null,
    });

    const result = await handler.execute(new GetInvitePreviewQuery(PLAINTEXT, 'user-1'));

    expect(result.alreadyJoined).toBe(true);
    expect(mRepo.findActiveByUser).toHaveBeenCalledWith('gs-1', 'user-1');
  });

  it('returns alreadyJoined=false when authenticated caller has no active membership', async () => {
    vi.mocked(mRepo.findActiveByUser).mockResolvedValue(null);

    const result = await handler.execute(new GetInvitePreviewQuery(PLAINTEXT, 'user-99'));

    expect(result.alreadyJoined).toBe(false);
  });
});

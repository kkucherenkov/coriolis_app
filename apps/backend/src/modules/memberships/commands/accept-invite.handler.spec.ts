import { beforeEach, describe, expect, it, vi } from 'vitest';

import { InviteNotFoundError, CharacterNotOwnedError } from '../domain/membership.errors';
import { hashInviteToken } from '../domain/invite-token';

import { AcceptInviteCommand } from './accept-invite.command';
import { AcceptInviteHandler } from './accept-invite.handler';
import { MemberJoinedEvent } from '../events/member-joined.event';

import type { EventBus } from '@nestjs/cqrs';
import type {
  IGameSessionInviteRepo,
  IMembershipRepo,
  MembershipReadModel,
} from '../domain/membership.ports';
import type { ICharacterOwnership } from './link-character.handler';

const PLAINTEXT = 'Sl9X3kQpZr8mVtNuY7Hb2C';

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

function makeCharOwnership(): ICharacterOwnership {
  return { isOwnedBy: vi.fn().mockResolvedValue(true) };
}

function makeBus(): EventBus {
  return { publish: vi.fn(), publishAll: vi.fn() } as unknown as EventBus;
}

function makeMembership(overrides: Partial<MembershipReadModel> = {}): MembershipReadModel {
  return {
    id: 'm-new',
    gameSessionId: 'gs-1',
    userId: 'user-1',
    role: 'player',
    displayName: 'Test Player',
    characterId: null,
    characterName: null,
    joinedAt: new Date().toISOString(),
    leftAt: null,
    ...overrides,
  };
}

describe('AcceptInviteHandler', () => {
  let mRepo: IMembershipRepo;
  let iRepo: IGameSessionInviteRepo;
  let charOwnership: ICharacterOwnership;
  let bus: EventBus;
  let handler: AcceptInviteHandler;

  beforeEach(() => {
    mRepo = makeMembershipRepo();
    iRepo = makeInviteRepo();
    charOwnership = makeCharOwnership();
    bus = makeBus();
    handler = new AcceptInviteHandler(mRepo, iRepo, charOwnership, bus);
  });

  it('throws InviteNotFoundError when no session matches the token hash', async () => {
    vi.mocked(iRepo.findSessionByTokenHash).mockResolvedValue(null);

    await expect(
      handler.execute(new AcceptInviteCommand(PLAINTEXT, 'user-1', null)),
    ).rejects.toBeInstanceOf(InviteNotFoundError);

    expect(mRepo.insert).not.toHaveBeenCalled();
  });

  it('throws InviteNotFoundError when stored hash does not match (rotated token)', async () => {
    vi.mocked(iRepo.findSessionByTokenHash).mockResolvedValue(null);

    await expect(
      handler.execute(new AcceptInviteCommand('old-token', 'user-1', null)),
    ).rejects.toBeInstanceOf(InviteNotFoundError);
  });

  it('returns existing membership idempotently when caller is already an active member', async () => {
    const existing = makeMembership({ id: 'm-existing' });
    vi.mocked(mRepo.findActiveByUser).mockResolvedValue(existing);

    const result = await handler.execute(new AcceptInviteCommand(PLAINTEXT, 'user-1', null));

    expect(result).toEqual(existing);
    expect(mRepo.insert).not.toHaveBeenCalled();
    expect(bus.publish).not.toHaveBeenCalled();
  });

  it('throws CharacterNotOwnedError when supplied characterId does not belong to caller', async () => {
    vi.mocked(charOwnership.isOwnedBy).mockResolvedValue(false);

    await expect(
      handler.execute(new AcceptInviteCommand(PLAINTEXT, 'user-1', 'char-other')),
    ).rejects.toBeInstanceOf(CharacterNotOwnedError);

    expect(mRepo.insert).not.toHaveBeenCalled();
  });

  it('inserts membership and publishes MemberJoinedEvent on happy path', async () => {
    const newMembership = makeMembership();
    vi.mocked(mRepo.insert).mockResolvedValue(newMembership);

    const result = await handler.execute(new AcceptInviteCommand(PLAINTEXT, 'user-1', null));

    expect(mRepo.insert).toHaveBeenCalledWith({
      gameSessionId: 'gs-1',
      userId: 'user-1',
      role: 'player',
      characterId: null,
    });
    expect(bus.publish).toHaveBeenCalledWith(
      expect.objectContaining({
        membershipId: 'm-new',
        gameSessionId: 'gs-1',
        userId: 'user-1',
      }),
    );
    expect(result).toEqual(newMembership);
  });

  it('links character at join time when characterId is provided and owned', async () => {
    const newMembership = makeMembership({ characterId: 'char-mine' });
    vi.mocked(charOwnership.isOwnedBy).mockResolvedValue(true);
    vi.mocked(mRepo.insert).mockResolvedValue(newMembership);

    await handler.execute(new AcceptInviteCommand(PLAINTEXT, 'user-1', 'char-mine'));

    expect(charOwnership.isOwnedBy).toHaveBeenCalledWith('char-mine', 'user-1');
    expect(mRepo.insert).toHaveBeenCalledWith(
      expect.objectContaining({ characterId: 'char-mine' }),
    );
  });
});

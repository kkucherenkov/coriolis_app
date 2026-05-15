import { beforeEach, describe, expect, it, vi } from 'vitest';

import { GameSessionNotOwnerError } from '../../game-sessions/domain/game-session.errors';
import { CannotKickGmError, MembershipNotFoundError } from '../domain/membership.errors';

import { KickMemberCommand } from './kick-member.command';
import { KickMemberHandler } from './kick-member.handler';

import type { EventBus } from '@nestjs/cqrs';
import type {
  IGameSessionInviteRepo,
  IMembershipRepo,
  MembershipReadModel,
} from '../domain/membership.ports';

function makeMembershipRepo(): IMembershipRepo {
  return {
    listActive: vi.fn(),
    findById: vi.fn(),
    findActiveByUser: vi.fn(),
    softDelete: vi.fn(),
    setCharacter: vi.fn(),
  };
}

function makeInviteRepo(): IGameSessionInviteRepo {
  return { assertOwner: vi.fn(), getMetadata: vi.fn(), rotate: vi.fn(), revoke: vi.fn() };
}

function makeBus(): EventBus {
  return { publish: vi.fn(), publishAll: vi.fn() } as unknown as EventBus;
}

function makeMember(overrides: Partial<MembershipReadModel> = {}): MembershipReadModel {
  return {
    id: 'm-1',
    gameSessionId: 'gs-1',
    userId: 'user-player',
    role: 'player',
    displayName: 'Yara',
    characterId: null,
    characterName: null,
    joinedAt: '2026-05-15T10:00:00.000Z',
    leftAt: null,
    ...overrides,
  };
}

describe('KickMemberHandler', () => {
  let mRepo: IMembershipRepo;
  let iRepo: IGameSessionInviteRepo;
  let bus: EventBus;
  let handler: KickMemberHandler;

  beforeEach(() => {
    mRepo = makeMembershipRepo();
    iRepo = makeInviteRepo();
    bus = makeBus();
    handler = new KickMemberHandler(mRepo, iRepo, bus);
  });

  it('asserts owner before kicking', async () => {
    vi.mocked(mRepo.findById).mockResolvedValue(makeMember());
    await handler.execute(new KickMemberCommand('gs-1', 'user-gm', 'm-1'));
    expect(iRepo.assertOwner).toHaveBeenCalledWith('gs-1', 'user-gm');
  });

  it('throws MembershipNotFoundError when the membership does not exist', async () => {
    vi.mocked(mRepo.findById).mockResolvedValue(null);
    await expect(
      handler.execute(new KickMemberCommand('gs-1', 'user-gm', 'm-X')),
    ).rejects.toBeInstanceOf(MembershipNotFoundError);
  });

  it('refuses to kick a GM-role membership', async () => {
    vi.mocked(mRepo.findById).mockResolvedValue(makeMember({ role: 'gm' }));
    await expect(
      handler.execute(new KickMemberCommand('gs-1', 'user-gm', 'm-1')),
    ).rejects.toBeInstanceOf(CannotKickGmError);
    expect(mRepo.softDelete).not.toHaveBeenCalled();
  });

  it('refuses cross-session kick (membership belongs to another session)', async () => {
    vi.mocked(mRepo.findById).mockResolvedValue(makeMember({ gameSessionId: 'gs-OTHER' }));
    await expect(
      handler.execute(new KickMemberCommand('gs-1', 'user-gm', 'm-1')),
    ).rejects.toBeInstanceOf(MembershipNotFoundError);
  });

  it('refuses non-owner caller', async () => {
    vi.mocked(iRepo.assertOwner).mockRejectedValue(new GameSessionNotOwnerError('gs-1'));
    await expect(
      handler.execute(new KickMemberCommand('gs-1', 'user-X', 'm-1')),
    ).rejects.toBeInstanceOf(GameSessionNotOwnerError);
  });

  it('soft-deletes and publishes MemberKickedEvent', async () => {
    const member = makeMember();
    vi.mocked(mRepo.findById).mockResolvedValue(member);
    await handler.execute(new KickMemberCommand('gs-1', 'user-gm', 'm-1'));
    expect(mRepo.softDelete).toHaveBeenCalledWith('m-1');
    expect(bus.publish).toHaveBeenCalledWith(
      expect.objectContaining({
        membershipId: 'm-1',
        gameSessionId: 'gs-1',
        userId: 'user-player',
      }),
    );
  });
});

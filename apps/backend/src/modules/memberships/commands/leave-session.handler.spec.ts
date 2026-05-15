import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  CannotKickGmError,
  MembershipNotAuthorizedError,
  MembershipNotFoundError,
} from '../domain/membership.errors';

import { LeaveSessionCommand } from './leave-session.command';
import { LeaveSessionHandler } from './leave-session.handler';

import type { EventBus } from '@nestjs/cqrs';
import type { IMembershipRepo, MembershipReadModel } from '../domain/membership.ports';

function makeRepo(): IMembershipRepo {
  return {
    listActive: vi.fn(),
    findById: vi.fn(),
    findActiveByUser: vi.fn(),
    softDelete: vi.fn(),
    setCharacter: vi.fn(),
    insert: vi.fn(),
    findActiveSessionsForUser: vi.fn(),
  };
}

function makeBus(): EventBus {
  return { publish: vi.fn(), publishAll: vi.fn() } as unknown as EventBus;
}

function makeMember(overrides: Partial<MembershipReadModel> = {}): MembershipReadModel {
  return {
    id: 'm-1',
    gameSessionId: 'gs-1',
    userId: 'user-1',
    role: 'player',
    displayName: 'Yara',
    characterId: null,
    characterName: null,
    joinedAt: '2026-05-15T10:00:00.000Z',
    leftAt: null,
    ...overrides,
  };
}

describe('LeaveSessionHandler', () => {
  let repo: IMembershipRepo;
  let bus: EventBus;
  let handler: LeaveSessionHandler;

  beforeEach(() => {
    repo = makeRepo();
    bus = makeBus();
    handler = new LeaveSessionHandler(repo, bus);
  });

  it('lets a player leave their own membership', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeMember());
    await handler.execute(new LeaveSessionCommand('gs-1', 'user-1', 'm-1'));
    expect(repo.softDelete).toHaveBeenCalledWith('m-1');
    expect(bus.publish).toHaveBeenCalledWith(
      expect.objectContaining({ membershipId: 'm-1', userId: 'user-1' }),
    );
  });

  it('refuses to leave a non-existent membership', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);
    await expect(
      handler.execute(new LeaveSessionCommand('gs-1', 'user-1', 'm-X')),
    ).rejects.toBeInstanceOf(MembershipNotFoundError);
  });

  it("refuses to leave someone else's membership", async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeMember({ userId: 'OTHER' }));
    await expect(
      handler.execute(new LeaveSessionCommand('gs-1', 'user-1', 'm-1')),
    ).rejects.toBeInstanceOf(MembershipNotAuthorizedError);
    expect(repo.softDelete).not.toHaveBeenCalled();
  });

  it('refuses to leave a cross-session membership', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeMember({ gameSessionId: 'gs-OTHER' }));
    await expect(
      handler.execute(new LeaveSessionCommand('gs-1', 'user-1', 'm-1')),
    ).rejects.toBeInstanceOf(MembershipNotFoundError);
  });

  it('refuses to leave a GM membership (self-kick disallowed)', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeMember({ role: 'gm' }));
    await expect(
      handler.execute(new LeaveSessionCommand('gs-1', 'user-1', 'm-1')),
    ).rejects.toBeInstanceOf(CannotKickGmError);
  });
});

/**
 * Unit tests for system-message subscribers (Stream D / Task 2).
 *
 * Strategy: no DB, no Centrifugo, no full NestJS bootstrap.
 * Each subscriber is instantiated directly with vi.fn() mocks for
 * CommandBus and the relevant repo port.
 *
 * Assertions per handler:
 *   - PostSystemMessageCommand dispatched exactly once.
 *   - Correct gameSessionId forwarded.
 *   - Correct systemKey.
 *   - Correct systemParams shape.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { MemberJoinedEvent } from '../../memberships/events/member-joined.event';
import { MemberKickedEvent } from '../../memberships/events/member-kicked.event';
import { MemberLeftEvent } from '../../memberships/events/member-left.event';
import { RollPushedEvent } from '../../dice/events/roll-pushed.event';
import { PostSystemMessageCommand } from '../commands/post-system-message.command';
import {
  MemberJoinedSystemMessageSubscriber,
  MemberKickedSystemMessageSubscriber,
  MemberLeftSystemMessageSubscriber,
  RollPushedSystemMessageSubscriber,
} from './system-message.subscriber';

import type { CommandBus } from '@nestjs/cqrs';
import type { ICharacterRepo } from '../../characters/domain/character.ports';
import type { IMembershipRepo } from '../../memberships/domain/membership.ports';

// ---------------------------------------------------------------------------
// Shared factories
// ---------------------------------------------------------------------------

function makeBus(): Pick<CommandBus, 'execute'> {
  return { execute: vi.fn().mockResolvedValue(undefined) };
}

function makeMembershipRepo(displayName: string | null = 'Aelis'): IMembershipRepo {
  return {
    findById: vi.fn().mockResolvedValue({ displayName }),
    insert: vi.fn(),
    softDelete: vi.fn(),
    setCharacter: vi.fn(),
    listActive: vi.fn(),
    findActiveByUser: vi.fn(),
    findActiveSessionsForUser: vi.fn(),
  } as unknown as IMembershipRepo;
}

function makeCharacterRepo(name: string | null = 'Kael'): ICharacterRepo {
  return {
    findActiveById: vi.fn().mockResolvedValue({ name }),
    findOwnerIdById: vi.fn(),
    list: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
    deleteAbandonedDrafts: vi.fn(),
  } as unknown as ICharacterRepo;
}

// ---------------------------------------------------------------------------
// MemberJoinedSystemMessageSubscriber
// ---------------------------------------------------------------------------

describe('MemberJoinedSystemMessageSubscriber', () => {
  let bus: Pick<CommandBus, 'execute'>;
  let membershipRepo: IMembershipRepo;
  let sut: MemberJoinedSystemMessageSubscriber;

  beforeEach(() => {
    bus = makeBus();
    membershipRepo = makeMembershipRepo('Aelis');
    sut = new MemberJoinedSystemMessageSubscriber(bus as CommandBus, membershipRepo);
  });

  it('dispatches PostSystemMessageCommand with key=chat.system.member_joined and correct params', async () => {
    const event = new MemberJoinedEvent('mem-1', 'gs-1', 'user-1');

    await sut.handle(event);

    expect(bus.execute).toHaveBeenCalledOnce();
    expect(bus.execute).toHaveBeenCalledWith(
      expect.objectContaining({
        gameSessionId: 'gs-1',
        systemKey: 'chat.system.member_joined',
        systemParams: { displayName: 'Aelis' },
      }),
    );
    const cmd = vi.mocked(bus.execute).mock.calls[0]![0] as PostSystemMessageCommand;
    expect(cmd).toBeInstanceOf(PostSystemMessageCommand);
  });

  it('falls back to userId when membership.displayName is null', async () => {
    membershipRepo = makeMembershipRepo(null);
    sut = new MemberJoinedSystemMessageSubscriber(bus as CommandBus, membershipRepo);

    await sut.handle(new MemberJoinedEvent('mem-x', 'gs-2', 'user-fallback'));

    const cmd = vi.mocked(bus.execute).mock.calls[0]![0] as PostSystemMessageCommand;
    expect(cmd.systemParams).toEqual({ displayName: 'user-fallback' });
  });
});

// ---------------------------------------------------------------------------
// MemberLeftSystemMessageSubscriber
// ---------------------------------------------------------------------------

describe('MemberLeftSystemMessageSubscriber', () => {
  let bus: Pick<CommandBus, 'execute'>;
  let membershipRepo: IMembershipRepo;
  let sut: MemberLeftSystemMessageSubscriber;

  beforeEach(() => {
    bus = makeBus();
    membershipRepo = makeMembershipRepo('Noa');
    sut = new MemberLeftSystemMessageSubscriber(bus as CommandBus, membershipRepo);
  });

  it('dispatches PostSystemMessageCommand with key=chat.system.member_left and correct params', async () => {
    const event = new MemberLeftEvent('mem-2', 'gs-3', 'user-2');

    await sut.handle(event);

    expect(bus.execute).toHaveBeenCalledOnce();
    expect(bus.execute).toHaveBeenCalledWith(
      expect.objectContaining({
        gameSessionId: 'gs-3',
        systemKey: 'chat.system.member_left',
        systemParams: { displayName: 'Noa' },
      }),
    );
  });

  it('calls CommandBus.execute exactly once per event', async () => {
    await sut.handle(new MemberLeftEvent('mem-2', 'gs-3', 'user-2'));
    expect(bus.execute).toHaveBeenCalledOnce();
  });
});

// ---------------------------------------------------------------------------
// MemberKickedSystemMessageSubscriber
// ---------------------------------------------------------------------------

describe('MemberKickedSystemMessageSubscriber', () => {
  let bus: Pick<CommandBus, 'execute'>;
  let membershipRepo: IMembershipRepo;
  let sut: MemberKickedSystemMessageSubscriber;

  beforeEach(() => {
    bus = makeBus();
    membershipRepo = makeMembershipRepo('Riko');
    sut = new MemberKickedSystemMessageSubscriber(bus as CommandBus, membershipRepo);
  });

  it('dispatches PostSystemMessageCommand with key=chat.system.member_kicked and correct params', async () => {
    const event = new MemberKickedEvent('mem-3', 'gs-4', 'user-3');

    await sut.handle(event);

    expect(bus.execute).toHaveBeenCalledOnce();
    expect(bus.execute).toHaveBeenCalledWith(
      expect.objectContaining({
        gameSessionId: 'gs-4',
        systemKey: 'chat.system.member_kicked',
        systemParams: { displayName: 'Riko' },
      }),
    );
  });

  it('calls CommandBus.execute exactly once per event', async () => {
    await sut.handle(new MemberKickedEvent('mem-3', 'gs-4', 'user-3'));
    expect(bus.execute).toHaveBeenCalledOnce();
  });
});

// ---------------------------------------------------------------------------
// RollPushedSystemMessageSubscriber
// ---------------------------------------------------------------------------

describe('RollPushedSystemMessageSubscriber', () => {
  let bus: Pick<CommandBus, 'execute'>;
  let characterRepo: ICharacterRepo;
  let sut: RollPushedSystemMessageSubscriber;

  beforeEach(() => {
    bus = makeBus();
    characterRepo = makeCharacterRepo('Kael');
    sut = new RollPushedSystemMessageSubscriber(bus as CommandBus, characterRepo);
  });

  it('dispatches PostSystemMessageCommand with key=chat.system.roll_pushed and correct params', async () => {
    const event = new RollPushedEvent('roll-1', 'char-1', 'gs-5', 3);

    await sut.handle(event);

    expect(bus.execute).toHaveBeenCalledOnce();
    expect(bus.execute).toHaveBeenCalledWith(
      expect.objectContaining({
        gameSessionId: 'gs-5',
        systemKey: 'chat.system.roll_pushed',
        systemParams: { characterName: 'Kael', hits: 3 },
      }),
    );
  });

  it('does NOT dispatch when gameSessionId is null (out-of-session roll)', async () => {
    const event = new RollPushedEvent('roll-solo', 'char-1', null, 2);

    await sut.handle(event);

    expect(bus.execute).not.toHaveBeenCalled();
  });

  it('falls back to characterId when character not found', async () => {
    characterRepo = {
      ...makeCharacterRepo('ignored'),
      findActiveById: vi.fn().mockResolvedValue(null),
    } as unknown as ICharacterRepo;
    sut = new RollPushedSystemMessageSubscriber(bus as CommandBus, characterRepo);

    await sut.handle(new RollPushedEvent('roll-2', 'char-ghost', 'gs-5', 1));

    const cmd = vi.mocked(bus.execute).mock.calls[0]![0] as PostSystemMessageCommand;
    expect(cmd.systemParams).toEqual({ characterName: 'char-ghost', hits: 1 });
  });

  it('calls CommandBus.execute exactly once per in-session roll', async () => {
    await sut.handle(new RollPushedEvent('roll-3', 'char-1', 'gs-5', 0));
    expect(bus.execute).toHaveBeenCalledOnce();
  });
});

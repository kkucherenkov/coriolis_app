import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  ChatBodyEmptyError,
  ChatBodyTooLargeError,
  ChatMessageNotAuthorizedError,
  ChatRateLimitedError,
  ChatTargetBlockedError,
  ChatTargetNotMemberError,
} from '../domain/chat.errors';
import { ChatMessagePostedEvent } from '../events/chat-message-posted.event';

import { PostChatMessageCommand } from './post-chat-message.command';
import { PostChatMessageHandler } from './post-chat-message.handler';

import type { AppConfig } from '../../../common/config/app-config';
import type { MembershipReadModel } from '../../memberships/domain/membership.ports';
import type { IMembershipRepo } from '../../memberships/domain/membership.ports';
import type {
  ChatMessageReadModel,
  IChatBlockRepo,
  IChatMessageRepo,
  IChatRateLimiter,
} from '../domain/chat.ports';

function makeMessageRepo(): IChatMessageRepo {
  return {
    insert: vi.fn(),
    findById: vi.fn(),
    updateBody: vi.fn(),
    softDelete: vi.fn(),
    list: vi.fn(),
    listConversations: vi.fn(),
    countNewerThan: vi.fn(),
  };
}

function makeMembershipRepo(): IMembershipRepo {
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

function makeBlockRepo(): IChatBlockRepo {
  return {
    exists: vi.fn(),
    insert: vi.fn(),
    delete: vi.fn(),
    listForBlocker: vi.fn(),
  };
}

function makeRateLimiter(): IChatRateLimiter {
  return {
    consume: vi.fn(),
  };
}

function makeEventBus() {
  return { publish: vi.fn() };
}

function makeConfig(): Pick<AppConfig, 'chat'> {
  return {
    chat: {
      maxBodyBytes: 4096,
      maxMessagesPerMinute: 30,
      burst: 5,
      editWindowSeconds: 300,
    },
  };
}

function makeMembership(overrides: Partial<MembershipReadModel> = {}): MembershipReadModel {
  return {
    id: 'mem-target',
    gameSessionId: 'gs-1',
    userId: 'user-target',
    role: 'player',
    displayName: 'Target Player',
    characterId: null,
    characterName: null,
    joinedAt: '2026-01-01T00:00:00.000Z',
    leftAt: null,
    ...overrides,
  };
}

function makeMessage(overrides: Partial<ChatMessageReadModel> = {}): ChatMessageReadModel {
  return {
    id: 'msg-1',
    gameSessionId: 'gs-1',
    authorMembershipId: 'mem-author',
    authorDisplayName: 'Author',
    targetMembershipId: null,
    kind: 'text',
    body: 'Hello',
    systemKey: null,
    systemParams: null,
    createdAt: '2026-05-17T10:00:00.000Z',
    editedAt: null,
    deletedAt: null,
    ...overrides,
  };
}

describe('PostChatMessageHandler', () => {
  let messageRepo: IChatMessageRepo;
  let membershipRepo: IMembershipRepo;
  let blockRepo: IChatBlockRepo;
  let rateLimiter: IChatRateLimiter;
  let eventBus: ReturnType<typeof makeEventBus>;
  let handler: PostChatMessageHandler;
  const fixedNow = new Date('2026-05-17T10:00:00.000Z');

  beforeEach(() => {
    messageRepo = makeMessageRepo();
    membershipRepo = makeMembershipRepo();
    blockRepo = makeBlockRepo();
    rateLimiter = makeRateLimiter();
    eventBus = makeEventBus();

    handler = new PostChatMessageHandler(
      messageRepo,
      membershipRepo,
      blockRepo,
      rateLimiter,
      makeConfig() as AppConfig,
      eventBus as never,
      () => fixedNow,
    );
  });

  it('posts a broadcast message successfully', async () => {
    const msg = makeMessage();
    vi.mocked(messageRepo.insert).mockResolvedValue(msg);

    const cmd = new PostChatMessageCommand('gs-1', 'user-1', 'mem-author', null, 'Hello');
    const result = await handler.execute(cmd);

    expect(rateLimiter.consume).toHaveBeenCalledWith('user-1', fixedNow);
    expect(messageRepo.insert).toHaveBeenCalledWith({
      gameSessionId: 'gs-1',
      authorMembershipId: 'mem-author',
      targetMembershipId: null,
      kind: 'text',
      body: 'Hello',
      systemKey: null,
      systemParams: null,
    });
    expect(eventBus.publish).toHaveBeenCalledWith(new ChatMessagePostedEvent(msg));
    expect(result).toBe(msg);
  });

  it('posts a whisper message successfully', async () => {
    const targetMembership = makeMembership();
    vi.mocked(membershipRepo.findById).mockResolvedValue(targetMembership);
    vi.mocked(blockRepo.exists).mockResolvedValue(false);
    const msg = makeMessage({ targetMembershipId: 'mem-target' });
    vi.mocked(messageRepo.insert).mockResolvedValue(msg);

    const cmd = new PostChatMessageCommand('gs-1', 'user-1', 'mem-author', 'mem-target', 'Hi');
    const result = await handler.execute(cmd);

    expect(membershipRepo.findById).toHaveBeenCalledWith('mem-target');
    expect(blockRepo.exists).toHaveBeenCalledWith({
      gameSessionId: 'gs-1',
      blockerMembershipId: 'mem-target',
      blockedMembershipId: 'mem-author',
    });
    expect(result).toBe(msg);
  });

  it('rejects empty body with ChatBodyEmptyError (422)', async () => {
    const cmd = new PostChatMessageCommand('gs-1', 'user-1', 'mem-author', null, '   ');

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatBodyEmptyError);
    expect(messageRepo.insert).not.toHaveBeenCalled();
  });

  it('rejects body exceeding maxBodyBytes with ChatBodyTooLargeError (413)', async () => {
    const bigBody = 'x'.repeat(5000);
    const cmd = new PostChatMessageCommand('gs-1', 'user-1', 'mem-author', null, bigBody);

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatBodyTooLargeError);
    expect(messageRepo.insert).not.toHaveBeenCalled();
  });

  it('rejects whisper to non-member target with ChatTargetNotMemberError (404)', async () => {
    vi.mocked(membershipRepo.findById).mockResolvedValue(null);

    const cmd = new PostChatMessageCommand('gs-1', 'user-1', 'mem-author', 'mem-gone', 'Hi');

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatTargetNotMemberError);
    expect(messageRepo.insert).not.toHaveBeenCalled();
  });

  it('rejects whisper when target has blocked author with ChatTargetBlockedError (403)', async () => {
    vi.mocked(membershipRepo.findById).mockResolvedValue(makeMembership());
    vi.mocked(blockRepo.exists).mockResolvedValue(true);

    const cmd = new PostChatMessageCommand('gs-1', 'user-1', 'mem-author', 'mem-target', 'Hi');

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatTargetBlockedError);
    expect(messageRepo.insert).not.toHaveBeenCalled();
  });

  it('rejects when rate limiter throws ChatRateLimitedError (429)', async () => {
    vi.mocked(rateLimiter.consume).mockRejectedValue(new ChatRateLimitedError());

    const cmd = new PostChatMessageCommand('gs-1', 'user-1', 'mem-author', null, 'Hello');

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatRateLimitedError);
    expect(messageRepo.insert).not.toHaveBeenCalled();
  });

  it('rejects whisper to membership in a different session with ChatTargetNotMemberError (404)', async () => {
    vi.mocked(membershipRepo.findById).mockResolvedValue(
      makeMembership({ gameSessionId: 'gs-OTHER' }),
    );

    const cmd = new PostChatMessageCommand('gs-1', 'user-1', 'mem-author', 'mem-target', 'Hi');

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatTargetNotMemberError);
    expect(messageRepo.insert).not.toHaveBeenCalled();
  });
});

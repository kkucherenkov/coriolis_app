import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ChatMessagePostedEvent } from '../events/chat-message-posted.event';

import { PostSystemMessageCommand } from './post-system-message.command';
import { PostSystemMessageHandler } from './post-system-message.handler';

import type { ChatMessageReadModel, IChatMessageRepo } from '../domain/chat.ports';

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

function makeEventBus() {
  return { publish: vi.fn() };
}

function makeSystemMessage(overrides: Partial<ChatMessageReadModel> = {}): ChatMessageReadModel {
  return {
    id: 'msg-sys-1',
    gameSessionId: 'gs-1',
    authorMembershipId: null,
    authorDisplayName: null,
    targetMembershipId: null,
    kind: 'system',
    body: null,
    systemKey: 'chat.system.member_joined',
    systemParams: { displayName: 'Alice' },
    createdAt: '2026-05-17T10:00:00.000Z',
    editedAt: null,
    deletedAt: null,
    ...overrides,
  };
}

describe('PostSystemMessageHandler', () => {
  let messageRepo: IChatMessageRepo;
  let eventBus: ReturnType<typeof makeEventBus>;
  let handler: PostSystemMessageHandler;

  beforeEach(() => {
    messageRepo = makeMessageRepo();
    eventBus = makeEventBus();
    handler = new PostSystemMessageHandler(messageRepo, eventBus as never);
  });

  it('inserts a system message and emits ChatMessagePostedEvent', async () => {
    const msg = makeSystemMessage();
    vi.mocked(messageRepo.insert).mockResolvedValue(msg);

    const cmd = new PostSystemMessageCommand('gs-1', 'chat.system.member_joined', {
      displayName: 'Alice',
    });
    const result = await handler.execute(cmd);

    expect(messageRepo.insert).toHaveBeenCalledWith({
      gameSessionId: 'gs-1',
      authorMembershipId: null,
      targetMembershipId: null,
      kind: 'system',
      body: null,
      systemKey: 'chat.system.member_joined',
      systemParams: { displayName: 'Alice' },
    });
    expect(eventBus.publish).toHaveBeenCalledWith(new ChatMessagePostedEvent(msg));
    expect(result).toBe(msg);
  });

  it('throws when called with a non-null targetMembershipId (defensive guard)', async () => {
    // System messages are always broadcast — callers must not pass a target.
    // This is a programming error guard, not a user-facing validation.
    const cmd = new PostSystemMessageCommand('gs-1', 'chat.system.member_joined', null);

    // Inject a targetMembershipId by constructing the command with a hack —
    // we test the handler's defensive branch directly via an extended command object.
    const illegalCmd = Object.assign(
      new PostSystemMessageCommand('gs-1', 'chat.system.member_joined', null),
      { targetMembershipId: 'mem-some' },
    );

    await expect(handler.execute(illegalCmd as PostSystemMessageCommand)).rejects.toThrow(
      'System messages must always be broadcast',
    );
    expect(messageRepo.insert).not.toHaveBeenCalled();
  });
});

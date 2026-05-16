import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ChatMessageNotAuthorizedError, ChatMessageNotFoundError } from '../domain/chat.errors';
import { ChatMessageDeletedEvent } from '../events/chat-message-deleted.event';

import { DeleteChatMessageCommand } from './delete-chat-message.command';
import { DeleteChatMessageHandler } from './delete-chat-message.handler';

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

function makeBroadcast(overrides: Partial<ChatMessageReadModel> = {}): ChatMessageReadModel {
  return {
    id: 'msg-1',
    gameSessionId: 'gs-1',
    authorMembershipId: 'mem-author',
    authorDisplayName: 'Author',
    targetMembershipId: null, // broadcast
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

function makeWhisper(overrides: Partial<ChatMessageReadModel> = {}): ChatMessageReadModel {
  return makeBroadcast({
    targetMembershipId: 'mem-target',
    ...overrides,
  });
}

function makeDeletedRow(msg: ChatMessageReadModel, deletedAt: Date): ChatMessageReadModel {
  return { ...msg, deletedAt: deletedAt.toISOString() };
}

describe('DeleteChatMessageHandler', () => {
  let messageRepo: IChatMessageRepo;
  let eventBus: ReturnType<typeof makeEventBus>;
  let handler: DeleteChatMessageHandler;
  const fixedNow = new Date('2026-05-17T10:05:00.000Z');

  beforeEach(() => {
    messageRepo = makeMessageRepo();
    eventBus = makeEventBus();
    handler = new DeleteChatMessageHandler(messageRepo, eventBus as never, () => fixedNow);
  });

  it('author deletes own broadcast message successfully', async () => {
    const msg = makeBroadcast();
    const deleted = makeDeletedRow(msg, fixedNow);
    vi.mocked(messageRepo.findById).mockResolvedValue(msg);
    vi.mocked(messageRepo.softDelete).mockResolvedValue(deleted);

    const cmd = new DeleteChatMessageCommand('msg-1', 'user-1', 'mem-author', false);
    await handler.execute(cmd);

    expect(messageRepo.softDelete).toHaveBeenCalledWith('msg-1', fixedNow);
    expect(eventBus.publish).toHaveBeenCalledWith(
      new ChatMessageDeletedEvent({
        id: 'msg-1',
        gameSessionId: 'gs-1',
        authorMembershipId: 'mem-author',
        targetMembershipId: null,
        deletedAt: fixedNow.toISOString(),
      }),
    );
  });

  it('GM deletes another player broadcast message successfully', async () => {
    const msg = makeBroadcast({ authorMembershipId: 'mem-player' });
    const deleted = makeDeletedRow(msg, fixedNow);
    vi.mocked(messageRepo.findById).mockResolvedValue(msg);
    vi.mocked(messageRepo.softDelete).mockResolvedValue(deleted);

    const cmd = new DeleteChatMessageCommand('msg-1', 'user-gm', 'mem-gm', true);
    await handler.execute(cmd);

    expect(messageRepo.softDelete).toHaveBeenCalledWith('msg-1', fixedNow);
  });

  it('throws ChatMessageNotAuthorizedError when non-author non-GM tries to delete broadcast (403)', async () => {
    const msg = makeBroadcast({ authorMembershipId: 'mem-author' });
    vi.mocked(messageRepo.findById).mockResolvedValue(msg);

    const cmd = new DeleteChatMessageCommand('msg-1', 'user-X', 'mem-other', false);

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatMessageNotAuthorizedError);
    expect(messageRepo.softDelete).not.toHaveBeenCalled();
  });

  it('author deletes own whisper message successfully', async () => {
    const msg = makeWhisper();
    const deleted = makeDeletedRow(msg, fixedNow);
    vi.mocked(messageRepo.findById).mockResolvedValue(msg);
    vi.mocked(messageRepo.softDelete).mockResolvedValue(deleted);

    const cmd = new DeleteChatMessageCommand('msg-1', 'user-1', 'mem-author', false);
    await handler.execute(cmd);

    expect(messageRepo.softDelete).toHaveBeenCalledWith('msg-1', fixedNow);
    expect(eventBus.publish).toHaveBeenCalledWith(
      new ChatMessageDeletedEvent({
        id: 'msg-1',
        gameSessionId: 'gs-1',
        authorMembershipId: 'mem-author',
        targetMembershipId: 'mem-target',
        deletedAt: fixedNow.toISOString(),
      }),
    );
  });

  it('GM cannot delete whisper — returns ChatMessageNotFoundError (404), not 403', async () => {
    // GM has no visibility into whispers they are not party to
    // Visibility filter fires first → 404 (design: privacy over authz)
    const msg = makeWhisper({ authorMembershipId: 'mem-player', targetMembershipId: 'mem-target' });
    vi.mocked(messageRepo.findById).mockResolvedValue(msg);

    const cmd = new DeleteChatMessageCommand('msg-1', 'user-gm', 'mem-gm', true);

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatMessageNotFoundError);
    expect(messageRepo.softDelete).not.toHaveBeenCalled();
  });

  it('throws ChatMessageNotFoundError for whisper bystander (404)', async () => {
    const msg = makeWhisper();
    vi.mocked(messageRepo.findById).mockResolvedValue(msg);

    const cmd = new DeleteChatMessageCommand('msg-1', 'user-X', 'mem-bystander', false);

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatMessageNotFoundError);
    expect(messageRepo.softDelete).not.toHaveBeenCalled();
  });

  it('throws ChatMessageNotFoundError when message is already deleted (404)', async () => {
    const msg = makeBroadcast({ deletedAt: '2026-05-17T09:00:00.000Z' });
    vi.mocked(messageRepo.findById).mockResolvedValue(msg);

    const cmd = new DeleteChatMessageCommand('msg-1', 'user-1', 'mem-author', false);

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatMessageNotFoundError);
    expect(messageRepo.softDelete).not.toHaveBeenCalled();
  });
});

import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  ChatBodyEmptyError,
  ChatEditWindowExpiredError,
  ChatMessageNotAuthorizedError,
  ChatMessageNotFoundError,
} from '../domain/chat.errors';
import { ChatMessageEditedEvent } from '../events/chat-message-edited.event';

import { EditChatMessageCommand } from './edit-chat-message.command';
import { EditChatMessageHandler } from './edit-chat-message.handler';

import type { AppConfig } from '../../../common/config/app-config';
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

function makeMessage(overrides: Partial<ChatMessageReadModel> = {}): ChatMessageReadModel {
  return {
    id: 'msg-1',
    gameSessionId: 'gs-1',
    authorMembershipId: 'mem-author',
    authorDisplayName: 'Author',
    targetMembershipId: null,
    kind: 'text',
    body: 'Original',
    systemKey: null,
    systemParams: null,
    createdAt: '2026-05-17T10:00:00.000Z',
    editedAt: null,
    deletedAt: null,
    ...overrides,
  };
}

describe('EditChatMessageHandler', () => {
  let messageRepo: IChatMessageRepo;
  let eventBus: ReturnType<typeof makeEventBus>;
  let handler: EditChatMessageHandler;
  // fixedNow is 2 minutes after createdAt — well within 5 min edit window
  const createdAt = '2026-05-17T10:00:00.000Z';
  const fixedNow = new Date('2026-05-17T10:02:00.000Z');

  beforeEach(() => {
    messageRepo = makeMessageRepo();
    eventBus = makeEventBus();

    handler = new EditChatMessageHandler(
      messageRepo,
      makeConfig() as AppConfig,
      eventBus as never,
      () => fixedNow,
    );
  });

  it('edits a broadcast message successfully', async () => {
    const original = makeMessage({ createdAt });
    const updated = makeMessage({ createdAt, body: 'Updated', editedAt: fixedNow.toISOString() });
    vi.mocked(messageRepo.findById).mockResolvedValue(original);
    vi.mocked(messageRepo.updateBody).mockResolvedValue(updated);

    const cmd = new EditChatMessageCommand('msg-1', 'user-1', 'mem-author', 'Updated');
    const result = await handler.execute(cmd);

    expect(messageRepo.updateBody).toHaveBeenCalledWith('msg-1', 'Updated', fixedNow);
    expect(eventBus.publish).toHaveBeenCalledWith(new ChatMessageEditedEvent(updated));
    expect(result).toBe(updated);
  });

  it('throws ChatMessageNotFoundError when message does not exist (404)', async () => {
    vi.mocked(messageRepo.findById).mockResolvedValue(null);

    const cmd = new EditChatMessageCommand('msg-missing', 'user-1', 'mem-author', 'Hi');

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatMessageNotFoundError);
    expect(messageRepo.updateBody).not.toHaveBeenCalled();
  });

  it('throws ChatMessageNotAuthorizedError when caller is not the author (403)', async () => {
    vi.mocked(messageRepo.findById).mockResolvedValue(makeMessage({ createdAt }));

    const cmd = new EditChatMessageCommand('msg-1', 'user-X', 'mem-bystander', 'Hi');

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatMessageNotAuthorizedError);
    expect(messageRepo.updateBody).not.toHaveBeenCalled();
  });

  it('throws ChatEditWindowExpiredError when edit window has passed (422)', async () => {
    const expiredNow = new Date('2026-05-17T10:10:00.000Z'); // 10 min after createdAt
    handler = new EditChatMessageHandler(
      messageRepo,
      makeConfig() as AppConfig,
      eventBus as never,
      () => expiredNow,
    );
    vi.mocked(messageRepo.findById).mockResolvedValue(makeMessage({ createdAt }));

    const cmd = new EditChatMessageCommand('msg-1', 'user-1', 'mem-author', 'Hi');

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatEditWindowExpiredError);
    expect(messageRepo.updateBody).not.toHaveBeenCalled();
  });

  it('throws ChatBodyEmptyError when body trims to empty (422)', async () => {
    vi.mocked(messageRepo.findById).mockResolvedValue(makeMessage({ createdAt }));

    const cmd = new EditChatMessageCommand('msg-1', 'user-1', 'mem-author', '   ');

    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatBodyEmptyError);
    expect(messageRepo.updateBody).not.toHaveBeenCalled();
  });

  it('throws ChatMessageNotFoundError (404) when whisper bystander tries to edit', async () => {
    // Whisper between mem-author and mem-target; caller is bystander
    const whisper = makeMessage({
      createdAt,
      targetMembershipId: 'mem-target',
    });
    vi.mocked(messageRepo.findById).mockResolvedValue(whisper);

    const cmd = new EditChatMessageCommand('msg-1', 'user-X', 'mem-bystander', 'Hi');

    // Bystander hits visibility filter → 404 (not 403)
    await expect(handler.execute(cmd)).rejects.toBeInstanceOf(ChatMessageNotFoundError);
    expect(messageRepo.updateBody).not.toHaveBeenCalled();
  });
});

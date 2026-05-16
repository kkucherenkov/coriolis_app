import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ChatMessageNotFoundError } from '../domain/chat.errors';

import { GetChatMessageQuery } from './get-chat-message.query';
import { GetChatMessageHandler } from './get-chat-message.handler';

import type {
  IMembershipRepo,
  MembershipReadModel,
} from '../../memberships/domain/membership.ports';
import type { ChatMessageReadModel, IChatMessageRepo } from '../domain/chat.ports';

// ---------------------------------------------------------------------------
// Factory helpers
// ---------------------------------------------------------------------------

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

function makeMember(overrides: Partial<MembershipReadModel> = {}): MembershipReadModel {
  return {
    id: 'mem-caller',
    gameSessionId: 'gs-1',
    userId: 'user-1',
    role: 'player',
    displayName: 'Yara',
    characterId: null,
    characterName: null,
    joinedAt: '2026-05-17T10:00:00.000Z',
    leftAt: null,
    ...overrides,
  };
}

function makeMessage(overrides: Partial<ChatMessageReadModel> = {}): ChatMessageReadModel {
  return {
    id: 'msg-1',
    gameSessionId: 'gs-1',
    authorMembershipId: 'mem-caller',
    authorDisplayName: 'Yara',
    targetMembershipId: null,
    kind: 'text',
    body: 'Hello broadcast',
    systemKey: null,
    systemParams: null,
    createdAt: '2026-05-17T10:00:00.000Z',
    editedAt: null,
    deletedAt: null,
    ...overrides,
  };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe('GetChatMessageHandler', () => {
  let membershipRepo: IMembershipRepo;
  let chatRepo: IChatMessageRepo;
  let handler: GetChatMessageHandler;

  beforeEach(() => {
    membershipRepo = makeMembershipRepo();
    chatRepo = makeMessageRepo();
    handler = new GetChatMessageHandler(membershipRepo, chatRepo);
  });

  it('broadcast message — visible to any active session member', async () => {
    const msg = makeMessage({ targetMembershipId: null, kind: 'text' });
    vi.mocked(chatRepo.findById).mockResolvedValue(msg);
    // caller is a member of gs-1
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(makeMember());

    const result = await handler.execute(new GetChatMessageQuery('msg-1', 'user-1'));

    expect(result.id).toBe('msg-1');
  });

  it('broadcast message — 404 to caller with no membership in that session', async () => {
    const msg = makeMessage({ targetMembershipId: null });
    vi.mocked(chatRepo.findById).mockResolvedValue(msg);
    // caller has no active membership in gs-1
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(null);

    await expect(
      handler.execute(new GetChatMessageQuery('msg-1', 'user-x')),
    ).rejects.toBeInstanceOf(ChatMessageNotFoundError);
  });

  it('whisper message — visible to the author and to the target (privacy contract)', async () => {
    const msg = makeMessage({
      authorMembershipId: 'mem-author',
      targetMembershipId: 'mem-target',
    });
    vi.mocked(chatRepo.findById).mockResolvedValue(msg);

    // Test author visibility
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(
      makeMember({ id: 'mem-author', userId: 'user-author' }),
    );
    const asAuthor = await handler.execute(new GetChatMessageQuery('msg-1', 'user-author'));
    expect(asAuthor.id).toBe('msg-1');

    // Test target visibility
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(
      makeMember({ id: 'mem-target', userId: 'user-target' }),
    );
    const asTarget = await handler.execute(new GetChatMessageQuery('msg-1', 'user-target'));
    expect(asTarget.id).toBe('msg-1');
  });

  it('whisper message — 404 to a session member who is neither author nor target (bystander and GM)', async () => {
    const msg = makeMessage({
      authorMembershipId: 'mem-author',
      targetMembershipId: 'mem-target',
    });
    vi.mocked(chatRepo.findById).mockResolvedValue(msg);

    // Bystander: active member but not author/target
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(
      makeMember({ id: 'mem-bystander', userId: 'user-bystander' }),
    );
    await expect(
      handler.execute(new GetChatMessageQuery('msg-1', 'user-bystander')),
    ).rejects.toBeInstanceOf(ChatMessageNotFoundError);

    // GM who is not author/target — same 404 (privacy contract: non-existence over forbidden)
    vi.mocked(membershipRepo.findActiveByUser).mockResolvedValue(
      makeMember({ id: 'mem-gm', userId: 'user-gm', role: 'gm' }),
    );
    await expect(
      handler.execute(new GetChatMessageQuery('msg-1', 'user-gm')),
    ).rejects.toBeInstanceOf(ChatMessageNotFoundError);
  });
});

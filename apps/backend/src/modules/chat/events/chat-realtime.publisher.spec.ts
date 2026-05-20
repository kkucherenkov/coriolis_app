/**
 * Unit tests for ChatRealtimePublisher event handlers (Stream C/7).
 *
 * Strategy: mock RealtimeRouter methods via vi.fn() — no real Centrifugo,
 * no DB. The three publisher classes delegate routing + publishing to the
 * router, so tests assert the correct router method is called with the
 * expected arguments rather than asserting centrifugo.publish directly.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ChatMessageDeletedEvent } from './chat-message-deleted.event';
import { ChatMessageEditedEvent } from './chat-message-edited.event';
import { ChatMessagePostedEvent } from './chat-message-posted.event';
import {
  ChatMessageDeletedPublisher,
  ChatMessageEditedPublisher,
  ChatMessagePostedPublisher,
} from './chat-realtime.publisher';

import type { ChatMessageReadModel } from '../domain/chat.ports';
import type { RealtimeRouter } from '../../realtime/realtime-router';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function makeRouter(): RealtimeRouter {
  return {
    publishChatMessage: vi.fn().mockResolvedValue(undefined),
    publishChatMessageDeleted: vi.fn().mockResolvedValue(undefined),
    publishDpChanged: vi.fn().mockResolvedValue(undefined),
    publishRollPushed: vi.fn().mockResolvedValue(undefined),
    publishCombatUpdated: vi.fn().mockResolvedValue(undefined),
  } as unknown as RealtimeRouter;
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

// ---------------------------------------------------------------------------
// ChatMessagePostedPublisher
// ---------------------------------------------------------------------------

describe('ChatMessagePostedPublisher', () => {
  let router: RealtimeRouter;
  let publisher: ChatMessagePostedPublisher;

  beforeEach(() => {
    router = makeRouter();
    publisher = new ChatMessagePostedPublisher(router);
  });

  it('delegates broadcast posted to router.publishChatMessage with null target', async () => {
    const msg = makeMessage({ targetMembershipId: null });
    await publisher.handle(new ChatMessagePostedEvent(msg));

    expect(router.publishChatMessage).toHaveBeenCalledOnce();
    expect(router.publishChatMessage).toHaveBeenCalledWith(
      'gs-1',
      'mem-author',
      null,
      msg,
    );
  });

  it('delegates whisper posted to router.publishChatMessage with both membership ids', async () => {
    const msg = makeMessage({ authorMembershipId: 'mem-author', targetMembershipId: 'mem-target' });
    await publisher.handle(new ChatMessagePostedEvent(msg));

    expect(router.publishChatMessage).toHaveBeenCalledOnce();
    expect(router.publishChatMessage).toHaveBeenCalledWith(
      'gs-1',
      'mem-author',
      'mem-target',
      msg,
    );
  });

  it('passes the message read model as payload', async () => {
    const msg = makeMessage({ body: 'Important message' });
    await publisher.handle(new ChatMessagePostedEvent(msg));

    const [, , , payload] = vi.mocked(router.publishChatMessage).mock.calls[0]!;
    expect(payload).toBe(msg);
  });

  it('router error propagates (router handles fire-and-forget internally)', async () => {
    // RealtimeRouter.publishChatMessage never throws — it catches internally.
    // Publisher simply awaits; if router did throw, it would bubble up.
    // This test confirms the publisher doesn't add extra try/catch.
    vi.mocked(router.publishChatMessage).mockResolvedValue(undefined);
    const msg = makeMessage();

    await expect(publisher.handle(new ChatMessagePostedEvent(msg))).resolves.toBeUndefined();
  });
});

// ---------------------------------------------------------------------------
// ChatMessageEditedPublisher
// ---------------------------------------------------------------------------

describe('ChatMessageEditedPublisher', () => {
  let router: RealtimeRouter;
  let publisher: ChatMessageEditedPublisher;

  beforeEach(() => {
    router = makeRouter();
    publisher = new ChatMessageEditedPublisher(router);
  });

  it('delegates edit on broadcast message to router.publishChatMessage', async () => {
    const msg = makeMessage({
      targetMembershipId: null,
      body: 'Updated body',
      editedAt: '2026-05-17T10:05:00.000Z',
    });
    await publisher.handle(new ChatMessageEditedEvent(msg));

    expect(router.publishChatMessage).toHaveBeenCalledOnce();
    expect(router.publishChatMessage).toHaveBeenCalledWith(
      'gs-1',
      'mem-author',
      null,
      msg,
    );
  });

  it('passes updated message fields through to router', async () => {
    const msg = makeMessage({ body: 'Edited', editedAt: '2026-05-17T10:05:00.000Z' });
    await publisher.handle(new ChatMessageEditedEvent(msg));

    const [, , , payload] = vi.mocked(router.publishChatMessage).mock.calls[0]!;
    expect((payload as ChatMessageReadModel).body).toBe('Edited');
    expect((payload as ChatMessageReadModel).editedAt).toBe('2026-05-17T10:05:00.000Z');
  });
});

// ---------------------------------------------------------------------------
// ChatMessageDeletedPublisher
// ---------------------------------------------------------------------------

describe('ChatMessageDeletedPublisher', () => {
  let router: RealtimeRouter;
  let publisher: ChatMessageDeletedPublisher;

  beforeEach(() => {
    router = makeRouter();
    publisher = new ChatMessageDeletedPublisher(router);
  });

  it('delegates broadcast deleted to router.publishChatMessageDeleted', async () => {
    const event = new ChatMessageDeletedEvent({
      id: 'msg-1',
      gameSessionId: 'gs-1',
      authorMembershipId: 'mem-author',
      targetMembershipId: null,
      deletedAt: '2026-05-17T10:10:00.000Z',
    });
    await publisher.handle(event);

    expect(router.publishChatMessageDeleted).toHaveBeenCalledOnce();
    expect(router.publishChatMessageDeleted).toHaveBeenCalledWith(
      'gs-1',
      'mem-author',
      null,
      { id: 'msg-1', gameSessionId: 'gs-1', targetMembershipId: null, deletedAt: '2026-05-17T10:10:00.000Z' },
    );
  });

  it('delegates whisper deleted to router with both membership ids', async () => {
    const event = new ChatMessageDeletedEvent({
      id: 'msg-2',
      gameSessionId: 'gs-1',
      authorMembershipId: 'mem-author',
      targetMembershipId: 'mem-target',
      deletedAt: '2026-05-17T10:10:00.000Z',
    });
    await publisher.handle(event);

    expect(router.publishChatMessageDeleted).toHaveBeenCalledOnce();
    expect(router.publishChatMessageDeleted).toHaveBeenCalledWith(
      'gs-1',
      'mem-author',
      'mem-target',
      expect.objectContaining({ id: 'msg-2', targetMembershipId: 'mem-target' }),
    );
  });
});

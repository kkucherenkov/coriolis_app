/**
 * Unit tests for ChatRealtimePublisher (Stream C/7).
 *
 * Strategy: mock ICentrifugoClient.publish via vi.fn() — no real Centrifugo,
 * no DB. Three publisher classes share the same buildChannels helper so
 * routing logic is exercised through the public handle() interface.
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
import type { ICentrifugoClient } from '../../realtime/centrifugo.client';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function makeCentrifugo(): ICentrifugoClient {
  return { publish: vi.fn().mockResolvedValue(undefined) };
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
  let centrifugo: ICentrifugoClient;
  let publisher: ChatMessagePostedPublisher;

  beforeEach(() => {
    centrifugo = makeCentrifugo();
    publisher = new ChatMessagePostedPublisher(centrifugo);
  });

  it('broadcast posted → 1 publish call to session.<id>.chat', async () => {
    const msg = makeMessage({ targetMembershipId: null });
    await publisher.handle(new ChatMessagePostedEvent(msg));

    expect(centrifugo.publish).toHaveBeenCalledOnce();
    expect(centrifugo.publish).toHaveBeenCalledWith('session.gs-1.chat', expect.any(Object));
  });

  it('whisper posted → 2 publish calls to both member channels with identical payload', async () => {
    const msg = makeMessage({
      authorMembershipId: 'mem-author',
      targetMembershipId: 'mem-target',
    });
    await publisher.handle(new ChatMessagePostedEvent(msg));

    expect(centrifugo.publish).toHaveBeenCalledTimes(2);

    const calls = vi.mocked(centrifugo.publish).mock.calls;
    const channels = calls.map(([ch]) => ch);
    expect(channels).toContain('session.gs-1.member.mem-author');
    expect(channels).toContain('session.gs-1.member.mem-target');

    // Same payload object identity is guaranteed by the implementation (single ref)
    const payload0 = calls[0]?.[1];
    const payload1 = calls[1]?.[1];
    expect(payload0).toBe(payload1);
  });

  it('self-whisper (author === target) → 1 publish call (deduplicated)', async () => {
    const msg = makeMessage({
      authorMembershipId: 'mem-self',
      targetMembershipId: 'mem-self',
    });
    await publisher.handle(new ChatMessagePostedEvent(msg));

    expect(centrifugo.publish).toHaveBeenCalledOnce();
    expect(centrifugo.publish).toHaveBeenCalledWith(
      'session.gs-1.member.mem-self',
      expect.any(Object),
    );
  });

  it('Centrifugo throwing → publisher swallows error, handle() resolves cleanly', async () => {
    vi.mocked(centrifugo.publish).mockRejectedValue(new Error('network failure'));
    const msg = makeMessage({ targetMembershipId: null });

    await expect(publisher.handle(new ChatMessagePostedEvent(msg))).resolves.toBeUndefined();
  });
});

// ---------------------------------------------------------------------------
// ChatMessageEditedPublisher
// ---------------------------------------------------------------------------

describe('ChatMessageEditedPublisher', () => {
  let centrifugo: ICentrifugoClient;
  let publisher: ChatMessageEditedPublisher;

  beforeEach(() => {
    centrifugo = makeCentrifugo();
    publisher = new ChatMessageEditedPublisher(centrifugo);
  });

  it('edit on broadcast message → 1 publish call to session.<id>.chat with updated read model', async () => {
    const msg = makeMessage({
      targetMembershipId: null,
      body: 'Updated body',
      editedAt: '2026-05-17T10:05:00.000Z',
    });
    await publisher.handle(new ChatMessageEditedEvent(msg));

    expect(centrifugo.publish).toHaveBeenCalledOnce();
    const editCall = vi.mocked(centrifugo.publish).mock.calls[0]!;
    expect(editCall[0]).toBe('session.gs-1.chat');
    expect((editCall[1] as Record<string, unknown>)['body']).toBe('Updated body');
    expect((editCall[1] as Record<string, unknown>)['editedAt']).toBe('2026-05-17T10:05:00.000Z');
  });
});

// ---------------------------------------------------------------------------
// ChatMessageDeletedPublisher
// ---------------------------------------------------------------------------

describe('ChatMessageDeletedPublisher', () => {
  let centrifugo: ICentrifugoClient;
  let publisher: ChatMessageDeletedPublisher;

  beforeEach(() => {
    centrifugo = makeCentrifugo();
    publisher = new ChatMessageDeletedPublisher(centrifugo);
  });

  it('deleted broadcast → 1 publish call to session.<id>.chat with tombstone payload', async () => {
    const event = new ChatMessageDeletedEvent({
      id: 'msg-1',
      gameSessionId: 'gs-1',
      authorMembershipId: 'mem-author',
      targetMembershipId: null,
      deletedAt: '2026-05-17T10:10:00.000Z',
    });
    await publisher.handle(event);

    expect(centrifugo.publish).toHaveBeenCalledOnce();
    const deleteCall = vi.mocked(centrifugo.publish).mock.calls[0]!;
    expect(deleteCall[0]).toBe('session.gs-1.chat');
    expect(deleteCall[1]).toMatchObject({
      id: 'msg-1',
      gameSessionId: 'gs-1',
      targetMembershipId: null,
    });
  });
});

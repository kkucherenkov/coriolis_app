/**
 * Unit tests for ChatMessageRepo.
 * Prisma is mocked via vi.fn() on individual model methods — no real DB.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { encodeCursor } from '../domain/chat-cursor';

import { ChatMessageRepo } from './chat-message.repo';

import type { PrismaService } from '../../../common/prisma/prisma.service';

// ---------------------------------------------------------------------------
// Factory helpers
// ---------------------------------------------------------------------------

function makePrismaMock() {
  return {
    chatMessage: {
      create: vi.fn(),
      findUnique: vi.fn(),
      update: vi.fn(),
      findMany: vi.fn(),
      groupBy: vi.fn(),
    },
    gameSessionMembership: {
      findMany: vi.fn(),
    },
    user: {
      findMany: vi.fn(),
    },
  } as unknown as PrismaService;
}

/** Minimal Prisma ChatMessage row returned by CHAT_MESSAGE_SELECT */
function makeRow(overrides: Record<string, unknown> = {}) {
  return {
    id: 'msg-1',
    gameSessionId: 'gs-1',
    authorMembershipId: 'mem-1',
    targetMembershipId: null,
    kind: 'text',
    body: 'Hello',
    systemKey: null,
    systemParams: null,
    createdAt: new Date('2026-05-17T10:00:00.000Z'),
    editedAt: null,
    deletedAt: null,
    ...overrides,
  };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe('ChatMessageRepo', () => {
  let prisma: ReturnType<typeof makePrismaMock>;
  let repo: ChatMessageRepo;

  beforeEach(() => {
    prisma = makePrismaMock();
    repo = new ChatMessageRepo(prisma);

    // Default: membership and user mocks return empty (display names resolve to null)
    vi.mocked(prisma.gameSessionMembership.findMany).mockResolvedValue([]);
    vi.mocked(prisma.user.findMany).mockResolvedValue([]);
  });

  // -------------------------------------------------------------------------
  // insert
  // -------------------------------------------------------------------------

  it('insert: creates a row and returns a read model with resolved displayName', async () => {
    const row = makeRow();
    vi.mocked(prisma.chatMessage.create).mockResolvedValue(row);
    vi.mocked(prisma.gameSessionMembership.findMany).mockResolvedValue([
      { id: 'mem-1', userId: 'user-1' },
    ] as never);
    vi.mocked(prisma.user.findMany).mockResolvedValue([
      { id: 'user-1', displayName: 'Farid' },
    ] as never);

    const result = await repo.insert({
      gameSessionId: 'gs-1',
      authorMembershipId: 'mem-1',
      targetMembershipId: null,
      kind: 'text',
      body: 'Hello',
      systemKey: null,
      systemParams: null,
    });

    expect(prisma.chatMessage.create).toHaveBeenCalledOnce();
    expect(result.id).toBe('msg-1');
    expect(result.authorDisplayName).toBe('Farid');
    expect(result.createdAt).toBe('2026-05-17T10:00:00.000Z');
  });

  // -------------------------------------------------------------------------
  // findById
  // -------------------------------------------------------------------------

  it('findById: returns null when row does not exist', async () => {
    vi.mocked(prisma.chatMessage.findUnique).mockResolvedValue(null);

    const result = await repo.findById('no-such-id');

    expect(result).toBeNull();
    // Should not attempt membership/user lookup if no row
    expect(prisma.gameSessionMembership.findMany).not.toHaveBeenCalled();
  });

  it('findById: returns read model with null displayName when author is null (system message)', async () => {
    const row = makeRow({
      authorMembershipId: null,
      kind: 'system',
      body: null,
      systemKey: 'chat.system.joined',
    });
    vi.mocked(prisma.chatMessage.findUnique).mockResolvedValue(row);

    const result = await repo.findById('msg-1');

    expect(result).not.toBeNull();
    expect(result!.authorDisplayName).toBeNull();
    expect(result!.kind).toBe('system');
  });

  // -------------------------------------------------------------------------
  // list — broadcast, empty
  // -------------------------------------------------------------------------

  it('list: returns empty items and null nextCursor for broadcast with no messages', async () => {
    vi.mocked(prisma.chatMessage.findMany).mockResolvedValue([]);

    const result = await repo.list({
      gameSessionId: 'gs-1',
      callerMembershipId: 'mem-1',
      conversation: 'broadcast',
      cursor: null,
      limit: 50,
    });

    expect(result.items).toHaveLength(0);
    expect(result.nextCursor).toBeNull();
    // Where clause should include targetMembershipId: null
    expect(prisma.chatMessage.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({ targetMembershipId: null }),
      }),
    );
  });

  // -------------------------------------------------------------------------
  // list — broadcast with cursor
  // -------------------------------------------------------------------------

  it('list: applies cursor predicate and returns nextCursor when page overflows', async () => {
    // Simulate limit=2, 3 rows returned → nextCursor should be set
    const rows = [
      makeRow({ id: 'msg-3', createdAt: new Date('2026-05-17T10:02:00.000Z') }),
      makeRow({ id: 'msg-2', createdAt: new Date('2026-05-17T10:01:00.000Z') }),
      makeRow({ id: 'msg-1', createdAt: new Date('2026-05-17T10:00:00.000Z') }),
    ];
    vi.mocked(prisma.chatMessage.findMany).mockResolvedValue(rows);

    const result = await repo.list({
      gameSessionId: 'gs-1',
      callerMembershipId: 'mem-1',
      conversation: 'broadcast',
      cursor: null,
      limit: 2,
    });

    expect(result.items).toHaveLength(2);
    expect(result.nextCursor).not.toBeNull();
    // The dropped item is msg-1 (index 2)
    const expectedCursor = encodeCursor({
      createdAt: new Date('2026-05-17T10:00:00.000Z').toISOString(),
      id: 'msg-1',
    });
    expect(result.nextCursor).toBe(expectedCursor);
  });

  // -------------------------------------------------------------------------
  // list — whisper
  // -------------------------------------------------------------------------

  it('list: builds correct OR clause for whisper conversations', async () => {
    vi.mocked(prisma.chatMessage.findMany).mockResolvedValue([]);

    await repo.list({
      gameSessionId: 'gs-1',
      callerMembershipId: 'mem-caller',
      conversation: 'mem-partner',
      cursor: null,
      limit: 50,
    });

    const callArgs = vi.mocked(prisma.chatMessage.findMany).mock.calls[0]![0]!;
    expect(callArgs.where).toMatchObject({
      gameSessionId: 'gs-1',
      deletedAt: null,
      OR: [
        { authorMembershipId: 'mem-caller', targetMembershipId: 'mem-partner' },
        { authorMembershipId: 'mem-partner', targetMembershipId: 'mem-caller' },
      ],
    });
  });

  // -------------------------------------------------------------------------
  // list — invalid cursor silently ignored
  // -------------------------------------------------------------------------

  it('list: silently ignores an invalid cursor and returns the first page', async () => {
    vi.mocked(prisma.chatMessage.findMany).mockResolvedValue([makeRow()]);

    const result = await repo.list({
      gameSessionId: 'gs-1',
      callerMembershipId: 'mem-1',
      conversation: 'broadcast',
      cursor: 'not-valid-base64url!!!',
      limit: 50,
    });

    // Should still return results (first page)
    expect(result.items).toHaveLength(1);
    // Where clause should NOT have an AND array (no cursor predicate applied)
    const callArgs = vi.mocked(prisma.chatMessage.findMany).mock.calls[0]![0]!;
    expect(callArgs.where).not.toHaveProperty('AND');
  });

  // -------------------------------------------------------------------------
  // updateBody
  // -------------------------------------------------------------------------

  it('updateBody: calls prisma.update with body and editedAt, returns updated read model', async () => {
    const editedAt = new Date('2026-05-17T11:00:00.000Z');
    const updated = makeRow({ body: 'Edited text', editedAt });
    vi.mocked(prisma.chatMessage.update).mockResolvedValue(updated);

    const result = await repo.updateBody('msg-1', 'Edited text', editedAt);

    expect(prisma.chatMessage.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: 'msg-1' },
        data: { body: 'Edited text', editedAt },
      }),
    );
    expect(result.body).toBe('Edited text');
    expect(result.editedAt).toBe(editedAt.toISOString());
  });

  // -------------------------------------------------------------------------
  // softDelete
  // -------------------------------------------------------------------------

  it('softDelete: sets deletedAt and returns read model with deletedAt populated', async () => {
    const deletedAt = new Date('2026-05-17T12:00:00.000Z');
    const deleted = makeRow({ deletedAt });
    vi.mocked(prisma.chatMessage.update).mockResolvedValue(deleted);

    const result = await repo.softDelete('msg-1', deletedAt);

    expect(prisma.chatMessage.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: 'msg-1' },
        data: { deletedAt },
      }),
    );
    expect(result.deletedAt).toBe(deletedAt.toISOString());
  });
});

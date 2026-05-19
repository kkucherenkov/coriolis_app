/**
 * Unit tests for RealtimeService.buildAllowedChannels (widened in Stream C/7).
 *
 * Strategy: mock ISessionAccessRepo, AppConfig, AuthService, and I18nService.
 * Only the channel-building logic is under test here — JWT signing is covered
 * indirectly (we verify the `channels` payload on the decoded token).
 */
import { describe, expect, it, vi } from 'vitest';
import * as jwt from 'jsonwebtoken';

import { RealtimeService } from './realtime.service';

import type { AppConfig, CentrifugoConfig } from '../../common/config/app-config';
import type { ISessionAccessRepo, UserMembership } from './domain/session-ownership.port';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function makeConfig(secret = 'test-secret'): AppConfig {
  return {
    centrifugo: {
      apiUrl: 'http://centrifugo:8000',
      apiKey: 'test-api-key',
      tokenHmacSecret: secret,
      tokenTtlSeconds: 300,
    } satisfies CentrifugoConfig,
  } as AppConfig;
}

function makeSessionAccess(memberships: UserMembership[]): ISessionAccessRepo {
  return {
    findActiveSessionIdsForUser: vi.fn(),
    findActiveMembershipsForUser: vi.fn().mockResolvedValue(memberships),
  };
}

function makeAuth(userId: string) {
  return {
    getSession: vi.fn().mockResolvedValue({ user: { id: userId } }),
  };
}

function makeI18n() {
  return {} as never;
}

function makeRequest() {
  return {} as never;
}

interface DecodedRealtimeJwt {
  sub: string;
  exp: number;
  channels: string[];
  info: {
    memberships: { gameSessionId: string; membershipId: string }[];
  };
}

/** Decode the JWT and return the full payload. */
function decodeToken(token: string, secret: string): DecodedRealtimeJwt {
  return jwt.verify(token, secret) as DecodedRealtimeJwt;
}

/** Decode the JWT and return the `channels` claim. */
function decodeChannels(token: string, secret: string): string[] {
  return decodeToken(token, secret).channels;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe('RealtimeService — buildAllowedChannels (Stream C/7)', () => {
  it('active member of two sessions receives exactly 6 channel entries (3 per session)', async () => {
    const memberships: UserMembership[] = [
      { gameSessionId: 'gs-A', membershipId: 'mem-A' },
      { gameSessionId: 'gs-B', membershipId: 'mem-B' },
    ];

    const service = new RealtimeService(
      makeConfig(),
      makeAuth('user-1') as never,
      makeI18n(),
      makeSessionAccess(memberships),
    );

    const { token } = await service.issueToken(makeRequest());
    const channels = decodeChannels(token, 'test-secret');

    expect(channels).toHaveLength(6);
    expect(channels).toContain('session.gs-A');
    expect(channels).toContain('session.gs-A.chat');
    expect(channels).toContain('session.gs-A.member.mem-A');
    expect(channels).toContain('session.gs-B');
    expect(channels).toContain('session.gs-B.chat');
    expect(channels).toContain('session.gs-B.member.mem-B');
  });

  it('kicked member (leftAt non-null) contributes zero channels — repo returns empty array', async () => {
    const service = new RealtimeService(
      makeConfig(),
      makeAuth('kicked-user') as never,
      makeI18n(),
      makeSessionAccess([]), // repo filter excludes kicked members (leftAt IS NOT NULL)
    );

    const { token } = await service.issueToken(makeRequest());
    const channels = decodeChannels(token, 'test-secret');

    expect(channels).toHaveLength(0);
  });

  it('member of session A is not issued any session.B.* channel', async () => {
    const memberships: UserMembership[] = [{ gameSessionId: 'gs-A', membershipId: 'mem-A' }];

    const service = new RealtimeService(
      makeConfig(),
      makeAuth('user-A') as never,
      makeI18n(),
      makeSessionAccess(memberships),
    );

    const { token } = await service.issueToken(makeRequest());
    const channels = decodeChannels(token, 'test-secret');

    const bChannels = channels.filter((c) => c.startsWith('session.gs-B'));
    expect(bChannels).toHaveLength(0);
    expect(channels).toHaveLength(3);
  });
});

// ---------------------------------------------------------------------------
// Phase 8.5 follow-up #6 — connection info claim for presence wiring.
// Centrifugo propagates the JWT `info` claim verbatim into the `connInfo`
// field on presence / join / leave events for every channel the connection
// subscribes to. Web + mobile clients read this to map a presence entry to
// its membershipId.
// ---------------------------------------------------------------------------

describe('RealtimeService — info claim (Phase 8.5 follow-up #6)', () => {
  it('embeds one info.memberships entry per active membership', async () => {
    const memberships: UserMembership[] = [
      { gameSessionId: 'gs-A', membershipId: 'mem-A' },
      { gameSessionId: 'gs-B', membershipId: 'mem-B' },
    ];

    const service = new RealtimeService(
      makeConfig(),
      makeAuth('user-1') as never,
      makeI18n(),
      makeSessionAccess(memberships),
    );

    const { token } = await service.issueToken(makeRequest());
    const decoded = decodeToken(token, 'test-secret');

    expect(decoded.info.memberships).toEqual([
      { gameSessionId: 'gs-A', membershipId: 'mem-A' },
      { gameSessionId: 'gs-B', membershipId: 'mem-B' },
    ]);
  });

  it('embeds an empty info.memberships array for users with no active memberships', async () => {
    const service = new RealtimeService(
      makeConfig(),
      makeAuth('orphan-user') as never,
      makeI18n(),
      makeSessionAccess([]),
    );

    const { token } = await service.issueToken(makeRequest());
    const decoded = decodeToken(token, 'test-secret');

    expect(decoded.info).toEqual({ memberships: [] });
    expect(decoded.channels).toHaveLength(0);
  });

  it('info.memberships only carries (gameSessionId, membershipId) — no other fields leak', async () => {
    const service = new RealtimeService(
      makeConfig(),
      makeAuth('user-1') as never,
      makeI18n(),
      makeSessionAccess([{ gameSessionId: 'gs-A', membershipId: 'mem-A' }]),
    );

    const { token } = await service.issueToken(makeRequest());
    const decoded = decodeToken(token, 'test-secret');

    expect(Object.keys(decoded.info)).toEqual(['memberships']);
    expect(decoded.info.memberships).toHaveLength(1);
    expect(Object.keys(decoded.info.memberships[0]!).toSorted()).toEqual([
      'gameSessionId',
      'membershipId',
    ]);
  });
});

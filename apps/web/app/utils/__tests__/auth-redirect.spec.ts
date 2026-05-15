/**
 * auth-redirect.spec.ts
 *
 * Unit tests for the pure helpers behind `auth-required.global`. Same
 * pattern as `bridge.spec.ts` / `iconRoll.spec.ts`: the helpers live in
 * `~/utils/auth-redirect.ts` and are exercised here without mounting
 * Nuxt or Better Auth.
 *
 * The middleware itself is a thin wrapper that delegates the decision
 * to `decideAuthAction`; once these assertions pass we trust the
 * middleware's branching.
 */

import { describe, it, expect } from 'vitest';

import { decideAuthAction, isRateLimitedError, type SessionResult } from '../auth-redirect';

describe('isRateLimitedError', () => {
  it('returns false for null / undefined', () => {
    expect(isRateLimitedError(null)).toBe(false);
    expect(isRateLimitedError(undefined)).toBe(false);
  });

  it('returns true when error.status === 429', () => {
    expect(isRateLimitedError({ status: 429 })).toBe(true);
  });

  it('returns true when legacy error.statusCode === 429', () => {
    expect(isRateLimitedError({ statusCode: 429 })).toBe(true);
  });

  it('matches our backend RFC 9457 detail body', () => {
    // Exact string the NestJS http-exception filter emits on throttler hit.
    expect(isRateLimitedError({ message: 'ThrottlerException: Too Many Requests' })).toBe(true);
  });

  it('matches a literal 429 in the message', () => {
    expect(isRateLimitedError({ message: 'Got HTTP 429 from /auth/get-session' })).toBe(true);
  });

  it('matches case-insensitive "rate limit" / "rate-limit"', () => {
    expect(isRateLimitedError({ message: 'Rate limit exceeded' })).toBe(true);
    expect(isRateLimitedError({ message: 'rate-limited by upstream' })).toBe(true);
  });

  it('returns false for unrelated errors', () => {
    expect(isRateLimitedError({ status: 401, message: 'Unauthorized' })).toBe(false);
    expect(isRateLimitedError({ status: 500, message: 'Internal Server Error' })).toBe(false);
    expect(isRateLimitedError({ message: 'Invalid credentials' })).toBe(false);
  });
});

describe('decideAuthAction', () => {
  it('redirects when the result is null (network threw)', () => {
    expect(decideAuthAction(null)).toBe('redirect');
  });

  it('allows when data.user.id is present', () => {
    const r: SessionResult = { data: { user: { id: 'u-1' } }, error: null };
    expect(decideAuthAction(r)).toBe('allow');
  });

  it('redirects when there is neither a session nor a 429', () => {
    const r: SessionResult = { data: null, error: null };
    expect(decideAuthAction(r)).toBe('redirect');
  });

  it('redirects on a 401 (genuinely unauthenticated)', () => {
    const r: SessionResult = { data: null, error: { status: 401, message: 'Unauthorized' } };
    expect(decideAuthAction(r)).toBe('redirect');
  });

  it('does NOT redirect when the session check was rate-limited (status 429)', () => {
    // This is the T-UX-2026-05-15-AUTH-THROTTLE regression guard: a 429
    // on `/auth/get-session` must not bounce the user to /login.
    const r: SessionResult = { data: null, error: { status: 429 } };
    expect(decideAuthAction(r)).toBe('rate-limited-allow');
  });

  it('does NOT redirect when the only signal is a "Too Many Requests" message', () => {
    const r: SessionResult = {
      data: null,
      error: { message: 'ThrottlerException: Too Many Requests' },
    };
    expect(decideAuthAction(r)).toBe('rate-limited-allow');
  });

  it('prefers the session when both data and a 429 error are present', () => {
    // Defensive: if a future server response carries both a valid
    // session payload and a stale 429 (e.g. partial cache), we honour
    // the session.
    const r: SessionResult = {
      data: { user: { id: 'u-2' } },
      error: { status: 429 },
    };
    expect(decideAuthAction(r)).toBe('allow');
  });

  it('redirects when data.user is missing its id', () => {
    const r: SessionResult = { data: { user: {} }, error: null };
    expect(decideAuthAction(r)).toBe('redirect');
  });

  it('redirects when data is an unexpected shape', () => {
    const r: SessionResult = { data: { something: 'else' }, error: null };
    expect(decideAuthAction(r)).toBe('redirect');
  });
});

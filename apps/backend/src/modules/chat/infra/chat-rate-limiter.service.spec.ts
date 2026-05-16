/**
 * Unit tests for ChatRateLimiterService.
 * Uses explicit `now: Date` injection — does NOT use vi.useFakeTimers (fragile).
 * All five tests per plan Task 4.4.
 */
import { beforeEach, describe, expect, it } from 'vitest';

import { ChatRateLimitedError } from '../domain/chat.errors';

import { ChatRateLimiterService } from './chat-rate-limiter.service';

import type { AppConfig } from '../../../common/config/app-config';

function makeConfig(overrides: { maxMessagesPerMinute?: number; burst?: number } = {}): AppConfig {
  return {
    chat: {
      maxBodyBytes: 4096,
      maxMessagesPerMinute: overrides.maxMessagesPerMinute ?? 30,
      burst: overrides.burst ?? 5,
      editWindowSeconds: 300,
    },
  } as unknown as AppConfig;
}

describe('ChatRateLimiterService', () => {
  const t0 = new Date('2026-05-17T10:00:00.000Z');

  // Helper: advance time by `ms` milliseconds from a base date
  function advance(base: Date, ms: number): Date {
    return new Date(base.getTime() + ms);
  }

  let service: ChatRateLimiterService;

  beforeEach(() => {
    service = new ChatRateLimiterService(makeConfig());
  });

  // -------------------------------------------------------------------------
  // 1. Under minute limit: all 30 messages succeed
  // -------------------------------------------------------------------------

  it('allows up to maxMessagesPerMinute messages within one minute window', async () => {
    const config = makeConfig({ maxMessagesPerMinute: 5, burst: 100 });
    service = new ChatRateLimiterService(config);

    for (let i = 0; i < 5; i++) {
      // Space them 200ms apart to avoid burst limit (burst=100, so no burst concern here)
      await expect(service.consume('user-1', advance(t0, i * 200))).resolves.toBeUndefined();
    }
  });

  // -------------------------------------------------------------------------
  // 2. At minute limit: (limit+1)th message throws ChatRateLimitedError
  // -------------------------------------------------------------------------

  it('throws ChatRateLimitedError when minute limit is exceeded', async () => {
    // Use burst=100 so only minute limit fires; minute limit=3
    const config = makeConfig({ maxMessagesPerMinute: 3, burst: 100 });
    service = new ChatRateLimiterService(config);

    // Space messages 200ms apart (within the same 60s window)
    await service.consume('user-1', advance(t0, 0));
    await service.consume('user-1', advance(t0, 200));
    await service.consume('user-1', advance(t0, 400));

    await expect(service.consume('user-1', advance(t0, 600))).rejects.toBeInstanceOf(
      ChatRateLimitedError,
    );
  });

  // -------------------------------------------------------------------------
  // 3. Burst limit is independent of minute limit
  // -------------------------------------------------------------------------

  it('throws ChatRateLimitedError when burst limit is exceeded within 1 second', async () => {
    // minute=100 so only burst fires; burst=3
    const config = makeConfig({ maxMessagesPerMinute: 100, burst: 3 });
    service = new ChatRateLimiterService(config);

    // All within same 1-second window
    await service.consume('user-1', advance(t0, 0));
    await service.consume('user-1', advance(t0, 100));
    await service.consume('user-1', advance(t0, 200));

    await expect(service.consume('user-1', advance(t0, 300))).rejects.toBeInstanceOf(
      ChatRateLimitedError,
    );
  });

  // -------------------------------------------------------------------------
  // 4. Minute window resets after 60 seconds
  // -------------------------------------------------------------------------

  it('resets the minute bucket after the 60-second window expires', async () => {
    const config = makeConfig({ maxMessagesPerMinute: 2, burst: 100 });
    service = new ChatRateLimiterService(config);

    // Fill the minute bucket
    await service.consume('user-1', advance(t0, 0));
    await service.consume('user-1', advance(t0, 500));
    // This would fail in the same window
    await expect(service.consume('user-1', advance(t0, 1_000))).rejects.toBeInstanceOf(
      ChatRateLimitedError,
    );

    // After 60 seconds the window resets — should succeed again
    await expect(service.consume('user-1', advance(t0, 60_001))).resolves.toBeUndefined();
  });

  // -------------------------------------------------------------------------
  // 5. Separate users do not share buckets
  // -------------------------------------------------------------------------

  it('does not share rate limit state between different users', async () => {
    const config = makeConfig({ maxMessagesPerMinute: 1, burst: 100 });
    service = new ChatRateLimiterService(config);

    // user-A fills its minute bucket
    await service.consume('user-A', t0);
    await expect(service.consume('user-A', advance(t0, 100))).rejects.toBeInstanceOf(
      ChatRateLimitedError,
    );

    // user-B has its own fresh bucket — should succeed
    await expect(service.consume('user-B', advance(t0, 100))).resolves.toBeUndefined();
  });
});

/**
 * WHY this file exists:
 * In-memory per-user token bucket rate limiter for chat messages.
 * Single-node v1.1 only — if the backend is sharded, replace with a Redis-backed
 * sliding window (e.g. lua script + EVALSHA) and update the IChatRateLimiter binding.
 *
 * Two independent buckets per user:
 *   - minute: 30 messages per 60-second window (CHAT_RATE_LIMIT_PER_MINUTE)
 *   - burst:  5  messages per 1-second  window (CHAT_RATE_LIMIT_BURST)
 *
 * `consume(userId, now)` accepts an explicit `now: Date` so tests can control time
 * without relying on vi.useFakeTimers (fragile). When called from the command handler,
 * pass `new Date()`.
 *
 * Throws ChatRateLimitedError (429) when either bucket is exhausted.
 */
import { Injectable } from '@nestjs/common';

import { AppConfig } from '../../../common/config/app-config';
import { ChatRateLimitedError } from '../domain/chat.errors';

import type { IChatRateLimiter } from '../domain/chat.ports';

interface Bucket {
  count: number;
  windowStartMs: number;
}

@Injectable()
export class ChatRateLimiterService implements IChatRateLimiter {
  /** Per-user minute bucket: 30 msg / 60 s */
  private readonly minuteBuckets = new Map<string, Bucket>();
  /** Per-user burst bucket: 5 msg / 1 s */
  private readonly burstBuckets = new Map<string, Bucket>();

  constructor(private readonly config: AppConfig) {}

  consume(userId: string, now: Date): Promise<void> {
    // Sync work wrapped to honour the Promise<void> port contract and ensure
    // throws from `tick()` surface as rejected promises (callers `await`).
    try {
      const nowMs = now.getTime();
      const { maxMessagesPerMinute, burst } = this.config.chat;
      this.tick(this.minuteBuckets, userId, nowMs, 60_000, maxMessagesPerMinute);
      this.tick(this.burstBuckets, userId, nowMs, 1000, burst);
      return Promise.resolve();
    } catch (error) {
      return Promise.reject(error instanceof Error ? error : new Error(String(error)));
    }
  }

  /**
   * Advances the sliding window for `key` in `map`.
   * - If the slot is missing or the window has expired: reset to count=1.
   * - If count >= limit: throw ChatRateLimitedError.
   * - Otherwise: increment count.
   */
  private tick(
    map: Map<string, Bucket>,
    key: string,
    nowMs: number,
    windowMs: number,
    limit: number,
  ): void {
    const slot = map.get(key);
    if (!slot || nowMs - slot.windowStartMs >= windowMs) {
      map.set(key, { count: 1, windowStartMs: nowMs });
      return;
    }
    if (slot.count >= limit) {
      throw new ChatRateLimitedError();
    }
    slot.count += 1;
  }
}

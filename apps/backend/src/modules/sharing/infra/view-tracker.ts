/**
 * WHY this file exists:
 * In-memory view-count accumulator for the public character read endpoint.
 * The read path calls recordView(slug) which buffers the count in a Map.
 * The FlushViewTrackerJob drains the buffer every minute in a single batched
 * Prisma transaction — keeping the read path free of DB writes.
 *
 * ADR 0003: Lazy in-memory tracking is acceptable at current scale (single pod).
 * At most 60 seconds of counts can be lost on process restart.
 */
import { Injectable } from '@nestjs/common';

import type { ViewFlushEntry } from '../domain/share-link.ports';

@Injectable()
export class ViewTracker {
  /** Map from slug to accumulated pending view count. */
  private readonly pending = new Map<string, number>();

  /**
   * Increment the pending view count for the given slug by 1.
   * Purely in-memory — no I/O.
   */
  recordView(slug: string): void {
    this.pending.set(slug, (this.pending.get(slug) ?? 0) + 1);
  }

  /**
   * Drain all accumulated entries and return them as a snapshot.
   * Clears the internal buffer atomically from the caller's perspective
   * (single-threaded Node.js event loop guarantees no interleaving).
   */
  drain(): ViewFlushEntry[] {
    if (this.pending.size === 0) return [];

    const entries: ViewFlushEntry[] = [];
    for (const [slug, count] of this.pending) {
      entries.push({ slug, count });
    }
    this.pending.clear();
    return entries;
  }

  /** Exposed for testing — returns the current size of the pending buffer. */
  get pendingSize(): number {
    return this.pending.size;
  }
}

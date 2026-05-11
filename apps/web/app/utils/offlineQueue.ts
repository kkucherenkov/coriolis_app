/**
 * offlineQueue — IDB-backed FIFO of mutations that couldn't reach the server.
 *
 * Shape per entry:
 *   { id, method, url, body, headers, createdAt }
 *
 * Only PATCH / PUT / DELETE are enqueued. POST is excluded because creates
 * depend on a server-assigned id we can't fake. GET is excluded because the
 * SW from T-2026-05-11-007 serves stale reads from cache.
 *
 * Storage uses `idb-keyval` with a single key (`coriolis.offlineQueue`)
 * holding the whole array. The queue is small enough (per-user, only
 * unfinished mutations) that we don't need a custom IDB schema.
 *
 * All exported functions are pure-ish — they touch IDB and `Date.now()`,
 * nothing else. Reactive state lives in `useOfflineQueue` on top.
 */

import { get, set } from 'idb-keyval';

const STORAGE_KEY = 'coriolis.offlineQueue';

export type QueueableMethod = 'PATCH' | 'PUT' | 'DELETE';

export interface QueueEntry {
  /** Unique id (timestamp + random suffix). Stable across reloads. */
  id: string;
  method: QueueableMethod;
  /** Absolute URL the original request targeted. */
  url: string;
  /** Serialized body (null for DELETE). */
  body: string | null;
  /** Subset of headers we replay (Authorization stripped — re-injected at replay). */
  headers: Record<string, string>;
  /** Epoch ms of when the request was queued. */
  createdAt: number;
}

function newId(): string {
  const timestamp = Date.now().toString(36);
  const suffix = Math.random().toString(36).slice(2, 8);
  return `${timestamp}-${suffix}`;
}

export async function listQueue(): Promise<QueueEntry[]> {
  const stored = await get<QueueEntry[]>(STORAGE_KEY);
  return Array.isArray(stored) ? stored : [];
}

export async function enqueue(entry: Omit<QueueEntry, 'id' | 'createdAt'>): Promise<QueueEntry> {
  const queue = await listQueue();
  const full: QueueEntry = { ...entry, id: newId(), createdAt: Date.now() };
  queue.push(full);
  await set(STORAGE_KEY, queue);
  return full;
}

export async function removeEntry(id: string): Promise<void> {
  const queue = await listQueue();
  await set(
    STORAGE_KEY,
    queue.filter((e) => e.id !== id),
  );
}

export async function clearQueue(): Promise<void> {
  await set(STORAGE_KEY, []);
}

export async function count(): Promise<number> {
  const queue = await listQueue();
  return queue.length;
}

/**
 * Pick the queueable subset of a Headers / object shape. We strip
 * Authorization because it may have expired by replay time — the fetch
 * override re-injects the current bearer.
 */
export function serializeHeaders(input: HeadersInit | undefined): Record<string, string> {
  const out: Record<string, string> = {};
  if (!input) return out;
  const headers = input instanceof Headers ? input : new Headers(input);
  for (const [key, value] of headers.entries()) {
    if (key.toLowerCase() === 'authorization') continue;
    out[key] = value;
  }
  return out;
}

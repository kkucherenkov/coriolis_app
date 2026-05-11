/**
 * useOfflineQueue — reactive view of the offline write-queue (T-2026-05-11-008).
 *
 * Singleton-style: the listener and timer state live in module scope so a
 * single `online` handler drains the queue exactly once, no matter how
 * many components import the composable.
 *
 * Exposed shape:
 *   pending  — count of unsent mutations in IDB
 *   status   — 'idle' | 'syncing' | 'synced' | 'error'
 *
 * `idle` covers both "online, queue empty" and "offline, queue empty".
 * `syncing` is briefly true while `drain()` walks the queue.
 * `synced` shows for ~2 s after a successful drain (the banner uses it
 * for the "all changes saved" pulse), then drops back to `idle`.
 * `error` means at least one replay failed and entries are still in IDB.
 */

import { readonly, ref } from 'vue';

import { listQueue, removeEntry, type QueueEntry } from '~/utils/offlineQueue';
import { readBearerToken } from '~/composables/useAuth';

export type OfflineQueueStatus = 'idle' | 'syncing' | 'synced' | 'error';

// Module-scoped singletons. Created lazily on first composable call.
const pending = ref(0);
const status = ref<OfflineQueueStatus>('idle');
let initialised = false;
let draining = false;
let syncedFadeTimer: ReturnType<typeof setTimeout> | null = null;

async function refreshCount(): Promise<void> {
  const queue = await listQueue();
  pending.value = queue.length;
}

/**
 * Standalone refresher for non-Vue callers (e.g. the API plugin's fetch
 * override, which enqueues before any component instance exists). Bumps
 * the module-scoped `pending` ref so the offline banner reflects the
 * newly queued mutation immediately.
 */
export async function refreshOfflineQueueCount(): Promise<void> {
  await refreshCount();
}

async function replayEntry(entry: QueueEntry): Promise<boolean> {
  const headers = new Headers(entry.headers);
  const token = readBearerToken();
  if (token) headers.set('Authorization', `Bearer ${token}`);

  try {
    const response = await globalThis.fetch(entry.url, {
      method: entry.method,
      headers,
      body: entry.body,
      credentials: 'include',
    });
    // Treat 2xx/3xx as success. 4xx/5xx leaves the entry in the queue so
    // the user can intervene (e.g. a 409 conflict the server rejected).
    return response.ok;
  } catch {
    return false;
  }
}

async function drain(): Promise<void> {
  if (draining) return;
  draining = true;
  try {
    const queue = await listQueue();
    if (queue.length === 0) {
      status.value = 'idle';
      return;
    }
    status.value = 'syncing';
    let anyFailed = false;
    for (const entry of queue) {
      const ok = await replayEntry(entry);
      if (ok) {
        await removeEntry(entry.id);
      } else {
        anyFailed = true;
        // Keep going — a later entry might still succeed; the failed one
        // surfaces via `status: 'error'` so the user can refresh / retry.
      }
    }
    await refreshCount();
    if (anyFailed) {
      status.value = 'error';
    } else {
      status.value = 'synced';
      if (syncedFadeTimer !== null) clearTimeout(syncedFadeTimer);
      syncedFadeTimer = setTimeout(() => {
        if (status.value === 'synced') status.value = 'idle';
        syncedFadeTimer = null;
      }, 2000);
    }
  } finally {
    draining = false;
  }
}

function onOnline(): void {
  void drain();
}

function initIfNeeded(): void {
  if (initialised) return;
  initialised = true;
  // Hydrate the count from any queue left over from a previous session.
  void refreshCount();
  if (typeof globalThis.addEventListener === 'function') {
    globalThis.addEventListener('online', onOnline);
  }
}

export function useOfflineQueue() {
  initIfNeeded();
  return {
    pending: readonly(pending),
    status: readonly(status),
    /** Recompute `pending` from IDB. Call after enqueue. */
    refresh: refreshCount,
    /** Trigger replay manually (e.g. a "Retry now" button). */
    drainNow: drain,
  };
}

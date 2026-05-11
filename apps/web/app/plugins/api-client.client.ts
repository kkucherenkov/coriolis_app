/**
 * api-client.client — configures the generated `@app/api-client-ts` SDK
 * singleton at app boot.
 *
 * Authentication is bearer-token based: the backend exposes
 * `Authorization: Bearer <token>` via the better-auth `bearer()` plugin, and
 * the token is captured into localStorage by `useAuth()` on signin/signup.
 * Here we install a fetch override that injects the header on every SDK call
 * so authenticated endpoints (like /api/v1/characters) accept the request.
 *
 * The override also implements the T-2026-05-11-008 offline write-queue:
 * PATCH / PUT / DELETE attempted while `navigator.onLine === false` (or
 * that fail with a network error mid-flight) get persisted to IDB and
 * replayed on reconnect by `useOfflineQueue`. The override returns a
 * synthetic 200 `{}` so the SDK doesn't surface the queued state as an
 * error — autosave callers spread-merge the response into local state,
 * which they've already mutated optimistically.
 *
 * POST is intentionally NOT queued: creates depend on a server-assigned
 * id we can't fake. GET is intentionally NOT queued: the SW read-cache
 * from T-2026-05-11-007 already serves stale GETs offline.
 *
 * SPA-only (`.client` suffix) — Nuxt is configured with `ssr: false`, so this
 * runs once in the browser before any page mounts.
 */
import { client } from '@app/api-client-ts';

import { readBearerToken } from '~/composables/useAuth';
import { refreshOfflineQueueCount } from '~/composables/useOfflineQueue';
import { enqueue, serializeHeaders, type QueueableMethod } from '~/utils/offlineQueue';

const QUEUEABLE = new Set<string>(['PATCH', 'PUT', 'DELETE']);

function isQueueable(method: string | undefined): method is QueueableMethod {
  return method != null && QUEUEABLE.has(method.toUpperCase());
}

function syntheticAck(): Response {
  // 200 + `{}` so the generated SDK parses success and the caller's
  // `{ ...local, ...response }` spread is a no-op on the already-
  // optimistically-updated local state.
  return new Response('{}', {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
}

async function readRequestBody(
  input: RequestInfo | URL,
  init?: RequestInit,
): Promise<string | null> {
  if (init?.body != null) {
    if (typeof init.body === 'string') return init.body;
    if (init.body instanceof Blob) return await init.body.text();
    return JSON.stringify(init.body);
  }
  if (input instanceof Request) {
    try {
      return await input.clone().text();
    } catch {
      return null;
    }
  }
  return null;
}

function resolveUrl(input: RequestInfo | URL): string {
  if (typeof input === 'string') return input;
  if (input instanceof URL) return input.toString();
  return input.url;
}

function resolveMethod(input: RequestInfo | URL, init?: RequestInit): string {
  return (init?.method ?? (input instanceof Request ? input.method : 'GET')).toUpperCase();
}

export default defineNuxtPlugin(() => {
  const { public: pub } = useRuntimeConfig();

  // SDK paths already include `/api/v1/...`, so baseUrl must be the bare
  // backend origin. `authBaseUrl` carries that — `apiBaseUrl` includes the
  // version prefix and would double-up.
  client.setConfig({
    baseUrl: pub.authBaseUrl,
    fetch: async (input, init) => {
      // The Hey API generated client calls `fetch(request)` with a Request
      // object (body + headers including Content-Type already set) and no
      // init. If we build headers from `init?.headers` here we'd start with
      // an empty Headers, only add Authorization, and then `fetch(request,
      // { headers })` overrides the Request's own headers — wiping
      // Content-Type and triggering 415 on every JSON POST/PATCH.
      // Seed the Headers from the Request (or init) and clone via Request
      // so the body / method / signal stay intact.
      const baseHeaders = init?.headers ?? (input instanceof Request ? input.headers : undefined);
      const headers = new Headers(baseHeaders);
      const token = readBearerToken();
      if (token && !headers.has('Authorization')) {
        headers.set('Authorization', `Bearer ${token}`);
      }

      const method = resolveMethod(input, init);
      const queueable = isQueueable(method);

      // Pre-flight: offline + queueable → enqueue without touching the
      // network. The SW from T-007 wouldn't catch mutations anyway
      // (Workbox runtime rules are GET-only).
      if (queueable && typeof navigator !== 'undefined' && !navigator.onLine) {
        const body = await readRequestBody(input, init);
        await enqueue({
          method: method as QueueableMethod,
          url: resolveUrl(input),
          body,
          headers: serializeHeaders(headers),
        });
        await refreshOfflineQueueCount();
        return syntheticAck();
      }

      try {
        if (input instanceof Request && !init) {
          return await globalThis.fetch(new Request(input, { headers }));
        }
        return await globalThis.fetch(input, { ...init, headers });
      } catch (networkError) {
        // Mid-flight failure (TypeError from fetch). For queueable methods
        // treat it the same as offline: persist and ack synthetically so
        // the caller's optimistic UI doesn't roll back.
        if (queueable) {
          const body = await readRequestBody(input, init);
          await enqueue({
            method: method as QueueableMethod,
            url: resolveUrl(input),
            body,
            headers: serializeHeaders(headers),
          });
          await refreshOfflineQueueCount();
          return syntheticAck();
        }
        throw networkError;
      }
    },
  });
});

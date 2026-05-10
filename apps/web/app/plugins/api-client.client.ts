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
 * SPA-only (`.client` suffix) — Nuxt is configured with `ssr: false`, so this
 * runs once in the browser before any page mounts.
 */
import { client } from '@app/api-client-ts';

import { readBearerToken } from '~/composables/useAuth';

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
      const baseHeaders =
        init?.headers ?? (input instanceof Request ? input.headers : undefined);
      const headers = new Headers(baseHeaders);
      const token = readBearerToken();
      if (token && !headers.has('Authorization')) {
        headers.set('Authorization', `Bearer ${token}`);
      }
      if (input instanceof Request && !init) {
        return globalThis.fetch(new Request(input, { headers }));
      }
      return globalThis.fetch(input, { ...init, headers });
    },
  });
});

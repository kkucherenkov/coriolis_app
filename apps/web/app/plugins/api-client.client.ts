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
      const headers = new Headers(init?.headers);
      const token = readBearerToken();
      if (token && !headers.has('Authorization')) {
        headers.set('Authorization', `Bearer ${token}`);
      }
      return globalThis.fetch(input, { ...init, headers });
    },
  });
});

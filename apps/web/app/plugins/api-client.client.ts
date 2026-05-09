/**
 * api-client.client — configures the generated `@app/api-client-ts` SDK
 * singleton at app boot.
 *
 * Without this every fetch from the SDK omits the Better Auth session cookie
 * (`credentials: 'omit'` is the default), so authenticated routes return 401
 * even when the cookie is present. We also override the baseUrl from runtime
 * config so non-localhost deployments work without regenerating the client.
 *
 * SPA-only (`.client` suffix) — Nuxt is configured with `ssr: false`, so this
 * runs once in the browser before any page mounts.
 */
import { client } from '@app/api-client-ts';

export default defineNuxtPlugin(() => {
  const { public: pub } = useRuntimeConfig();

  // SDK paths already include `/api/v1/...`, so baseUrl must be the bare
  // backend origin. `authBaseUrl` carries that — `apiBaseUrl` includes the
  // version prefix and would double-up.
  client.setConfig({
    baseUrl: pub.authBaseUrl,
    credentials: 'include',
  });
});

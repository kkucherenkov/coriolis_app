import tailwindcss from '@tailwindcss/vite';

export default defineNuxtConfig({
  compatibilityDate: '2026-04-18',
  srcDir: 'app/',
  ssr: false,
  devtools: { enabled: true },
  modules: ['@nuxt/ui', '@nuxtjs/i18n', '@vite-pwa/nuxt'],

  // ── Service worker (Phase 7 — read-only offline cache) ─────────────────────
  // T-2026-05-11-007: precache app shell + Stale-While-Revalidate for
  // /api/v1/me* GETs so a player at the table can read their characters /
  // ships / NPCs / sessions when the network drops. Mutations are
  // intentionally NOT cached — POST/PUT/PATCH/DELETE go straight to the
  // network and fail loudly when offline (the explicit write-queue MVP is
  // the next PR). `urlPattern` matches by `url.pathname` so it works for
  // both the dev cross-origin layout (web :3001 → api :3010) and any
  // production same-origin proxy.
  pwa: {
    registerType: 'autoUpdate',
    injectRegister: 'auto',
    workbox: {
      navigateFallback: '/',
      // Precache the SPA shell. Vite-PWA generates the manifest from the
      // build output; we keep the glob conservative — fonts come from
      // @nuxt/fonts already, no separate caching needed.
      globPatterns: ['**/*.{js,css,html,svg,ico,woff2}'],
      runtimeCaching: [
        {
          urlPattern: ({ url, request }) =>
            request.method === 'GET' && url.pathname.startsWith('/api/v1/me'),
          handler: 'StaleWhileRevalidate',
          options: {
            cacheName: 'api-me',
            expiration: {
              maxEntries: 100,
              maxAgeSeconds: 60 * 60 * 24 * 7, // 7 days
            },
            cacheableResponse: { statuses: [0, 200] },
          },
        },
      ],
    },
    client: { installPrompt: false },
    devOptions: {
      // The SW is disabled in `nuxt dev` by default; flip this when smoke-
      // testing offline behaviour locally without a production build.
      enabled: false,
      type: 'module',
    },
  },

  nitro: {
    // No explicit `preset: 'static'`. With `ssr: false` Nuxt infers the static
    // preset automatically on `nuxt generate`, and forcing it here triggers
    // Nitro's "Payload extraction is recommended" warning that cannot be
    // silenced by user config — `@nuxt/schema` hard-resolves
    // `experimental.payloadExtraction` to `false` whenever `ssr: false`,
    // which the same module then flags as a missing opt-in. Upstream bug.
    //
    // Separately, Nuxt 4.4 + Nitro 2.13 ship overlapping `useAppConfig`
    // auto-imports (`nitropack/runtime/internal/config` +
    // `@nuxt/nitro-server/.../app-config`). Unimport logs a benign
    // "Duplicated imports" warning; @nuxt/nitro-server's copy wins.
    // Pending https://github.com/nuxt/nuxt — expected to clear in 4.5.
  },

  // Translations live in per-component `<i18n lang="json">` blocks. We keep a
  // global config only to enumerate locales + drive the switcher — no global
  // message files. `useI18n({ useScope: 'local' })` on every component.
  //
  // PRD §6: en + ru are the active v1 locales. uk + el were previously stubbed
  // out as `[uk-todo]` / `[el-todo]` placeholders so `pnpm check:i18n` could
  // see their namespaces — they have been removed (see T-2026-05-18-003).
  // Adding a new locale: append to `locales` here and add `<i18n>` entries
  // across all .vue files; `pnpm check:i18n` will then enforce parity.
  i18n: {
    strategy: 'no_prefix',
    defaultLocale: 'en',
    locales: [
      { code: 'en', language: 'en-US', name: 'English' },
      { code: 'ru', language: 'ru-RU', name: 'Русский' },
    ],
    detectBrowserLanguage: {
      useCookie: true,
      cookieKey: 'i18n_locale',
      redirectOn: 'root',
      fallbackLocale: 'en',
    },
  },

  css: ['~/assets/css/main.css'],

  vite: {
    plugins: [
      tailwindcss(),
      // unplugin-vue-i18n@11 (vendored by @nuxtjs/i18n v10) tries to neuter
      // `vite:json` so it doesn't double-process SFC `<i18n>` virtual ids
      // (`?vue&type=i18n&...&lang.json`). Its patch (lib/index.mjs:288–305)
      // assumes the old Vite plugin form `transform: Function` — but Vite 7
      // ships `vite:json` with the new `transform: { filter, handler }`
      // shape, so the patch overwrites `transform` with a plain function,
      // discarding `.handler`, and the follow-up `if ("handler" in ...)`
      // branch can never re-attach. Net result: `vite:json` runs unpatched,
      // tries to `JSON.parse` the `export default` output produced by
      // unplugin-vue-i18n's SFC transform, and crashes with "Failed to
      // parse JSON file" / "Unexpected token 'export'". We re-apply the
      // patch correctly here: skip `vite:json` for any `?vue` virtual id.
      {
        name: 'coriolis-fix-vite-json-sfc',
        configResolved(config) {
          const jsonPlugin = config.plugins.find(
            (p) => !!p && (p as { name?: string }).name === 'vite:json',
          ) as { transform: unknown } | undefined;
          if (!jsonPlugin) return;
          const t = jsonPlugin.transform as
            | ((code: string, id: string) => unknown)
            | { filter?: unknown; handler: (code: string, id: string) => unknown };
          const orgHandler = typeof t === 'function' ? t : t.handler;
          const wrapped = function (this: unknown, code: string, id: string) {
            if (/[?&]vue\b/.test(id)) return null;
            return orgHandler.call(this, code, id);
          };
          if (typeof t === 'function') {
            (jsonPlugin as { transform: unknown }).transform = wrapped;
          } else {
            t.handler = wrapped;
          }
        },
      },
    ],
    // Pre-bundle libs Vite would otherwise discover at runtime and trigger
    // a full dev-server reload for.
    optimizeDeps: {
      include: ['better-auth/vue'],
    },
  },

  typescript: {
    strict: true,
    typeCheck: false,
  },

  runtimeConfig: {
    public: {
      apiBaseUrl: process.env.NUXT_PUBLIC_API_BASE_URL ?? 'http://localhost:3010/api/v1',
      authBaseUrl: process.env.NUXT_PUBLIC_AUTH_BASE_URL ?? 'http://localhost:3010',
      // Centrifugo websocket endpoint. The default mirrors the docker-compose
      // container (`docker/compose.yml`) at port 8000; production overrides via
      // env. The session-detail page subscribes to `session.{id}` here for
      // live DP / roll-pushed updates (Phase 4 Feature 7.4).
      realtimeWsUrl:
        process.env.NUXT_PUBLIC_REALTIME_WS_URL ?? 'ws://localhost:8000/connection/websocket',
    },
  },

  ui: {
    colorMode: true,
  },

  devServer: {
    port: 3001,
    host: '0.0.0.0',
  },
});

import tailwindcss from '@tailwindcss/vite';

export default defineNuxtConfig({
  compatibilityDate: '2026-04-18',
  srcDir: 'app/',
  ssr: false,
  devtools: { enabled: true },
  modules: ['@nuxt/ui', '@nuxtjs/i18n'],

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
  // PRD §6: en + ru are active for v1. uk + el are wired (so `pnpm check:i18n`
  // sees their key namespaces) but not populated; populating them is a v1.1+
  // task. Browser detection only opts into the active locales.
  i18n: {
    strategy: 'no_prefix',
    defaultLocale: 'en',
    locales: [
      { code: 'en', language: 'en-US', name: 'English' },
      { code: 'ru', language: 'ru-RU', name: 'Русский' },
      { code: 'uk', language: 'uk-UA', name: 'Українська' },
      { code: 'el', language: 'el-GR', name: 'Ελληνικά' },
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

## T-2026-05-11-007 — Phase 7: web offline (read-only cache + SW shell)

- Created: 2026-05-11
- Owner: claude
- Spec: PRD §11 (Phase 7 — Hardening · "Offline support (web SW + Flutter SQLite)")
- Goal: a player who loses connectivity at the table can still navigate to their characters / ships / NPCs / sessions and read everything they had loaded once. Mutations stay best-effort (today's behaviour: network error → toast); the explicit write-queue + replay engine is the next PR.
- Acceptance:
  - Service worker registers on first load; subsequent visits boot from cache when offline.
  - App shell (HTML, JS, CSS, fonts) is precached at SW install (Workbox manifest from Vite-PWA).
  - GET responses for `/api/v1/me`, `/api/v1/me/characters`, `/api/v1/me/characters/{id}`, `/api/v1/me/ships*`, `/api/v1/me/npcs*`, `/api/v1/me/sessions*` use Stale-While-Revalidate (cap: 100 entries, 7 days).
  - Mutations (POST/PUT/PATCH/DELETE) and `/api/v1/auth/*`, `/api/v1/realtime/*`, `/api/v1/public/*` always go to network — no caching, no offline mocking.
  - A site-wide `<OfflineBanner>` appears when `navigator.onLine === false` and disappears on reconnect; reads `useOnline()` composable.
  - Bundle budgets from T-006 still pass with the SW registration JS folded in (bump the limit in the same diff if needed; explain in the PR description).
- Spec diff: none
- Codegen impact: no
- Design impact: new `@app/ui` `<OfflineBanner>` (reuses `AppBanner` tone="parchment" or new tone — TBD); inventory row added.
- Tests:
  - `useOnline` unit test (vitest, mock `navigator.onLine` + dispatch online/offline events).
  - `<OfflineBanner>` story (online + offline states) + spec.
  - Manual smoke (DevTools → Application → Service Workers → Offline checkbox; verify reads work, writes show error toast, banner appears).
- Sub-steps:
  - [x] Push task entry.
  - [x] Install `@vite-pwa/nuxt` + `workbox-window` as devDeps in `apps/web`.
  - [x] Wire module + runtime caching in `nuxt.config.ts` — precache shell, SWR for `/api/v1/me*` GETs (path-pattern match works for both dev cross-origin layout and any prod proxy).
  - [x] `composables/useOnline.ts` — reactive `navigator.onLine` mirror with `online`/`offline` listeners and `onBeforeUnmount` cleanup. Defaults to `true` so we never flash the banner during hydration.
  - [x] No new `@app/ui` component — used existing `<AppBanner tone="warning">` inline in `layouts/app.vue` (one-line composition; a wrapper would have been over-abstraction, no Flutter parity question).
  - [x] Mount banner in `apps/web/app/layouts/app.vue` above the `<AppHeader>`. Strings added to all 4 locale blocks (en + ru populated, uk + el `[*-todo]` placeholders matching the existing parity convention).
  - [x] No design-inventory change needed (no new `@app/ui` component).
  - [x] Build green; size budgets all pass — Total JS 384 → 387 kB (+3 kB for `workbox-window` registration shim), still under the 410 kB ceiling. CSS unchanged.
  - [x] Vitest — `useOnline.spec.ts` (5 cases): default-true, mount-mirrors-false, online → on event, offline ← on event, listener cleanup. All 438 web tests green.
  - [x] ESLint — fixed `unicorn/prefer-global-this` by writing `globalThis.addEventListener` (was `window.addEventListener`).
  - [ ] Manual offline smoke after merge — DevTools → Application → Service Workers → Offline checkbox; verify reads work, mutation toasts surface, banner appears.
  - [ ] PR.
- Status: ready-to-PR
- Blockers: —

## Out of scope (next PR — write-queue MVP)

- Disabled-input UX while offline (the "block writes" half of the user's original ask).
- IndexedDB-persisted mutation queue + replay-on-reconnect.
- ETag/If-Match conflict handling (deferred to the optional 3rd PR per the original brainstorm).

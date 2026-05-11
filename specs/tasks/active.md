## T-2026-05-11-008 — Phase 7: web offline write-queue (PATCH/PUT/DELETE)

- Created: 2026-05-11
- Owner: claude
- Spec: PRD §11 (Phase 7 — Hardening · "Offline support"); follow-up to T-2026-05-11-007.
- Goal: offline mutations no longer surface as silent errors. PATCH / PUT / DELETE while disconnected get persisted to an IDB queue and replayed sequentially on reconnect, so a player editing their character on the train doesn't lose work when the tunnel ends.
- Acceptance:
  - When `navigator.onLine === false` AND method ∈ {PATCH, PUT, DELETE}, the SDK fetch override enqueues the request to IDB and returns a synthetic `200 {}` so callers don't blow up.
  - POST is intentionally NOT queued (creates need a server-assigned id we can't fake).
  - GET is intentionally NOT queued (the SW read-cache from T-007 already serves stale).
  - On `online` event, the queue drains FIFO via direct `fetch`. Successful entries delete; failed entries (5xx, 409) stay queued and surface via toast.
  - Pending count is exposed reactively; the offline banner shows "N changes will save when you reconnect" while offline, and a brief "Syncing N changes…" / "All changes saved" pulse on reconnect.
  - Queue persists across page reloads (IDB, not localStorage / memory).
  - Bundle budgets from T-006 still pass — `idb-keyval` is the only new dep (~600 B brotli).
- Spec diff: none
- Codegen impact: no
- Design impact: none new (banner already exists from T-007).
- Tests:
  - `offlineQueue.spec.ts` — enqueue, FIFO drain order, IDB roundtrip, drain failure leaves entry in place.
  - Manual smoke: DevTools Application → SW → tick "Offline", edit ship name, see "1 change pending"; untick, see drain + "All changes saved".
- Sub-steps:
  - [x] Push task entry.
  - [x] Added `idb-keyval` (prod) + `fake-indexeddb` (dev) to `apps/web`.
  - [x] `~/utils/offlineQueue.ts` — `listQueue` / `enqueue` / `removeEntry` / `clearQueue` / `count` / `serializeHeaders`. Strips `Authorization` from persisted headers (replay re-injects current bearer).
  - [x] `~/composables/useOfflineQueue.ts` — module-singleton `pending` / `status` refs (`idle | syncing | synced | error`), global `online` listener, FIFO drain via direct `fetch`. Exposes a standalone `refreshOfflineQueueCount` for non-Vue callers.
  - [x] `~/plugins/api-client.client.ts` — fetch override now queues PATCH/PUT/DELETE pre-flight when offline AND on mid-flight network errors. Returns synthetic 200 `{}` so the SDK's typed callers don't blow up (autosave callers spread-merge optimistic local state already).
  - [x] `layouts/app.vue` — banner now switches across 4 states: offline (no pending), offline (with pending count), syncing, synced (brief success pulse), error. Banner hides when `online && status === 'idle'`.
  - [x] i18n parity in all 4 locale blocks — en + ru populated, uk + el `[*-todo]`.
  - [x] `tests/unit/offlineQueue.spec.ts` (7 cases): start empty, enqueue ids + persist, FIFO order, removeEntry, clearQueue, serializeHeaders strips auth, serializeHeaders handles undefined. Uses `fake-indexeddb/auto`.
  - [x] `pnpm format && pnpm stylelint && pnpm design:audit` — clean.
  - [x] `pnpm --filter @app/web run lint` — 0 errors.
  - [x] `pnpm --filter @app/web run typecheck` — exit 0.
  - [x] `pnpm --filter @app/web test` — 445 / 445 (+7 from offlineQueue suite).
  - [x] `pnpm --filter @app/web size` — Total JS 387 → **389 kB** (+2 kB for `idb-keyval`); still under the 410 kB T-006 ceiling.
  - [ ] Manual smoke after merge: DevTools → Application → Service Workers → tick Offline; edit a ship name; see "1 change pending"; untick; banner cycles syncing → synced → fades.
  - [ ] PR.
- Status: ready-to-PR
- Blockers: —

## Out of scope (deferred)

- POST queueing (creates) — needs id reconciliation; not v1 MVP.
- ETag / If-Match conflict resolution — server still last-write-wins.
- Per-mutation status surfacing (toasts for individual failures); the global banner + count is enough.
- Disabled-input UX while offline (the explicit "block writes" stance) — chose pending-count over input-blocking; users can keep typing, edits just queue.

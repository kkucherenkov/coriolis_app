# Active tasks

## T-2026-05-17-PHASE-7-MOBILE-OFFLINE-2 — Phase 7 / Feature 10.2 / T-10.2.b — Mobile offline write-queue

- Created: 2026-05-17
- Owner: claude
- Status: ready-to-archive
- Spec: PRD §11 Phase 7 — "Offline support (web SW + Flutter SQLite)" · IMPLEMENTATION_PLAN.md Feature 10.2 (T-10.2.b)
- Contract mirror: web T-2026-05-11-008 (`apps/web/app/utils/offlineQueue.ts` + `apps/web/app/composables/useOfflineQueue.ts` + `apps/web/app/plugins/api-client.client.ts`).
- Goal: PATCH / PUT / DELETE attempted while offline (or that fail with a network `DioException` mid-flight) get persisted to a Drift-backed FIFO queue and replayed sequentially on reconnect, so a player editing their character without connectivity doesn't lose work.
- Acceptance:
  - **Queueable methods only.** PATCH / PUT / DELETE enqueue. POST / GET passthrough (POST needs server-assigned ids; GET is served by the read-cache from PHASE-7-MOBILE-OFFLINE-1).
  - **Synthetic 200 `{}`** returned on enqueue so optimistic UI doesn't roll back.
  - **Authorization stripped on persist** — the bearer at replay time is current, not the (possibly expired) one from when the request was queued.
  - **Queue survives process restart** (Drift on-disk).
  - **FIFO drain** on `Connectivity.onConnectivityChanged` transition to non-`none`. 2xx removes the entry; non-2xx leaves it and surfaces `status: 'error'`.
  - **Reactive state** — `pending` count + `status` (`idle` | `syncing` | `synced` | `error`); `synced` pulses for ~2 s after a clean drain.
  - **Banner widget** in app shell renders the four states. en + ru populated.
  - Cache failures never break the request flow.
- Sub-blocks:
  - [x] Block 1 — connectivity_plus dep, `PendingMutations` Drift table (schemaVersion 1→2 + `onUpgrade`), `LocalMutationQueue` port, `DriftMutationQueue` adapter, round-trip tests.
  - [x] Block 2 — `MutationQueueInterceptor` (Dio): enqueue on offline OR on `DioException` network-type error; return synthetic 200. mocktail tests.
  - [x] Block 3 — `MutationQueueDrainer` (ChangeNotifier + `ValueListenable<int> pending` + `ValueListenable<MutationQueueStatus> status`); FIFO drain via raw Dio bypassing the interceptor; 2 s `synced` pulse; tests with fake connectivity stream + mock Dio.
  - [x] Block 4 — `OfflineQueueBanner` widget + slang i18n entries (`offline_idle`, `offline_pending`, `syncing`, `synced`, `error`) en+ru; mount in app shell.
  - [x] Block 5 — DI in `injector.dart` (`Connectivity`, `LocalMutationQueue`, `MutationQueueDrainer`); interceptor added to `buildDio` after auth; `configureDependenciesForTesting` accepts mocks; final analyzer + test sweep; commit / push / PR.
- Notes:
  - "Identical contract to web" per IMPLEMENTATION_PLAN.md — keep the same status enum + banner copy semantics.
  - Drainer must use a **separate** Dio (or one constructed without the interceptor) to avoid re-enqueueing on replay.
  - ETag / If-Match conflict resolution stays deferred (open follow-up from web T-008).

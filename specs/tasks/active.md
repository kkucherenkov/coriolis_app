# Active tasks

## T-2026-05-19-005 — Phase 8.5 follow-up #10: mobile `chatDockedCollapsed` from `/me/settings`

- Created: 2026-05-19
- Status: in-progress
- Goal: Mobile reads/writes `chatDockedCollapsed` via `GET /api/v1/me` + `PATCH /api/v1/me`, replacing any local-only fallback. Debounced write (~600ms), silent-on-failure, in-memory cache update.
- Scope: `apps/mobile` only — backend, web, specs already done.
- Checklist:
  - [ ] `features/me/domain/` — `MeProfile` entity + `MeRepository` interface
  - [ ] `features/me/data/` — `MeRepositoryImpl` (Dio direct, GET + PATCH /me)
  - [ ] `features/sessions/presentation/blocs/chat_dock/` — `ChatDockCubit` + `ChatDockState`
  - [ ] Wire cubit into `PlayerSessionDetailPage` — hydrate + toggle
  - [ ] Register `MeRepository` + `ChatDockCubit` in injector
  - [ ] Unit tests: hydrate, debounced write, offline-safe
  - [ ] Widget test: dock control reflects cubit state
  - [ ] `flutter analyze` clean
  - [ ] `flutter test` green

## T-2026-05-17-DEEP-LINK-SETUP — Deep-link configuration (mobile + web)

- Created: 2026-05-16
- Status: blocked — waiting on marketing host availability
- Goal: Configure `app_links` (mobile) + `apple-app-site-association` / `assetlinks.json` (web) so that tapping an invite URL on a phone opens the native app instead of the browser.
- Gate: `APP_LINKS_HOST` env var must be live (currently unset across the monorepo — `grep -r APP_LINKS_HOST apps/ docker/` returned zero matches).
- Design ref: `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md` decision #5 ("defer until host available").
- Unblocks: T-11.1.1.l from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Notes: The web invite-join page at `/app/sessions/join/:token` works as a plain web link without deep-link configuration. This is the correct v1.1 state per decision #5. When the marketing host is provisioned: add iOS Universal Links manifest, Android App Links assetlinks.json, and `app_links` mobile package wiring.

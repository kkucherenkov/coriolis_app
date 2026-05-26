# Active tasks

## T-2026-05-25-001 — Character sheet impeccable pass (harden/clarify/layout/polish)

- Created: 2026-05-25
- Owner: claude
- Spec: design follow-up from `/impeccable critique` snapshot `.impeccable/critique/2026-05-25T15-10-18Z__apps-web-app-pages-app-characters-id-vue.md` (29/40)
- Goal: resolve the critique's P0/P1/P2 + minor on `apps/web/app/pages/app/characters/[id].vue`.
- Spec diff: none (no API/route change)
- Codegen impact: no
- Sub-steps:
  - [x] P0: surface silent save failures on attr/skill/HP/MP (no longer roll back silently)
  - [x] P1: dead tabs Talents/Notes/Share → disabled + "soon" affordance
  - [x] P1: "Saved" commit-button label → dedicated `apply` key
  - [x] P2: tab↔panel ARIA (role=tabpanel, aria-controls/labelledby, arrow-key nav)
  - [x] P2: delete + injury-remove via AppConfirm (focus-trap, confirm)
  - [x] minor: useAutoSave flush() on unmount; roller __result-label overflow guard; injury rapid-save guard; advanced-note legibility; 44px injury touch target
  - [x] lint + typecheck + affected specs green (548 web unit tests pass, eslint/stylelint/prettier clean, i18n parity ok)
- Status: in-progress — awaiting commit/PR
- Blockers: —

## T-2026-05-17-DEEP-LINK-SETUP — Deep-link configuration (mobile + web)

- Created: 2026-05-16
- Status: blocked — waiting on marketing host availability
- Goal: Configure `app_links` (mobile) + `apple-app-site-association` / `assetlinks.json` (web) so that tapping an invite URL on a phone opens the native app instead of the browser.
- Gate: `APP_LINKS_HOST` env var must be live (currently unset across the monorepo — `grep -r APP_LINKS_HOST apps/ docker/` returned zero matches).
- Design ref: `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md` decision #5 ("defer until host available").
- Unblocks: T-11.1.1.l from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Notes: The web invite-join page at `/app/sessions/join/:token` works as a plain web link without deep-link configuration. This is the correct v1.1 state per decision #5. When the marketing host is provisioned: add iOS Universal Links manifest, Android App Links assetlinks.json, and `app_links` mobile package wiring.

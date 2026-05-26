# Active tasks

## T-2026-05-26-001 — Click-the-dot stat editing (AppDotInput)

- Created: 2026-05-26
- Owner: claude
- Spec: confirmed shape brief (this session) — follow-up to PR #64 deferral
- Goal: replace the popover-stepper edit on attributes + skills with direct click-the-dot via a new interactive `AppDotInput` (role=slider).
- Spec diff: none (no API/route change)
- Codegen impact: no
- Sub-steps:
  - [x] new `@app/ui` `AppDotInput` (role=slider, click/keyboard, hover preview, enlarged touch hit) + story + spec + index export
  - [x] `AppStatBlock` gains `editable` mode (renders AppDotInput, emits update:value) + story/spec
  - [x] integrate into sheet: attributes + skills use AppDotInput; remove popovers/steppers + dead state
  - [x] debounced optimistic commit (350ms) reusing the statError rollback path
  - [x] lint + typecheck + ui & web specs green (1125 ui + 548 web; eslint/stylelint/prettier clean on touched files; i18n parity ok)
  - [x] polish pass (slider aria-valuetext, dead CSS/keys/SCSS-vars removed)
- Status: in-progress — awaiting commit/PR. Remaining: manual browser pass (mobile tap targets, click-idiom feel) — flagged risk in brief.
- Blockers: —

## T-2026-05-17-DEEP-LINK-SETUP — Deep-link configuration (mobile + web)

- Created: 2026-05-16
- Status: blocked — waiting on marketing host availability
- Goal: Configure `app_links` (mobile) + `apple-app-site-association` / `assetlinks.json` (web) so that tapping an invite URL on a phone opens the native app instead of the browser.
- Gate: `APP_LINKS_HOST` env var must be live (currently unset across the monorepo — `grep -r APP_LINKS_HOST apps/ docker/` returned zero matches).
- Design ref: `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md` decision #5 ("defer until host available").
- Unblocks: T-11.1.1.l from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Notes: The web invite-join page at `/app/sessions/join/:token` works as a plain web link without deep-link configuration. This is the correct v1.1 state per decision #5. When the marketing host is provisioned: add iOS Universal Links manifest, Android App Links assetlinks.json, and `app_links` mobile package wiring.

# Active tasks

## T-2026-05-20-002 — Phase 8.5 follow-up #9: Storybook a11y addon enabled in CI

- Created: 2026-05-20
- Status: in-progress
- Goal: Wire `@storybook/addon-a11y` + `@storybook/test-runner` axe sweep into the CI Quality job so every story fixture runs axe-core with WCAG 2.1 AA ruleset; zero violations gate.
- Scope: `packages/ui` only — `.storybook/preview.ts`, `.storybook/test-runner.ts`, `package.json` scripts, `docs/done/phase-8.md` scope cleanup (drop follow-up #1 and #2, add status tick for #9).
- [ ] Confirm addon/runner config matches WCAG 2.1 AA requirements
- [ ] Ensure test-runner respects per-story `parameters.a11y.disable` overrides
- [ ] Verify `test:storybook:ci` script is correct and CI step unchanged
- [ ] Run storybook:build + test:storybook:ci locally; document violation count before/after
- [ ] Scope cleanup in docs/done/phase-8.md: remove #1 (deep-link) and #2 (Redis rate-limiter), renumber, add #9 status tick
- [ ] Update active.md → done.md, open PR


## T-2026-05-17-DEEP-LINK-SETUP — Deep-link configuration (mobile + web)

- Created: 2026-05-16
- Status: blocked — waiting on marketing host availability
- Goal: Configure `app_links` (mobile) + `apple-app-site-association` / `assetlinks.json` (web) so that tapping an invite URL on a phone opens the native app instead of the browser.
- Gate: `APP_LINKS_HOST` env var must be live (currently unset across the monorepo — `grep -r APP_LINKS_HOST apps/ docker/` returned zero matches).
- Design ref: `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md` decision #5 ("defer until host available").
- Unblocks: T-11.1.1.l from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Notes: The web invite-join page at `/app/sessions/join/:token` works as a plain web link without deep-link configuration. This is the correct v1.1 state per decision #5. When the marketing host is provisioned: add iOS Universal Links manifest, Android App Links assetlinks.json, and `app_links` mobile package wiring.

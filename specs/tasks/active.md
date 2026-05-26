# Active tasks

## T-2026-05-26-002 — AppDotInput affordance + sheet a11y/concept follow-ups

- Created: 2026-05-26
- Owner: claude
- Spec: `/impeccable critique` re-run snapshot `.impeccable/critique/2026-05-26T09-01-10Z__apps-web-app-pages-app-characters-id-vue.md` (34/40); user chose "affordance + hover −", scope "all".
- Goal: resolve the click-the-dot discoverability/decrement regression + P2/P3/Sam a11y from the re-critique.
- Spec diff: none
- Codegen impact: no
- Sub-steps:
  - [ ] AppDotInput: visible affordance (empty-dot rings, whole-control hover), explicit −/+ stepper (hover/focus reveal on fine, always on coarse, space reserved — no layout shift), click-dot = set-exactly (remove footgun step-down)
  - [ ] AppDotInput a11y: aria-valuetext "{label}: {n} of {max}", roledescription/instructions, unfilled-dot contrast ≥3:1
  - [ ] update AppDotInput + AppStatBlock story/spec
  - [ ] sheet: one-time inline edit hint near Attributes/Skills; per-control save pulse (P2)
  - [ ] P3 bug: concept rendered via t() in hero vs raw in identity card → one localized computed
  - [ ] lint + typecheck + ui & web specs green; impeccable detect clean
- Status: in-progress
- Blockers: —

## T-2026-05-17-DEEP-LINK-SETUP — Deep-link configuration (mobile + web)

- Created: 2026-05-16
- Status: blocked — waiting on marketing host availability
- Goal: Configure `app_links` (mobile) + `apple-app-site-association` / `assetlinks.json` (web) so that tapping an invite URL on a phone opens the native app instead of the browser.
- Gate: `APP_LINKS_HOST` env var must be live (currently unset across the monorepo — `grep -r APP_LINKS_HOST apps/ docker/` returned zero matches).
- Design ref: `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md` decision #5 ("defer until host available").
- Unblocks: T-11.1.1.l from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Notes: The web invite-join page at `/app/sessions/join/:token` works as a plain web link without deep-link configuration. This is the correct v1.1 state per decision #5. When the marketing host is provisioned: add iOS Universal Links manifest, Android App Links assetlinks.json, and `app_links` mobile package wiring.

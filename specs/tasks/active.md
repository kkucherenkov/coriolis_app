# Active tasks

## T-2026-05-26-003 — Critique re-run P1 fixes (char sheet, ship sheet, @app/ui)

- Created: 2026-05-26
- Owner: claude
- Spec: critique re-run `.impeccable/critique/2026-05-26T10-12..10-15Z__*.md`; user chose blocks 1+2+3 in parallel; P0 (forge `POST items` 400) already fixed separately.
- Goal: resolve the 5 P1s from the re-run across three surfaces.
- Spec diff: none
- Codegen impact: no
- Sub-steps:
  - [x] Char sheet [P1] talents render as raw slugs (`personal-menacing`) → id-path via `findCatalogTalentById` in `useTalentLocalization`; spec added (8 tests)
  - [x] Char sheet [P1] skill names truncate (`Mele…`, `Infiltr…`) → `minmax(min-content, 1fr)` + removed nowrap/ellipsis from `&__skill-name`
  - [x] @app/ui [P1] Storybook canvas off-brand near-black → `preview.css` fixed to `var(--color-bg)`; backgrounds toolbar void+parchment added
  - [x] Ship sheet [P1] card monotony + sprawl → two-column composition (3fr|2fr), default-collapse empty Notes/History, tighten rhythm
  - [x] Ship sheet [P1] stat editing diverges → `AppStatPair` created (story+spec, 21 tests, axe-clean); adopted on ship sheet with Hull+Energy as pair counters
  - [x] lint + typecheck + ui & web specs green (run in `coriolis-companion-web-1`); scoped format only — UI 1149 / web 556 tests, typecheck clean, changed files lint-clean (12 pre-existing @app/ui lint errors in untouched AppDie/AppField/AppIconCoriolis/AppProgress left as-is)
- Status: done — pending PR
- Blockers: —

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

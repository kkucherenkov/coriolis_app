# Active tasks

LIFO stack. Newest task on top. Full audit context: [`docs/audits/design-2026-05-14.md`](../../docs/audits/design-2026-05-14.md). All entries below are the follow-up tickets staged from that audit, consolidated into 5 parent tasks. Typography schema (T-2026-05-14-002) landed; T-2026-05-14-003 (v1 design atoms) is `in-progress`, the rest stay `queued` until their predecessor lands.

---

## T-2026-05-14-006 — Backfill design documentation to handoff parity

- Created: 2026-05-14
- Owner: claude
- Spec: [`docs/audits/design-2026-05-14.md`](../../docs/audits/design-2026-05-14.md) §2 + handoff `/tmp/coriolis-handoff/coriolis-app/project/specs/design/`
- Goal: project design docs match the handoff's coverage so engineering has a single source of truth for patterns, voice, motifs, a11y, i18n.
- Acceptance:
  - `specs/design/PATTERNS.md` authored — page padding scale, card composition order, hero grid template, empty-state cadence, banner recipes, modal contract (backdrop click is **not** a close trigger), button taxonomy, view-only pattern triad.
  - `specs/design/CONTENT.md` authored — voice ("steward, not a host"), in-product taxonomy (Bridge / Library / Push / Icon / Mystic), number formatting (`/` HP separator, ✶ U+2736 successes, `b` birr), dice flavor template, copy do/don't list.
  - `FOUNDATIONS.md` backfilled — motif density rule (`restrained | balanced | maximum`), composite typography tokens, shadow semantics, opacity semantics, hard rules ("Forum never inside chat", min font 24px @ 1920×1080, no `<small>`, "no raw hex in screens").
  - Canonical `A11Y.md` extracted — keyboard map (arrow-key roving for tablist, listbox/radio), focus-ring contract (`--focus-ring = var(--brand-brass-light)`, 2px outline + 2px soft-glow), color-is-not-the-only-signal matrix, landmark map, PR-gate checklist, RTL readiness. (`docs/A11Y_AUDIT.md` is a point-in-time snapshot — separate doc.)
  - `I18N.md` design-layer added — Cyrillic stress-test, `domain.subject.detail` key naming, plural design (`=1{}other{}` + ru one/few/many/other), `Intl.RelativeTimeFormat`, untranslated-nouns list.
  - **Forum-Cyrillic conflict resolved** between handoff `I18N.md:L110-L114` (Latin-only + Cormorant Garamond fallback) and `docs/DESIGN.md` §3 (full Cyrillic). Pick one and update both.
- Spec diff: none
- Codegen impact: no
- Design impact: docs only
- Tests: none (doc PRs reviewed via the spec-reviewer agent)
- Sub-steps:
  - [ ] author `specs/design/PATTERNS.md`
  - [ ] author `specs/design/CONTENT.md`
  - [ ] backfill `FOUNDATIONS.md` (motif density, shadow/opacity semantics, hard rules)
  - [ ] extract canonical `A11Y.md`
  - [ ] add I18N design layer + resolve Forum-Cyrillic conflict
  - [ ] update `specs/design/README.md` reading order + gap log
- Status: queued
- Blockers: —

---

## T-2026-05-14-005 — Close remaining v1 surface gaps

- Created: 2026-05-14
- Owner: claude
- Spec: [`docs/audits/design-2026-05-14.md`](../../docs/audits/design-2026-05-14.md) §4 follow-ups 9–12
- Goal: bring wizard, mobile ship sheet, mobile combat tracker, and landing to v1 parity with the handoff.
- Acceptance:
  - Wizard step count reconciled across handoff (8) / web (7) / mobile (6). Canonical inventory specced (likely 8: Origin · Concept · Group · Attributes · Icon · Skills · Talents · Gear). Origin + Gear added on web + mobile; Group added on mobile; ordering matches spec.
  - `apps/mobile/lib/features/ships/` implemented — Flutter ship sheet on parity with `apps/web/app/pages/app/ships/[id].vue`.
  - Mobile combat expanded from `widgets/active_combat_card.dart` to full initiative tracker: initiative list, DP pool, sticky toolbar (End-encounter / End-round / Next-turn).
  - Landing (`apps/web/app/pages/index.vue`) gains 4 arabesque corners, top-nav locale toggle, 3-feature grid (Sheet / Share / Run), starfield bg, fan-project disclaimer footer.
- Spec diff: none (surface-only work)
- Codegen impact: no
- Design impact: consumes atoms from T-2026-05-14-003
- Tests: Vitest page specs (web), Flutter widget tests (mobile), Playwright smoke for landing
- Sub-steps:
  - [ ] **T-WIZARD-STEP-COUNT** — spec canonical step inventory; add missing steps (Origin + Gear on web+mobile, Group on mobile); fix ordering
  - [ ] **T-MOBILE-SHIP-SHEET** — implement `apps/mobile/lib/features/ships/`
  - [ ] **T-MOBILE-COMBAT-TRACKER** — expand combat to full initiative tracker + DP pool + sticky toolbar
  - [ ] **T-LANDING-FRAMING** — arabesque corners, locale-toggle nav, 3-feature grid, starfield bg, fan-project footer
- Status: queued
- Blockers: T-2026-05-14-003 (atom layer must land first)

---

## T-2026-05-14-004 — Ship the Bridge dashboard

- Created: 2026-05-14
- Owner: claude
- Spec: [`docs/audits/design-2026-05-14.md`](../../docs/audits/design-2026-05-14.md) §4 (Dashboard / Bridge row) + handoff `SURFACES.md` Bridge section
- Goal: auth users land on the Bridge — three-card cycle-time / sync / aphorism surface — instead of a flat character list. Single largest surface gap per the audit.
- Acceptance:
  - `apps/web/app/pages/app/dashboard.vue` implements the Bridge (3-card layout).
  - Greeting eyebrow, cycle-time stat, sync indicator visible on first paint.
  - Footer aphorism rendered.
  - Auth redirect target switched from `/app/characters` to `/app/dashboard` (currently `apps/web/app/pages/index.vue:11`).
  - i18n keys for RU + EN; passes a11y gate (focus order, landmarks, contrast).
- Spec diff: none (surface only — data sources already exist)
- Codegen impact: no
- Design impact: consumes `AppPanelTitle`, `AppWordmark`, `AppArabesqueCorner` from T-2026-05-14-003
- Tests: Vitest page spec + Playwright smoke
- Sub-steps:
  - [ ] create `pages/app/dashboard.vue` with 3-card grid
  - [ ] greeting eyebrow + cycle-time stat + sync indicator cards
  - [ ] footer aphorism block
  - [ ] flip auth redirect to `/app/dashboard`
  - [ ] i18n keys (RU + EN)
  - [ ] a11y pass + Playwright smoke
- Status: queued
- Blockers: T-2026-05-14-003 (AppPanelTitle + AppWordmark required)

---

## T-2026-05-14-003 — Scaffold critical v1 design atoms

- Created: 2026-05-14
- Owner: claude
- Spec: [`docs/audits/design-2026-05-14.md`](../../docs/audits/design-2026-05-14.md) §3.1, §3.2 + handoff `COMPONENTS.md` + handoff `primitives.jsx`
- Goal: ship the v1 atom layer that unblocks sheets, wizard, dashboard, dice-roller.
- Acceptance:
  - `AppPanelTitle` + `AppSwash` exist in `packages/ui` with Storybook stories, colocated specs, and Flutter mirrors.
  - `AppWordmark` (Forum uppercase + swash + Inter eyebrow lockup) — Storybook + Flutter mirror. Used by landing, dashboard hero, session-join card.
  - `AppSkillRow` — Storybook + Flutter mirror. Used by character sheet (desktop + mobile) and wizard step 6.
  - `AppButton` gains `secondary` and `mystic` variants. `mystic` = "Push the Roll" CTA in the dice roller.
  - `AppIconMedallion` (brass disc + Forum monogram + astrolabe ticks + `glow` prop) — Storybook + Flutter mirror. Used by wizard step 5. NB: do **not** refactor existing `AppIconCoriolis` — add as a new atom.
  - Portrait strategy decided + shipped: either extend `AppAvatar` with an `astrolabe` shape prop **or** ship `AppPortrait` wrapping `AppAvatar`. Used across sheet hero, combat tracker, GM crew.
  - Cosmetic drift accepted as out-of-scope for this task but documented: `AppStarOrnament` variant, `AppArabesqueCorner` default colour, `AppDie` visual style, `AppChip`/`AppConditionPill` name mapping (see audit §3.2).
- Spec diff: none
- Codegen impact: no
- Design impact: 6 new/extended `@app/ui` components + Flutter mirrors
- Tests: Storybook stories + colocated Vitest specs + Flutter widget tests; visual diff in Storybook
- Sub-steps:
  - [x] `/component-new AppPanelTitle` (+ `AppSwash` paired sibling) — landed 2026-05-14 (Vue + Flutter + stories + specs)
  - [x] `/component-new AppWordmark` — landed 2026-05-14 (Vue + Flutter + stories + specs; auto-scales eyebrow + swash from `size`)
  - [x] `/component-new AppSkillRow` — landed 2026-05-14 (Vue + Flutter + 9 stories + 16 Vue specs + 13 Flutter widget tests; brass / mystic tones, `name` slot/builder override for the key-chip case, rank clamp 0…rankMax)
  - [ ] extend `AppButton` with `secondary` + `mystic` variants (not /component-new — variant extension)
  - [ ] `/component-new AppIconMedallion`
  - [ ] decide Portrait strategy (extend `AppAvatar` vs ship `AppPortrait`) → implement
  - [ ] publish handoff→project component name map (see audit §3.3)
- Status: in-progress
- Blockers: —  (T-2026-05-14-002 landed)

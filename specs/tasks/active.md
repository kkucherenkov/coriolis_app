# Active tasks

LIFO stack. Newest task on top. Full audit context: [`docs/audits/design-2026-05-14.md`](../../docs/audits/design-2026-05-14.md). Typography schema (T-2026-05-14-002), the v1 atom layer (T-2026-05-14-003), and the design-doc backfill (T-2026-05-14-006) have all landed (see `done.md`). The remaining surface-layer tasks are T-2026-05-14-005 (wizard / mobile parity / landing) and T-2026-05-14-004 (Bridge dashboard) — both unblocked.

---

## T-2026-05-14-005 — Close remaining v1 surface gaps

- Created: 2026-05-14
- Owner: claude
- Spec: [`docs/audits/design-2026-05-14.md`](../../docs/audits/design-2026-05-14.md) §4 follow-ups 9–12
- Goal: bring wizard, mobile ship sheet, mobile combat tracker, and landing to v1 parity with the handoff.
- Acceptance:
  - Wizard step inventory specced canonically per ST3001 (not handoff). Spec doc: [`specs/design/CHARACTER_WIZARD.md`](../design/CHARACTER_WIZARD.md). Code reorder + Gear backend split into the follow-up sub-steps below.
  - `apps/mobile/lib/features/ships/` implemented — Flutter ship sheet on parity with `apps/web/app/pages/app/ships/[id].vue`.
  - Mobile combat expanded from `widgets/active_combat_card.dart` to full initiative tracker: initiative list, DP pool, sticky toolbar (End-encounter / End-round / Next-turn).
  - Landing (`apps/web/app/pages/index.vue`) gains 4 arabesque corners, top-nav locale toggle, 3-feature grid (Sheet / Share / Run), starfield bg, fan-project disclaimer footer.
- Spec diff: none for the spec sub-step; `T-WIZARD-GEAR-BACKEND` will require an OpenAPI diff.
- Codegen impact: only `T-WIZARD-GEAR-BACKEND` (wallet endpoints).
- Design impact: consumes atoms from T-2026-05-14-003; spec adds [`CHARACTER_WIZARD.md`](../design/CHARACTER_WIZARD.md) to the design-doc family.
- Tests: Vitest page specs (web), Flutter widget tests (mobile), Playwright smoke for landing.
- Sub-steps:
  - [x] **T-WIZARD-STEP-COUNT** (spec) — canonical 8-step inventory authored in [`specs/design/CHARACTER_WIZARD.md`](../design/CHARACTER_WIZARD.md); ST3001-faithful (Biography → Concept → Role → Attributes → Skills → Talents → Icon → Gear). Resolved handoff vs rulebook conflict in §5. _Block 1, 2026-05-14._
  - [ ] **T-WIZARD-WEB-REORDER** — rename `Step{N}*.vue`, set `TOTAL_STEPS = 8`, reshuffle imports in `apps/web/app/pages/app/characters/new.vue`, swap legacy `step.N.*` i18n keys to `wizard.step.<name>.*`, update Vitest page spec.
  - [ ] **T-WIZARD-MOBILE-PARITY** — add Role step, add CrewConcept field to Biography, reorder steps to canonical 8, port the i18n key rename in `apps/mobile/lib/i18n/characters_<locale>.i18n.json`.
  - [ ] **T-WIZARD-GEAR-BACKEND** — design wallet (`birr` balance) + starting-kit derivation per (amplua, role, upbringing) per ST3001 amplua tables. Spec in `packages/specs/openapi/openapi.yaml` first.
  - [ ] **T-WIZARD-GEAR-UI** — once backend ships, add Step 8 Gear on web + mobile (per-amplua picker + Bazaar shop).
  - [ ] **T-WIZARD-ICON-ROLL** — add the optional "Roll d66 for me" CTA on the Icon step, mapping d66 → IconId via the rulebook table.
  - [ ] **T-MOBILE-SHIP-SHEET** — implement `apps/mobile/lib/features/ships/`.
  - [ ] **T-MOBILE-COMBAT-TRACKER** — expand combat to full initiative tracker + DP pool + sticky toolbar.
  - [ ] **T-LANDING-FRAMING** — arabesque corners, locale-toggle nav, 3-feature grid, starfield bg, fan-project footer.
- Status: in-progress (spec landed; code reorder + Gear backend queued).
- Blockers: T-WIZARD-GEAR-UI is blocked by T-WIZARD-GEAR-BACKEND. Other sub-steps are independent.

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
- Blockers: T-2026-05-14-003 landed — ready to start any time.

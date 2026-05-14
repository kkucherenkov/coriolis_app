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
  - [x] **T-WIZARD-STEP-COUNT** (spec) — canonical 8-step inventory authored in [`specs/design/CHARACTER_WIZARD.md`](../design/CHARACTER_WIZARD.md); ST3001-faithful (Biography → Concept → Role → Attributes → Skills → Talents → Icon → Gear). Resolved handoff vs rulebook conflict in §5. _Block 1, 2026-05-14 (commit `3f55bde`)._
  - [x] **T-WIZARD-WEB-REORDER** — `Step{N}*.vue` renamed via git mv, imports + render order in `new.vue` re-threaded, `step.N.*` i18n keys migrated to `wizard.step.<id>.*` (EN/RU/UK/EL), Vitest spec rebound to step 2 (Concept) for name validation, Playwright e2e step ordering updated. `TOTAL_STEPS` stays at 7 until Gear ships. _Block 2, 2026-05-14 (commit `e61f691`)._
  - [x] **T-WIZARD-ICON-ROLL** — d66 helper extracted to `apps/web/app/utils/iconRoll.ts` (deterministic table — each Icon gets 4 of 36 outcomes, canonical order); "Roll d66" mystic CTA added to `Step7Icon.vue` with EN/RU copy + UK/EL stubs; Vitest spec locks the table. _Block 3, 2026-05-14._
  - [ ] **T-WIZARD-MOBILE-DOMAIN-ALIGN** _(precursor — was T-WIZARD-MOBILE-PARITY)_ — current mobile cubit / state diverges far from the backend domain model: `origin` uses handoff naming (`stationary | zenithian | firstcome | nomad`) instead of free string; `upbringing` only has 2 hardcoded options (`plebeian | statesman`) vs backend's 3 (`plebeian | stationary | aristocrat`); no `iconId` field (icons are an out-of-canon enum `theJudiciary | theLegionnaire | …` and stored as `notes: "icon:…"`); no `role`, `crewConcept`, `mutant`, `mutantLineage`. Step 2 PATCH encodes biography as `concept: "origin:…|upbringing:…|age:…"`. Realign `WizardDraft` + cubit + Step* widgets to the backend `Character` shape **before** attempting the canonical step reorder; otherwise the reorder ships broken data.
  - [ ] **T-WIZARD-MOBILE-REORDER** _(blocked by T-WIZARD-MOBILE-DOMAIN-ALIGN)_ — once the cubit is aligned: rename `step_{N}_*.dart`, add `step_3_role.dart`, add CrewConcept field to Biography, set canonical 7-step ordering, migrate i18n keys in `apps/mobile/lib/i18n/characters_<locale>.i18n.json` to `wizard.step.<id>.*`.
  - [x] **T-WIZARD-GEAR-BACKEND** (spec) — `Character.birr` (mutable wallet) + `CharacterUpdate.birr` added to OpenAPI; wallet lifecycle (`birr = startingWealth` on forge, immutable while draft) documented in [`CHARACTER_WIZARD.md` §3.8](../design/CHARACTER_WIZARD.md). _Block 4, 2026-05-14 (commit `226937f`)._
  - [x] **T-WIZARD-GEAR-BACKEND-IMPL** — Prisma `birr Int @default(500)` on Character + migration `20260514000001_add_character_birr` (backfills `birr = startingWealth`); new `BirrDraftImmutableError` (`BIRR_DRAFT_IMMUTABLE` / 422); `create-character.handler.ts` seeds `birr = startingWealth` on every create; `update-character.handler.ts` rejects draft birr PATCHes, re-derives birr on draft upbringing change, accepts birr PATCHes on active; `duplicate-character.handler.ts` resets birr to startingWealth on copy; `share-link.repo.ts` selects + maps birr; OpenAPI promotes `birr` to `required:` and codegen ships it as a non-optional field. Backend tests: 954/954 (5 new assertions in `update-character.handler.spec.ts § birr (wallet)`). _Block 5, 2026-05-14._
  - [ ] **T-WIZARD-GEAR-BACKEND-DERIVE** — starting-kit derivation rule: choose between (a) backend computes per-amplua starter pack on forge, or (b) client renders the picker reading a static catalogue. Spec in OpenAPI / @app/specs first.
  - [ ] **T-WIZARD-GEAR-UI** — once backend impl ships, add Step 8 Gear on web + mobile (per-amplua picker + Bazaar shop). `TOTAL_STEPS` flips from 7 → 8.
  - [ ] **T-MOBILE-SHIP-SHEET** — implement `apps/mobile/lib/features/ships/`.
  - [ ] **T-MOBILE-COMBAT-TRACKER** — expand combat to full initiative tracker + DP pool + sticky toolbar.
  - [x] **T-LANDING-FRAMING** — `apps/web/app/pages/index.vue` rebuilt: 4 `AppArabesqueCorner`s (brass-deep), top-nav locale switcher (EN/RU/UK/EL pills sourced from Nuxt i18n config), `AppWordmark` hero (size 88), 3-feature grid (Sheet · Share · Run) with EN/RU copy + UK/EL stubs, two-layer radial-gradient starfield (suppressed under `prefers-reduced-motion`), fan-project + IP-attribution footer. _Block 6, 2026-05-14._
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
  - Auth redirect target switched from `/app/characters` to `/app/dashboard`.
  - i18n keys for RU + EN; passes a11y gate (focus order, landmarks, contrast).
- Sub-steps:
  - [x] `pages/app/dashboard.vue` with 3-card grid (cycle / sync / roster) + AppArabesqueCorner pair + AppWordmark hero + AppPanelTitle per card. _Block 7, 2026-05-14._
  - [x] greeting eyebrow (`useAuth().getSession()` → name/email) + cycle clock (`Intl.DateTimeFormat` ticking every minute) + sync indicator (`navigator.onLine` + relative-time-formatted last-sync) + roster card (live count via `useCharactersApi.list`, with empty / error / browse states). _Block 7._
  - [x] footer aphorism — three Coriolis lines, deterministic day-of-year pick. _Block 7._
  - [x] flip auth redirect: `apps/web/app/pages/index.vue`, `pages/login.vue`, `pages/signup.vue` now point at `/app/dashboard`. _Block 7._
  - [x] i18n keys (EN + RU complete; UK + EL — see follow-up below).
  - [x] **T-BRIDGE-I18N-STUBS** — UK + EL stubs landed for every `wizardLabel` / `greeting.*` / `card.*` / `sync.*` / `aphorism.*` key on the dashboard. _Block 8, 2026-05-14._
  - [x] **T-BRIDGE-TESTS (unit)** — pure helpers extracted to `apps/web/app/utils/bridge.ts` (`pickAphorism`, `formatCycleClock`, `formatCycleDate`, `formatSyncLabel`); locked by `app/utils/__tests__/bridge.spec.ts` (16 assertions: deterministic day-of-epoch picker, 24h clock shape, locale-respecting long-form date, offline / pending / seconds / minutes / hours branches of the sync label, plus a no-`t`-call invariant on the relative-time branch). _Block 8, 2026-05-14._
  - [ ] **Follow-up:** Playwright smoke for `/app/dashboard` (mounted page integration). Wait until the Bridge gets a real-time channel binding so the smoke covers the live state, not just the first paint.
- Status: shipped on web (block 7) + helpers extracted, unit-tested, EN/RU/UK/EL i18n complete (block 8); Playwright smoke remains the only follow-up.
- Blockers: — (T-2026-05-14-003 atom layer landed 2026-05-14)

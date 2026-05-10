# Done tasks

_Archive of shipped tasks. Never delete entries — cancelled tasks go here with reason._

## T-2026-05-10-003 — Phase 4 mobile (Flutter): dice + sessions + DP live updates

- Completed: 2026-05-10
- Owner: claude
- Spec: PRD §11 Phase 4. Same backend that the web blocks
  (T-2026-05-10-002) consumed. Mobile previously had only auth /
  characters / settings features.
- Goal: Bring the Coriolis dice loop to mobile so a player at the
  table can roll + push from their character sheet, browse history,
  and see Darkness Points tick live during a GM-run session.
- Result: shipped on `main` across four feature commits + a codegen
  prep commit + a band-aid fix for an upstream openapi-generator
  bug. All blocks landed continuously per the updated workflow rule.
  - `fae41e0` `chore(codegen): regenerate dart api-client built_value .g.dart files`
  - `22b0a79` `feat(mobile): T-2026-05-10-003 Block 1 — rolls feature + dice bottom sheet`
  - `6190e02` `feat(mobile): T-2026-05-10-003 Block 2 — roll history list inside dice sheet`
  - `013764d` `fix(api-client-dart): add missing ShipModuleSlot import to ship_module_*`
  - `59e1a42` `feat(mobile): T-2026-05-10-003 Block 3 — sessions list + detail with GM controls`
  - `e8abc66` `feat(mobile): T-2026-05-10-003 Block 4 — Centrifugo live updates on session detail`
- Spec diff: none. Codegen impact: only the dart `.g.dart` files
  needed regeneration (build_runner). Two new flutter deps:
  `centrifuge ^0.18.0` (dart Centrifugo client) and `intl` (used by
  the relative-timestamp helper — already on the transitive graph).
- Acceptance check (against the original list):
  - ✅ Character sheet exposes a Roll FAB that opens a bottom-sheet
    roller (pool stepper 1–10, label, Roll, Push). Push gating
    mirrors `RulesEngine.canPush` (already-pushed + exhausted) so
    the disabled state surfaces without a 422 round-trip.
  - ✅ Same bottom sheet scrolls below the roller into a compact
    history list with relative timestamps; tap opens a detail
    dialog with the full dice strip + pool + hits + absolute
    datetime. Mobile UX trade vs web: one screen, one mental
    model — no separate "Rolls" tab on the sheet.
  - ✅ A Game Sessions screen at `/app/sessions` (reachable via
    casino-icon action on the characters list AppBar) lists
    active / archived sessions with FAB → create + popup-menu
    archive toggle. Detail page branches on `me.id ==
    session.ownerId`.
  - ✅ Detail page subscribes to `session.{id}` over Centrifugo
    via `shared/realtime/SessionRealtime` (wraps `centrifuge`
    0.18.0). `dp.changed` patches the visible counter via
    `applyDpChanged`; `roll.pushed` surfaces a 3-second SnackBar.
    Token rotation via `ClientConfig.getToken`. Subscription
    closes on `Cubit.close()`.
- Tests: 65/65 mobile (53 → 65, +12 new across DiceRoller and
  RollHistory cubits). flutter analyze clean modulo the
  pre-existing `built_collection` dev-dep warning + ui_flutter
  `withOpacity` deprecation infos.
- Drive-by drop-off:
  - The regenerated dart SDK shipped `Concept` as an EnumClass; the
    mobile `character_repository_impl` was bridged via
    `Concept.valueOf(...)` / `.name`. Domain-level `concept` is
    still wire-string — promoting it to a typed enum is a
    follow-up.
  - openapi-generator's output for the four oneOf'd ship-module
    discriminator subclasses references `ShipModuleSlot` without
    importing it. The .dart parents got the missing import; the
    matching .g.dart files inherit via `part of`. Long-term fix is
    to migrate to `@hey-api/openapi-ts`-style codegen (Phase-7
    hardening item).
- Open follow-ups:
  - Cursor-pagination UI on `/app/sessions` (cap at 20).
  - Character assignment UX on the mobile detail page —
    deliberately deferred. The mobile detail is glance-only; heavy
    "set up the session" workflow stays on web.
  - Cross-route tap target for `/app/sessions` from a global nav
    (e.g. bottom-nav rebuild) — currently only reachable via the
    characters-list AppBar action.
  - Translator pass for uk/el on the new mobile strings.

## T-2026-05-10-002 — Phase 4 web frontend: dice + sessions + DP + live updates

- Completed: 2026-05-10
- Owner: claude
- Spec: PRD §11 Phase 4 (Dice & Sessions). Backend was already
  shipped between `phase-3-complete` and `97c62ae` (Roll module,
  GameSession CRUD, DP audit log, AsyncAPI session channels,
  Centrifugo publishing). Web SPA had none of it before this task.
- Goal: Wire the existing Phase-4 backend into the web SPA so a
  player can roll dice (and push), browse roll history, and see
  Darkness Points update live during a GM-run session.
- Result: shipped on `main` across five feature commits + per-block
  bookkeeping. Each block landed continuously per the updated
  `feedback_block_workflow` rule.
  - `4e18df2` `feat(web): T-2026-05-10-002 Block 1 — useRollsApi + dice roller widget`
  - `ae27f42` `feat(web): T-2026-05-10-002 Block 2 — roll history list + detail modal`
  - `9b78301` `feat(web): T-2026-05-10-002 Block 3 — sessions index + detail skeleton`
  - `65dfafa` `feat(web): T-2026-05-10-002 Block 4 — DP controls + audit log + assignment`
  - `1b9fb40` `feat(web): T-2026-05-10-002 Block 5 — Centrifugo live updates on session detail`
- Spec diff: none. Codegen impact: none. Backend +1 dependency:
  `centrifuge` JS client added to `apps/web` for the Block-5
  websocket subscription.
- Acceptance check (against the original list):
  - ✅ From a character sheet, a player can pick a pool size, label
    the roll, click "Roll", see the dice result, and push when
    eligible. Push gating mirrors `RulesEngine.canPush`
    (already-pushed + exhausted) so the disabled state surfaces
    without a 422 round-trip.
  - ✅ Recent Rolls panel shows last 50 in reverse chrono with
    hits / pushed badge / relative time; row click opens an
    `AppModal` with full dice + pool + absolute timestamp.
  - ✅ `/app/sessions` lists owner's sessions with active /
    archived tabs, inline create form (auto-redirects to detail),
    and per-card archive / unarchive actions.
  - ✅ `/app/sessions/[id]` branches GM vs player. GM gets DP +/-
    + delta-with-reason form, audit log tail, character
    `<select>` assign / unassign. Players see read-only DP +
    assigned list.
  - ✅ Detail page subscribes to `session.{id}` over Centrifugo;
    `dp.changed` patches the visible counter and prepends a
    synthetic audit row (de-duped against the GM's own adjust);
    `roll.pushed` surfaces a 5-second toast above the DP card.
    "Live" / "Reconnecting" badge tracks connection state. Token
    rotation handled by Centrifuge's `getToken` callback.
- Tests: 53/53 web (mounting deferred to Playwright e2e — same
  pattern as the rest of the auth + sheet surface). 434/434
  backend (unchanged from T-2026-05-10-001). typecheck clean. lint
  zero errors at every block boundary.
- Open follow-ups:
  - Cursor-pagination UI on `/app/sessions` (currently capped at
    first 20).
  - Visibility-change reconnect on the realtime subscription (rely
    on Centrifuge's auto-retry for now).
  - Toast component in `@app/ui` to replace the inline
    `AppBanner + Transition` pattern used for `roll.pushed`.
  - uk/el strings on the new pages — same translator-pass
    deferral as T-2026-05-10-001.

## T-2026-05-10-001 — T-005 + T-004 follow-ups before next epic

- Completed: 2026-05-10
- Owner: claude
- Spec: carried-over follow-ups recorded on T-2026-05-09-005 (character
  creation rules alignment) and T-2026-05-09-004 (signup page) entries
  earlier in this file.
- Goal: Close the three open code follow-ups from those tasks so a
  fresh epic starts on a clean slate. Translator-pass items (uk/el
  copy) were explicitly out of scope and remain tracked under "Open
  follow-ups" below.
- Result: shipped on `main` across three feature commits + bookkeeping.
  Each block landed in its own session per the saved
  `feedback_block_workflow` rule.
  - `0dc1f87` `feat(character): T-2026-05-10-001 Block 1 — locale-aware talent rendering`
  - `41f61c5` `feat(character): T-2026-05-10-001 Block 2 — amplua-filtered personal pool`
  - `cdfca86` `feat(web): T-2026-05-10-001 Block 3 — forgot-password + reset-password flow`
- Spec diff: none — all three blocks are frontend-only (Block 1 reads
  the existing catalog at render time; Block 2 ships a new map in
  `@app/specs` consumed only by the wizard; Block 3 wires Better
  Auth's existing `request-password-reset` / `reset-password` routes,
  which were already configured in `auth.service.ts` from T-005).
- Acceptance check (against the original list):
  - ✅ Character sheet renders catalog talents (`kind ≠ personal`) in
    the active i18n locale via `useTalentLocalization`
    (`apps/web/app/composables/useTalentLocalization.ts`); user-
    edited rows fall through to stored name/description.
  - ✅ Wizard Step 6 personal-pool picker narrows to ST3001 ch.2
    recommendations per amplua via
    `RECOMMENDED_PERSONAL_TALENTS_BY_CONCEPT`; default-on toggle,
    auto-drops when the picked talent isn't in the new amplua's
    list.
  - ✅ `/login` shows "Forgot password?" link → `/forgot-password`
    → `auth.requestPasswordReset` → email link →
    `/reset-password?token=…` → `auth.resetPassword` → bounce to
    `/login`. Page also renders a "Reset link incomplete" block
    when the token query parameter is missing.
- Tests: 434/434 backend (425 → 434, +9 new specs covering
  `findCatalogTalentByName`, `pickLocalized`,
  `getRecommendedPersonalTalents`), 53/53 web. typecheck clean. lint
  zero errors.
- Open follow-ups (deferred — need a translator, not code):
  - `uk` and `el` strings on `/signup`, `/login`,
    `/forgot-password`, `/reset-password` are still
    `[uk-todo]/[el-todo]` placeholders.
  - `uk` and `el` entries in `packages/specs/src/talents.ts` — same
    shape, same reason.
  - SDK-method naming clarification: BA's email-and-password reset
    surface is `auth.requestPasswordReset` (not `forgetPassword`,
    which is reserved for the email-OTP plugin). Memorialised here
    so a future agent reading the BA docs doesn't reach for the
    wrong name.

## T-2026-05-09-003 — Epic 7 Feature 7.3: Darkness Points + push wiring

- Completed: 2026-05-10
- Owner: claude
- Spec: Epic 7, Feature 7.3, tasks T-7.3.1.a, T-7.3.1.b, T-7.3.1.c
- Goal: DP adjustment endpoint, DpEvent audit log, RollPushedEvent → +1 DP
  wiring.
- Result: shipped on `main` across the spec → migration → handler →
  event-bus chain. The internal-caller path (RollPushedHandler emitting
  `UpdateDpCommand` with `source: ROLL_PUSH`) bypasses the GM-owner ACL
  via a discriminated `callerKind` on the command, not a magic flag —
  the original task entry's "internal flag" wording was tightened to a
  proper sum type during implementation.
  - `2ecbcd0` `feat(specs): DP adjustment endpoint + DpEvent audit log (v0.8.1)`
  - `b6d2172` `chore(codegen): regenerate clients after DP spec (v0.8.1)`
  - `a447aa2` `feat(backend): Prisma DpEvent migration (dp-events)`
  - `afd5472` `feat(backend): UpdateDpCommand + DpEvent persistence + ACL`
  - `a2a7ade` `feat(backend): wire RollPushedEvent to +1 DP via internal command`
  - `6cac7a2` `feat(backend): publish dp.changed on every DpEvent insert`
- Spec diff: openapi `0.8.0 → 0.8.1` (additive — two new paths, two
  schemas).
- Acceptance check (against the original list):
  - ✅ `POST /api/v1/game-sessions/{id}/dp` adjusts DP atomically
    inside a Prisma transaction (`update-dp.handler.ts`).
  - ✅ `GET /api/v1/game-sessions/{id}/dp/events` returns paginated
    `DpEvent` audit log (`list-dp-events.handler.ts`).
  - ✅ `DpEvent` persisted per adjustment with `source: GM_MANUAL |
ROLL_PUSH`. The original spec also listed `SYSTEM` — dropped during
    implementation because no caller path emits it; can be added later
    if a maintenance script needs it.
  - ✅ Only the GM owner may apply a negative delta; internal `ROLL_PUSH`
    callers bypass the ACL (`update-dp.handler.spec.ts` line 81 +
    "internal caller bypasses GM-owner ACL" case).
  - ✅ `RollPushedHandler` emits `UpdateDpCommand` when
    `gameSessionId != null` (`roll-pushed.handler.ts` +
    `roll-pushed.handler.spec.ts`).
  - ✅ 22 new unit specs (12 update-dp + 4 list-dp-events + 6
    roll-pushed-handler — comfortably above the ≥12 floor).

## T-2026-05-09-002 — Epic 7 Feature 7.1 backend: DiceModule

- Completed: 2026-05-10
- Owner: claude
- Spec: Epic 7, Feature 7.1, tasks T-7.1.1.a, T-7.1.1.b, T-7.1.1.e
- Goal: Server-side Coriolis dice roller with push mechanic. Create roll,
  list history, push reroll.
- Result: shipped on `main`. `canPush()` lives in the cross-module
  `rules-engine` (not inside `dice/domain/`) so rolls and conditions can
  share invariants without a circular import — fix `6a8182b` later
  promoted its return type from `boolean | string` to a real
  discriminated union (`{ ok: true } | { ok: false; reason: ... }`).
  - `4d98fff` `feat(specs): Roll resource + push endpoint (v0.8.0)`
  - `0550b4e` `feat(backend): Prisma Roll migration`
  - `048704a` `feat(backend): DiceModule — create + list rolls`
  - `6a8182b` `fix(backend): CanPushResult is a real discriminated union`
  - `b0ef2a3` `feat(backend): publish roll.pushed when a roll is pushed`
- Spec diff: openapi `0.7.1 → 0.8.0` (new `Roll`, `RollCreate`,
  `RollList` schemas + 3 paths).
- Acceptance check (against the original list):
  - ✅ `POST /api/v1/characters/{id}/rolls` → 201 `Roll`, server rolls
    pool d6 with `crypto.randomInt` (`create-roll.handler.ts`).
  - ✅ `GET /api/v1/characters/{id}/rolls?limit=50` → 200 `RollList`,
    last 50 ordered desc (`list-rolls.handler.ts`).
  - ✅ `PATCH /api/v1/rolls/{id}/push` → 200 `Roll | 422
ROLL_NOT_PUSHABLE` (`push-roll.handler.ts` +
    `roll.errors.ts:ROLL_NOT_PUSHABLE`).
  - ✅ `canPush(roll, conditions)` returns `{ ok, reason? }`, gated on
    exhausted + already-pushed (`rules-engine` in
    `apps/backend/src/modules/rules-engine`).
  - ✅ `RollPushedEvent` emitted on the bus with `{ rollId, characterId,
gameSessionId, hits }` (`roll-pushed.event.ts`); both the DP
    handler and the Centrifugo `roll.pushed` publisher subscribe to it.
  - ✅ 20 new unit specs (6 create-roll + 8 push-roll + 6 list-rolls —
    above the ≥18 floor).

## T-2026-05-09-001 — implement share-link backend (Epic 6 Feature 6.1)

- Completed: 2026-05-10
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md §5.4, Plan §6.1
- Goal: Enable public read-only sharing of characters via unguessable slug
  URLs with owner controls (create, list, revoke) and lazy view tracking.
- Result: shipped on `main`. The original "stub OG image controller"
  scope grew when the web sharer page needed real Open Graph thumbnails
  to be link-previewable on Discord / Telegram — `d247051` replaced the
  501 stub with a Satori + Resvg renderer that lives in
  `apps/backend/src/modules/sharing/og/`. Frontend share viewer
  (`AppShareViewer`, `/shared/character/[slug]`) was built on top of
  the same backend in a follow-up batch (`1f1fbbb` →
  `08f00f6`) — not part of this task entry but worth tracking when
  reading the area.
  - `cadfbbc` `docs(adr): 0003 — share-link design`
  - `59a0d92` `feat(specs): ShareLink + share endpoints + public read paths (v0.7.0)`
  - `fc5643d` `chore(codegen): regenerate clients after share-link spec (v0.7.0)`
  - `f01c16a` `feat(backend): Prisma ShareLink migration`
  - `f11cd55` `feat(backend): SharingModule — slug + create + list + revoke`
  - `d247051` `feat(backend): GET /public/og/character/:slug.png replaces 501 stub`
  - `f450098` `docs(tasks): bookkeep Epic 6 Feature 6.1 (share-link backend)`
- Spec diff: openapi `0.6.0 → 0.7.0` (new ShareLink + 5 paths).
- Acceptance check (against the original list):
  - ✅ `POST /api/v1/characters/{id}/share` returns 201 `ShareLink` with
    a 24-char nanoid slug (`create-share-link.handler.ts` +
    `domain/slug.ts`).
  - ✅ `GET /api/v1/characters/{id}/shares` returns active (non-revoked)
    links (`list-share-links.handler.ts`).
  - ✅ `DELETE /api/v1/share-links/{id}` soft-revokes by setting
    `revokedAt`; subsequent public reads return 410
    (`revoke-share-link.handler.ts` + `get-public-character.handler.ts`).
  - ✅ `GET /api/v1/public/character/{slug}` returns the character
    without auth and filters `notes` when `includeGmNotes=false`
    (`public-sharing.controller.ts` + handler).
  - ✅ `GET /api/v1/public/og/character/{slug}.png` evolved beyond the
    original "returns 501" stub into a real Satori-rendered PNG
    (`og/og.service.ts`).
  - ✅ View counts batched in memory and flushed every minute
    (`infra/view-tracker.ts` + `jobs/flush-view-tracker.job.ts`).
  - ✅ 36 new unit specs across 7 files (≥15 floor).

## T-2026-05-09-004 — web: signup page + auth layout fixes

- Completed: 2026-05-10
- Owner: claude
- Spec: bug-fix on existing auth UI (no PRD/epic)
- Goal: Add missing `/signup` page, fix landing CTA wiring, improve auth-page
  layout proportions.
- Result: shipped on `main` across five commits as the work expanded into a
  full bearer-token migration (Better Auth's session cookie did not survive
  the SPA → backend round-trip on Forgejo's reverse proxy, so the signup
  flow had to switch to `Authorization: Bearer <token>` end-to-end before it
  could land green).
  - `91169bb` `fix(web): /signup page, landing CTA, and post-auth redirect`
  - `c962b8f` `fix(web): auth-required reads getSession() result directly`
  - `193c8e6` `fix(web): SDK client singleton sends session cookie`
  - `7e4ea73` `fix(backend): JSON body parser before OpenAPI validator`
  - `772509e` `feat(web): switch auth from session cookie to bearer token`
- Spec diff: none (auth surface untouched — the signup form was already
  served by Better Auth's `/api/v1/auth/sign-up/email` endpoint).
- Acceptance check (against the original list):
  - ✅ `/signup` route renders email + password + confirm form
    (`apps/web/app/pages/signup.vue`).
  - ✅ Successful submit calls `auth.signUp.email` and redirects (to
    `/app/characters` rather than `/` — `autoSignIn` is on, so dropping
    new accounts on the public landing felt wrong).
  - ✅ Landing "Create account" button navigates to `/signup`
    (`onCreateAccount → navigateTo('/signup')` in `app/pages/index.vue`).
  - ✅ Login + signup cards capped at 480 px, no `100dvh`, wordmark above
    card. Both pages share the same BEM scaffold (`page-login__shell` /
    `page-signup__shell`) so future restyles touch one set of tokens.
- Open follow-ups (carried in the feature backlog, not blockers):
  - `uk` and `el` strings on `/signup` are still `[uk-todo]` /
    `[el-todo]` placeholders — translator pass when those locales come
    online.
  - "Forgot password" link is not on the login card yet (Better Auth
    `forgetPassword` endpoint exists; the UI lands in Phase 1 Epic 4).

## T-2026-05-09-005 — character creation rules alignment with ST3001

- Completed: 2026-05-10
- Owner: claude
- Spec: Coriolis ST3001 — `ГЛАВА 2 Персонажи игроков` + `ГЛАВА 4 Достоинства`
  (Russian rulebook, canonical per
  `.claude/projects/.../memory/coriolis-rulebook-ru.md`). PRD §5.2 was silent
  / partially wrong on these mechanics.
- Goal: make web character creation enforce the rulebook's budget, caps,
  and talent model — upbringing-driven point pools, structured concept
  enum (амплуа), full talent catalog (icon gifts + crew + personal +
  stigmas), and the mutant flag.
- Result: shipped as 6 commits directly on `main` (ff push to
  `origin/main`). The original "single big PR" plan was abandoned in
  favour of per-block direct-to-main commits per the saved
  `feedback_block_workflow.md` rule (each block = its own commit + push +
  follow-up note + new session). The repo lives on a self-hosted
  Forgejo (`code.homelab.local`) — no GitHub PR equivalent was created.
  - `cf47ef1` `feat(character): T-2026-05-09-005 Block 1 — upbringing
field & budgets`
  - `91dac1d` `feat(character): T-2026-05-09-005 Block 2 — Concept
(amplua) enum`
  - `250e918` `feat(character): T-2026-05-09-005 Block 3 — Talent kind +
CrewConcept`
  - `db52555` `feat(character): T-2026-05-09-005 Block 4 — Talent
catalog data`
  - `8cd30ac` `feat(character): T-2026-05-09-005 Block 5 — Mutant flag +
stigma`
- Spec evolution: openapi `0.8.1 → 0.12.0` (4 minor bumps); asyncapi
  unchanged. Prisma migrations: `upbringing_fields`, `concept_enum`,
  `talent_kind_and_crew_concept`, `mutant_fields`. New
  `packages/specs/src/talents.ts` ships the canonical ST3001 ch.4
  catalog (9 icon gifts + 15 crew + 26 personal + 3 stigmas) and is the
  single source of truth for both backend seeding and web rendering.
- Test totals at end: **425/425** backend, **53/53** web. All 5 blocks
  cleared lint / typecheck / format on each commit.
- Acceptance check (against the original list):
  - ✅ Upbringing drives attribute/skill budgets, reputation, starting
    wealth (15/8 — 14/10 — 13/12; 2/4/6; 500/1000/5000 birrs).
  - ✅ Concept is a structured 11-amplua enum with key-attribute cap 5,
    other-attr cap 4, key-skill cap 3, other-skill cap 1, plus
    reputation modifier.
  - ✅ Talents at creation: personal + crew + iconGift; stigma when
    mutant=true. iconGift auto-seeded from icon; rest picked by player
    via the regular `addTalent` flow after `forge()`.
  - ✅ Talent catalog: 9 icon gifts, 15 crew (5 amplua × 3), 26
    personal, 3 stigmas — en/ru complete, uk/el placeholders.
  - ✅ Backend rejects budget / kind / mutant violations with structured
    400/422 + RFC 9457 codes (`ATTRIBUTE_BUDGET_EXCEEDED`,
    `SKILL_BUDGET_EXCEEDED`, `TALENT_KIND_DUPLICATE`,
    `MUTANT_LINEAGE_REQUIRED`, `MUTANT_LINEAGE_FORBIDDEN`,
    `MUTANT_IMMUTABLE`, `STIGMA_REQUIRES_MUTANT`,
    `UPBRINGING_IMMUTABLE`, `CONCEPT_IMMUTABLE`,
    `CREW_CONCEPT_IMMUTABLE`).
  - ✅ Web wizard surfaces budgets/caps/hints on Step 1/2/4/5/6.
  - ✅ Mobile out of scope (untouched).
- Follow-ups (open as separate tasks if/when needed):
  - `uk` and `el` translations across new i18n keys (Step1Concept
    mutant copy, Step2Background upbringing/crew copy, Step6Talents
    sections, talent catalog `name` + `description`) currently carry
    `[uk-todo]`/`[el-todo]` placeholders.
  - Personal-talent pool is rendered as a flat 26-card list. A future
    enhancement could filter by amplua per ST3001 if/when player
    feedback says the full pool is overwhelming.
  - Read-side localization: character sheet (`[id].vue`) renders
    `talent.name` raw — when the catalog ID convention is universal,
    we can resolve it through `findCatalogTalentById` for
    locale-aware display.

## Mobile flutter analyze cleanup (Phase 3 tail)

- Completed: 2026-05-09
- Owner: claude (parent session)
- Spec: open follow-up from Epic 6 Feature 6.4 bookkeeping (mobile flutter
  analyze drift after Flutter 3.41 SDK upgrade + dart codegen change).
- Result: ff-merged to main as `<mobile range>` (2 commits).
  - `<head-1>` `fix(mobile): repoint app_api_client at the inner generated
package + repo_impl`. Three structural fixes that cleared 166 errors: - `mobile/pubspec.yaml`: `app_api_client.path` now points at
    `packages/api-client-dart/lib/generated` (the inner Dart package
    produced by openapi-generator). The outer `packages/api-client-dart/`
    lib has only `generated/` subfolder — Dart resolves
    `package:app_api_client/app_api_client.dart` against the OUTER `lib/`,
    which has no barrel file. The inner package is the real one. - `character_repository_impl.dart`: split the `Character as
ApiCharacter` show-with-as combination (Dart syntax error) into two
    imports; drop `quantity` references on `ItemOther` (spec doesn't
    have the field); switch to top-level `updateTalent`/`deleteTalent`/
    `updateItem`/`deleteItem` API methods (the repo had been calling
    non-existent `updateCharacterTalent` etc). - Ran `dart run build_runner build` inside
    `packages/api-client-dart/lib/generated` to produce the missing
    `*.g.dart` built_value generated code (88 files committed; without
    them the builder fields type-resolve as nullable and 100+ cascade
    assignments fail to type-check).
  - `<head>` `chore(mobile): clear remaining flutter analyze info + warning`:
    drop unused `_weaponTypes` field; `withOpacity` → `withValues(alpha:)`;
    `dart fix --apply` (12 `prefer_const_constructors` auto-fixes); capture
    `Navigator` before `.then()` async gap; declare `built_collection` +
    `one_of` as mobile direct deps.
- Verification: `flutter analyze` reports **No issues found!** Mobile
  52/52 tests; ui_flutter 153/153 tests.

## Mobile pass + a11y audit + HC theme persist (Epic 6 Features 6.4, 6.5)

- Completed: 2026-05-09
- Owner: claude (flutter-engineer + frontend-engineer agents + parent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 6 Features 6.4 (T-6.4.1.{a,b,c}) and 6.5 (T-6.5.1.{c,d,e}).
- Result: ff-merged to main as `<6.4 + 6.5 range>`.

  **6.4 — Mobile pass:**
  - `f38792e` `docs(mobile): MOBILE_AUDIT — sheet vs sheet-mobile.jsx`. 8-item audit; 2 high-impact gaps fixed (bottom tab bar, RankStepperSheet extraction); 6 already match. Cyrillic decision: rely on Flutter's system-fallback (Roboto on Android, SF/Helvetica on iOS — both have full Cyrillic). Forum bundling deferred per audit. Cold-start measurement plan documented (no Android emulator at the bench; PRD NFR §6 target ≤ 2.0s, baseline Pixel 4).
  - `<head>` `feat(mobile): bottom tab bar + private-class extractions per MOBILE_AUDIT`. `_SheetTabBar` moved to `Scaffold.bottomNavigationBar`, `_RankStepperSheet` extracted to public `RankStepperSheet`, wizard `_StepHeader` made `WizardStepHeader` (private symbols don't cross library boundaries via `show`).

  **6.5 — A11y audit + HC theme:**
  - `4ff0e8c` `feat(specs): Me.theme dark|high-contrast (v0.7.1)`. Required field on Me with default `dark`; allowed transitions documented inline.
  - `270f73f` `chore(codegen): regenerate clients after Me.theme`.
  - `b80b489` `feat(backend): persist theme on User + Me query/update`. Prisma migration `me_theme`. `UpdateMeCommand` validates the enum with a new `InvalidThemeError`.
  - `cedc394` `feat(web): persist HC toggle via PATCH /me`. `settings.vue` now drives the toggle through `updateMe({ theme })` with optimistic UI + rollback. localStorage kept only as a hint to avoid FOIT during reload.
  - `302f234` `fix(ui): reduced-motion fallbacks audit + missing fixes`. AppButton spinner gained an opacity-pulse fallback; `settings.vue`, `characters/index.vue`, `shared/character/[slug].vue` skeletons gained `animation: none` under `prefers-reduced-motion: reduce`.
  - `d845fc7` `docs(a11y): A11Y_AUDIT — page-level axe + SR pass plan`. Playwright + axe smoke at `tests/e2e/a11y.spec.ts` covering `/`, `/login`, `/signup` (auth-gated routes documented as deferred with bypass instructions). Manual VoiceOver / NVDA checklist included.
  - `cd469ef` `chore: apply prettier + stylelint auto-format`.
  - `<head>` `style(web): apply ESLint auto-fixes (vue formatting, batch 2)` — 45 vue/max-attributes-per-line warnings introduced by the HC toggle wiring.

- Verification at merge time: backend 264 specs + lint clean + typecheck clean; web 53 specs + lint zero warnings; ui 713 specs.
- Open follow-ups (Phase 3 / Phase 4):
  - Mobile flutter analyze drift (codegen-related): the dart-codegen output is missing nullable annotations in some places; `character_repository_impl.dart` references API symbols that resolve through the inner generated package. **Pre-existing** (predates this batch). Move api-client-dart's outer `pubspec.yaml` to forward to `lib/generated` OR re-point mobile at `path: ../../packages/api-client-dart/lib/generated` and audit non-null access in the repo impl. Tracked separately.
  - Page-level axe pass on auth-gated routes — needs a session-cookie bypass in CI or a test account fixture (documented in `A11Y_AUDIT.md` §2).
  - Manual SR pass — checklist in `A11Y_AUDIT.md` §5; needs human runner.
  - Cyrillic Forum subset bundling — deferred per `MOBILE_AUDIT.md`.

## Open Graph image renderer (Epic 6 Feature 6.3)

- Completed: 2026-05-09
- Owner: claude (backend-engineer agent + parent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 6 Feature 6.3, T-6.3.1.{a,b,d,e}.
  T-6.3.1.c (ship OG) deferred until ship-share endpoints exist.
- Result: ff-merged to main as `<og range>` (3 commits).
  - `9b05ed6` `chore(backend): add satori + @resvg/resvg-js + react deps
for OG renderer`. Versions: `satori@0.26.0`, `@resvg/resvg-js@2.6.2`
    (prebuilt binaries for `darwin-arm64` + `linux-x64-gnu`),
    `react@19.2.6` (used only for `React.createElement` in the Satori
    template).
  - `17859f1` `feat(backend): OG image renderer service + character
template`. `og.service.ts` is stateless (Satori → Resvg pipeline) +
    embedded fallback PNG (1200×630 solid surface-void) for renderer
    failures. `og.fonts.ts` lazy-loads Forum + Inter from Google Fonts
    with in-process caching and graceful network degradation.
    `templates/character-og.ts` is the brass-on-indigo card layout via
    `React.createElement`.
  - `3b155b7` `feat(backend): GET /public/og/character/:slug.png
replaces 501 stub`. `OgService` injected via DI; cache headers
    `Cache-Control: public, max-age=3600,
stale-while-revalidate=86400`.
- 8 snapshot specs cover: PNG magic bytes, 1200×630 dimensions,
  non-empty pixel sum, long-name wrapping, null concept, null iconId,
  fallback on Satori error, the static fallback PNG. Backend total: 260
  tests passing.
- Notable design constraints (documented inline):
  - Satori CSS subset doesn't support `border` shorthand → use
    `border{Top,Bottom,Left,Right}{Width,Style,Color}`.
  - Satori doesn't support font fallback stacks (`'Forum, serif'`) → use
    primary family only.
  - Hex literals are explicitly justified inside the OG template
    (Satori needs concrete colors; can't read CSS custom properties).
- Open follow-ups (Phase 3+):
  - T-6.3.1.c ship OG endpoint (deferred with ship-share work).
  - Cache-warmup / persistent cache (currently the Cache-Control window
    is the only cache layer).

## Public read-only viewer — web (Epic 6 Feature 6.2)

- Completed: 2026-05-09
- Owner: claude (frontend-engineer agent + parent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 6 Feature 6.2, T-6.2.1.{a,c,d,e}.
  T-6.2.1.b (ship variant) shipped as a coming-soon placeholder; full
  implementation lands when ship-share endpoints exist.
- Result: ff-merged to main as `<viewer range>` (5 commits).
  - `d2c771f` `feat(web): usePublicSharingApi composable` — typed wrapper
    over `getPublicCharacter` from the generated SDK.
  - `1f1fbbb` `feat(web): AppShareViewer composition (read-only sheet)`
    — parchment AppBanner disclaimer, hero header, three-column layout
    with display-only AppConditionPill / AppStatBlock / AppDots /
    talents / inventory. NO edit affordances rendered.
  - `e0b20e4` `feat(web): /shared/character/[slug] page with OG meta`
    — SPA-friendly fetch, status routing (404 not-found, 410 revoked,
    5xx error). `useHead` reactively sets `og:title`, `og:description`,
    `og:image` → `/api/v1/public/og/character/:slug.png` (renderer
    landed in 6.3).
  - `744c2fc` `feat(web): /shared/ship/[slug] page placeholder`
    — coming-soon banner; no fetch (ship endpoints not yet shipped).
  - `cb9ca90` `test(web): share viewer snapshot + api specs` — 13 specs
    covering composable success/404/410, no-edit-affordance assertion
    (T-6.2.1.d), page status routing.
- Verification: web typecheck/lint/test all green; 53 web specs pass.
- Open follow-ups (Phase 3):
  - Lighthouse measurement on the share route (target ≥ 90 across all
    scores). Bundle-size and font-subset polishing land here.
  - Ship-share full implementation when the public ship endpoint exists.

## Share-link backend (Epic 6 Feature 6.1)

- Completed: 2026-05-09
- Owner: claude (backend-engineer agent + parent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 6 Feature 6.1, T-6.1.1.{a,b,c,d,e}.
- Result: ff-merged to main as `<sharing range>` (6 commits).
  - `d990682` `docs(adr): 0003 — character draft state`. Covers slug
    strategy (`nanoid(24)` w/ ambiguous-char-free alphabet), soft
    revocation (`revokedAt` → 410 Gone), lazy view tracking (in-memory
    ring-buffer flushed by 1-min cron), multi-link per character,
    `includeGmNotes` filter.
  - `99a9d07` `feat(specs): ShareLink + share endpoints + public read
paths (v0.7.0)`. New schemas (`ShareLink`, `ShareLinkCreate`,
    `ShareLinkList`); endpoints `POST /characters/{id}/share`, `GET
/characters/{id}/shares`, `DELETE /share-links/{id}`, `GET
/public/character/{slug}`; OG image path stubbed at 501.
  - `31d81d1` `chore(codegen): regenerate clients after share-link
spec`.
  - `cbbfe09` `feat(backend): Prisma ShareLink migration` — `ShareLink`
    model, FK to `Character` (cascade), `slug` UNIQUE,
    `@@index([characterId])` + `@@index([revokedAt])`.
  - `93b1d96` `feat(backend): SharingModule — slug + create + list +
revoke`. Includes the public-read query with notes filter +
    revoked/expired status checks, `view-tracker.ts` (in-memory
    `Map<slug, count>`), `flush-view-tracker.job.ts` (`@Cron('* * * *
*')` flushes via batched Prisma transaction), and `OG_NOT_IMPLEMENTED`
    501 stub for the OG image route.
  - `7d79173` `chore(backend): apply lint --fix auto-corrections`.
- 28 new vitest specs across the SharingModule. Backend total: 252 tests
  passing. Spec at v0.7.0; codegen up to date for both TS and Dart
  clients.
- Open follow-ups (Phase 3):
  - Feature 6.2 — public web viewer pages (`/shared/character/[slug].vue`,
    `/shared/ship/[slug].vue`).
  - Feature 6.3 — OG image renderer (Satori + Resvg) replacing the 501
    stub.
  - Ship-share endpoints (`/public/ship/{slug}`) — symmetric to character;
    deferred until ship feature is shipped (Phase 5 currently).

## Mobile sheet + wizard — Flutter tail (Epic 5 Features 5.1–5.6)

- Completed: 2026-05-09
- Owner: claude (flutter-engineer agents ×2 + parent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 5 T-5.1.1.e, 5.2.d, 5.3.c, 5.4.e,
  5.5.c, 5.6.f. T-5.6.1.g (native-speaker Cyrillic review) still
  outstanding.
- Result: ff-merged to main as `8c8efcd..` (14 commits across two
  flutter-engineer runs + codegen + parent fix).
  - **Sheet (5.1–5.5):** 4 commits.
    - `8c8efcd` `feat(ui-flutter): AppSavePulse widget` — 4-state animated
      dot mirroring the Vue primitive. 8 widget tests.
    - `e92e6fa` `feat(mobile): extend CharacterSheetCubit + domain` — full
      domain rewrite (`CharacterAttributes`, `CharacterSkills`,
      `CharacterConditions`, `DomainTalent`, `DomainItem` with 6-type
      discriminated union via `OneOfDynamic`); repo gains
      addTalent/updateTalent/removeTalent + addItem/updateItem/removeItem;
      cubit gains all debounced edit operations + optimistic CRUD with
      rollback; i18n extended for all 4 locales.
    - `cfe6ae0` `feat(mobile): full character sheet page` — sticky header
      (avatar, name/concept, AppSavePulse, condition strip), hero counters
      (HP/MP/ENC with ±, encumbrance warning), attributes block, skills
      block, conditions panel + critical injuries list, talents tab,
      inventory tab with 6-type ItemEditor bottom sheet, save error banner,
      delete confirm dialog. Stats / Gear / Talents / Notes tabs.
    - `fecf343` `test(mobile): BLoC + widget tests` — 11 BLoC + 11 widget
      tests for the sheet edit surfaces.
  - **Wizard (5.6.f):** 8 commits. - `bf4b4e7` `feat(mobile): CharacterWizardCubit + state machine + draft
persistence`. - `f99f7b8` `feat(mobile): wizard shell page` — brass progress, step
    labels, Back/Save & exit/Next/Forge. - `4070c17` `feat(mobile): wizard step 1+2` — concept + people /
    background. - `98857a7` `feat(mobile): wizard step 3 — Nine Icons grid + teal aura
pulse` (T-5.6.1.d). `MediaQuery.disableAnimations` →
    static teal halo fallback. - `6fd5713` `feat(mobile): wizard step 4+5` — attributes + skills point
    pools. - `7a6c164` `feat(mobile): wizard step 6 + Forge transition`. - `1c21436` `i18n(mobile): wizard en + ru full, uk + el placeholders`. - `08f2507` `test(mobile): wizard cubit + widget specs` — 8 cubit + 5
    widget tests.
  - **Codegen + status wiring**: 2 follow-up commits by parent. - `<head-1>` `chore(codegen): regenerate dart client + bundled types
after spec v0.6.0` — backfills the missing `status` enum on
    CharacterCreate / CharacterUpdate that the wizard-backend batch
    didn't propagate to dart. - `<head>` `fix(mobile): wire CharacterStatus through repo + wizard
forge` — wizard now creates with `status: 'draft'` and forges with
    `status: 'active'` explicitly. The earlier "concept-as-sentinel"
    workaround is removed.
- Verification: `flutter test` / `flutter analyze` could NOT run locally
  (system Dart 3.5 vs project floor 3.8; `fvm` not configured). CI under
  the target SDK is authoritative.
- Open follow-ups (Phase 2):
  - T-5.6.1.g native-speaker review of `ru` mobile copy (sheet + wizard).
  - Spec gap: wizard step 2 (origin / upbringing / age) is currently
    pickled into the `concept` field — the spec lacks dedicated fields.
    Add to a future spec batch.
  - `AppIconCoriolis` Flutter widget — wizard step 3 currently uses
    letter-medallion stand-ins; promote when an icon-glyph widget ships.

## Character creation wizard (Epic 5 Feature 5.6)

- Completed: 2026-05-09
- Owner: claude (backend-engineer agent + frontend-engineer agent + parent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 5 Feature 5.6, T-5.6.1.{a,b,c,d,e}.
  T-5.6.1.f (Flutter wizard) deferred. T-5.6.1.g (native-speaker Cyrillic
  review) flagged with a TODO; not gating the merge.
- Result: ff-merged to main as `<wizard range>` (12 commits across two
  worktree-isolated agent runs + spec fix).

  **Backend / spec / Prisma**:
  - `5d1af2e` `docs(adr): 0002 — character draft state via status flag`
    chooses option B (status flag on Character) over a separate
    `/draft` resource. ADR enumerates the 5-point rationale.
  - `3a7a1c0` `feat(specs): add Character.status (draft|active) +
includeDrafts query` — bumps spec to **0.6.0**. Required `status` on
    `Character`; optional on `CharacterCreate`/`CharacterUpdate`. New
    `?includeDrafts=false` query on `GET /characters`. Forge transition is
    a plain `PATCH` with `{ status: 'active' }`; `active → draft` is
    rejected with 422 `INVALID_STATUS_TRANSITION`.
  - `a3ad6aa` `chore(codegen): regenerate clients after Character.status`
    — codegen-only commit per CLAUDE.md.
  - `4e2eb90` `feat(backend): Prisma Character.status migration` —
    `CharacterStatus` enum (`ACTIVE`, `DRAFT`), `@@index([status])`.
  - `459d453` `feat(backend): wizard support — draft status +
status-transition guard + listings + cleanup-abandoned-drafts cron`.
    The cron runs at `EVERY_DAY_AT_3:05` (offset from user-cleanup) and
    deletes drafts older than 30 days. 22 new specs across 4 files.
  - `<head>` `fix(backend): align legacy list-characters specs with
includeDrafts param` — two pre-existing specs needed expectations
    updated since the handler now always passes the param.

  **Web wizard UI**:
  - `be06e2a` `feat(web): wizard shell — progress, header, footer,
navigation` — `WizardShell.vue` skeleton (AppProgress in
    `--brand-brass`, Back / Save & exit / Next + Forge footer).
  - `88c9eba` `feat(web): wizard step 1+2 — concept + people/background`.
  - `4307e65` `feat(web): wizard step 3 — Nine Icons grid + teal aura
pulse` (T-5.6.1.d). 3×3 grid; selected icon pulses
    `--state-mystic-teal`; `prefers-reduced-motion` strips animation.
  - `6c949f2` `feat(web): wizard step 4+5 — attributes + skills point
pools`. Soft point-pool guidance (rulebook-derived); enforcement is
    backend-side via `Attributes` 1–5 / `Skills` 0–5 schema bounds.
  - `19a9820` `feat(web): wizard step 6 — talents + Forge transition`
    (T-5.6.1.e). Final step PATCHes `{ status: 'active' }` and
    `navigateTo(\`/app/characters/${id}\`)`.
  - `e2b1eec` `i18n(web): wizard en + ru full, uk + el placeholders`.
  - `2f440ab` `test(web): wizard orchestration specs` — 7 wizard-specific
    describe blocks; final web-suite total at 40 specs.

- Wizard architecture:
  - `/app/characters/new` reads `?id=` to resume mid-wizard. With no `id`
    it POSTs `{ name: 'Untitled', status: 'draft' }` and `replaceState`s
    so refresh stays on the same draft.
  - Each step PATCHes the draft on advance via the `useAutoSave` composable.
  - Forge = PATCH `{ status: 'active' }` then redirect.

- Verification at merge time: `@app/backend` 224 tests; `@app/web` 40
  tests; `@app/ui` a11y smoke 306/306; typecheck/lint/stylelint/format
  clean across all packages.

- Open follow-ups (Phase 2 / Phase 3):
  - T-5.6.1.f Flutter mobile wizard (deferred with the rest of the
    Flutter sheet tail).
  - T-5.6.1.g native-speaker review of `ru` wizard copy (TODO).
  - Step 7 (Relationships) deferred to v1.1+ with a
    `TODO(wizard-step-7-relationships)` marker in `new.vue` /
    `Step6Talents.vue`.

## Character sheet — Inventory & gear (Epic 5 Feature 5.4)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent + parent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 5 Feature 5.4, T-5.4.1.{a,b,d}.
  T-5.4.1.c (backend item commands) was already shipped in Phase 1.
  T-5.4.1.e (Flutter inventory) deferred.
- Result: ff-merged to main as `<inventory range>` (4 commits).
  - `14cdcf6` `feat(ui): AppModal primitive` — Teleport-to-body, focus
    trap, Esc/backdrop close, sm/md/lg sizes, default+trigger+footer
    slots, reduced-motion fade fallback. 14 specs, 4 stories.
  - `0d4d15d` `feat(web): useItemsApi composable` — addItem / updateItem /
    removeItem against existing backend endpoints.
  - `3ceecc1` `feat(web): Gear tab + ItemEditor (6 types) + equipped
quick view + encumbrance warning` — adds the Gear tab to the sheet
    tab row; ItemEditor handles WEAPON / ARMOR / GEAR / CYBERNETIC /
    SHIP_MODULE / OTHER with per-type field sets; equipped right-column
    panel replaces the placeholder; encumbrance warning ("warn, do not
    block" per PRD §5.3) renders on `current > max`. TalentEditor
    refactored from native `<dialog>` to AppModal in the same diff.
  - `2fa8ada` `test(web): inventory orchestration specs + typecheck fix
in test union` — 11 new vitest specs (addItem, isEncumbered,
    equippedItems, type-discriminated payload).
- Verification: `@app/ui` 711 tests, a11y smoke 306/306 green;
  `@app/web` 28 tests; typecheck/lint clean.
- Open follow-ups (Phase 2):
  - T-5.4.1.e Flutter mobile inventory (deferred with the Flutter sheet
    tail).
  - Type-specific summary columns are placeholders for slots/range
    presentation; full polish lands during the Phase 3 share viewer pass.

## Character sheet — Talents, conditions, save-pulse (Epic 5 Features 5.2, 5.3, 5.5)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent + backend-engineer agent + parent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 5 Features 5.2 / 5.3 / 5.5.
- Result: ff-merged to main as `cb58fcf..` (6 commits).
  - `55f17f7` `feat(backend): rules-engine.applyConditions — −1 die per active
condition` (Feature 5.3 T-5.3.1.d). Pure helper, 12 specs.
  - `9cf488c` `feat(ui): AppSavePulse primitive` — 4 lifecycle states
    (idle/saving/saved/error), pulse animation, `prefers-reduced-motion`
    fade fallback. 4 specs, 5 stories.
  - `e057615` `feat(web): useTalentsApi composable` — addTalent /
    updateTalent / removeTalent against the existing backend endpoints.
  - `9325608` `feat(web): conditions panel + critical injuries +
talents tab + AppSavePulse wire` — replaces three placeholders on
    `[id].vue`: - Conditions: 4 `AppConditionPill`s with optimistic toggle + rollback. - Critical injuries: list + inline-input add + remove. PATCH the full
    array. - Talents: list + native `<dialog>` `TalentEditor` (add / edit / delete
    with confirm). - Save indicator: text → `AppSavePulse` with sr-only fallback.
  - `79982b8` `test(web): condition / talent / save-pulse orchestration
specs` — 11 new vitest specs (4 condition-toggle, 4 talent-list,
    1 save-pulse perf — Feature 5.5 T-5.5.1.d, 100-cycle 50ms-per-call
    budget under fake timers, plus 2 misc).
  - `<head>` `fix(ui): drop redundant story-local a11y override on
AppSavePulse` — story used the array form of axe rules (broken) and
    duplicated the global `color-contrast` disable.
- Verification at merge time: `@app/ui` 693 tests + a11y smoke 302/302
  green; `@app/web` 17 tests; backend 191 tests; typecheck/lint clean.
- Open follow-ups (Phase 2):
  - `AppModal` primitive — TalentEditor uses native `<dialog>` (per agent
    brief). Promote to a real primitive when a third dialog surface lands.
  - Mobile (Flutter) talents/conditions/save-pulse mirrors (Feature 5.2.d,
    5.3.c, 5.5.c) — deferred with the rest of the Flutter sheet tail.

## Character sheet — Attributes & skills section (Epic 5 Feature 5.1)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent ×2 + parent session)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 5, Feature 5.1, T-5.1.1.{a,b,c,d,f}.
  T-5.1.1.e (Flutter mirror) deferred to a later batch.
- Result: ff-merged to main as `43d2e87..ba6b7ee` (5 commits across two
  worktree-isolated agent runs + one spec fix).
  - `a646cf5` `feat(ui): AppStatBlock` — attribute/derived-stat block primitive
    (button-or-div, brass/mystic tones, sm/md sizes, hideDots, aria-label
    forwarding). 16 specs, 6 stories.
  - `082ebc5` `feat(ui): AppPopover` — controlled tokens-styled popover
    (4 placements, focus trap, Escape + click-outside close, reduced-motion
    aware). 14 specs, 4 stories.
  - `b508bac` `chore(ui): export AppStatBlock + AppPopover from @app/ui barrel`
    - `specs/design/README.md` inventory rows.
  - `43d2e87` `fix(ui): align AppBanner spec with <div> root` (regression
    from the a11y CI batch — the `<aside>`→`<div>` change had not been
    mirrored in the spec).
  - `63882b2` `feat(web): extract useAutoSave composable from sheet skeleton`
    — preempts Feature 5.5 T-5.5.1.a (composable only; no save-pulse
    component yet). Lifecycle: idle / saving / saved / error; flush + cancel.
  - `ba6b7ee` `feat(web): character sheet — three-column layout, hero
counters, attributes + skills panels`. Rewrites `[id].vue` from the
    name+concept skeleton into the full sheet. Includes 8 vitest specs.
- Backend: T-5.1.1.b is free — `express-openapi-validator` enforces
  Attributes 1–5 and Skills 0–5 bounds at runtime from the OpenAPI schema.
  No code change needed.
- Open follow-ups (Phase 2):
  - Flutter sheet (T-5.1.1.e).
  - Conditions & critical injuries panel (Feature 5.3) — currently a
    placeholder card on the desktop sheet.
  - Equipped / Talents / Recent rolls right-column cards — placeholders;
    implemented under Features 5.2 (talents) and 5.4 (inventory).
  - `AppSavePulse` micro-component (Feature 5.5 T-5.5.1.b) — current sheet
    uses plain text "saving / saved / error".
- Agent-discipline notes: the second agent (sheet build) ignored two
  guardrails — touched `packages/ui/` (legitimate lint/typecheck fixes
  in AppPopover/AppStatBlock; kept) and committed a self-bookkeeping entry
  to `done.md` (dropped at merge time; re-written by parent here).

## Storybook a11y CI smoke (Phase 2 follow-up)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent + parent session)
- Spec: Phase 1 ledger follow-up "Storybook visual smoke + a11y panel CI".
- Result: ff-merged to main as `4f352b0..ec99ba3` (2 commits).
  - `ci(ui): wire Storybook a11y smoke via test-runner + axe-playwright` —
    new `ui-storybook` CI job (build static Storybook → install Chromium →
    run test-runner). `axe-playwright` injected via `preVisit` hook;
    `postVisit` calls `checkA11y` against `#storybook-root`. Visual snapshot
    block kept but gated behind `STORYBOOK_VISUAL=1` until baselines are
    seeded from a Linux runner. preview.ts decorator themes aligned with
    Coriolis (`dark` + `high-contrast`, dropping stale `light/sepia/forest`
    that ADR-0001 retired). Two axe rules globally disabled with WHY
    comments + Phase 2 follow-ups: `color-contrast` (design-intentional
    dark palette; AA gate lives on `[data-theme='high-contrast']`) and
    `nested-interactive` (AppChip-removable refactor needed).
  - `fix(ui): a11y violations in 8 component stories (61 → 0)` — story-level
    fixes for AppDots/AppProgress (`label` prop), AppInput/AppTextarea
    (`aria-label` in meta render), AppSelect (paired `<label for>` +
    `selectId`), AppSwitch (label default + bare-toggle aria-label), AppTab
    (`<div role="tablist">` wrappers, `<nav>`→`<div>` to fix
    `aria-allowed-role`). One component change: AppBanner.vue
    `<aside>`→`<div>` (aside's implicit `complementary` role conflicts
    with `role="status"`/`alert`).
- Final state: 287 / 287 stories pass a11y smoke locally. CI job gates the
  same on every push.
- Open follow-ups (added to Phase 2 ledger):
  - Visual snapshot baselines on Linux runner.
  - `color-contrast` audit on `[data-theme='high-contrast']` and design
    refresh for failing combos.
  - AppChip-removable structural refactor (sibling buttons) to re-enable
    `nested-interactive`.

## Web typecheck unblock (Phase 1 tech-debt)

- Completed: 2026-05-08
- Owner: claude (parent session)
- Spec: Phase 1 ledger follow-up "Web pnpm typecheck fix (oxc-parser native
  binding)".
- Result: ff-merged to main as `e24690b..96fe7a8` (1 commit).
- Diagnosis: the previously-blocking `@oxc-parser/binding-darwin-universal`
  binding error self-resolved under the current pnpm 10.33 / Node 24.15
  toolchain. What remained were two real TypeScript errors blocking
  `pnpm --filter @app/web typecheck`:
  - `app/pages/app/settings.vue:137`: `setLocale` expected `LocaleCode`
    union, got widened `string`. Fix: `SUPPORTED_LOCALES` const tuple +
    `isLocaleCode()` type guard, narrowing happens at the call site.
  - `app/pages/login.vue:176`: AppButton was being passed boilerplate
    Nuxt UI props (`label`, `color`, `variant='solid'`, `block`). AppButton
    has none of those. Fix: switch to default slot, `variant='primary'`,
    page-scoped `&__submit { width: 100% }` for block-layout.
- Verification: `pnpm --filter @app/web typecheck` exits 0 (only
  pre-existing duplicate-import warnings remain — auto-import noise from
  Nuxt, harmless).

## Flutter foundation tail — 8 deferred widgets (Epic 2.5)

- Completed: 2026-05-08
- Owner: claude (flutter-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2.5 — first Phase 2 deliverable after `phase-1-complete` tag.
- Result: ff-merged to main as `7e7d1d0..a5832cd` (4 commits). Closes Epic 2.5 at 20/20 widgets.
  - `7e7d1d0` AppIcon (CustomPaint, zero-dep, 20-icon static map) + AppKbd.
  - `0378dce` AppTooltip (Flutter Tooltip wrapper; left/right placement falls back to bottom — API limitation, documented inline) + AppTab (brass/mystic underline-on-active, `Semantics(selected)`) + AppBanner (5 tones incl. parchment).
  - `0d5514b` AppSegControl<T> (2–5 options) + AppSelect (DropdownButton via InputDecorator, `dropdownColor: surfaceNight`; full menu-row theming deferred) + AppTextarea (`minLines: rows`, `maxLines: null` for unbounded growth).
  - `a5832cd` Barrel re-export.
- 50 new tests (13 + 20 + 17), tap targets ≥ 44×44, tokens-only, no hex literals, no new pubspec entries.
- Local `flutter analyze`/`flutter test` skipped — system Dart SDK 3.5 below project floor 3.8 (`fvm` not configured locally). CI under target SDK is authoritative.
- Pre-existing follow-up still open: AppTextarea autosize content-grow (Phase 2 ledger).

## Email mailer + Coriolis voice copy (Epic 4.3)

- Completed: 2026-05-08
- Owner: claude (backend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 4.3, T-4.3.1.a–c
- Result: merged at `bf6d158`. Four commits — MailerModule + ports + adapters (`ff6381d`), Better Auth callback wiring (`689618e`), domain-error voice refresh (`68527b6`), pnpm-lock resolution (`ce02ed6`).
- New module `apps/backend/src/modules/mailer/`:
  - `IMailer` port (`mailer.port.ts`) with `sendVerificationEmail` / `sendPasswordResetEmail`.
  - `MockMailer` adapter (default in dev/test) — ring-buffer of last 50 sends, `getLastSent()` for test inspection, debug logging.
  - `ResendMailer` adapter — `node:fetch` to Resend API, no new dep, throws on non-2xx.
  - `@Global()` `MailerModule` with factory selecting Mock vs Resend via `AppConfig.mailer.provider`. Boot-time guard throws if provider=`resend` without `RESEND_API_KEY`.
  - 31 new vitest specs (14 service + 17 templates).
- Email templates: 4 inline-TS templates (`verification` + `password-reset` × `en/ru`). HTML shell in `templates/email-shell.ts` is the only backend file with hex literals — explicitly justified (email clients don't support CSS custom properties).
- Better Auth wiring: `auth.service.ts` injects `MailerService` and wires `emailVerification.sendVerificationEmail` and `emailAndPassword.sendResetPassword` callbacks. Locale defaults to `'en'` for now (TODO when `user.locale` field arrives).
- Domain-error copy refreshed for Coriolis voice across `user.errors.ts`, `character.errors.ts`, `item.errors.ts`, `talent.errors.ts`. `code` strings unchanged (clients depend on them).
- 191 backend specs pass total (was 160).

## Web delete-account UI (Epic 4.2.c)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 4.2, T-4.2.1.d
- Result: merged at `5afef03`. Two commits — `useMeApi.deleteMe()` (`f79c226`) and the settings-page modal flow (`5afef03`).
- Native `<dialog>` confirmation modal with double-confirm via typing the exact phrase ("DELETE MY ACCOUNT" / "УДАЛИТЬ МОЙ АККАУНТ"). Locale-aware comparison.
- Inline error state — Problem.detail rendered above action buttons, modal stays open for retry.
- Post-delete redirect to `/`; auth guard handles the bounce to `/login`.
- 87 web i18n keys × 4 locales clean (was 78).

## Coriolis-decorative primitives (Epic 2.2 — final 4)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2 Feature 2.2 (T-2.2.a, .c, .e, .f)
- Result: merged at `ff53323`. Nine commits — one component + one specs/stories per primitive plus a barrel/inventory commit and a typecheck fix.
- AppIconCoriolis: 9 SVG glyphs for the Nine Icons (placeholder designs ready for a publisher-aware illustration pass), `currentColor` stroke. Static map + `v-html` rendering with explicit ESLint suppression rationale (closed map, not user input).
- AppDiePool: composes AppDie; counts hits per ST3001 ГЛАВА 5 (all 6s count, including pushed); pushed dice get a translateY+opacity visual without losing their hit contribution.
- AppStarOrnament: single 12-point polygon on a 100×100 viewBox; filled rather than stroked for legibility at sm size.
- AppArabesqueCorner: single canonical TL path + `rotate()` for the four orientations.
- 655 vitest specs across the @app/ui package (all primitives green).

## Account deletion backend (Epic 4.2.b–c)

- Completed: 2026-05-08
- Owner: claude (backend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 4.2, T-4.2.1.b–c
- Result: merged at `8db8a7f`. Three commits: DeleteMeCommand handler (`6ea0835`), daily cron job (`cbf3822`), UserDeletedEvent + log handler (`8db8a7f`).
- New dep: `@nestjs/schedule@^6.1.3`. `ScheduleModule.forRoot()` registered at app level.
- Idempotent path: `repo.softDelete` uses `prisma.user.updateMany` with `where: { id, deletedAt: null }`; if `count === 0`, the handler returns 204 without re-stamping or emitting events.
- BA session revocation: `auth.api.revokeSessions` requires the caller's own session, so `AuthService.revokeAllSessions(userId)` instead clears `prisma.session` directly. Session FK to User has `onDelete: Cascade`, so the eventual hard-delete flushes any survivors.
- Cron: `@Cron(CronExpression.EVERY_DAY_AT_3AM)` deletes users with `deletedAt < now - 30d`. Cascade FKs handle children. TODO: Centrifugo channel cleanup + share-slug invalidation when those systems land (Epic 7).
- 160 backend specs pass total (+16 new across DeleteMe handler + cron job).

## Mobile sheet skeleton (Epic 3.4)

- Completed: 2026-05-08
- Owner: claude (flutter-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 3.4, T-3.4.1.a–e
- Result: merged at `df5194b`. Four commits: domain layer + repository (`2cd0fc1`), CharactersListCubit + list page (`82649ce`), CharacterSheetCubit + detail page (`c25e0c3`), creation page + routing + DI + i18n (`a159931`).
- Mirror of Epic 3.3 web skeleton on Flutter. Feature-first layering under `apps/mobile/lib/features/characters/{domain,data,presentation}/`. `flutter_bloc` cubits with 500ms debounce auto-save. New `characters` slang namespace (en/ru populated; uk/el `[xx-todo]`). `auth_gate.dart` updated to gate the route surface.
- Note from agent: hand-written stub `apps/mobile/lib/i18n/strings.g.dart` is gitignored; CI/build env regenerates via `dart run slang` (project SDK 3.8 vs. local 3.5 — agent used a SDK-constraint workaround for analyze-only verification).

## Foundation tail — AppTooltip + AppKbd + AppSegControl

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2 Feature 2.1 (T-2.1.1.l + .m + .p)
- Result: merged at `f3a799a`. Six commits — one component + one specs/stories per primitive plus a final barrel update.
- AppTooltip: hover/focus + ESC-dismiss; native `useId()`, `aria-describedby`. No edge-flip in v1; consumer responsible for placement. AppKbd: semantic `<kbd>` element(s) with mono typography. AppSegControl: `role="radiogroup"` with roving focus and arrow-key navigation between segments.
- 558 vitest specs pass total (60+ new across the three).
- Note: agent root-cause fixed initial test failures: the components had HTML comments outside the root element making `@vue/test-utils` see multiple roots; comments moved inside the root.

## Codegen — DELETE /api/v1/me

- Completed: 2026-05-08
- Owner: claude (main thread)
- Result: merged at `75a213a`. New `deleteMe` operation in TS sdk and Dart `UsersApi`. info.version 0.5.1 reflected.

## DELETE /api/v1/me spec (Epic 4.2.a)

- Completed: 2026-05-08
- Owner: claude (spec-writer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 4.2, T-4.2.1.a
- Result: merged at `12c6b43`. Single new operation under `users` tag; 204 idempotent (no 404 on already-deleted); 401 problem+json. info.version 0.5.0 → 0.5.1.
- Open questions for the backend implementer (T-4.2.1.b-c) — captured in the agent's report:
  - Cron anchor: 30-day window from exact `deletedAt` timestamp (recommended) vs start-of-calendar-day.
  - Cascade ordering: single-transaction `deleteMany` on Character (Cascade FKs handle children) vs explicit ordered cascade with Centrifugo / share-slug invalidation hooks.

## Flutter foundation widgets (Epic 2.5 — partial: 12 of 20)

- Completed: 2026-05-08
- Owner: claude (flutter-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2 Feature 2.5, T-2.5.1.a
- Result: merged at `cc012c0`. Four commits batched by primitive cluster: `f9637f6` (Button/Badge/Chip), `cf52b8b` (Input/Switch/Progress), `7462813` (Card/Label/Field/Divider/Dots), `78c0dbf` (Avatar + barrel + app_ui export).
- Widgets shipped (12): `AppButton`, `AppBadge`, `AppChip`, `AppInput`, `AppSwitch`, `AppProgress`, `AppCard`, `AppLabel`, `AppField`, `AppDivider`, `AppDots`, `AppAvatar`. All token-driven via `tokens.g.dart` — no hex literals, no Material `Colors.foo`. 44×44 tap targets via `ConstrainedBox` wrapper. AnimatedContainer transitions use `AppEasing.standard` + `AppDuration.fast`/`dDefault`.
- Deferred (8 next milestone): AppIcon, AppTab, AppBanner, AppTooltip, AppKbd, AppSegControl, AppSelect, AppTextarea — they have Flutter idioms (TabBar / SnackBar / Tooltip / DropdownButton) needing separate consideration.
- Verified: `flutter analyze lib/` clean, `flutter test test/widgets/` 91/91 pass.
- Dependency note: image loading uses `Image.network` with `errorBuilder` fallback rather than `cached_network_image` (no new dep). Cyrillic-safe initials via `String.runes.first`.

## AppDie + AppConditionPill (Epic 2.2.b + 2.2.d)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent — second attempt; first hit a Bash permissions block)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2 Feature 2.2 — first two Coriolis-specific primitives.
- Result: merged at `489604f` (committed directly to main due to worktree-isolation slip; work fully verified).
- AppDie: 100×100 SVG viewBox with absolute pip coordinates; canonical d6 face layouts; states `normal`/`hit`/`pushed`/`failed`; `hit` uses an SVG `<filter>` (feGaussianBlur + feFlood) tinted with `var(--state-mystic-teal)` plus a stroke overlay for the brass ring; sm/md/lg sizes (24/32/48 px).
- AppConditionPill: `<button aria-pressed>` for the four PRD §5 conditions (exhausted/sleepless/thirsty/hungry); per-condition Lucide icons (battery-low/moon/droplet/apple); active state filled mystic-teal with `--shadow-icon-glow`; default capitalized fallback when no slot.
- 498/498 vitest specs pass across 19 files.

## Spec tech-debt — extract named oneOf variants for Item + ShipModule

- Completed: 2026-05-08
- Owner: claude (spec-writer agent + main-thread codegen)
- Result: spec merged at `e12f2b5`, codegen merged at `fbfcd41`. info.version 0.4.0 → 0.5.0.
- 22 new named schemas: 12 for Item (ItemWeaponCreate/Update, ItemArmorCreate/Update, ItemGearCreate/Update, ItemCyberneticCreate/Update, ItemShipModuleCreate/Update, ItemOtherCreate/Update); 10 for ShipModule (ShipModuleWeaponCreate/Update, ShipModuleTorpedoCreate/Update, ShipModuleHoldCreate/Update, ShipModuleSensorCreate/Update, ShipModuleOtherCreate/Update). Discriminator `mapping` blocks added.
- Codegen output now uses intent-revealing class names. The previous dart-dio orphans (`ItemCreateOneOf{,1..5}.dart`, `Model0{,1..5}.dart`, `ShipModuleCreateOneOf{,1..4}.dart`, `Model0{2..42}.dart`) are removed in the same codegen commit.
- Wire format unchanged — only client class names differ.
- Two pre-existing path examples (`PATCH /items/{id}`, `PATCH /ship-modules/{id}`) were missing the discriminator field; fixed to keep validation clean.

## Codegen — /api/v1/ships

- Completed: 2026-05-08
- Owner: claude (main thread; codegen-runner agent hit a permissions block)
- Result: merged at `75a6ee8`. 113 files / +14K lines. New ShipsApi (TS + Dart), Ship/ShipCreate/ShipUpdate/ShipList types, discriminated ShipModule union, CrewSlot, six new enums.
- Note: dart-dio still emits `ShipModuleCreateOneOf{,1..4}` and `Model0{2..42}` duplicate names for the inline `oneOf` discriminator branches (same pattern as Items). When a ShipsModule backend is dispatched (Phase 5), follow up with a spec PR to extract `ShipModuleWeaponCreate`/`ShipModuleTorpedoCreate`/etc. as named schemas.

## AppTab Coriolis primitive (Epic 2.1.k)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Result: merged at `5508b02`. `<button role="tab">` with `aria-selected` per ARIA-1.2; underline-on-active via `::after` pseudo. 27 vitest specs, 10 stories. Brass + mystic tones, sm/md sizes.

## AppBanner Coriolis primitive (Epic 2.1.j)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Result: merged at `f0914c7`. Inline notice panel with 5 tones (info/success/warning/danger/parchment), default-icon-per-tone via AppIcon, optional dismiss + actions slot. `role="alert"` for danger, `role="status"` otherwise. 32 vitest specs. Parchment variant verified WCAG AAA contrast (text-ink #1A1810 on surface-parchment #F2E8D0 ≈ 12.5:1).

## Web settings page (Epic 4.1.c)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Result: merged at `ee9b8d9`. New `/app/settings` route, behind the existing `/app/**` auth guard.
- `apps/web/app/composables/useMeApi.ts` — CRUD wrapper around `getMe`/`updateMe`. Throws RFC 9457 `Problem` on error.
- `apps/web/app/pages/app/settings.vue` — four `AppCard` panels: Profile (avatar + displayName editable + email/createdAt read-only with debounced auto-save mirroring the sheet header), Locale (`AppSelect` for en/ru/uk/el; uk/el labeled `[uk-todo]`/`[el-todo]`), Theme (`AppSwitch` for high-contrast persisted to `localStorage('coriolis.theme')` — server-side persistence pending Phase 2), Account (delete button visibly disabled with help text referencing T-4.2.1).
- 78 i18n keys × 4 locales clean. Stylelint clean.

## T-2026-05-08-022 — Ships OpenAPI surface (Epic 5 / Feature 8.1+8.2)

- Created/Completed: 2026-05-08
- Owner: claude (spec-writer agent)
- Spec: docs/PRD.md §6 + ST3001 ГЛАВА 7
- Result: merged at `dbc3e58`. info.version 0.3.0 → 0.4.0. New `ships` tag with 12 operations (listShips, createShip, getShip, updateShip, deleteShip, duplicateShip, exportShip, addShipModule, updateShipModule, deleteShipModule, assignCrew, unassignCrew). 13 new schemas including discriminated `ShipModule` union. Six enums (ShipClass=20 hull types, ShipModuleSlot=21, ShipWeaponRange=5, CrewPosition=6).
- Open questions / divergences from PRD captured in commit body: `signature` field naming kept English while ГЛАВА 7 uses "Заметность"; `energyPoints` modeled as `{current, max}` per ГЛАВА 7 reactor mechanics (PRD silent); added `cargoCapacity` aggregate for class-derived hold sizing.
- Codegen pending — separate `chore(codegen): regenerate clients for /api/v1/ships` task.

## T-2026-05-08-020 — Add AppAvatar primitive

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.i
- Result: merged at `17c4257`. Image variant with lazy loading + initials fallback on `@error`. 5 sizes (xs/sm/md/lg/xl), 4 tones (brass/mystic/crimson/darkness), 2 shapes (circle/squircle). Cyrillic-safe initials algorithm. Visually-hidden full-name span for screen readers. 16+ specs.

## T-2026-05-08-019 — AppTextarea primitive

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2 Feature 2.1
- Result: merged at `580132e`. Multi-line counterpart to AppInput; mirrored prop shape (size/disabled/readonly/invalid/placeholder/inputId/maxlength + `rows`). 14 vitest specs. Note: `autosize` prop accepts the BEM modifier but content-grow behavior is deferred — TODO comment in component for `field-sizing: content` + JS recompute polyfill.

## T-2026-05-08-021 — Web sheet skeleton (Epic 3.3)

- Created: 2026-05-08
- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 3.3 Feature 3.3.1 (T-3.3.1.a–e)
- Branch: feat/phase-1/web-sheet-skeleton
- Result: 4 commits on branch, ready for PR.
  - `auth-required.global.ts` — global middleware guards `/app/**`; redirects to `/login?redirect=…`
  - `useCharactersApi.ts` — character CRUD composable wrapping `@app/api-client-ts` SDK
  - `useDebounceFn.ts` — minimal local debounce composable (no @vueuse/core dependency)
  - `pages/app/characters/index.vue` — grid + skeleton + empty + error states, en/ru/uk/el i18n
  - `pages/app/characters/new.vue` — name form, inline validation, POST → redirect
  - `pages/app/characters/[id].vue` — header with initials avatar + editable name/concept, 500ms debounced auto-save, saving/saved/error indicator, native `<dialog>` delete confirmation, body placeholder for Epic 5

## T-2026-05-08-018 — build AppSelect primitive

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2 Feature 2.1
- Result: merged at `88e27d8`. Native `<select>` styled to Coriolis chrome with chevron, sm/md/lg sizes, disabled/invalid states, options via prop with placeholder support, 28 vitest specs.

## T-2026-05-08-017 — AppField primitive

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: IMPLEMENTATION_PLAN.md Epic 2 Feature 2.1
- Result: merged at `44488bf`. Form-row composer using Vue 3.5 `useId()` for auto-id, scoped slot exposing `slotAttrs` with `id` + `aria-describedby` + `aria-invalid`, error replaces help, role="alert" on error span. 26 specs, 11 stories.

## T-2026-05-08-016 — implement AppLabel primitive

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2 Feature 2.1
- Result: merged at `9160271`. `<label for>` or `<span>` based on `for` prop. Tones default/eyebrow/stat-block. Required marker with `aria-label="required"`. helpText support. 21 specs, 11 stories.

## T-2026-05-08-015 — Add rules-engine module and wire derived stats into CharactersModule

- Created/Completed: 2026-05-08
- Owner: claude (backend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 3.2 Story 3.2.2, T-3.2.2.a..d
- Result: merged at `c423dc2` — three commits `1f6a869` (module), `a0578dc` (wire into character.repo.ts), `c423dc2` (specs).
- Formulas (PRD §5.2): `hpMax = STR + AGI`, `mpMax = WIT + EMP`, `encumbranceMax = STR × 2`, `encumbranceCurrent = sum(item.weight)`, `canPush(conditions, alreadyPushed) = !exhausted && !alreadyPushed`.
- ReadOnlyFieldError (422 `READ_ONLY_FIELD`) added to UpdateCharacterHandler — rejects PATCH bodies that try to set `hp.max`, `mp.max`, `encumbrance.max`, or `encumbrance.current`. Defence-in-depth alongside spec's `readOnly: true` declarations.
- 39 new specs (33 rules-engine + 6 ReadOnlyFieldError); 144/144 backend tests pass.

## T-2026-05-08-014 — Build AppProgress Coriolis primitive

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.f
- Result: merged at `f230d4c` (`chore(ui): register`); preceded by `00a47f2` (component+stories+spec) and `b68ffa3` (task entry).
- Linear-only — circular variant deferred. 5 tones, 3 sizes, role="progressbar" with full aria-value attrs. 36 vitest specs.
- Notes: circular variant deferred; wizard-icon.jsx and sheet-desktop.jsx need only the linear bar.

## T-2026-05-08-013 — Implement AppChip Coriolis primitive

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md §Epic 2.1.c
- Result: merged at `d64d72b` (`docs(design)`); preceded by `fcf03d6` (component) and `644d667` (task entry).
- `<button type="button">` with `aria-pressed`. Five Coriolis variants × 2 sizes. Toggleable `update:modelValue` + optional `removable` with `remove` event. 28 vitest specs.

## T-2026-05-08-012 — AppSwitch Coriolis primitive

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md §Epic 2.1.e
- Result: merged at `940d115` — three commits `9fb6b2b` (task) + `1bdba04` (component) + `940d115` (specs+stories).
- `<button role="switch">` with `aria-checked`. Brass-on-night track, brass-light thumb. Slot wins over `label` prop when both present. 19 specs, 11 stories.

## T-2026-05-08-011 — Implement CharactersModule backend (Epic 3.2 Story 3.2.1)

- Created/Completed: 2026-05-08
- Owner: claude (backend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 3.2 Story 3.2.1
- Result: merged at `64db2d0` — three commits `d94d8fe` (Prisma schema) + `8ab5452` (CharactersModule + nested ItemsModule and TalentsModule) + `64db2d0` (105 handler specs).
- Files: 57 files, +3873 lines. Full Coriolis domain (Character, Item, Talent, Relationship, CriticalInjury) Prisma models with cascade-delete on character delete. CQRS layout under `apps/backend/src/modules/characters/` with sub-modules for `items/` and `talents/`. Ownership guards on every parameterized route. JSON columns for attributes/skills/conditions/item.data per design judgement. 105 vitest specs across 20 files, all green.
- Notes: derived stats (hp.max/mp.max/encumbrance.max) returned as placeholders 14/10/5 with `TODO(rules-engine, T-3.2.2)` comments. Encumbrance current = 0 placeholder pending rules-engine. Item.type stored as enum + `data: Json` column for the discriminated union (alternative to 6-table-per-type schema; documented in module).

## T-2026-05-08-010 — Add AppDivider primitive to @app/ui

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.o
- Result: merged at `02e3ecb` (`docs(design)`); preceded by `834bc21` (specs+stories) and `fbfdb99` (component rewrite).
- Variants: `horizontal` (`<hr>`) / `vertical` (`<div role="separator" aria-orientation="vertical">`); tone `brass-deep`/`brass-shadow`/`brass`; weight `hairline`/`thin`/`medium` via SCSS variables; optional `inset` margin.

## T-2026-05-08-009 — Add AppDots primitive to @app/ui

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.n
- Result: merged at `9c19faa` (`docs(design)`); preceded by `6d2732e` (component+stories+spec) and `de126f7` (task entry).
- Markup: `<div role="meter">` with `aria-valuenow`/`aria-valuemin`/`aria-valuemax` per DESIGN §10. Props: `value`, `max=5`, `size sm/md/lg`, `tone brass/mystic/crimson/darkness`, optional `label`. `value` clamped silently.
- Tests: 22 vitest specs, 222/222 pass.

## T-2026-05-08-008 — Implement AppIcon Coriolis primitive (Epic 2.1.g)

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md §2.1.g, docs/DESIGN.md §4.3
- Result: merged at `1a5b299` (`docs(design)`); preceded by `8edd14c` (component) and `b70441f` (lucide-vue-next dep + task entry).
- Dependency: `lucide-vue-next@0.511.0` added to `packages/ui/package.json`.
- Strategy: static `import * as lucideIcons from 'lucide-vue-next'` + runtime PascalCase lookup; unknown names → `console.warn` + empty `<span>` (no crash).
- Props: `name`, `size xs/sm/md/lg/xl`, `color brass/mystic/crimson/success/darkness/inherit`, `strokeWidth=1.5`. Default `aria-hidden="true"` unless consumer passes `aria-label`.
- Tests: 8 specs, all pass; 258/258 total in @app/ui.

## T-2026-05-08-007 — Codegen follow-up for /api/v1/characters

- Created/Completed: 2026-05-08
- Owner: claude (codegen-runner agent)
- Spec: post-merge of T-006 (691e9de). `pnpm spec:bundle && pnpm spec:codegen` against info.version 0.3.0.
- Result: merged at `d2f1751`. 141 files, +15750 / −70.
- TS: 13 new operations in sdk.gen.ts, +1383 lines in types.gen.ts, openapi-types.ts +1528 lines.
- Dart: new `CharactersApi` class (40K), 36 new model classes, 46 doc files + 46 stub tests, serializers updated.
- **Open lint: dart-dio generated `ItemCreateOneOf{,1..5}` AND `Model{0..5}` duplicate type names** for the inline `oneOf` discriminator branches the spec-writer used. Backend can use these names; if the mobile app finds them confusing, a follow-up spec PR can extract `ItemWeaponCreate`/`ItemArmorCreate`/etc. as named schemas.

## T-2026-05-08-006 — Add /api/v1/characters CRUD + nested items/talents to OpenAPI spec

- Created: 2026-05-08
- Completed: 2026-05-08
- Owner: claude (spec-writer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 3.1, T-3.1.1.a..d
- Result: merged at `691e9de`. info.version bumped 0.2.0 → 0.3.0.
- Goal: Define the full character API surface in OpenAPI so backend and generated clients have an unambiguous contract to implement against.
- Acceptance — all met:
  - [x] `pnpm spec:validate` green (Redocly + AsyncAPI)
  - [x] 13 new operations under `characters` tag (listCharacters, createCharacter, getCharacter, updateCharacter, deleteCharacter, duplicateCharacter, exportCharacter, addCharacterItem, updateItem, deleteItem, addCharacterTalent, updateTalent, deleteTalent)
  - [x] ~15 new schemas (Character + Create/Update, CharacterList, IconId, Attributes, Skills, ConditionFlags, CriticalInjury, Talent + Create/Update, Relationship, ItemBase + 6 type variants + Item discriminated union + ItemCreate/Update)
  - [x] RFC 9457 problem+json on every 4xx with named codes
  - [x] info.version is 0.3.0
- Open questions raised by the agent (deferred):
  - **ItemRangeEnum naming** — used `arm/near/short/long/distant` per the task brief; PRD §5.3 lists "Engaged/Short/Medium/Long/Extreme". Worth aligning before backend lands the wire validation.
  - **Skill max** — set to 5 uniformly; PRD §5.2 says "0–3 typical for advanced skills". Backend can layer a soft warning.
  - **Reputation / birr** fields — not in Character DTO; PRD §5.2 mentions them. Add in Epic 5 (full sheet).
  - **Relationship.kind** — task brief enumerated `ally/rival/family/mentor/debtor/creditor`; PRD §5.2 leaves it free-text. Followed task brief.

## T-2026-05-08-005 — build AppBadge Coriolis primitive

- Created: 2026-05-08
- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md §Feature 2.1 T-2.1.1.b
- Result: merged at `bc50700` (docs); preceded by `36844a5` (specs + stories) and `92bde7e` (component rewrite).
- Goal: Replace the boilerplate AppBadge with a native Coriolis-token badge chip covering 5 state-color variants and 2 sizes, with story + spec.
- Acceptance — all met:
  - [x] `pnpm --filter @app/ui typecheck` green
  - [x] `pnpm --filter @app/ui test` 181 specs pass (11 new AppBadge)
  - [x] `pnpm stylelint "packages/ui/src/components/AppBadge/**/*.{vue,scss,css}"` green
  - [x] AppBadge row in `specs/design/README.md`
  - [x] 10 variant × size stories + WithIcon + LongLabel + InlineWithText + AllVariants
- Variants: `brass` (default), `mystic`, `crimson`, `success`, `darkness` × `sm` / `md`. `<span>` root, decorative `tabindex="-1"`.

## T-2026-05-08-004 — Replace AppInput with Coriolis-token implementation

- Created: 2026-05-08
- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2.1.d; docs/DESIGN.md §11.1
- Result: merged at `4b0f644` (docs); preceded by `cf2817a` (specs + stories) and `c35d0fe` (component rewrite).
- Goal: Deliver a fully-styled AppInput primitive that uses Coriolis design tokens, matching the cor-input / cor-input--invalid contract from primitives.jsx.
- Acceptance — all met:
  - [x] `pnpm --filter @app/ui typecheck` green
  - [x] `pnpm --filter @app/ui test` 199 specs pass (30 new AppInput)
  - [x] `pnpm stylelint` green for AppInput files
  - [x] 13 stories covering variant × size matrix + states + types
  - [x] AppInput row in `specs/design/README.md`
- Note: `inputmode` prop typed as explicit union literal rather than `HTMLInputElement['inputMode']` to avoid vue-tsc TS2322 widening to `string`.

## T-2026-05-08-003 — UsersModule backend (T-4.1.1.b)

- Created: 2026-05-08
- Completed: 2026-05-08
- Owner: claude (backend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md T-4.1.1.b
- Result: PR #8 — merged. Branch `feat/phase-1/me-endpoint-backend`; final tip `995264e` (`feat(backend): UsersModule with GetMeQuery and UpdateMeCommand handlers`); preceded by `82bb772` (Prisma schema + Better Auth additionalFields).
- Goal: Implement `UsersModule` under `apps/backend/src/modules/users/` with CQRS layout. Add `displayName` and `deletedAt` to Prisma `User` model, wire `additionalFields` in Better Auth config, expose `GET /api/v1/me` and `PATCH /api/v1/me` per the OpenAPI spec.
- Acceptance — all met:
  - [x] `pnpm --filter @app/backend prisma:generate` exits 0; client picks up `displayName` + `deletedAt`
  - [x] `pnpm --filter @app/backend typecheck` exits 0
  - [x] `pnpm --filter @app/backend test` 10 files / 44 tests pass (4 GetMeHandler + 10 UpdateMeHandler new)
- Sub-steps:
  - [x] Push entry to active.md
  - [x] Add `displayName` and `deletedAt` to schema.prisma
  - [x] Wire `additionalFields` in Better Auth config
  - [x] Create domain/{ports,errors}, queries/get-me.{query,handler}, commands/update-me.{command,handler}, infra/user.repo, users.controller, users.module
  - [x] Register UsersModule in app.module.ts
  - [x] Write handler spec files
  - [x] Verify prisma:generate + typecheck + test green

## T-2026-05-08-002 — implement AppCard Coriolis primitive

- Created: 2026-05-08
- Completed: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.h
- Result: PR #6 — merged at `b50b80f` (`docs(design): list AppCard in @app/ui component inventory`); preceded by `5beaabe` (specs + stories) and `c6dfee2` (component rewrite).
- Goal: Replace the boilerplate AppCard with a Coriolis-token-driven component (default / featured variants, optional header/footer slots, `as` polymorphic prop) that passes typecheck, Vitest, and Stylelint.
- Acceptance — all met:
  - [x] `pnpm --filter @app/ui typecheck` (vue-tsc) exits 0
  - [x] `pnpm --filter @app/ui test` (vitest, 185 tests) exits 0
  - [x] `pnpm stylelint "packages/ui/src/components/AppCard/**/*.{vue,scss,css}"` exits 0
  - [x] AppCard row appears in `specs/design/README.md` component inventory
- Sub-steps:
  - [x] Push task entry to active.md
  - [x] Rewrite AppCard.vue with Coriolis tokens (default + featured variants, header/footer slots, `as` prop)
  - [x] Write AppCard.stories.ts with 8 stories (Default, Featured, WithHeader, WithFooter, WithHeaderAndFooter, BodyWithLongText, Polymorphic, AllVariants)
  - [x] Write AppCard.spec.ts with full coverage (13 specs)
  - [x] Update specs/design/README.md component inventory
  - [x] Verify typecheck + test + stylelint green

## T-2026-05-08-001 — implement AppButton Coriolis primitive

- Created: 2026-05-08
- Completed: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.a
- Result: PR #3 — merged at `2708ce2` (`docs(design): list AppButton in @app/ui component inventory`); preceded by `1466dba` (specs + stories) and `127a157` (component rewrite).
- Goal: Replace the boilerplate AppButton with a Coriolis-token-driven component (primary / ghost / danger variants, sm / md / lg sizes) that passes typecheck, Vitest, and Stylelint.
- Acceptance — all met:
  - [x] `pnpm --filter @app/ui typecheck` (vue-tsc) exits 0
  - [x] `pnpm --filter @app/ui test` (vitest, 186 tests) exits 0
  - [x] `pnpm stylelint "packages/ui/**/*.{vue,scss,css}"` exits 0 for AppButton files
  - [x] AppButton row appears in `specs/design/README.md` component inventory
- Sub-steps:
  - [x] Push task entry to active.md
  - [x] Rewrite AppButton.vue with Coriolis tokens
  - [x] Rewrite AppButton.stories.ts with variant/size matrix (14 stories)
  - [x] Rewrite AppButton.spec.ts with full coverage (18 specs)
  - [x] Update specs/design/README.md component inventory
  - [x] Verify typecheck + test + stylelint green

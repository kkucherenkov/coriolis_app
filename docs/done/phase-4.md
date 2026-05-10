# Phase 4 — Dice & Sessions

**Phase:** 4
**Tag:** `phase-4-complete`
**PRD section:** §11 (roadmap)
**Date:** 2026-05-10

## What shipped

A player can now roll a dice pool from the character sheet, push the
roll at the rulebook cost (+1 Darkness Point), and watch the GM's DP
counter tick up live on every connected device. Phase 3 left the
character + sharing surface complete but mute on the table-side
mechanics; Phase 4 wires the full dice loop end-to-end — backend roll
persistence, push semantics, GameSession container, Darkness Points
audit log, Centrifugo channel ACL, web roller + history + GM session
view, mobile bottom-sheet roller + sessions screen — and uses the
round trip to migrate the web client off cookie auth onto the same
bearer flow the mobile app already used. Roughly fifty commits across
backend, web, mobile, specs, codegen, and bookkeeping.

A player can:

- Roll a dice pool of 1–10 d6 from the character sheet via
  `POST /api/v1/characters/{id}/rolls` — server rolls with
  `crypto.randomInt`, persists `dice[]`, computes `hits` (count of
  6s), and returns the full `Roll` shape.
- See the last 50 rolls in a "Recent Rolls" panel on web (sibling
  component) or scrolled below the roller form on mobile (one-screen
  bottom sheet).
- Push a non-pushed roll via `PATCH /api/v1/rolls/{id}/push` — non-6
  dice are rerolled once, hits recomputed, `pushed` flag flipped,
  `RollPushedEvent` fired. The push button is hidden when no roll
  exists, disabled when `pushed=true` or the character carries the
  `exhausted` condition flag — same truth table as
  `RulesEngine.canPush`, so the 422 round-trip is a defense-in-depth
  rather than the primary gate.
- See the original dice strip alongside the rerolls after a push,
  with failed pushes (still non-6) faded.

A GM can:

- Create a `GameSession` (name, optional system notes, optional ship
  assignment), list active and archived sessions, archive / unarchive,
  and assign or unassign characters via
  `POST /api/v1/game-sessions/{id}/characters` /
  `DELETE …/characters/{characterId}`.
- Adjust Darkness Points via `POST /api/v1/game-sessions/{id}/dp`
  with a signed delta and a free-form reason — atomic Prisma
  transaction increments `dpCount` and inserts a `DpEvent` audit row
  with `source: gm-manual | roll-push | system`.
- Read the audit tail at `GET …/dp/events` (last 20 by default).
- Watch the DP counter and roll-pushed toasts update live without
  polling: every `DpEvent` insert publishes `dp.changed` on
  `session.{gameSessionId}` and every push publishes `roll.pushed`
  before the +1 DP command lands.

A connected client can:

- Mint a Centrifugo JWT via `POST /api/v1/realtime/token` — token
  carries an explicit `channels` claim scoped to `session.{id}` for
  every GameSession the user owns (GM role).
- Subscribe to `session.{id}` and receive `dp.changed` and
  `roll.pushed` payloads, both contracts pinned in
  `packages/specs/asyncapi/centrifugo.yaml`.

Web also got the bearer-auth migration — the SDK singleton now
attaches `Authorization: Bearer <token>` from `localStorage` instead
of relying on `credentials: 'include'`, matching the mobile client and
sidestepping the SameSite/cookie quirks that surfaced during the dice
work.

## What landed (by feature group)

### Character creation rules alignment (carried Phase-3 follow-up)

Character forge pulled into rulebook compliance before the dice loop
landed on top of it: upbringing field + budgets, `Concept` (amplua)
enum, `Talent.kind` discriminator + `CrewConcept`, talent catalog
data, Mutant flag + stigma. Carried from Phase 3's tail follow-ups.

- `c70754f` — chore(tasks): T-2026-05-09-005 character creation rules alignment
- `cf47ef1` — feat(character): Block 1 — upbringing field & budgets
- `4c7a239` — chore(format): repo-wide prettier sweep
- `91dac1d` — feat(character): Block 2 — Concept (amplua) enum
- `250e918` — feat(character): Block 3 — Talent kind + CrewConcept
- `db52555` — feat(character): Block 4 — Talent catalog data
- `8cd30ac` — feat(character): Block 5 — Mutant flag + stigma
- `b8afde5` + `614e31f` + `e21dea5` — task archives

### Character follow-ups + auth flow (T-2026-05-10-001)

Locale-aware talent rendering, amplua-filtered personal-talent pool
on Step 6 of the wizard, and the missing `/signup` + forgot/reset
password pages — surfaced once the bearer migration removed the cookie
side-effects that masked the redirect bug.

- `6e58f40` — chore(tasks): T-005 + T-004 follow-ups before next block
- `0dc1f87` — feat(character): Block 1 — locale-aware talent rendering
- `070a94a` — chore(tasks): Block 1 done
- `41f61c5` — feat(character): Block 2 — amplua-filtered personal pool
- `766e660` — chore(tasks): Block 2 done
- `cdfca86` — feat(web): Block 3 — forgot-password + reset-password pages
- `fbab15c` — chore(tasks): Block 3 mark done
- `97c62ae` — chore(tasks): archive T-001; push T-002

### Bearer-auth migration (web)

The web SDK switched from session cookie to `Authorization: Bearer`,
matching mobile. Several incidental fixes lit up under the new flow.

- `91169bb` — fix(web): /signup page, landing CTA, and post-auth redirect
- `c962b8f` — fix(web): auth-required reads getSession() result directly
- `193c8e6` — fix(web): SDK client singleton sends session cookie (transitional)
- `7e4ea73` — fix(backend): JSON body parser before OpenAPI validator
- `772509e` — feat(web): switch auth from session cookie to bearer token

### Roll resource — spec + backend (Epic 7 Feature 7.1)

`POST /characters/{id}/rolls`, `GET …/rolls`, `PATCH /rolls/{id}/push`
in the spec; Prisma `Roll` model with composite
`(characterId, createdAt)` index; `DiceModule` with create / list /
push CQRS, `RulesEngine.canPush(roll, conditions)` returning a
discriminated union, and the roll engine using `crypto.randomInt`.

- `4d98fff` — feat(specs): Roll resource + push endpoint (v0.8.0)
- `4b84e8d` — chore(codegen): regenerate clients after Roll spec
- `2f00cef` — feat(backend): RulesEngine.canPush new {ok, reason} signature
- `0550b4e` — feat(backend): Prisma Roll migration
- `048704a` — feat(backend): DiceModule — create + list rolls
- `6a8182b` — fix(backend): CanPushResult is a real discriminated union

### GameSession resource — spec + backend (Epic 7 Feature 7.2)

Seven new paths under `/game-sessions`, six schemas, Prisma
`GameSession` + `CharacterGameSession` join table, `GameSessionsModule`
with the full CRUD + assignment commands and queries.

- `63682b9` — feat(specs): GameSession resource + CRUD + character assignment (v0.8.0)
- `3308b12` — chore(codegen): regenerate clients after merging Roll + GameSession
- `b10bedb` — feat(backend): Prisma GameSession + CharacterGameSession migration
- `b33516d` — feat(backend): GameSessionsModule — CRUD commands/queries

### Darkness Points + audit log (Epic 7 Feature 7.3)

DP adjustment endpoint, atomic Prisma transaction for
`dpCount` increment + `DpEvent` insert, ACL (only GM may apply
negative deltas; `internal=true` bypasses for system callers), and
the bridge from `RollPushedEvent` to a `+1 DP` command via internal
flag.

- `2ecbcd0` — feat(specs): DP adjustment endpoint + DpEvent audit log (v0.8.1)
- `b6d2172` — chore(codegen): regenerate clients after DP spec
- `a447aa2` — feat(backend): Prisma DpEvent migration
- `afd5472` — feat(backend): UpdateDpCommand + DpEvent persistence + ACL
- `a2a7ade` — feat(backend): wire RollPushedEvent to +1 DP via internal command

### Centrifugo realtime — token ACL + publish (Epic 7 Feature 7.4)

AsyncAPI extension for `session.{gameSessionId}` with `dp.changed`
and `roll.pushed` payloads, `CentrifugoClient` publish wrapper, and
the channel-scoped JWT ACL via `ISessionOwnershipRepo`. Both publish
paths are non-fatal — the DB write commits regardless, the failure is
caught and logged.

- `7e309a9` — feat(specs): AsyncAPI session channel + dp.changed + roll.pushed (v0.8.2)
- `812f988` — chore(codegen): regenerate clients after AsyncAPI extension
- `bde00d1` — feat(backend): CentrifugoClient — publish wrapper + spec
- `6e1e1d5` — feat(backend): tighten /realtime/token ACL with allowed-channel list
- `6cac7a2` — feat(backend): publish dp.changed on every DpEvent insert
- `b0ef2a3` — feat(backend): publish roll.pushed when a roll is pushed
- `fcfee69` — test(backend): realtime e2e — subscriber receives dp.changed

### Web — dice roller + history + sessions + DP + live (T-2026-05-10-002)

The five-block web pass: composable + roller widget; sibling history
panel; sessions index + detail skeleton; DP controls + audit log +
character assignment; live updates via the `centrifuge` JS client
wired to `useSessionRealtime`.

- `4e18df2` — feat(web): Block 1 — useRollsApi + dice roller widget
- `7e55f74` — chore(tasks): Block 1 done — start Block 2
- `ae27f42` — feat(web): Block 2 — roll history list + detail modal
- `2bf89ce` — chore(tasks): Block 2 done — start Block 3
- `9b78301` — feat(web): Block 3 — sessions index + detail skeleton
- `b6b676f` — chore(tasks): Block 3 done — start Block 4
- `65dfafa` — feat(web): Block 4 — DP controls + audit log + assignment
- `d12033e` — chore(tasks): Block 4 done — start Block 5 (Centrifugo)
- `1b9fb40` — feat(web): Block 5 — Centrifugo live updates on session detail
- `3ebc6f5` — chore(tasks): Block 5 done — task ready to archive
- `09c345d` — chore(tasks): archive T-002; push T-003

### Mobile — dice + history + sessions + live (T-2026-05-10-003)

The four-block mobile pass: rolls feature with bottom-sheet roller;
history list inside the same sheet; sessions list + detail with
GM-gated controls; Centrifugo live updates via the `centrifuge` Dart
package and a per-session `SessionRealtime` adapter.

- `fae41e0` — chore(codegen): regenerate dart api-client built_value .g.dart files
- `22b0a79` — feat(mobile): Block 1 — rolls feature + dice bottom sheet
- `51fae5b` — chore(tasks): Block 1 done — start Block 2
- `6190e02` — feat(mobile): Block 2 — roll history list inside dice sheet
- `37c95b5` — chore(tasks): Block 2 done — start Block 3
- `013764d` — fix(api-client-dart): add missing ShipModuleSlot import
- `59e1a42` — feat(mobile): Block 3 — sessions list + detail with GM controls
- `9e29931` — chore(tasks): Block 3 done — start Block 4
- `e8abc66` — feat(mobile): Block 4 — Centrifugo live updates on session detail
- `379eadf` — chore(tasks): Block 4 done — task ready to archive
- `dbc22c9` — chore(tasks): archive T-003; push T-004 (Phase 5 backend)

## Notable decisions

- **Channel ACL via JWT `channels` claim, not server-side join.**
  `/realtime/token` walks the user's owned `GameSession`s through
  `ISessionOwnershipRepo` and writes `channels: ['session.<id>', …]`
  into the JWT. Centrifugo enforces the claim on subscribe; the
  backend never sees a "subscribe" event. Trade-off: a freshly created
  session is unreachable until the next token rotation (≤5 min TTL).
  Acceptable for v1 — alternative was a server-mediated "subscribe
  RPC" which would have pulled the publish path through the backend.
  (`6e1e1d5`.)
- **Realtime publish is non-fatal, DB write is the source of truth.**
  Both `dp.changed` and `roll.pushed` are published _after_ the
  Prisma transaction commits; publish failure is caught and logged
  (`Logger.warn`), and the committed row is never rolled back.
  Clients will receive the next `dp.changed` on the following adjust
  and reconverge — eventual consistency on the read path was cheaper
  than two-phase commit. (`6cac7a2`, `b0ef2a3`.)
- **Push-roll → +1 DP via internal command, not a transaction.**
  `RollPushedDpHandler` issues `UpdateDpCommand` with `internal=true`,
  which bypasses the GM-owner ACL and stamps `source: ROLL_PUSH` into
  the audit row. The original push commits regardless of the DP
  outcome (errors caught + logged). Keeps the dice and game-sessions
  modules orthogonal — `DiceModule` doesn't import anything from
  `GameSessionsModule`; the handler lives in the latter and listens
  for the former's event. (`a2a7ade`.)
- **AsyncAPI v0.8.2 extension via codegen rewrite.**
  `7e309a9` extends the channel definition to two payloads
  (`DpChanged` + `RollPushed`) and rewrites `codegen-asyncapi.ts` to
  emit a _union_ of message types per channel instead of the
  first-only behaviour the script had been carrying. Pre-empted the
  trap of drifting into a single-message-per-channel world.
- **Spec versioning landmarks.** `v0.8.0` cut the new dice + session
  resources together (Roll spec at `4d98fff`, GameSession 3-way
  merged in at `63682b9` without bumping). `v0.8.1` added the DP
  endpoints additively (`2ecbcd0`). `v0.8.2` extended AsyncAPI
  (`7e309a9`). The spec-first loop ran cleanly in every step —
  no spec-after-implementation, no retroactive bumps.
- **Bearer auth is now the canonical web flow.**
  `772509e` is a behavioural cutover, not a refactor: web reads
  `set-auth-token` from signin/signup responses into `localStorage`
  and the SDK fetch override injects `Authorization` on every call.
  Cross-origin SameSite/cookie quirks no longer matter, DevTools
  requests are easier to inspect, and the same wire shape works in
  both clients. The earlier band-aid fixes (`193c8e6`, `c962b8f`,
  `91169bb`, `7e4ea73`) cleared the path before the cutover landed.
- **`canPush` returns `{ok, reason}` not a boolean.**
  `2f00cef` reshapes the helper and `6a8182b` follows up to make the
  result a proper TypeScript discriminated union — narrowing on
  `result.ok` exposes the typed `reason` to the controller, which
  maps it onto the 422 problem `code` (`ROLL_NOT_PUSHABLE` with a
  `reason` field). Keeps the rule out of the controller.
- **Mobile bottom-sheet collapses roller and history into one
  surface.** Web has two siblings (`SheetDiceRoller`,
  `SheetRollHistory`); mobile has one `DraggableScrollableSheet` that
  scrolls below the form into the history list. Different ergonomics:
  on mobile a player taps to open the dice loop, rolls, scrolls down
  to confirm; on web the GM may have multiple sheets visible at once.
  The repository / cubit boundary is identical across both. (`22b0a79`,
  `6190e02`.)
- **`CharacterRepositoryImpl` bridges `Concept` String ↔ EnumClass.**
  The regenerated Dart SDK shipped `Concept` as an `EnumClass`
  (built_value); the mobile domain layer kept it as a wire-string for
  forward compat with future amplua values. The data layer translates
  via `Concept.valueOf(...)` / `concept.name`. Promoting the domain
  field to a typed enum is its own follow-up. (`22b0a79` drive-by.)
- **Per-session websocket on mobile, shared cubit-scoped lifecycle.**
  DI constructs a fresh `SessionRealtime` per `SessionDetailCubit`
  factory — each detail page gets its own websocket which is the
  right granularity since the page is the only consumer. Cubit
  `close()` cancels both stream subscriptions and disposes the
  adapter so a navigated-away page doesn't leak. (`e8abc66`.)

## Follow-ups

- **Cursor pagination on roll history + DP audit log.** Both endpoints
  cap at 50 / 20 events; "Load more" is a follow-up if/when the
  corpus grows. Mobile sessions list pagination is in the same
  bucket.
- **Character assignment UX on mobile.** Web has the full
  `<select>` + per-row remove flow; mobile session detail surfaces
  the assigned character list but not the assign / unassign actions —
  the GM uses the laptop for those.
- **Character realtime channel.** `/realtime/token` only writes
  `session.{id}` into the `channels` claim. The PRD §10 channel table
  also lists `character.{id}` for live sheet collaboration; deferred
  to Epic 8 / 9 (offline + collab).
- **Centrifugo wiring unit tests.** Both web and mobile ship the
  realtime adapters but the e2e is a backend-only roundtrip
  (`fcfee69`). Web client-side and Flutter adapter tests deferred
  alongside the rest of the SFC mounting backlog.
- **Mobile `Concept` typed in domain.** The bridge in
  `CharacterRepositoryImpl` is intentional kostyl until the domain
  layer adopts a sealed Dart enum.
- **Storybook visual regression.** Still TODO; carried since Phase 1.
- **uk + el wizard translations.** Still placeholder; carried.
- **8 Flutter primitives.** Still pending the per-widget
  Material/Cupertino evaluation pass; carried since Phase 1.
- **Web `pnpm typecheck` local breakage.** macOS `oxc-parser` binding
  bug; CI under Linux remains the source of truth. Carried.
- **Phase 5 entry point.** Ships — sheets, crew assignment, ship
  sharing. Per PRD §11 Phase 5. The OpenAPI surface and the typed
  clients have been around since the Phase-1 spec sweep but
  `apps/backend/src/modules/ships` doesn't exist yet; T-004 in
  `active.md` opens with five sub-blocks (Prisma migration, core CRUD,
  module sub-resource, crew assignment, duplicate + export stub).

## Local merge ledger

Roughly fifty commits across the `phase-3-complete..dbc22c9` range,
landed under the same push-per-block cadence (see
`feedback_block_workflow.md` in auto-memory). Most recent first; the
per-feature task entries with judgement-call notes live in
`specs/tasks/done.md`.

- `dbc22c9` — archive T-003; push T-004 (Phase 5 backend)
- `379eadf` + `e8abc66` + `9e29931` + `59e1a42` + `013764d`
  - `37c95b5` + `6190e02` + `51fae5b` + `22b0a79` + `fae41e0` —
    T-003 mobile dice + history + sessions + live
- `09c345d` — archive T-002; push T-003
- `3ebc6f5` + `1b9fb40` + `d12033e` + `65dfafa` + `b6b676f`
  - `9b78301` + `2bf89ce` + `ae27f42` + `7e55f74` + `4e18df2` —
    T-002 web dice + history + sessions + DP + live
- `97c62ae` — archive T-001; push T-002
- `fbab15c` + `cdfca86` + `766e660` + `41f61c5` + `070a94a`
  - `0dc1f87` + `6e58f40` — T-001 character follow-ups + auth pages
- `fcfee69` + `b0ef2a3` + `6cac7a2` + `6e1e1d5` + `bde00d1` —
  Centrifugo realtime publish + ACL + e2e
- `91169bb` + `c962b8f` + `193c8e6` + `7e4ea73` + `772509e` —
  bearer-auth cutover + JSON body parser fix
- `812f988` + `7e309a9` — AsyncAPI v0.8.2 + codegen
- `a2a7ade` + `afd5472` + `a447aa2` + `b6d2172` + `2ecbcd0` —
  DP audit log + DP endpoint spec (v0.8.1) + roll-pushed bridge
- `6a8182b` + `3308b12` + `63682b9` + `b33516d` + `b10bedb` —
  GameSession spec + module + Prisma migration + canPush union fix
- `048704a` + `0550b4e` + `2f00cef` + `4b84e8d` + `4d98fff` —
  Roll spec (v0.8.0) + codegen + canPush helper + Prisma migration + DiceModule
- `e21dea5` + `614e31f` + `b8afde5` + `8cd30ac` + `db52555`
  - `250e918` + `91dac1d` + `4c7a239` + `cf47ef1` + `c70754f` —
    T-2026-05-09-005 character creation rules alignment (carried Phase-3 follow-up)

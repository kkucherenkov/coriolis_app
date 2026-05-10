# Phase 6 — GM Tools (backend)

**Phase:** 6 (backend only)
**Tag:** `phase-6-be-complete` (web + mobile deferred to `phase-6-complete`)
**PRD section:** §11 (roadmap)
**Date:** 2026-05-11

## What shipped

The backend half of GM Tools — NPC library, Encounter container,
Combatant sub-resource with state-machined damage / status / initiative
ops, and a Centrifugo `combat.updated` realtime publisher — is live on
`main`. The matching player surfaces (web combat tracker T-008, mobile
read-along card T-2026-05-11-002) are not yet shipped, so this phase
gets a separate `phase-6-be-complete` tag; the canonical
`phase-6-complete` tag is reserved for when the two clients land.

What also rode in on this phase, beyond the GM-tools spec + backend:

- **ST3001 canon remediation** (T-010 across ten blocks A–J + the five
  Block-J spin-offs T-012..T-016) — every accumulated rules drift
  flagged by the new `librarian` agent flushed in one campaign,
  cresting in the **OpenAPI `info.version` 0.17.0 → 1.0.0** major bump.
- **Web wizard role picker** (T-011) — first client to consume the new
  canonical Role enum + role-scoped key-skills shape.
- **Mid-phase fixes**: wizard step-5 single skill pool (T-009), backend
  boot unblock after Prisma client regenerate, web fetch Content-Type
  preservation, two false-start specs/.js stubs reverted then restored.
- **Test infra**: Playwright bootstrap + first wizard role-picker e2e
  smoke (T-017).
- **Web global navigation** (T-018) — header, mobile drawer, user menu,
  language switcher. Orthogonal to GM Tools but it landed in window
  and unblocks the upcoming combat-tracker page.

A GM can (server-side, via the typed clients):

- Manage a session-scoped NPC library — `POST /api/v1/game-sessions/
{id}/npcs`, list / patch / delete with attribute floor, statusFlags,
  weapons, armor, role, faction. Same shape as `Character` but without
  the player-facing wizard.
- Open and close encounters — `POST /api/v1/game-sessions/{id}/
encounters` with `{ name, npcIds[], characterIds[] }`. Server seeds
  one `Combatant` row per source, status `ENCOUNTER_PREP` → `ACTIVE` →
  `RESOLVED` via state-machined transitions.
- Roll / reroll initiative on the encounter — `POST /encounters/{id}/
initiative/roll` re-rolls 1d6 per combatant; ties resolve via reroll
  loop (canon) rather than agility tiebreak. `POST /encounters/{id}/
turn/advance` walks `turnOrder` ascending with a wrap-around to start
  a new round.
- Mutate combatants individually — `PATCH /combatants/{id}` for
  `hpCurrent` / `statusFlags`, with the canon clamp at 0..20 dice on
  any pool field, the canonical 11-value `CombatantStatusFlag` taxonomy,
  and the role / Role enum / role-scoped key-skill rules pushed down
  through the rules-engine.
- Receive realtime combat updates — every encounter / combatant /
  initiative mutation lazily snapshots through the
  `CentrifugoCombatPublisher` and lands on `session.{gameSessionId}`
  as a `combat.updated` envelope (full encounter + ordered combatants
  payload, AsyncAPI-locked shape).

A web wizard player can additionally:

- Pick a canonical Role on a new dedicated step (Step 5 — Role); the
  wizard renumbered 6 → 7 to make room. Role catalogue carries all 33
  canon roles with per-role 4 key skills surfaced on Step 6 (skills);
  unmigrated `Character` rows surface a `RoleUnmigratedBanner` until
  they pick.

## What landed (by feature group)

### Phase 6 spec — Npc + Encounter + Combatant + initiative + realtime (T-2026-05-10-006)

The five-block spec pass: NPC resource, Encounter resource, Combatant
sub-resource, initiative + turn-order ops, AsyncAPI `combat.updated`
extension. Each block ends with a codegen pass; OpenAPI walked from
0.12.x to 0.17.0 across this task before T-010 Block J pushed it to
1.0.0.

- `1dca68b` — feat(specs): Block 1 — Npc resource (v0.13.0)
- `738e2bc` — chore(codegen): regenerate clients after Npc spec
- `db0186c` — feat(specs): Block 2 — Encounter resource (v0.14.0)
- `a1e9658` — chore(codegen): regenerate clients after Encounter spec
- `55d792e` — feat(specs): Block 3 — Combatant sub-resource (v0.15.0)
- `b6837a4` — chore(codegen): regenerate clients after Combatant spec
- `14c4302` — feat(specs): Block 4 — initiative + turn order ops (v0.16.0)
- `239275c` — chore(codegen): regenerate clients after initiative spec
- `ee727a0` — feat(specs): Block 5 — combat.updated AsyncAPI message
- `deafe5d` — chore(codegen): regenerate clients after AsyncAPI extension
- `7cbbaed` — chore(tasks): Block 5 done — task ready to archive
- `0ea94b9` — chore(codegen): finalise Phase 6 openapi-types tail
- `0010b71` — chore(tasks): archive T-006, push T-007 (backend) + T-008 (web)

### Phase 6 backend — NpcModule + EncountersModule + Centrifugo publisher (T-2026-05-10-007)

The five-block backend pass: NPC CQRS module, Encounter CQRS + state
machine, Combatant sub-resource + state-machine wire-up, initiative +
turn ops, Centrifugo `combat.updated` publisher.

- `34a1fca` — feat(backend): Block 1 — NPC CQRS module
- `87688a3` — feat(backend): Block 2 — Encounter CQRS module + state machine
- `0655d91` — feat(backend): Block 3 — Combatant sub-resource + state-machine wire-up
- `022309c` — feat(backend): Block 4 — initiative + turn ops
- `a9b0298` — feat(backend): Block 5 — Centrifugo combat.updated publisher
- `a7367f4` — fix(backend): import RealtimeModule in EncountersModule
- `d6c4989` — chore(tasks): T-007 → done.md (Phase 6 backend complete)

Boot also broke once mid-task on a Prisma client regenerate; fixed in
`bdd3709` (13 type errors). `fdfebab` patched a web Content-Type loss
when the api-client SDK called `fetch(request)`. `e804feb` + `1069fe1`
were a false-start revert / restore of `.js` stubs in `packages/specs/
src/` — Vite/Nuxt needs them; backend doesn't care.

### ST3001 canon remediation (T-2026-05-10-010 + T-012..T-016)

A read-only `librarian` agent (`13c9ae5`) was added to audit
implementation against the ST3001 Russian rulebook. It returned ten
canon drifts; the remediation walked them in alphabetical blocks
A–J with the same spec → codegen → backend → bookkeeping shape per
block. Block J then split five spec-silence follow-ups out as
self-contained T-tasks (T-012..T-016).

T-010 blocks (in canonical order):

- `bf41a9a` — Block A — d6 initiative + reroll tie-break (replacing
  the placeholder d10 + agility tiebreak)
- `9e3d0dd` — Block B — Combatant `statusFlags` canon taxonomy (left
  as free-form string array per-shipped, not enum-locked)
- `457fe42` — Block C — dice pool 0..20 clamp + Ноль кубиков rule
- `05b6a2c` — Block D — Attributes minimum 2 (active-PC invariant)
- `80bf2d8` — Block E — Character.role + 33-value canonical Role enum
  - role-scoped key skills (per-role 4 key skills surfaced)
- `6ddf8c3` — Block F — ItemRangeEnum 5-band → canonical 4-band
  (close, medium, long, extreme)
- `49821a4` — Block G — ItemCybernetic.bodyPoints retired, replaced
  with xpCost
- `9bc569b` — Block H — ItemSlotType retired; ItemShipModule.slot
  unified on the canonical 21-value ShipModuleSlot
- `7f09036` — Block I — PRD-override comments on rules-engine /
  Combatant.hpCurrent / signature + i18n glossary
- `32f6fa3` — Block J — bump `info.version` 0.17.0 → 1.0.0
- `18f1aff` — Block J close: T-010 done, 5 deferred tasks pushed

Each Block has a matching `chore(codegen)` regenerate commit and a
`chore(tasks)` tick — omitted above to keep the list scannable.

The five Block-J spin-offs (independent, sequenced):

- `9fcd89d` + `e2ed42f` + `3b3f5f7` — T-012 ItemWeapon.initiative
  modifier (ГЛАВА 6 weapon tables) + apply on roll
- `196e8ed` + `459febd` + `998901a` — T-013 ItemArmor.extraSlotCount
  (ТАБЛИЦА 6.14) + apply on equip
- `1fc660c` — T-014 canonical ship class table from ТАБЛИЦА 7.5
  (no spec change — backend constants only)
- `f3c03d1` + `a7fe95b` + `df349c1` — T-015 RollKind discriminator +
  gate `pushRoll` to `roll.kind === 'skill'`
- `f77cdb2` + `3cb7e85` + `ddf436d` — T-016 RollCreate.breakdown
  audit trail (persist `RollBreakdown` + sum-equality invariant)
- `5c04d49` — fix(backend): typecheck under
  exactOptionalPropertyTypes — T-012 / T-016 fallout (three errors:
  source-lookup adapter, roll.repo breakdown insert, two test
  fixtures missing the new required fields)

### Web wizard role picker (T-2026-05-10-011)

First UI consumer of the canon Role enum. Five blocks: roleCatalogue
data file, Step5Role + wizard renumber 6 → 7, Step6Skills role-scoped
key-skill highlight, RoleUnmigratedBanner + RoleCard, drop the
augmented Character type now that the spec carries `role` directly.

- `a248e1e` — Block 1 — roleCatalogue.ts (33 entries + i18n keys)
- `29a20d0` — Block 2 — Step5Role + wizard renumber 6 → 7
- `a9ca8e5` — Block 3 — Step6Skills role-scoped key-skills
- `bfa24ee` — Block 4 — RoleUnmigratedBanner + RoleCard
- `2de2d5b` + `b6d208c` + `364f579` — Block 5 — Character.roleUnmigrated
  spec field + drop augmented type
- `577b306` — fix(web): T-010 web fix-forward — range / xpCost / slot
  cascading rename
- `23cd407` — chore(tasks): T-011 done

### Web global navigation (T-2026-05-10-018)

Orthogonal to GM Tools but it landed in window. Five blocks: UserMenu,
AppHeader desktop, AppMobileDrawer + AppHeader integration, global app
layout (header + drawer + user menu), Playwright nav smoke.

- `66912e6` — Block 1 — UserMenu component
- `6423582` — Block 2 — AppHeader (desktop)
- `0603c2c` — Block 3 — AppMobileDrawer + AppHeader integration
- `cabe22a` — Block 4 — global app layout
- `7736fbc` — Block 5 — global nav smoke + close T-018

### Mid-phase fixes and test infra

- `8d55fd7` — T-009 wizard step-5 single skill pool sized by
  upbringing, key/non-key caps. Pre-empted before role-picker landed
  on top of it.
- `e9ae933` + `48c0295` — T-017 Playwright bootstrap + wizard
  role-picker e2e smoke (test infra dovetailed with T-011).
- `13c9ae5` — chore(agents): add librarian (read-only canon audit
  agent — drove the entire T-010 campaign).
- `7124152` — chore(tasks): T-010 push (canon alignment task entry).
- `7a09ee5` — chore(format): exempt `specs/tasks/{active,done}.md`
  from prettier (markdown line-wrap was eating the LIFO entries).
- `f6f2904` + `6781da3` + `a73e85c` + `3aaddb8` — periodic prettier
  sweeps across web, asyncapi, ships, and ui SFCs.
- `1f85d23` — chore(tasks): archive T-010..T-018 (9 tasks moved to
  `done.md`).

## Notable decisions

- **`phase-6-be-complete` vs deferred `phase-6-complete`.** PRD §11
  Phase 6 is GM Tools _across all three clients_: combat tracker
  (desktop-shaped), mobile read-along card, NPC library, GM session
  view, realtime combatant updates. The backend half + the contract
  are fully shipped on `main` — the spec is locked at `1.0.0`, the
  Centrifugo channel is publishing, and the typed clients carry every
  shape. T-008 (web combat tracker) and T-2026-05-11-002 (mobile
  read-along) are the remaining halves and they're in `active.md` but
  not yet shipped. Cutting the canonical `phase-6-complete` tag now
  would lie about what works for an end user. The compromise: cut
  `phase-6-be-complete` here so the backend milestone is reachable in
  git history (and the contract version 1.0.0 has a tag against it),
  and reserve `phase-6-complete` for when the two clients land.
- **Initiative is d6 with reroll on tie, not d10 with agility
  tiebreak.** Block A flipped the placeholder rules-engine code that
  had been carrying d10 + agility-tiebreak shape from a pre-canon
  guess. The canon (ГЛАВА 4) is 1d6 per combatant; ties reroll until
  resolved. The tiebreak loop is unbounded in canon and matches in
  the implementation — no clamp on iteration count, since with 1d6 +
  N combatants the geometric expectation is bounded by ~6 iterations
  in the worst case anyway.
- **`statusFlags` is a free-form `string[]`, not an enum.** Block B's
  spec defines a canonical 11-value taxonomy in the description
  (PANICKED, BROKEN, STUNNED, …) but the OpenAPI shape stayed
  `array<string>` — homebrew GMs can carry their own statuses without
  forking the spec, and the canonical taxonomy is a backend
  validation guard rather than a wire constraint. Fixtures were
  canonicalised in `9e3d0dd`.
- **Dice pool 0..20 + Ноль кубиков.** Block C clamped every dice-pool
  field across the spec at 0..20. The Ноль кубиков (zero-dice) rule
  is the canon failure mode when a pool resolves to 0 — surfaces as a
  `roll.kind === 'skill'` outcome with `successes === 0` and a
  client-rendered translation string. Implementation lives in the
  rules-engine; the spec carries the `0` minimum so client code can
  pre-validate.
- **Attributes minimum 2, not 1.** Block D lifted the floor from 1 to
  2 — canon (ГЛАВА 2) says active PCs cannot have a 1 in any
  attribute (a 1 is "incapacitated / dying"). NPC fixture in
  `aac0dca` was bumped from `empathy: 1` to `empathy: 2` to match.
  The web wizard already enforced 2 client-side; this just made the
  spec honest.
- **Role canonical enum + role-scoped key skills.** Block E adds
  `Character.role: Role` (33 canonical values) and surfaces the
  `ROLE_CONCEPT_MISMATCH` invariant when a character flips to active
  status. Each role has 4 canonical key skills — the rules-engine
  treats these as pool +1 / non-key as pool flat. Web wizard
  consumed it via T-011 (`a9ca8e5` Step6Skills).
- **ItemRangeEnum 4-band, not 5-band.** Block F dropped `engaged`
  from a presumed 5-band ladder, leaving the canon 4-band ladder
  (`close, medium, long, extreme`) per ТАБЛИЦА 6.14. Engaged-range
  combat is a status / situation, not a weapon range.
- **`info.version` 0.17.0 → 1.0.0.** Block J's major bump owns five
  breaking changes (Block D attributes floor, Block E Role,
  Block F range tightening, Block G ItemCybernetic xpCost,
  Block H ShipModuleSlot unification). The 1.0.0 marker also
  reflects the canon-alignment effort finishing — every wire shape
  the librarian flagged is now either fixed or pushed out as a
  numbered T-task with citation. Subsequent T-012..T-016 land on
  top of 1.0.0 with minor bumps (the spec carries `Combatant.
initiative` bump and `RollCreate.breakdown` as additive minor
  changes; TypeScript / Dart codegen treated them as non-breaking).
- **Web global navigation included in this doc.** T-018 is general
  web infra (header / drawer / language switcher / settings page)
  rather than GM Tools, but it landed in this window and the
  upcoming web combat tracker (T-008) sits inside the layout it
  introduces. Excluding it would leave a hole in the merge ledger;
  including it makes the dependency chain readable for the next
  phase.
- **Librarian agent.** Read-only canon-audit agent — given a piece
  of the codebase, returns drift findings against ST3001 with
  citations. Drove the entire T-010 campaign and seeded T-012..T-016.
  Lives at `.claude/agents/librarian/` (added in `13c9ae5`); intended
  to run before each phase-spec pass and on demand.
- **Combat publisher uses lazy snapshots, not diffs.** Block 5 of
  T-007 emits the full `{ encounter, combatants[] }` payload on
  every mutation — clients re-render from the snapshot. Diff
  computation would have required either ETags or operation
  envelopes; the encounter cardinality is small enough (single
  digits of combatants per encounter) that the bandwidth saving
  doesn't pay for the complexity. Channel is
  `session.{gameSessionId}`; payload mirrors the AsyncAPI
  `CombatUpdated` shape (`centrifugo.yaml` lines 165–257).

## Follow-ups

- **T-2026-05-10-008 — Phase 6 web: NPC library + GM combat tracker.**
  Already in `active.md`. Depends on T-007 (this phase). The piece
  the player and GM actually see — desktop combat tracker + NPC
  library page. Cutting `phase-6-complete` is gated on this.
- **T-2026-05-11-002 — Phase 6 mobile: read-along combat card
  (Flutter).** Already in `active.md`. Depends on T-008 (so the web
  shape is settled before Flutter mirrors it). Read-only — the
  player sees the live encounter + their own turn cue, doesn't
  mutate combat state.
- **`phase-6-complete` tag deferred.** Cut after T-008 and
  T-2026-05-11-002 land; this `phase-6.md` will get a revision (or
  appendix) covering the web + mobile halves at that point.
- **Encounter end-state cleanup.** `RESOLVED` encounters stay on the
  session indefinitely. No archive / TTL flow yet — fine while
  greenfield, will need a sweep when sessions accumulate dozens of
  resolved encounters. Not blocking.
- **Combatant sourceId vs referenceId.** AsyncAPI required-subset
  carries `referenceId` on the publisher payload while the storage
  column is `sourceId`. Mapped in `CentrifugoCombatPublisher` per
  `a9b0298`. The naming asymmetry is deliberate (publisher payload
  is wire-locked; storage uses the domain term) but it's a footgun
  for anyone reading the publisher cold — ADR candidate.
- **NPC reusability across sessions.** NPCs are scoped to one
  `gameSessionId`; reusing a beloved antagonist across sessions
  means cloning. Acceptable for greenfield; a session-agnostic
  "NPC library" surface is a Phase-7+ ask.
- **`_prisma_migrations` baselining.** Same Phase-7 hardening item
  carried since Phase 5. Encounter / Combatant / NPC migrations all
  applied via `db push` for the dev DB; the migration SQL files are
  committed.
- **Storybook visual regression.** Still TODO; carried since
  Phase 1.
- **8 Flutter primitives.** Still pending the per-widget
  Material/Cupertino evaluation pass; carried since Phase 1.
- **Web `pnpm typecheck` local breakage.** macOS `oxc-parser`
  binding bug; CI under Linux remains the source of truth. Carried.
- **uk + el role / status / range / cybernetic translations.** Block E
  / F / G shipped en + ru with uk / el placeholders. Same status as
  the rest of the wizard surfaces — carried.
- **Phase 7 entry point.** Not yet scoped in `active.md` beyond the
  PRD §11 line — PCs vs NPCs combat resolution polish, sharing,
  printable / export polish. The Phase-6 web + mobile halves come
  first.

## Local merge ledger

119 commits across the `39595f8..5c04d49` range, landed under the
push-per-block cadence (see `feedback_block_workflow.md` in
auto-memory). Most recent first; per-feature task entries with
judgement-call notes live in `specs/tasks/done.md`.

- `5c04d49` — typecheck under exactOptionalPropertyTypes (T-012 /
  T-016 fallout)
- `3aaddb8` — chore(format): Prettier drift across web + ui SFCs
- `1f85d23` — chore(tasks): archive T-010..T-018 (9 tasks)
- `7736fbc` + `cabe22a` + `0603c2c` + `6423582` + `66912e6` —
  T-018 web global navigation (5 blocks)
- `48c0295` + `e9ae933` — T-017 Playwright bootstrap +
  wizard role-picker e2e smoke
- `10c9eec` + `ddf436d` + `3cb7e85` + `f77cdb2` — T-016
  RollCreate.breakdown audit trail
- `68ccbcc` + `df349c1` + `a7fe95b` + `f3c03d1` — T-015
  RollKind discriminator + push gate
- `8dbebaf` + `1fc660c` — T-014 canonical ship class table
- `dc5306e` + `998901a` + `459febd` + `196e8ed` — T-013
  ItemArmor.extraSlotCount
- `531270e` + `3b3f5f7` + `e2ed42f` + `9fcd89d` — T-012
  ItemWeapon.initiative
- `8fc2847` — push T-018 entry
- `23cd407` + `364f579` + `b6d208c` + `2de2d5b` + `bfa24ee` +
  `a73e85c` + `a9ca8e5` + `29a20d0` + `577b306` + `a248e1e` —
  T-011 web wizard role picker (5 blocks + fix-forward)
- `18f1aff` + `32f6fa3` + `afad9f3` + `7f09036` + `f7c8559` +
  `d058b2e` + `a941fba` + `9bc569b` + `78e556e` + `c5cde35` +
  `0ff7f5a` + `49821a4` + `23c412d` + `4cca564` + `7beac51` +
  `6ddf8c3` + `39df704` + `1219df4` + `d547392` + `80bf2d8` +
  `1e6ca54` + `059f661` + `9adff15` + `aac0dca` + `05b6a2c` +
  `381ddef` + `345e0e4` + `44c2f5f` + `457fe42` + `8d8c30a` +
  `8a27aef` + `24ad906` + `9e3d0dd` + `c0fcba9` + `a65016d` +
  `bf41a9a` + `d0e553b` — T-010 canon remediation (Blocks A–J +
  per-block codegen + tasks ticks)
- `7a09ee5` — exempt active.md / done.md from prettier
- `a7367f4` + `d6c4989` + `a9b0298` + `7124152` + `13c9ae5` +
  `08b8fcb` + `022309c` + `f5cda39` + `0655d91` + `9ae32e6` +
  `87688a3` + `f6f2904` + `892b7ef` + `34a1fca` + `0010b71` —
  T-007 Phase 6 backend (5 blocks) + librarian agent
- `afea9d5` + `8d55fd7` — T-009 wizard step-5 single pool
- `fdfebab` — fix(web): preserve Content-Type when SDK calls fetch
- `1069fe1` + `e804feb` — false-start revert / restore of .js stubs
- `bdd3709` — fix(backend): unblock backend boot post-Prisma
- `6781da3` + `0ea94b9` + `7cbbaed` + `deafe5d` + `ee727a0` +
  `649c4e6` + `239275c` + `14c4302` + `19b5561` + `b6837a4` +
  `55d792e` + `41fb3e5` + `a1e9658` + `db0186c` + `362724a` +
  `738e2bc` + `1dca68b` — T-006 Phase 6 spec (5 blocks +
  per-block codegen + tasks ticks)

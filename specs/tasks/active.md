## T-2026-05-11-001 — Backfill `phase-{2..6}-complete` tags + `docs/done/` summaries

- Created: 2026-05-11
- Owner: claude
- Spec: PRD §11 ("Phased Roadmap") +
  [`docs/done/README.md`](../../docs/done/README.md)
  ("phase-N.md summary entries written when the
  phase-N-complete tag is cut").
- Goal: reconcile the phase-tag history with what's actually
  shipped on `main`. Phase 2 (character sheet + wizard),
  Phase 3 (sharing + polish), Phase 4 (dice + sessions +
  Darkness Points + push), Phase 5 (ships), and Phase 6
  backend (T-006 spec + T-007 backend + T-010 canon
  remediation) are all merged, but the most recent tag is
  `phase-3-complete` and `docs/done/` only contains
  `phase-0.md` + `phase-1.md`. Close the drift now while
  the PR-to-feature mapping is still legible from `git log`.
- Why now: T-008 (Phase 6 web combat tracker, next on the
  stack) is going to land soon. Better to land it on top
  of an honest phase ledger than improvise the Phase 6
  summary at merge time. The cost is one quiet hour
  today; the cost six months from now is reverse-engineering
  the timeline from commit messages.
- Depends on: nothing.
- Acceptance:
  - `docs/done/phase-2.md`, `phase-3.md`, `phase-4.md`,
    `phase-5.md`, `phase-6.md` exist, each following the
    template in `docs/done/README.md`. Each lists the PRs /
    task IDs that closed the phase, links to them, and names
    the deferred follow-ups.
  - Tags `phase-2-complete`, `phase-4-complete`,
    `phase-5-complete`, `phase-6-be-complete` cut at the
    correct commits (`phase-3-complete` already exists —
    leave it alone). `phase-6-complete` reserved — it is cut
    only when T-008 + T-2026-05-11-002 (mobile read-along)
    both land.
  - `docs/done/README.md` is unchanged; entries follow its
    template verbatim.
  - No code changes outside `docs/done/`.
- Spec diff: none.
- Codegen impact: none.
- Design impact: none.
- Tests: none — documentation + tagging only.
- Sub-blocks (one `chore(docs)` commit per block + one
  active.md follow-up commit, per
  `feedback_block_workflow.md`):
  - [x] Block 1 — `phase-2.md` (full character sheet,
        attributes / skills / talents / conditions, inventory,
        derived stats, auto-save, creation wizard,
        Cyrillic review). Tag `phase-2-complete` already
        cut at `a47e535`; only the summary doc was new.
        Doc landed; 50 commits classified into 8 feature
        groups (a11y CI, primitives, auto-save, sheet body,
        inventory, draft-state ADR, web wizard, mobile
        parity).
  - [x] Block 2 — `phase-3.md` (share links, public
        read-only views, OG image route, mobile pass, a11y
        audit). Tag already at `03e2c6c`; only the summary
        doc is new. 35 commits classified into 5 feature
        groups (Flutter 3.41 compat, share-link backend +
        ADR-0003, public viewer + OG renderer, mobile pass,
        theme persist + a11y/reduced-motion sweep).
  - [x] Block 3 — `phase-4.md` (dice roller web + mobile,
        push mechanic, GameSession, Darkness Points,
        Centrifugo channel for live DP). Tag
        `phase-4-complete` cut at `dbc22c9` (boundary
        commit — archives T-003 mobile, pushes T-004
        Phase 5 backend). Doc classifies ~60 commits into
        9 feature groups (dice spec, dice + push backend,
        GameSessions, DP audit log, Centrifugo realtime,
        web dice + sessions + DP + live, mobile parity,
        bearer-auth cutover, character-rules + locale-aware
        follow-ups).
  - [x] Block 4 — `phase-5.md` (ship sheets, modules,
        crew). Tag `phase-5-complete` cut at `39595f8`
        (boundary commit — archives T-005 web, pushes T-006
        Phase 6 spec). 21 commits classified into 2 task
        groups (T-004 backend ShipsModule + T-005 web ship
        list + sheet + module editor + crew widget +
        polish). Ship-share parity captured as a deferred
        follow-up — Phase 5 PRD scope ("ship sharing") did
        not ship.
  - [ ] Block 5 — `phase-6.md` (NPC + Encounter +
        Combatant + initiative + combat realtime backend,
        ST3001 canon remediation). Cut `phase-6-be-complete`
        at the T-007 final commit. Note in the summary that
        `phase-6-complete` is intentionally deferred until
        T-008 (web tracker) and T-2026-05-11-002
        (mobile read-along) land.
- Status: in-progress
- Blockers: —

## T-2026-05-10-008 — Phase 6 web: NPC library + GM combat tracker

- Created: 2026-05-10
- Owner: claude
- Spec: T-006 locked the wire contract; T-007 lands the backend
  implementation. This task wires the web SPA against both.
- Goal: GM-facing combat tracker UX — NPC library page,
  inline encounter creation on the session view, combatant
  picker (PC + NPC), initiative roll/reorder/advance, live
  combat re-render via the existing centrifuge subscription
  on `session.{id}` (DP composable already subscribes; reuse
  the channel, branch on payload type).
- Depends on: T-2026-05-10-007 (Phase 6 backend).
- Acceptance:
  - `/app/npcs` index — list + filter + inline create form +
    per-card Open / Duplicate / Delete + empty state, mirrors
    `/app/ships` index pattern.
  - `/app/npcs/[id]` sheet — full editable stat block with
    `useAutoSave` debounce on blur, header with rename +
    duplicate + delete + AppSavePulse.
  - On the session view (`/app/sessions/[id]`): an
    `EncounterPanel` that lists encounters for the session,
    inline create (name + notes), per-card open which expands
    a `CombatTracker` widget.
  - `CombatTracker` widget — combatant list ordered by
    `turnOrder`, active row highlighted, GM-only Roll
    Initiative / Advance Turn / Reorder (drag-and-drop)
    buttons. Add Combatant flyout with two tabs (PC picker
    pulling characters from the session, NPC picker pulling
    from `/api/v1/npcs`). Status-flag chips render the
    canonical tags (`incapacitated`, `prone`, `covered`) with
    themed icons and accept free-form additions per the
    T-010 Block B free-form policy. No client-side
    enum gate.
  - Realtime: subscribe to `session.{id}` (already done for
    DP) — branch on `payload.type` to update DP counter or
    re-render the combat tracker from the lazy snapshot. No
    diff computation in the client — replace local state
    wholesale.
  - i18n: every user-visible string keyed; ru + en strings
    in the existing `apps/web/i18n/locales/{ru,en}.json`.
  - Storybook: `CombatTracker` and `EncounterPanel` get
    stories (states: empty / setup / active / ended).
  - Vitest count climbs by ≥40.
- Spec diff: none.
- Codegen impact: none — generated TS client already exposes
  the Phase 6 ops from T-006.
- Design impact: combat tracker is a new pattern — capture
  tokens / spacing in the Storybook stories, no new design
  tokens needed (reuse existing role / size scales).
- Tests: vitest @testing-library/vue specs per page +
  composable; Storybook visual stories; one Playwright
  smoke flow (create encounter → add 2 combatants → roll
  initiative → advance turn → realtime update arrives).
- Sub-blocks (one feat-web commit per block + one
  active.md follow-up commit, per `feedback_block_workflow.md`):
  - [ ] Block 1 — `useNpcsApi` composable + `/app/npcs`
        index page (list, inline create, per-card actions,
        empty state, error retry). Nav link from characters
        AppBar.
  - [ ] Block 2 — `/app/npcs/[id]` sheet with auto-save
        on blur, header actions, problems card.
  - [ ] Block 3 — `useEncountersApi` composable +
        `EncounterPanel` on the session view. Inline create,
        list, open / delete. State-machine UI hints
        (e.g. "Add ≥1 combatant before rolling initiative").
  - [ ] Block 4 — `useCombatantsApi` + `CombatTracker`
        widget. PC + NPC picker, status chips, drag reorder.
        No initiative actions yet — picker + list only.
  - [ ] Block 5 — Initiative ops + realtime wire-up.
        Roll / Advance Turn buttons, drag reorder dispatch
        to backend, branch the existing `session.{id}`
        subscription on payload type to update tracker
        from `combat.updated` snapshots. Storybook
        stories landed.
- Status: in-progress (blockers cleared 2026-05-10 —
  T-007 backend done, T-010 canon remediation done; the
  d6 initiative + free-form `statusFlags` decisions from
  T-010 are now baked into the acceptance above)
- Blockers: —

## T-2026-05-11-002 — Phase 6 mobile: read-along combat card (Flutter)

- Created: 2026-05-11
- Owner: claude
- Spec: PRD §11 Phase 6 scope ("Combat tracker —
  desktop-shaped; mobile read-along card") + §7.6 Flutter
  feature map. Wire contract already published in
  OpenAPI v0.16+ + AsyncAPI `combat.updated` from T-006.
- Goal: a player on mobile, viewing an active session, sees
  a live, read-only card showing the current encounter —
  turn order, active row, status flags, combatant HP /
  armor / weapon — that re-renders as the GM advances
  turns, rerolls initiative, or edits combatants on web.
- Depends on: T-2026-05-10-008 (web combat tracker —
  first end-to-end consumer of the wire shape; if T-008
  surfaces a contract gap, that gets fixed before mobile
  consumes it). Soft dep — can start in parallel with
  T-008's last block once the realtime payload shape is
  known to be stable.
- Acceptance:
  - On the mobile session detail screen, when the session
    has at least one active encounter, an `ActiveCombatCard`
    renders below the existing DP counter. Clean empty
    state when no active encounter, error state with
    retry on fetch failure.
  - The card lists combatants ordered by `turnOrder`,
    highlights the active row, renders status-flag chips
    (canonical `incapacitated` / `prone` / `covered` get
    themed icons; other free-form tags render as plain
    chips per T-010 Block B).
  - Read-only — no roll, reorder, or add/remove. GM ops
    stay on web for v1.
  - Realtime: subscribes to the existing `session.{id}`
    channel via the centrifuge client added in T-003.
    Branches on `payload.type` — DP updates feed the
    existing DP cubit, `combat.updated` snapshots replace
    the local combat state wholesale (no client diff).
  - i18n: every visible string keyed in
    `apps/mobile/lib/i18n/` with ru + en + el + uk parity
    (matches the existing locale set).
  - Tests: cubit unit tests (load / realtime /
    error transitions), widget golden tests for the card in
    3 states (empty / active / ended), one integration
    smoke driving the realtime path with a fake
    centrifuge client.
- Spec diff: none — wire already shipped in T-006.
- Codegen impact: none — Dart client already exposes
  the Phase 6 ops.
- Design impact: new `ActiveCombatCard` widget — capture in
  the mobile widget catalogue. No new design tokens; reuse
  the existing role / size scales.
- Tests: cubit unit + widget goldens + 1 integration smoke.
- Sub-blocks (one `feat(mobile)` commit per block + one
  active.md follow-up commit, per
  `feedback_block_workflow.md`):
  - [ ] Block 1 — `lib/features/combat/` skeleton
        (data + domain + presentation), `CombatRepository`
        over the generated Dart client, fixture-backed
        widget catalogue entry.
  - [ ] Block 2 — `ActiveCombatCubit` (load by sessionId →
        resolve active encounter → fetch combatants),
        states (loading / empty / ready / error), unit
        tests.
  - [ ] Block 3 — `ActiveCombatCard` widget integrated
        into the session detail screen. Empty / active /
        ended state goldens.
  - [ ] Block 4 — Realtime: extend the existing
        `session.{id}` subscription router (T-003) to
        branch on `payload.type` and feed `combat.updated`
        snapshots into the cubit. Integration test with
        a fake centrifuge.
  - [ ] Block 5 — i18n + a11y pass (semantics labels for
        the active row, screen-reader cue when the active
        turn rotates, RTL-safe layout).
- Status: queued (blocked on T-008 to validate the wire
  shape end-to-end on web first; unblocks when T-008
  Block 5 lands)
- Blockers: T-2026-05-10-008

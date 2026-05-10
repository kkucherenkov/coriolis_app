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
  - [x] Block 1 — `lib/features/combat/` skeleton
        (data + domain + presentation), `CombatRepository`
        over the generated Dart client, fixture-backed
        widget catalogue entry. 8 unit tests on the
        repository impl. Codegen-drift follow-up noted:
        the generated Dart client has stale .g.dart files
        post-T-010 Block H (ShipModuleSlot import missing
        in 4 ship-module modules) — flagged for a separate
        `chore(codegen)` task; NOT fixed in this block since
        the combat module doesn't depend on those models.
  - [x] Block 2 — `ActiveCombatCubit` (load by sessionId →
        resolve active encounter → fetch combatants),
        states (loading / empty / ready / error), unit
        tests. State union uses Dart 3 sealed/final
        class idiom (matches sessions/characters cubits,
        no freezed). 8 cubit tests added — total combat
        scope 15/15 passing.
  - [x] Block 3 — `ActiveCombatCard` widget integrated
        into the session detail screen. Empty / active /
        ended state widget tests (11 widget tests). Card
        listens to ActiveCombatCubit, renders read-only
        combatant list ordered by turnOrder, canonical
        flag chips (incapacitated / prone / covered) with
        themed icons + free-form chips. Mounted below the
        DP counter via MultiBlocProvider. i18n: 4 new
        combat_*.i18n.json source files (ru full, uk + el
        placeholders); strings_*.g.dart regenerated via
        `dart run slang`.
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

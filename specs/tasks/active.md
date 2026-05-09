## T-2026-05-10-002 — Phase 4 web frontend: dice roller + sessions + DP + live updates

- Created: 2026-05-10
- Owner: claude
- Spec: PRD §11 Phase 4 (Dice & Sessions) — backend already shipped between
  `phase-3-complete` and HEAD (Roll module, GameSession CRUD, DP audit log,
  AsyncAPI session channels, Centrifugo publishing). The web frontend has
  none of it: there is no dice roller UI, no roll history view, no GM
  session view, and no DP counter. Players currently can roll dice via
  curl but not from the sheet.
- Goal: Wire the existing Phase-4 backend into the web SPA so a player can
  roll dice (and push), browse roll history, and see Darkness Points
  update live during a GM-run session.
- Acceptance:
  - From a character sheet, a player can pick a pool size, label the
    roll, click "Roll", see the dice result, and (when eligible) push
    the roll once to reroll non-sixes.
  - The character sheet's existing "Recent Rolls" panel lists the last
    50 rolls in reverse-chronological order with hits / pushed flag /
    timestamp; a row click opens the dice detail.
  - A new `/app/sessions` index lists the GM's game sessions; the
    detail page shows assigned characters, the live DP counter, and an
    audit log of recent DP events.
  - The session detail page subscribes to `session:{id}` over
    Centrifugo and applies `dp.changed` and `roll.pushed` events to
    the visible state without a page reload.
- Spec diff: none expected — the OpenAPI / AsyncAPI surface is already
  v0.8.2 and stable. Any wire-shape gap surfaced during wiring gets a
  spec-first fix in its own commit before any consumer change.
- Codegen impact: none expected (clients are already regenerated).
- Design impact: zero new components; reuse `AppButton`, `AppCard`,
  `AppInput`, `AppBadge`, `AppDots`, `AppDivider`, `AppModal`,
  `AppBanner`. A small page-scoped dice-icon SVG may live inside the
  roller widget if no `@app/ui` equivalent exists — keep it scoped, do
  not promote to `@app/ui` mid-block.
- Tests: per-block — at minimum a vitest spec covering each new
  composable (request-shape, error routing) and a structural test
  asserting the dice roller widget renders a result for a stubbed API
  response. Live-subscription smoke is a Playwright e2e — same pattern
  as `share-viewer.spec.ts`.
- Sub-blocks (one commit + push + new session per block, per
  `feedback_block_workflow.md`):
  - [x] Block 1 — `useRollsApi` composable + dice roller widget on
        the character sheet (commit pending push at start of Block 2).
        New `SheetDiceRoller` component reuses `@app/ui`'s
        `AppDiePool`; replaces the comingSoon placeholder in the
        Recent Rolls panel. Push gating mirrors `RulesEngine.canPush`
        server-side (already-pushed + exhausted), with inline
        "Exhausted — push not available" hint rather than a 422
        round-trip. Drive-by: prettier swept the long-standing
        vue/max-attributes-per-line warnings across the wizard, share
        viewer, and auth pages — folded into the same commit.
        Outstanding for next blocks: the widget keeps only the
        last roll in local state; full reverse-chrono history is
        Block 2's job.
  - [x] Block 2 — Roll history (sibling `SheetRollHistory` component).
        Fetches last 50 on mount, prepended via `defineExpose` from
        the parent on each `rollCreated` (no refetch — would race
        the INSERT). Detail modal shows full dice + pool + hits +
        absolute timestamp; list rows show trimmed label + hits
        badge + "Pushed" badge + relative time ("3m ago",
        "yesterday", "May 09"). Locale-aware via `locale.value`.
  - [x] Block 3 — `useGameSessionsApi` + `/app/sessions` index with
        active / archived tabs, inline create form (auto-redirects to
        detail), and per-card Archive / Unarchive toggles. Stub
        `/app/sessions/[id]` page renders basic session stats so the
        navigation and post-create redirect don't 404 — Block 4 fills
        in DP controls, audit log, character-assignment UX.
  - [x] Block 4 — Full session detail. GM gets DP +/- + free-form
        delta-with-reason form, audit log tail (zebra rows, coloured
        delta, localised source), and `<select>`-based character
        assign / unassign. Players see read-only DP + assigned list.
        Page resolves session + me + characters in parallel on mount.
        Each adjust patches the session from the POST response and
        refetches the audit list — Block 5 will replace the
        post-adjust refetch with the Centrifugo `dp.changed` push.
  - [ ] Block 5 — Centrifugo subscription on the session detail page.
        Reuse the realtime-token endpoint already in the spec; on
        `dp.changed` patch the local DP counter and prepend an audit
        row, on `roll.pushed` toast the roll-pushed event for any
        assigned character. Drop subscription on unmount; reconnect
        on visibility change.
- Status: in-progress
- Blockers: —

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
  - [ ] Block 1 — `useRollsApi` composable + dice roller widget on the
        character sheet. Pool selection (1–10 d6), label input,
        "Roll" button, result strip with sixes highlighted, "Push"
        button (disabled when ineligible — exhausted condition or
        already pushed). Wire into the existing "Recent Rolls" panel
        placeholder at `[id].vue`. Server holds the RNG; client just
        displays.
  - [ ] Block 2 — Roll history. Replace the "Recent Rolls" placeholder
        with the live list (last 50, reverse-chrono, hits + pushed
        flag + timestamp). Row click opens an `AppModal` showing the
        full dice array, label, pool, and pushed-vs-original split if
        applicable.
  - [ ] Block 3 — `useGameSessionsApi` + `/app/sessions` index page
        listing the GM's sessions (active + archived tabs) with
        create / archive actions. New session form (name +
        description) with optimistic auto-redirect to the detail
        page on create.
  - [ ] Block 4 — `/app/sessions/[id]` detail page: assigned
        characters list, DP counter, DP-adjustment controls
        (GM-only — owner check from session payload), DP audit log
        tail. `useDpApi` composable. Character assign / unassign UX.
  - [ ] Block 5 — Centrifugo subscription on the session detail page.
        Reuse the realtime-token endpoint already in the spec; on
        `dp.changed` patch the local DP counter and prepend an audit
        row, on `roll.pushed` toast the roll-pushed event for any
        assigned character. Drop subscription on unmount; reconnect
        on visibility change.
- Status: in-progress
- Blockers: —

## T-2026-05-10-003 — Phase 4 mobile (Flutter): dice + sessions + DP live updates

- Created: 2026-05-10
- Owner: claude
- Spec: PRD §11 Phase 4 (Dice & Sessions) — same backend that the
  web Block-1..5 consumed (T-2026-05-10-002). Flutter app currently
  has only auth / characters / settings features; no rolls,
  sessions, or DP UI.
- Goal: Bring the Coriolis dice loop to mobile so a player at the
  table can roll + push from their character sheet, browse history,
  and see Darkness Points tick live during a GM session. Mobile is
  primarily a player surface — heavy GM ergonomics (full audit log,
  delta-with-reason form) stay on web; mobile gets a minimal GM
  control panel for quick `+1`/`-1` taps and assigned-character
  view only.
- Acceptance:
  - From the character sheet, a player can open a dice bottom sheet,
    pick a pool size (1–10), label the roll, hit Roll, see the
    server-rolled result, and Push once when eligible.
  - The character sheet exposes the last 50 rolls (compact list)
    with row tap → detail modal showing full dice strip, label,
    pool, hits, and pushed flag.
  - A new `Sessions` screen lists the player's sessions
    (Centrifugo-friendly: anything they're a GM owner of OR a
    character is assigned to). Detail page shows DP counter,
    assigned characters, GM-only `+1`/`-1` controls when the user
    is the owner.
  - Session detail subscribes to `session.{id}` over Centrifugo
    (Dart client); `dp.changed` patches the counter live,
    `roll.pushed` surfaces a transient SnackBar.
- Spec diff: none — backend surface is stable, Dart SDK was already
  regenerated when each web block landed (`@app/api-client-dart`
  ships DiceApi + GameSessionsApi + DarknessPointsApi).
- Codegen impact: none.
- Design impact: zero new `app_ui` widgets in Block 1; reuse
  Material + the existing Coriolis primitives. A
  `RollResultStrip` widget may live page-scoped in Block 1 if no
  app_ui equivalent exists — keep it scoped, do NOT promote
  mid-block.
- Tests: per-block bloc/cubit specs covering happy path + error
  routing (RFC 9457 → `errorMessage`). Widget tests deferred to
  the existing `flutter_test` pattern used by `characters_list`.
- Sub-blocks (one commit + push + active.md follow-up per block,
  per `feedback_block_workflow.md`):
  - [x] Block 1 — `features/rolls/` skeleton + dice bottom sheet,
        wired via FAB on the character sheet (mobile is
        bottom-sheet-first; web's panel pattern doesn't translate).
        DiceRollerCubit shaped same as the existing
        CharactersListCubit. Drive-by: the regenerated dart SDK
        had no built_value `.g.dart` files; ran build_runner and
        committed as `chore(codegen)`. Also fixed `Concept` enum
        bridge in `character_repository_impl.dart` (regenerated SDK
        now has `Concept` as EnumClass; was String — bridged with
        `valueOf` / `.name`). Tests: 59/59 (+6 new in
        `dice_roller_cubit_test.dart`).
  - [ ] Block 2 — Roll history. `RollHistoryCubit` fetches last 50
        on mount; the DiceRoller emits via its repo and the cubit
        is parent-shared so a fresh roll prepends without a refetch
        race. Detail dialog shows full dice strip + push state.
        Wired into a new "Rolls" tab on the character sheet.
  - [ ] Block 3 — `features/sessions/` skeleton: list + detail.
        `GameSession` domain model, repository wrapping
        `app_api_client.GameSessionsApi`. List page shows active /
        archived tabs (compact compared to web). Detail page
        renders DP counter, assigned characters, and a GM-only
        control row (`+1` / `-1` taps via DarknessPointsApi).
        Player view hides the GM controls.
  - [ ] Block 4 — Centrifugo subscription via the `centrifuge_dart`
        package. Token mint reuses the existing realtime endpoint;
        on `dp.changed` patch the visible counter, on `roll.pushed`
        push a SnackBar. Subscription closes on dispose.
- Status: in-progress
- Blockers: —

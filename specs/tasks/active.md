## T-2026-05-10-005 — Phase 5 web frontend: ship list + sheet + module editor + crew

- Created: 2026-05-10
- Owner: claude
- Spec: PRD §11 Phase 5. Backend shipped in T-2026-05-10-004
  (`/api/v1/ships*` and `/api/v1/ship-modules/{id}`); the typed TS
  client is already generated. `apps/web` currently has nothing
  Ship-related — no composable, no pages, no nav surface.
- Goal: Wire the existing Phase-5 backend into the web SPA so a
  player can build a ship, install / edit modules, assign their
  characters as crew, and duplicate a ship into a copy. Mirrors the
  Phase 4 web work in shape — composables → list page → detail page
  → sub-resource editors.
- Acceptance:
  - `/app/ships` lists the owner's ships with create-ship inline
    form, per-card Open / Duplicate / Delete actions. Empty state
    + retry on error.
  - `/app/ships/[id]` renders the ship sheet: header (name +
    class + duplicate / delete), top stat block (hull / energy /
    armor / maneuverability / signature / speed / cargoCapacity),
    modules list grouped by `slot`, crew roster (six positions).
  - Module editor (modal) opens from "Add module" / row tap and
    drives the discriminator-aware form: WEAPON shows
    bonus/range/damage/crit; TORPEDO shows torpedo/mine counts;
    HOLD shows tons + concealed; SENSOR shows detection bonus;
    OTHER is base-only. Mandatory modules (BRIDGE/REACTOR/DRIVE)
    cannot be deleted from the UI either — the Delete button is
    hidden for them.
  - Crew assignment uses a `<select>` of the owner's active
    characters not already serving on this ship; per-row Remove
    action; vacant slots stay visible. Move semantics from the
    backend (Block 4) means picking a character already serving
    elsewhere on the same ship just shifts them.
  - Duplicate action on the list and the sheet creates a fresh
    ship via `POST /ships/{id}/duplicate` and navigates to the
    new sheet. Modules carry over; crew roster is empty on the
    copy.
- Spec diff: none — surface is stable from T-2026-05-10-004. Any
  wire-shape gap surfaced during wiring gets a spec-first fix in
  its own commit.
- Codegen impact: none.
- Design impact: zero new `@app/ui` components; reuse `AppCard`,
  `AppButton`, `AppInput`, `AppField`, `AppBadge`, `AppBanner`,
  `AppModal`, `AppSegControl`. A small page-scoped icon for
  ship-class / slot may live inline if no `@app/ui` equivalent
  exists.
- Tests: per-block vitest specs covering each new composable
  (request shape, error routing) and structural assertions on the
  module editor's discriminator switch. Page mounting deferred to
  Playwright e2e.
- Sub-blocks (one commit + push + active.md follow-up per block,
  per `feedback_block_workflow.md`):
  - [x] Block 1 — `useShipsApi` composable + `/app/ships` index
        page (active list, inline create form, per-card Open /
        Delete / Duplicate). Add a nav link from the characters
        index AppBar so the page is reachable. Stub
        `/app/ships/[id]` so the create-flow redirect doesn't
        404 — Block 2 fills it in.
  - [ ] Block 2 — `/app/ships/[id]` sheet: header (name + class
        + actions), stat block, modules list grouped by slot
        (read-only), crew roster (read-only). All scalar PATCH
        edits live here (rename, hull current, energy current,
        notes). Loads `Ship` once on mount; sub-resource mutations
        in Blocks 3 + 4 patch the local state via the shared
        cubit.
  - [ ] Block 3 — Module editor modal: discriminator-aware form
        switching on `slot`. Add / Edit / Delete via
        `useShipModulesApi` (new sibling composable wrapping
        `addShipModule` / `updateShipModule` / `deleteShipModule`).
        Hide the Delete button for BRIDGE / REACTOR / DRIVE (the
        server enforces 422 — surface as a non-issue in the UI).
  - [ ] Block 4 — Crew assignment widget on the sheet. Row per
        position; assigned character renders by name, vacant slot
        renders an Assign action that opens a `<select>` of the
        owner's characters. Reuses `useCharactersApi.list`.
        Remove action drives `unassignCrew`. The sheet refreshes
        the local Ship after each assignment because the backend
        returns CrewSlot — easier than threading a partial-state
        update.
  - [ ] Block 5 — Polish: ship duplication wired from both list
        + sheet, delete confirmation modal, "Recently created"
        toast on the index page after a duplicate redirect, link
        to `/api/v1/ships/{id}/export` (501 stub — render the
        affordance behind a feature flag so it can light up when
        the backend ships).
- Status: in-progress
- Blockers: —

### Block 1 done — follow-up note (2026-05-10)

Block 1 shipped: `useShipsApi.ts` composable (list / get / create /
update / delete / duplicate, RFC 9457 error throw), `/app/ships` index
page with inline create form (all 20 ShipClass values, humaniseClass
helper, hull/energy stats, module + crew badges, Open/Duplicate/Delete
actions, empty state, loading skeleton, error banner + retry), stub
`/app/ships/[id]` (resolves ship, renders name + class, "Coming in
Block 2–4" panel), and a "Ships" ghost-button nav link on the characters
index. Tests: 14 new vitest cases (was 53, now 67). typecheck and lint
both clean.

Block 2 next: replace the `[id].vue` stub with the real ship sheet —
header with rename/duplicate/delete actions, full stat block (hull /
energy / armor / maneuverability / signature / speed / cargoCapacity),
modules list grouped by slot (read-only in Block 2), and all scalar
PATCH edits (rename, hull current, energy current, notes). Load Ship
once on mount; sub-resource mutations follow in Blocks 3 + 4.

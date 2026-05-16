# README screenshot capture

Standalone Playwright script that produces the PNGs embedded in the
top-level `README.md` and `README.ru.md`.

## Run

```sh
docker compose -f docker/compose.yml up -d      # backend + web on 3010 / 3001
pnpm screenshots:capture
```

Writes to `docs/screenshots/{desktop,mobile}/*.png` plus a
`manifest.json` index. Idempotent — re-running signs back in as the
existing demo user instead of failing on duplicate signup.

## What it does

1. Health-checks `http://localhost:3010/api/v1/health`.
2. Signs up (or signs in) a demo user
   `demo+readme@coriolis.local` against Better Auth, captures the
   bearer token from `set-auth-token`.
3. Seeds one of each first-class resource through the public API —
   character, NPC, game session, DP delta, dice roll, share link.
4. Drives Chromium through two viewports — desktop `1280 × 800` and
   mobile `414 × 896` — visiting the ten routes listed below, injects
   the bearer token into `localStorage["app.auth.bearerToken"]` for
   authed pages, and snapshots each one.
5. Hides the Nuxt devtools floating chip so it doesn't clutter the
   captures.

Screens: `landing`, `login`, `signup`, `dashboard`, `characters-list`,
`character-sheet`, `ship-sheet`, `npc-editor`, `game-session`,
`shared-character`.

## Known limitations

- **Ship sheet skipped on `main`.** `POST /api/v1/ships` currently fails
  the response-codec round-trip for `ShipClass`. The script logs a
  warning and skips the ship-sheet PNG; remove the guard once the
  upstream regression is fixed (see commit log near
  `apps/backend/src/modules/ships/infra/ship.mapper.ts`).
- **Demo user is not cleaned up.** Better Auth has no self-delete on
  this project, so the row stays in `User`. Re-runs sign back into the
  same account — fine for this purpose. Drop the row by hand if you
  need a fresh start:

  ```sh
  docker compose -f docker/compose.yml exec postgres \
    psql -U postgres -d coriolis_companion \
    -c "DELETE FROM \"User\" WHERE email = 'demo+readme@coriolis.local';"
  ```

- **Web container needs to be warm.** A cold `web` container takes ~10 s
  to prebuild Vite; the script's settle timeout tolerates that, but the
  first run after a `docker compose up` may produce a couple of blank
  shells. Re-run once everything has compiled.

## Environment overrides

| Var             | Default                      |
| --------------- | ---------------------------- |
| `WEB_BASE`      | `http://localhost:3001`      |
| `API_BASE`      | `http://localhost:3010`      |
| `DEMO_EMAIL`    | `demo+readme@coriolis.local` |
| `DEMO_PASSWORD` | `Demo!Readme!Pass123`        |
| `DEMO_NAME`     | `Demo Reader`                |

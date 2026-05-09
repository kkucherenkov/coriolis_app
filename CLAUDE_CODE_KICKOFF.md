# Claude Code Kickoff — Phase 0 Runbook

Ordered runbook for taking the Coriolis Companion App from
**freshly-cloned boilerplate** to **Phase 0 complete and tagged**. Each
step has a definition of done that maps to a CI gate. Don't skip ahead —
Phase 1 starts on the green tag, not before.

Read [`AGENTS.md`](AGENTS.md), [`docs/PRD.md`](docs/PRD.md), and
[`docs/DESIGN.md`](docs/DESIGN.md) before starting. They explain _why_
each step has the constraints it does. The phased delivery order is in
[`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md).

---

## Step 0 — Local prerequisites (one-time)

- Node 24+ (the repo's `.nvmrc` pins `24`; the `package.json` engine is
  `>=24`). On nvm: `nvm install 24 && nvm use 24`.
- pnpm 10+ via corepack: `corepack enable && corepack prepare pnpm@10.33.0 --activate`.
  If corepack errors with `Cannot find matching keyid: …`, the local
  corepack is too old to know the current pnpm signing keys — upgrade it
  with `npm install -g corepack@latest` or `npm install -g pnpm@10.33.0`.
- Docker Desktop, Colima, or OrbStack
- Flutter 3.41 (only if working on `apps/mobile`)
- Claude Code CLI: `npm install -g @anthropic-ai/claude-code`
- Verify: `node -v`, `pnpm -v`, `docker info`, `claude --version`

---

## Step 1 — Wire up the agent context

The boilerplate already ships the agent context — don't re-create it. Verify
it's intact:

- `AGENTS.md` at repo root
- `.claude/settings.json` with permissions
- `.claude/commands/{precheck,spec-endpoint,component-new,phase-status,
feature-preflight,codegen-regen}.md`
- `.github/PULL_REQUEST_TEMPLATE.md` mapped to the §12 quality gates
- `docs/done/README.md` documenting the convention

The first PR of Phase 0 (`chore/baseline-docs`) lands the
**source-of-truth documents** the rest of the steps reference:

- `docs/PRD.md`, `docs/DESIGN.md`, `docs/IMPLEMENTATION_PLAN.md`
- `specs/design/mockups/*.jsx` (12 reference screens)

If your `AGENTS.md`, `.claude/docs/design-system.md`, etc. still reference
`specs/design/source-bundle/project/components/`, fix the path drift to
`specs/design/mockups/` — `mockups/` is the actual canonical location
(see `specs/design/README.md`).

**Definition of done.** `claude` opens in the repo, the agent acknowledges
it sees `AGENTS.md`, and `/precheck` runs end-to-end (it'll fail until
later steps land — that's expected here, just confirm the command itself
executes).

---

## Step 2 — Boilerplate adoption

In a separate PR titled `chore(phase-0): adopt boilerplate as Coriolis Companion`:

There is **no `scripts/setup.sh`** — the boilerplate's interactive script
was a one-shot tool that gets deleted as part of adoption (keeping it
gives a false signal that the repo is still a template). Replace
placeholders manually:

- `package.json` (root): `name` → `coriolis-companion`, `description` → Coriolis text
- `apps/web/package.json`, `apps/backend/package.json`, `packages/*/package.json`: descriptions
- `apps/mobile/pubspec.yaml`: `name: coriolis_companion`, description
- `docker/compose.yml`: every `{{APP_SLUG}}` → `coriolis-companion` (postgres user/pass/db, network, healthcheck, DATABASE_URL)
- `.devcontainer/devcontainer.json`: `name`
- `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `.github/ISSUE_TEMPLATE/*.md`: rewrite the boilerplate-template framing for the Coriolis Companion App
- `docker/README.md`: drop the `{{APP_SLUG}}` substitution instruction
- `apps/web/nuxt.config.ts`: enumerate all four locales (`en`, `ru`, `uk`, `el`); en/ru active in v1, uk/el wired but not populated (PRD §6).

**i18n architecture (deviates from the upstream boilerplate's runbook):**
the project uses **colocated `<i18n lang="json">` blocks per SFC**
(`useI18n({ useScope: 'local' })` on every component) — there are no
global `apps/web/i18n/*.json` files. `pnpm check:i18n` walks the SFC `<i18n>`
blocks for parity. When you add a new SFC with user-visible copy, populate
all four locale keys; if a translation isn't ready, ship it as
`[uk-todo]` / `[el-todo]` placeholder so the parity check still sees the
key.

**Definition of done.**

- `pnpm install` runs clean
- `docker compose -f docker/compose.yml up -d` brings up postgres, redis, centrifugo, backend, web, otel-lgtm — all healthy
- `coriolis-companion-backend-1` becomes `healthy`; `/api/v1/health` responds with `{"status":"ok",...}`
- The backend container's CMD runs `pnpm install` + `pnpm --filter @app/specs bundle` + `prisma generate` + `prisma db push` + `nest start --watch` automatically — Prisma migration against the empty domain schema (Better Auth tables only) succeeds
- `/` (web) returns 200

---

## Step 3 — Seed the design pipeline and tokens

PR title: `feat(phase-0): seed Coriolis design tokens` (or, when the
emitter shape diverges from the boilerplate's, the broader
`feat/phase-0/design-pipeline-coriolis`).

The boilerplate's design-tokens emitter is built around a multi-theme
shape (`light/dark/sepia/forest`) with `brand/surface/border/text/status/
vertical` color groups, role-via-slot typography, and z-index inside
`motion.json`. Coriolis's design language (DESIGN §2/§3) is dark-first
with `surface/brand/text/state` groups and decomposed `--type-{role}-*`
composites — not interchangeable with the boilerplate. **Rewrite the
emitter to Coriolis's schema in this step.** See
[`docs/adr/0001-phase-0-design-pipeline-rewrite.md`](docs/adr/0001-phase-0-design-pipeline-rewrite.md)
for the full reasoning.

Files touched:

- `packages/design-tokens/src/{types,load,emit-scss,emit-typescript,emit-dart}.ts`
- `specs/design/tokens/color.json` — `surface/brand/text/state`, plus `theme.high-contrast` overrides per DESIGN §2.2
- `specs/design/tokens/typography.json` — `font.{family,weight}` plus composite `type.{display-xl,display-lg,display-md,display-sm,body-lg,body-md,body-sm,mono-stat-xl,mono-stat-md}` per DESIGN §3.2
- `specs/design/tokens/spacing.json` — 4 px base, `--space-1` through `--space-12`
- `specs/design/tokens/radius.json` — `sm/md/lg/pill`
- `specs/design/tokens/motion.json` — `motion.{duration,ease,transition?}` (note: `ease`, not `easing`)
- `specs/design/tokens/shadow.json` — Coriolis named shadows (card-featured, panel-rise, icon-glow, brass-bevel, danger-pulse)
- `specs/design/tokens/opacity.json` — disabled / muted / subtle / secondary / elevated
- `specs/design/tokens/z-index.json` — separate first-class file (NOT inside `motion.json`)
- `specs/design/README.md` — Coriolis token inventory; component inventory empty (Phase 1 lands primitives)

Run `pnpm design:build` and verify the generated outputs. Per `.gitignore`
policy, only the Flutter Dart artefact is committed; the web/ui CSS and
TypeScript mirrors are gitignored:

- `apps/web/app/assets/css/tokens.generated.css` — gitignored
- `packages/ui/src/tokens.generated.css` — gitignored
- `apps/web/app/design-tokens.generated.ts` — gitignored
- `packages/ui/src/design-tokens.generated.ts` — gitignored
- `packages/ui_flutter/lib/src/theme/tokens.g.dart` — **committed**

Replace the boilerplate's `default.vue` and the `@theme inline` block in
`apps/web/app/assets/css/main.css` and `packages/ui/src/styles.css` with
Coriolis tokens (see Branch 3's `c0930d0`). The 11 boilerplate `@app/ui`
components and `apps/web/app/pages/login.vue` keep referencing legacy
token names and **render unstyled until Phase 1's UI Foundation Library
epic** rewrites them — this is intentional and recorded in ADR-0001.

**Definition of done.**

- `pnpm design:build` produces all five artefacts without error
- `pnpm --filter @app/design-tokens typecheck` is green
- A throwaway `<div style="background: var(--surface-void)">` in a Nuxt page renders the deep-space indigo
- `pnpm design:audit` is green (note: in Phase 0 the component inventory is intentionally empty)

> Do **not** edit the `*.generated.*` files directly. Edit JSON, run `pnpm design:build`. The Flutter artefact is committed for review and CI determinism only.

---

## Step 4 — Domain schema (deferred to per-phase delivery)

The original runbook seeded the entire Coriolis domain schema in Phase 0.
We deferred that: **domain models are added in the phase that needs
them** (matches the "по фичам и фазам" rule the project operates under).
For Phase 0 the Prisma schema keeps only the Better Auth tables (`user`,
`session`, `account`, `verification`) plus the boilerplate's existing
configuration; no Coriolis domain models yet.

Phase 1 (Foundation) adds `Character`, `Item`, `Relationship`,
`ShareLink`. Phase 4 (Dice & Sessions) adds `GameSession`, `Roll`,
`DpEvent`. Phase 5 adds `Ship`. Phase 6 adds `Encounter`, `Combatant`,
`Npc`. See `docs/IMPLEMENTATION_PLAN.md` for the full per-phase breakdown.

`User` custom fields (`displayName`, `deletedAt`) and the `JWKS` table
land alongside the auth-vertical work in Phase 1's Epic 4.

Reminder: the GM-side concept is `GameSession`, **never** `Session`.
Better Auth owns the `Session` name.

**Definition of done.**

- `pnpm --filter @app/backend prisma:db:push` (run automatically by the
  backend container on startup) succeeds against the empty domain schema
- Prisma Studio shows only Better Auth tables
- `pnpm --filter @app/backend test` (handler unit tests) still green

---

## Step 5 — OpenAPI title rename (endpoints deferred to per-phase delivery)

PR title: `feat(phase-0): rename OpenAPI title to Coriolis Companion API`.

Same rule as Step 4: **endpoints are added in the phase that needs them**.
For Phase 0 the OpenAPI surface keeps the boilerplate's `/api/v1/health`
and `/api/v1/realtime/token` unchanged; only `info.title` and `contact.name`
are renamed to "Coriolis Companion API" plus a description note pointing
at `IMPLEMENTATION_PLAN.md`.

Phase 1 adds `/me` (GET/PATCH/DELETE/export) and the empty-sheet CRUD
under `/characters`. Phase 5 adds `/ships`. Phase 6 adds `/sessions`,
`/encounters`. RFC 9457 problem+json stays the documented error shape on
every route added.

When you do add a route, run the five-step loop:

```bash
pnpm spec:validate
pnpm spec:bundle
pnpm spec:codegen
```

The runtime `express-openapi-validator` will reject any request or
response that drifts from the spec.

**Definition of done.**

- `pnpm --filter @app/specs run validate` is green for both OpenAPI and
  AsyncAPI documents
- The title-only change does not affect generated TS/Dart clients
  (verified: no diffs in `packages/api-client-{ts,dart}/`)

---

## Step 6 — Replace placeholder copy

PR title: `chore(phase-0): replace placeholder copy with Coriolis landing hero`.

Update the colocated `<i18n>` blocks in the layout and any Phase 0 page:

- `apps/web/app/layouts/default.vue` — wordmark in the header, fan-project disclaimer in the footer
- `apps/web/app/pages/index.vue` — landing hero (wordmark + tagline + sign-in / create-account CTAs)
- `apps/web/app/pages/login.vue` — register `uk` / `el` blocks with `[uk-todo]` / `[el-todo]` placeholder values for every key so `pnpm check:i18n` sees the structure for all four locales

**en and ru must stay in lockstep at the active-locale level.**
`pnpm check:i18n` enforces this. Use `[uk-todo]` / `[el-todo]` markers in
uk / el blocks whenever the translation isn't ready — but don't ship
those markers in a release tag for those locales (Phase 0 is a Phase
boundary; v1 ships en + ru active per PRD §6).

**Definition of done.**

- `pnpm check:i18n` (i.e. `node --experimental-strip-types scripts/check-i18n-parity.ts`) is green for all four locales × all SFC `<i18n>` blocks
- The landing page renders the wordmark and tagline from `landing.jsx`
- The "fan project · not affiliated with the publisher" disclaimer renders in the footer

---

## Step 7 — Tag and hand off

Run the full local quality-gate sweep:

```bash
pnpm --filter @app/specs run validate
pnpm --filter @app/design-tokens typecheck
pnpm --filter @app/design-tokens build       # design:build, regenerates artefacts
node --experimental-strip-types scripts/check-i18n-parity.ts
docker compose -f docker/compose.yml up -d   # one final smoke — landing page should render
```

If everything is green, tag locally (no remote yet — Phase 0 is local-merge-only until origin is added):

```bash
git tag phase-0-complete
```

Append `docs/done/phase-0.md` with links to the local commits/branches
that landed in steps 1–6, and the open known-debt list (the unstyled
`@app/ui` components, the deferred domain schema, the `[uk-todo]` /
`[el-todo]` markers in login.vue).

Open the **Phase 1 epic** per
[`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md) Epic 2 (UI
Foundation Library) and Epic 3 (Empty-Sheet CRUD).

---

## Working with Claude Code, day to day

For each Phase 1+ feature, prefer this loop:

1. **Branch.** `git switch -c feat/<area>-<short-desc>`.
2. **Open Claude Code.** `claude` in the repo root.
3. **One-line brief, with citation.** _"Implement PRD §5.2 attribute editing on the desktop sheet, behind the existing `characters/[id]` route. Mockup: `specs/design/mockups/sheet-desktop.jsx`."_
4. **Let it run the loop autonomously**, reviewing each step:
   - For API surface changes: the five-step loop (§4 of `AGENTS.md`).
   - For UI changes: the design loop (§5 of `AGENTS.md`).
5. **`/precheck`** before pushing.
6. **After merge**, append `docs/done/<feature>.md` with the PR link.

### Anti-patterns to avoid

- **Bundling spec, design, and feature in one PR.** Review is much faster
  when each is its own commit, and codegen-drift is easier to debug when
  the spec change is isolated.
- **Letting the agent write tests after the fact.** Have it write the
  contract test first (against the spec) and the unit tests alongside
  the handler.
- **Skipping the JSX mockup.** If a `.jsx` exists for the screen you're
  touching, read it first. It is more authoritative than the `.md` in
  `docs/DESIGN.md` per the conflict-resolution rule in `AGENTS.md`.
- **Merging on a yellow CI.** The quality gates are tuned to the
  boilerplate's invariants. A red gate is telling you a real thing.

### When the agent goes off-track

If Claude Code starts producing diffs that violate the non-negotiables in
`AGENTS.md` §3 (hex literals, `process.env` outside `AppConfig`,
hand-written `$fetch` instead of `@app/api-client-ts`, etc.), interrupt
and point it at the specific section. Don't let a "just this once"
exception land — the next agent session will see it as precedent.

If the same drift happens twice on the same kind of task, that's a
signal to add a slash command for it, or to extend `AGENTS.md` with a
clarifying example.

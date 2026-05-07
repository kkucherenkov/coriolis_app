# Phase 0 — Adoption

**Phase:** 0
**Tag:** `phase-0-complete`
**PRD section:** §11 (roadmap)
**Date:** 2026-05-07

## What shipped

The Coriolis Companion App is a Coriolis-shaped greenfield monorepo:
boilerplate placeholders gone, design pipeline rewritten end-to-end for a
dark-first language, the Phase 0 landing hero rendering with brass on
indigo, and the local Docker stack booting clean from a fresh clone.

Concretely:

- **Baseline reference docs in the repo.** `docs/PRD.md`, `docs/DESIGN.md`,
  `docs/IMPLEMENTATION_PLAN.md`, and the 12 JSX mockups in
  `specs/design/mockups/`. All path references inside agent-facing
  documents (`AGENTS.md`, `.claude/docs/*`, `.github/PULL_REQUEST_TEMPLATE.md`,
  the docs themselves) point at the canonical `mockups/` location, not
  the legacy `source-bundle/project/components/` path some early drafts
  referenced.
- **Boilerplate adoption.** Every `{{APP_NAME}}` / `{{APP_SLUG}}` /
  `{{APP_DESCRIPTION}}` / `boilerplate` / `YourApp` placeholder replaced
  manually (the interactive `scripts/setup.sh` was deleted — adoption is
  one-shot, keeping the script gives a false signal). `coriolis-companion`
  flows through `package.json`, every workspace `package.json`,
  `pubspec.yaml`, `docker/compose.yml` (network, postgres user/db/pass,
  healthcheck, `DATABASE_URL`), `.devcontainer`, `README.md`,
  `CONTRIBUTING.md`, `SECURITY.md`, and the issue templates. The web
  i18n config registers all four locales (`en`, `ru`, `uk`, `el`); en + ru
  active in v1, uk + el wired but not populated (PRD §6).
- **Coriolis design pipeline.** `packages/design-tokens/src/{types,load,
  emit-scss,emit-typescript,emit-dart}.ts` rewritten from the boilerplate's
  multi-theme `light/dark/sepia/forest` shape to Coriolis's dark-first
  `surface/brand/text/state` schema with optional `theme.<name>`
  overrides. `--type-{role}-*` decomposed CSS custom properties per
  DESIGN §3.2; `--motion-duration` (default-bare) plus
  `--motion-duration-{fast,slow,ceremony}`; `motion.ease` (not `easing`);
  z-index in its own first-class `z-index.json`. The 8 JSON token files
  (color/typography/spacing/radius/shadow/motion/opacity/z-index) are
  authored against the new schema; `pnpm design:build` emits to all 5
  targets including the committed `packages/ui_flutter/lib/src/theme/tokens.g.dart`.
- **Coriolis chrome on the landing surface.** `apps/web/app/layouts/default.vue`
  replaced with a Phase 0 minimum (brass-bordered header carrying the
  wordmark, slot, footer with the fan-project disclaimer). `apps/web/app/pages/index.vue`
  carries the landing hero (Forum 48 px wordmark, italic tagline, primary
  brass + ghost CTAs routing to `/login`). `apps/web/app/assets/css/main.css`
  and `packages/ui/src/styles.css` map Coriolis tokens to Tailwind v4's
  `--color-*` / `--radius-*` namespaces.
- **OpenAPI title.** `info.title` renamed to "Coriolis Companion API"
  with a description note pointing at `docs/IMPLEMENTATION_PLAN.md`. The
  surface itself stays at the boilerplate's `/api/v1/health` and
  `/api/v1/realtime/token` for Phase 0; domain endpoints land in their
  phase.

## Notable decisions

- **Path A (full pipeline rewrite)** over backward-compat aliases or an
  adapter layer for the design tokens. See
  [`docs/adr/0001-phase-0-design-pipeline-rewrite.md`](../adr/0001-phase-0-design-pipeline-rewrite.md).
- **Domain models per phase.** The original runbook seeded the entire
  Coriolis schema (Character / Item / Talent / ShareLink / Ship /
  GameSession / Encounter / Combatant / Npc / Roll / DpEvent) in Phase 0.
  Phase 0 keeps only the Better Auth tables; Phase 1+ adds models in the
  phase that needs them.
- **OpenAPI endpoints per phase.** Same rule — Phase 0 keeps the
  `/health` and `/realtime/token` surface; `/me`, `/characters`, `/ships`,
  `/sessions`, `/encounters` get added in their respective phases.
- **Colocated `<i18n>` blocks**, not global locale JSON. The boilerplate's
  Nuxt config is wired for per-component `<i18n lang="json">` blocks
  consumed via `useI18n({ useScope: 'local' })`. `pnpm check:i18n` walks
  those blocks for parity.
- **Phase 0 ships the design pipeline with intentionally unstyled
  boilerplate `@app/ui` components.** The 11 boilerplate primitives
  (`AppButton`, `AppInput`, `AppCard`, `AppChip`, `AppField`, `AppLabel`,
  `AppSelect`, `AppSwitch`, `AppTextarea`, `AppBadge`, `AppIcon`) and
  `apps/web/app/pages/login.vue` reference legacy token names that no
  longer exist (`--surface-bg`, `--brand-accent`, `--text-fg`,
  `--font-sans`, `--text-xs`, `--dur-fast`, `--ease-default`,
  `--border-default`). They render with `unset` fallbacks until Phase 1's
  UI Foundation Library epic reskins them
  ([`docs/IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md) Epic 2,
  Feature 2.1, T-2.1.1.a–p). Vitest specs cover component logic and
  continue to pass.
- **`scripts/setup.sh` removed.** The interactive boilerplate adoption
  script was a one-shot; keeping it gives a false signal that the repo
  is still a template.
- **Runbook updated to match reality.** `CLAUDE_CODE_KICKOFF.md` now
  documents the per-phase domain/spec rules, the colocated i18n
  architecture, the actual generated artefact paths
  (`apps/web/app/assets/css/...`, `packages/ui/src/...`,
  `packages/ui_flutter/lib/src/theme/...`), and removes the stale
  `setup.sh --name --slug …` invocation.

## Local quality-gate sweep (verified at tag time)

- `pnpm --filter @app/specs run validate` — OpenAPI and AsyncAPI clean.
- `pnpm --filter @app/design-tokens typecheck` — green.
- `pnpm --filter @app/design-tokens build` — five artefacts emitted; the
  Flutter Dart artefact is committed, the four web/ui CSS+TS mirrors are
  gitignored per `.gitignore` policy.
- `node --experimental-strip-types scripts/check-i18n-parity.ts` —
  mobile 4 locales × 83 keys clean; web 4 locales × 20 keys clean.
- Docker stack: postgres / redis / centrifugo healthy; backend `healthy`
  with `/api/v1/health` returning `{"status":"ok",...}`; web returns 200
  on `/`. Verified during Branch 2 and Branch 3 work; not re-run at tag
  time because the Docker daemon was not up locally — re-run before any
  hand-off.

## Local merge ledger

There is no remote `origin` yet, so Phase 0 was delivered through local
branches that fast-forward-merged into `main`:

| Branch | Topic | Final commit |
|---|---|---|
| `chore/baseline-docs` | PRD/DESIGN/IMPLEMENTATION_PLAN + JSX mockups + path-drift fixes | `aff3bcc` |
| `chore/phase-0/adopt-boilerplate` | placeholder substitution, doc rebrand, `scripts/setup.sh` deletion, locale wiring | `2308207` |
| `feat/phase-0/design-pipeline-coriolis` | emitter rewrite, JSON restructure, regenerated `tokens.g.dart`, layout/main.css/styles.css align, design README, ADR-0001 | `0d89205` |
| `feat/phase-0/openapi-coriolis-title` | OpenAPI title rename | `6a70eaa` |
| `chore/phase-0/coriolis-copy` | landing hero copy + `[uk-todo]`/`[el-todo]` markers in login.vue | `fe41a15` |
| `chore/phase-0/runbook-update-and-tag` | this entry + `CLAUDE_CODE_KICKOFF.md` rewrite | (current) |

## Follow-ups

- **Phase 1 — UI Foundation Library** ([`docs/IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md)
  Epic 2). Reskin the 11 boilerplate `@app/ui` components against
  Coriolis tokens; add the new Coriolis-specific primitives
  (`AppIconCoriolis`, `AppDie`, `AppDiePool`, `AppConditionPill`,
  `AppStarOrnament`, `AppArabesqueCorner`, `AppDots`, `AppKbd`,
  `AppDivider`, `AppSegControl`, `AppProgress`, `AppAvatar`, `AppBanner`,
  `AppTab`, `AppTooltip`).
- **Phase 1 — Auth vertical extensions** (Epic 4). Reskin
  `apps/web/app/pages/login.vue` against Coriolis tokens; replace the
  `[uk-todo]` / `[el-todo]` placeholder strings with real translations as
  uk/el get populated.
- **Phase 1 — Empty-Sheet CRUD** (Epic 3). First domain models
  (`Character`, `Item`, `Relationship`, `ShareLink`); first domain
  endpoints (`/me`, `/characters`); web + mobile sheet skeletons.
- **CI** — when an `origin` remote is added and CI is wired, run the
  quality-gate sweep there too, including a `pnpm test` (vitest) pass and
  the `codegen-drift` guard against the regenerated TS / Dart clients.
- **Local dev DX** — the workspace `node_modules/.bin/` is missing
  several binaries (`turbo`, `eslint`) after `pnpm install`; running
  scripts from inside the workspace package directory works around it,
  but `pnpm --filter` invocations from the repo root currently fail.
  Investigate before scaling up Phase 1 — it'll bite in CI too.

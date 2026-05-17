# Repository quick-reference

The **Coriolis Companion App** — fan-built character sheet, ship sheet, dice, and GM tools for _Coriolis: The Third Horizon_ (Free League Publishing). Three first-class clients on day one served by a single backend.

Greenfield monorepo. Three apps, one backend, one auth system, one source of truth for every wire contract, one design system. The Coriolis-specific operating manual lives in [`AGENTS.md`](../AGENTS.md); `docs/PRD.md` and `docs/DESIGN.md` are the product source of truth — this file is the deep operating reference.

## Layout

```
apps/backend    NestJS 11 + Prisma 7 + CQRS + Better Auth
apps/web        Nuxt 4 (SPA, ssr:false) + Nuxt UI v4 + Tailwind 4 + @app/ui + @nuxtjs/i18n
apps/mobile     Flutter 3.41 + flutter_bloc + get_it + Dio
packages/specs  OpenAPI 3.1 + AsyncAPI 3.0 — single source of API truth
packages/ui     brand component library + colocated Storybook + stories
packages/api-client-{ts,dart}   generated clients — never edit by hand
specs/tasks/    active.md (LIFO stack) + done.md (archive)
specs/design/   tokens JSON + optional JSX mockups under mockups/ (primary design reference when provided)
docker/         local stack (postgres 18.1, redis 8.6, centrifugo v6)
```

## Task stack — read every session

1. Before coding: push entry to `specs/tasks/active.md` (template in `specs/tasks/README.md`).
2. Check boxes as you go; flip to `blocked` with reason if stuck.
3. On done: move whole entry to top of `specs/tasks/done.md` with PR link.
4. Never delete from `done.md` — cancelled tasks go there with reason.
5. Session start: **read `active.md` first**.

## Spec-first loop (non-negotiable)

1. Edit `packages/specs/openapi/openapi.yaml` (or `asyncapi/centrifugo.yaml`).
2. `pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen`.
3. Implement in `apps/backend` — `express-openapi-validator` rejects drift.
4. Consume in `apps/web` / `apps/mobile` via the regenerated client.
5. Land codegen artefacts in their own commit.

## Prisma migrations — `migrate dev`, never `db push` for new schema

Every schema change MUST land as a real migration:

```sh
pnpm --filter @app/backend prisma migrate dev --name <slug>
```

**Never** edit `schema.prisma` and rely on `pnpm prisma:db:push` alone to sync.
`db push` syncs without recording — the next `migrate dev` produces an
incremental migration that ALTERS tables the migration history never CREATEd.
That's exactly how this repo entered the broken state where
`prisma migrate deploy` against a fresh DB failed on the first migration
(`20260508000001_character_status` ALTERed `character` before any migration
created it). The fix was a manually-generated baseline at
`apps/backend/prisma/migrations/20260508000000_baseline/` — once is enough,
but never again.

When `db push` is acceptable:

- Local exploration on a throwaway DB before you're ready to commit a name.
  As soon as the shape is settled: `migrate dev` and commit the migration.
- Inside `apps/backend/Dockerfile.dev`'s entrypoint, which deliberately
  syncs schema for hot-reload — production never runs that path.

Verification before committing a schema change:

```sh
docker compose -f docker/compose.yml down -v        # wipe DB
docker compose -f docker/compose.yml up -d postgres
pnpm --filter @app/backend prisma migrate deploy    # MUST succeed on empty DB
```

If `migrate deploy` errors with `relation "<table>" does not exist` or
`type "<enum>" already exists`, the migration history is incomplete and
must be repaired (baseline regen) before merge.

## Auto-format before done

After editing `.ts` / `.vue` / `.scss` / `.css` / `.json` / `.md`, run in order:

```sh
pnpm --filter <pkg> lint --fix   # ESLint
pnpm stylelint:fix               # Stylelint
pnpm format                      # Prettier
```

Never hand-fix what a fixer can do. Never add `eslint-disable` without a WHY comment.

## URLs

- API: `/api/v1/<resource>` (URI versioning, default v1)
- Auth: `/api/v1/auth/*` (Better Auth, mounted inside versioning)
- Realtime token: `POST /api/v1/realtime/token` (Centrifugo JWT, TTL ≤5 min)

## Local runtime (Docker Compose)

Stack is **normally running**. Check first: `docker ps --format '{{.Names}} {{.Status}} {{.Ports}}'`

| Service        | Port | URL                          |
| -------------- | ---- | ---------------------------- |
| web            | 3001 | http://localhost:3001        |
| backend        | 3010 | http://localhost:3010/api/v1 |
| postgres       | 5432 | —                            |
| redis          | 6379 | —                            |
| centrifugo     | 8000 | ws://localhost:8000          |
| grafana (otel) | 3200 | http://localhost:3200        |

Containers mount the repo as a volume — edits reach the running container automatically. Do NOT start `pnpm dev` if the container is up.

## Common commands

```sh
pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen
pnpm --filter @app/ui storybook          # :6006
turbo run lint test typecheck
pnpm lint:fast                            # oxlint pre-pass (~0.4 s)
pnpm lint:fast:fix                        # oxlint auto-fix
docker compose -f docker/compose.yml up -d
docker compose -f docker/compose.yml logs -f web --tail=100
docker compose -f docker/compose.yml restart backend
```

## Lint layers (fast → strict)

The repo runs **two complementary linters**:

| Layer         | Tool                           | Speed (full repo) | Coverage                                                                                                                                                                                           |
| ------------- | ------------------------------ | ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Pre-pass      | `pnpm lint:fast` (oxlint)      | ~0.4 s            | Common-bug catches (correctness + typescript + unicorn + vue + vitest + jsx-a11y). Runs in lint-staged before ESLint and as a CI shortcut.                                                         |
| Authoritative | `pnpm lint` (ESLint via turbo) | ~20-30 s          | Full ESLint config — `typescript-eslint` strict-type-checked, all `eslint-plugin-vue` rules, project-specific `no-restricted-syntax` (CLAUDE.md bans), `unicorn` full set. Final word on every PR. |

Config:

- `.oxlintrc.json` — oxlint config (kebab-case rule ids, plugin list, ignore patterns).
- `packages/eslint-config/{base,nuxt}.mjs` — ESLint flat config. `eslint-config-prettier` is the **last** entry in both presets so it disables formatting rules Prettier owns (without it `vue/max-attributes-per-line` and Prettier ping-pong).

When ESLint and oxlint disagree:

- Formatting: trust Prettier (ESLint should already be silent on it; oxlint doesn't format).
- Bug catches: trust ESLint (more rules, type-aware). Use oxlint findings as a hint, not as authority.

## Forge (Forgejo) interactions — always via `tea`

The remote is a self-hosted Forgejo at `code.homelab.local`; **`gh` does not
work against it**. Use the [`tea`](https://gitea.com/gitea/tea) CLI for every
PR / issue / branch / release operation. Login profile is already configured
as `homelab` (`tea login list` to confirm).

| Goal                 | Command                                                                           |
| -------------------- | --------------------------------------------------------------------------------- |
| Open PR              | `tea pr create --login homelab --title "…" --description "…"`                     |
| List open PRs        | `tea pr list --login homelab --state open`                                        |
| Show PR              | `tea pr <id> --login homelab` (also: `tea pr checkout <id>`)                      |
| Merge PR             | `tea pr merge <id> --login homelab --style squash` (or `rebase`, `merge`)         |
| Comment on PR/issue  | `tea comment <id> --login homelab "…"`                                            |
| List issues          | `tea issue list --login homelab`                                                  |
| Open issue           | `tea issue create --login homelab --title "…" --description "…"`                  |
| Show branch/repo URL | `tea pulls list` honours the current repo; `tea open` opens the repo in a browser |

Keep PR descriptions multi-line via a HEREDOC into `--description "$(cat <<'EOF' … EOF)"`
— `tea` accepts the same multi-line strings `gh pr create --body` does.
Never call `gh pr …` / `gh api …` against `code.homelab.local`; it will fail
and waste a permission prompt.

## Fix root causes, not symptoms

When a toolchain error appears, prefer a structural fix over a workaround:

- If a CI step fails, fix the config that causes it — don't lower the bar
  (e.g. don't drop coverage thresholds, don't add `--audit-level=critical`
  without reading the advisory, don't `continue-on-error` a real failure).
- If a tsconfig `extends` chain breaks under a bundler, inline or flatten the
  chain. Don't document "run it from a different directory" as the fix.
- If a test coverage denominator blows up, narrow `coverage.include` or
  remove thresholds entirely in a greenfield — don't tune a kostyl number
  that will rot.
- If you find yourself writing a `troubleshooting.md` entry whose "Fix"
  section tells the reader to avoid a command, stop — change the config so
  the command works instead.

`docs/troubleshooting.md` is for upstream bugs you cannot fix locally. Every
entry whose fix lives in _this_ repo's config belongs in the config, not the
docs.

## Things Claude must never do

- Edit `packages/api-client-ts/src/generated/` or `packages/api-client-dart/lib/generated/`.
- Introduce an HTTP route without updating `packages/specs/openapi/openapi.yaml` first.
- Read `process.env` directly — use `AppConfig`.
- Use `any` to escape a type error.
- Ship a user-visible string without `t()` / `AppLocalizations`.
- Ship a `@app/ui` component without a Storybook story + colocated spec.
- Use `!important`, inline `style=""`, or hard-coded hex brand colors.
- Skip updating `specs/tasks/active.md` / `done.md`.
- Commit to `main` without going through a PR.

## Detailed docs

| Topic                                      | File                                                     |
| ------------------------------------------ | -------------------------------------------------------- |
| Coriolis-specific operating manual         | [`AGENTS.md`](../AGENTS.md)                              |
| Backend, CQRS, Prisma, API conventions     | [`.claude/docs/handbook.md`](docs/handbook.md)           |
| Design system, @app/ui, tokens, BEM        | [`.claude/docs/design-system.md`](docs/design-system.md) |
| i18n (web + mobile + backend)              | [`.claude/docs/i18n.md`](docs/i18n.md)                   |
| Testing pyramid, DoD, PR checklist         | [`.claude/docs/testing.md`](docs/testing.md)             |
| Security, observability, a11y, performance | [`.claude/docs/security.md`](docs/security.md)           |
| Feature migration from another project     | [`.claude/docs/migration.md`](docs/migration.md)         |

<!-- REPOWISE:START — Do not edit below this line. Auto-generated by Repowise. -->

## IMPORTANT: Codebase Intelligence Instructions for coriolis_app

> This repository is indexed by [Repowise](https://repowise.dev).
> Use the MCP tools below for orientation, discovery, and enriched context
> (documentation, ownership, history, decisions). **Always verify against
> actual source files before making changes** — the index may be stale.

Last indexed: 2026-05-12 (commit 2d84021)

### Entry Points

- `packages/specs/src/index.ts`
- `packages/ui/src/index.ts`
- `apps/backend/src/main.ts`
- `apps/backend/src/modules/rules-engine/index.ts`
- `packages/ui/.storybook/main.ts`
- `packages/ui/src/components/AppArabesqueCorner/index.ts`
- `packages/ui/src/components/AppAvatar/index.ts`
- `packages/ui/src/components/AppBadge/index.ts`
- `packages/ui/src/components/AppBanner/index.ts`
- `packages/ui/src/components/AppButton/index.ts`

### Tech Stack

**Languages:** Node.js, TypeScript

**Infra:** Turborepo### Hotspots (High Churn)
| File | Churn | 90d Commits | Owner |
|------|-------|-------------|-------|
| `packages/specs/src/openapi-types.ts` | 99.9th %ile | 37 | Kirill Kucherenkov |
| `packages/api-client-ts/src/generated/types.gen.ts` | 99.8th %ile | 38 | Kirill Kucherenkov |
| `packages/api-client-ts/src/generated/sdk.gen.ts` | 99.7th %ile | 21 | Kirill Kucherenkov |
| `packages/api-client-dart/lib/generated/lib/src/api/encounters_api.dart` | 99.6th %ile | 4 | Kirill Kucherenkov |
| `apps/backend/src/modules/characters/commands/create-character.handler.spec.ts` | 99.6th %ile | 9 | Kirill Kucherenkov |

### Repowise MCP Tools

This project has a Repowise MCP server configured. These tools provide documentation, ownership, architectural decisions, and risk signals. Use them for orientation and discovery — then read actual source to verify before editing.

**Recommended workflow:**

1. Start with `get_overview()` on a new task to orient yourself.
2. Call `get_context(targets=["path/to/file.py"])` for enriched context on unfamiliar files — but always read the source before editing.
3. Call `get_risk(targets=["path/to/file.py"])` before changing hotspot files.
4. Don't know where something lives? Call `search_codebase(query="authentication flow")`.
5. Need to understand why code is structured a certain way? Call `get_why(query="why JWT over sessions")` before architectural changes.
6. After **architectural changes**, consider calling `update_decision_records(action="create", ...)` to record the rationale.
7. Need to understand how two modules connect? Call `get_dependency_path(source="src/auth", target="src/db")`.
8. Before cleanup tasks, call `get_dead_code()` to find confirmed unused code.
9. For documentation or diagrams, call `get_architecture_diagram(scope="src/auth")`.

**Note:** MCP tool responses reflect the last index run. If the index is stale, verify against source files.

| Tool                                          | When to use                                    |
| --------------------------------------------- | ---------------------------------------------- |
| `get_overview()`                              | Orient yourself on a new task                  |
| `get_context(targets=[...])`                  | Enriched context on unfamiliar files           |
| `get_risk(targets=[...])`                     | Before changing hotspot files                  |
| `get_why(query="...")`                        | Before architectural changes                   |
| `update_decision_records(action=...)`         | After architectural changes — record decisions |
| `search_codebase(query="...")`                | When locating code                             |
| `get_dependency_path(source=..., target=...)` | When tracing module connections                |
| `get_dead_code()`                             | Before any cleanup or removal                  |
| `get_architecture_diagram(scope=...)`         | For visual structure or documentation          |

### Codebase Conventions

**Commands:**

- Build: `pnpm build`
- Test: `pnpm test`
- Lint: `pnpm lint`
- Dev: `pnpm dev`
- Format: `pnpm format`
- Typecheck: `pnpm typecheck`

<!-- REPOWISE:END -->

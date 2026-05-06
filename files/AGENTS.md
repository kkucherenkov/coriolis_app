# AGENTS.md — Coriolis Companion App

> Read this once at the start of every session. `PRD.md` and `DESIGN.md` are the source of truth; this file is the operating manual that turns them into PRs.
>
> Claude Code reads both `AGENTS.md` and `CLAUDE.md`. This repo uses `AGENTS.md` (cross-vendor convention). If you need a project-local override, add `CLAUDE.md` next to this file.

---

## 1. What this is

The **Coriolis Companion App** helps players and GMs of *Coriolis: The Third Horizon* (Free League Publishing) run characters, ships, and sessions digitally. It ships **three first-class clients on day one**, served by a single backend:

- **`apps/web`** — Nuxt 4 SPA (`ssr: false`), Vue 3, Vite, Nuxt UI v4, Tailwind v4.
- **`apps/mobile`** — Flutter 3.41 / Dart 3.8, `flutter_bloc` + `get_it`.
- **`apps/backend`** — NestJS 11 with `@nestjs/cqrs`, Prisma 7, Postgres 18, Redis 8, Centrifugo v6, Better Auth.

Built on the `claude-driven-nest-nuxt-flutter-monorepo` boilerplate. The boilerplate's conventions are non-negotiable here — they're encoded in CI.

---

## 2. Where to look first

| Question | Source of truth |
|---|---|
| What does this feature do? | `PRD.md` (numbered sections) |
| What does it look like? | `DESIGN.md` + `specs/design/source-bundle/project/components/*.jsx` |
| What's the API contract? | `packages/specs/openapi/openapi.yaml` |
| What's the realtime contract? | `packages/specs/asyncapi/centrifugo.yaml` |
| What's a design token's value? | `specs/design/tokens/*.json` (NEVER edit `tokens.generated.*`) |
| What's been shipped? | `docs/done/*.md` |
| Why was X decided that way? | `docs/adr/*.md` |

**Conflict resolution:** if `DESIGN.md` and a `.jsx` mockup disagree, the JSX wins (per DESIGN §12). If the JSX and `tokens.generated.css` disagree, the JSON token wins.

---

## 3. Non-negotiables (CI-enforced)

Don't try to work around any of these. They fail PRs at merge time.

1. **Spec-first.** No backend route exists until it's in `openapi.yaml`. The `codegen-drift` job fails any PR where regenerated clients diverge from what's committed.
2. **Tokens-first.** No hex literals in `apps/web` or `packages/ui` SCSS. No raw `200ms` in component code — use `var(--motion-duration)`. No `!important`. No inline `style=""` with literals. Stylelint blocks all four.
3. **Component contract.** Every `@app/ui` component folder has `*.vue + *.stories.ts + *.spec.ts + index.ts`. CI rejects misses. Storybook `addon-a11y` panel must be clean.
4. **AppConfig only.** No `process.env.X` access outside `AppConfig`. Adding a config key means: `AppConfig` + `.env.example` + deploy config, all in the same PR.
5. **i18n parity.** `pnpm check:i18n` enforces key parity across `en` and `ru` (active v1 locales) for backend, web, and mobile. `uk` and `el` are wired but not populated at v1.
6. **`GameSession`, never `Session`.** Better Auth reserves `Session` for its bearer-token table. The GM-side concept is always `GameSession` — in code, in URLs, in the schema.
7. **No secrets in diff.** TruffleHog runs in CI.
8. **License hygiene.** `license-checker` blocks anything outside the OSI-permissive allowlist.

---

## 4. The five-step loop (every API change)

Per PRD §7.2 — this is the one workflow you cannot skip.

1. Edit `packages/specs/openapi/openapi.yaml` (or `asyncapi/centrifugo.yaml` for realtime).
2. `pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen`.
3. Implement the route in `apps/backend` — CQRS layout: command/query/event under `src/modules/<domain>/`. Controllers stay thin and dispatch through `CommandBus` / `QueryBus`.
4. Consume from `apps/web` via `@app/api-client-ts`, from `apps/mobile` via `app_api_client`. Both are read-only generated trees.
5. Land codegen artefacts in their own commit so review is mechanical.

`express-openapi-validator` runs at runtime — it will reject any response body the spec doesn't allow, even if Nest happily produced it.

---

## 5. The design loop (every visual change)

1. Token? Edit `specs/design/tokens/*.json` → `pnpm design:build` regenerates `tokens.generated.css`, `design-tokens.generated.ts`, `tokens.g.dart`.
2. New token? Add it to `specs/design/README.md` inventory in the same PR — `pnpm design:audit` fails otherwise.
3. New component? Folder under `packages/ui/src/components/<Name>/` with all four files. Mirror the Flutter widget under `packages/ui_flutter/lib/src/widgets/`. Add to `specs/design/README.md`.
4. Reference mockup? Add or update the `.jsx` in `specs/design/source-bundle/project/components/`.

**Renaming or removing a token requires an ADR** — it's a breaking change for every consumer.

---

## 6. Repo layout

```
apps/
  backend/                       NestJS 11 (CQRS)
    src/modules/<domain>/
      commands/  queries/  events/
      *.controller.ts            (thin — dispatch only)
      *.module.ts
  web/                           Nuxt 4 SPA, ssr: false
    pages/  components/  composables/  i18n/
  mobile/                        Flutter 3.41, feature-first
    lib/features/<feature>/{domain,data,presentation}/
    lib/core/{api,realtime,rules_engine,storage}/
packages/
  specs/                         OpenAPI 3.1 + AsyncAPI 3.0
  api-client-ts/                 Generated. Read-only.
  api-client-dart/               Generated. Read-only.
  ui/                            @app/ui (Vue brand library)
  ui_flutter/                    app_ui (Flutter brand widgets)
  config/                        Shared eslint/stylelint/tsconfig
specs/design/
  tokens/*.json                  Edit these
  source-bundle/project/components/*.jsx   Pixel-precise references
  README.md                      Component + token inventory
docker/compose.yml               Local stack
docs/
  done/                          done.md per shipped feature, with PR link
  adr/                           Architectural decision records
```

---

## 7. Commands you'll use constantly

```bash
# Local stack (don't run pnpm dev alongside — they conflict)
docker compose -f docker/compose.yml up -d

# Spec workflow
pnpm spec:validate
pnpm spec:bundle
pnpm spec:codegen

# Design pipeline
pnpm design:build
pnpm design:audit

# Local quality-gate sweep (run before pushing — see /precheck slash command)
pnpm lint && pnpm typecheck && pnpm test && pnpm check:i18n

# Backend
pnpm --filter backend prisma migrate dev
pnpm --filter backend prisma studio

# Web
pnpm --filter web storybook

# Mobile
cd apps/mobile && flutter pub get && flutter run
```

---

## 8. Quality gates (the full CI list)

A PR cannot merge unless **all** of these are green (PRD §12):

- `pnpm spec:validate` — OpenAPI + AsyncAPI lint clean
- `codegen-drift` — `pnpm spec:codegen` produces no diff
- `express-openapi-validator` runtime tests
- Stylelint — no hex literals, no `!important`, no inline `style=""` with literals
- `@app/ui` audit — every component folder has `*.vue + *.stories.ts + *.spec.ts + index.ts`
- `pnpm design:audit` — every token documented, every component listed
- `pnpm check:i18n` — en / ru parity across backend, web, mobile
- Vitest — backend coverage thresholds, `@app/ui` and web specs green
- TruffleHog — no secrets in diff
- `license-checker` — OSI-permissive allowlist only

---

## 9. Code conventions

### Backend (NestJS, CQRS)
Domain modules under `src/modules/<domain>/`. Controllers are thin — they dispatch commands and queries through the bus. Cross-handler logic only goes in a service if it's genuinely reused. Exception filter is RFC 9457 problem+json. Don't duplicate validation: the OpenAPI runtime validator is authoritative for shape; class-validator is only for invariants the spec can't express.

### Web (Nuxt 4 SPA)
Pages stay thin; logic lives in composables (`composables/use*.ts`). API access is **always** via `@app/api-client-ts` — never hand-write a `$fetch` to a route URL. SCSS uses BEM and design-token CSS custom properties. No Tailwind arbitrary values that bypass tokens.

### Mobile (Flutter)
Feature folders are `domain/` + `data/` + `presentation/`. State via `flutter_bloc`, DI via `get_it`, HTTP via Dio (wrapping the generated `app_api_client`). Tokens come from `tokens.g.dart`. Tap targets ≥ 44×44 (DESIGN §8).

---

## 10. What NOT to do

- Don't write a backend route before its spec exists.
- Don't paste hex colors anywhere except `specs/design/tokens/*.json`.
- Don't edit anything in `packages/api-client-*/src/` — it's regenerated.
- Don't introduce `process.env.X` access outside `AppConfig`.
- Don't add a CRDT, real-time editing, or multiplayer cursors. Sharing is read-only by design (PRD §2.2).
- Don't add Foundry/Roll20 integrations or adventure modules — explicit non-goals for v1.
- Don't run `pnpm dev` alongside the docker compose stack — they fight over ports.
- Don't reach for non-existent Forum Bold. Forum is single-weight; emphasis comes from size and tracking, or Inter Semibold pairing (DESIGN §3.1).
- Don't cite the `Session` Prisma model when you mean GM session — it's `GameSession`.

---

## 11. When unsure

1. Re-read the relevant numbered section of `PRD.md` or `DESIGN.md`.
2. If it's a UI question, look at the matching `.jsx` mockup in `specs/design/source-bundle/`.
3. Check `docs/done/` for prior precedent on similar features.
4. For a user-visible product trade-off, ask in the PR description — don't guess.

---

## 12. Phase awareness

Current target: **Phase 0 — Adoption** (PRD §11). Don't start Phase 1 work (empty-sheet CRUD, sheet skeletons, foundation primitives) until Phase 0 is tagged.

| Phase | Scope | Effort |
|---|---|---|
| **0 — Adoption** | `setup.sh` substitutions, domain Prisma schema, seed tokens, replace placeholder copy | ~1 wk |
| **1 — Foundation** | Empty-sheet CRUD, sheet skeletons (web + mobile), foundation `@app/ui` primitives | ~3 wks |
| **2 — Character Sheet** | Full sheet, inventory, derived stats, auto-save, creation wizard | ~4 wks |
| **3 — Sharing & Polish** | Share links, public read-only views, OG image route, a11y audit | ~2 wks |
| **4 — Dice & Sessions** | Dice roller, push, `GameSession`, Darkness Points, Centrifugo | ~2 wks |
| **5 — Ships** | Ship sheets, crew assignment, ship sharing | ~2 wks |
| **6 — GM Tools** | Combat tracker, NPC library, GM session view | ~3 wks |
| **7 — Hardening** | Offline (web SW + Flutter SQLite), JSON export, perf, beta | ~2 wks |

Each phase ends with a green CI run and a `phase-N-complete` git tag.

Every shipped feature gets a `docs/done/<feature>.md` entry with the PR link.

# Claude Code Kickoff — Phase 0 Runbook

This is the ordered runbook for taking the Coriolis project from **freshly-cloned boilerplate** to **Phase 0 complete and tagged**. Each step has a definition of done that maps to a CI gate. Don't skip ahead — Phase 1 starts on the green tag, not before.

Read `AGENTS.md` before starting. It explains *why* each step has the constraints it does.

---

## Step 0 — Local prerequisites (one-time)

- Node 20+, pnpm 9+
- Docker Desktop, Colima, or OrbStack
- Flutter 3.41 (only if working on `apps/mobile`)
- Claude Code CLI: `npm install -g @anthropic-ai/claude-code`
- Verify: `node -v`, `pnpm -v`, `docker info`, `claude --version`

---

## Step 1 — Wire up the agent context

Before Claude Code does anything else, give it the operating manual. Land these files in **one PR**, titled `chore: wire up agent context`:

- `AGENTS.md` at repo root
- `.claude/settings.json` with permissions
- `.claude/commands/precheck.md`, `spec-endpoint.md`, `component-new.md`, `phase-status.md`
- `.github/PULL_REQUEST_TEMPLATE.md` mapped to the §12 quality gates
- `docs/done/README.md` documenting the convention

**Definition of done.** `claude` opens in the repo, the agent acknowledges it sees `AGENTS.md`, and `/precheck` runs end-to-end (it'll fail until later steps land — that's expected here, just confirm the command itself executes).

---

## Step 2 — Boilerplate adoption

In a separate PR titled `chore(phase-0): adopt boilerplate as Coriolis Companion`:

```bash
./scripts/setup.sh \
  --name "Coriolis Companion" \
  --slug coriolis-companion \
  --locales en,ru \
  --inactive-locales uk,el
```

Verify the substitutions:

- `package.json` and every `apps/*/package.json` and `packages/*/package.json` name updated
- `apps/mobile/pubspec.yaml` name updated
- `docker/compose.yml` container names updated
- `apps/web/i18n/en.json` and `apps/web/i18n/ru.json` exist (boilerplate copy is fine here, gets replaced in Step 6)
- `apps/web/i18n/uk.json` and `apps/web/i18n/el.json` exist as stubs
- `.env.example` has the keys you need (Postgres URL, Redis URL, Centrifugo HMAC, Better Auth secret, S3 creds, mail provider)

**Definition of done.**
- `pnpm install` runs clean
- `docker compose -f docker/compose.yml up -d` brings up postgres, redis, centrifugo, backend, web, grafana — all healthy
- `pnpm --filter backend prisma migrate dev` succeeds against an empty domain schema (Better Auth tables only)

---

## Step 3 — Seed design tokens

PR title: `feat(phase-0): seed Coriolis design tokens`.

Adapt the boilerplate's starter token JSON to Coriolis values from `DESIGN.md` §2.

- `specs/design/tokens/color.json` — surfaces (void/night/dawn/parchment), brand brass (light/standard/deep), state colors (mystic teal, prayer crimson, darkness, success, warning)
- `specs/design/tokens/typography.json` — Forum (display, weight 400 only), Inter (body, 400/500/600/700), JetBrains Mono (numeric, 500/700). Latin + Cyrillic subsets.
- `specs/design/tokens/spacing.json` — 4px base scale
- `specs/design/tokens/radius.json` — sm/md/lg, plus the brass-corner ornament radius
- `specs/design/tokens/motion.json` — `--motion-duration` (default), `--motion-duration-slow`, `--motion-duration-ceremony`; easings `--motion-ease-standard`, `--motion-ease-emphasis`
- `specs/design/tokens/z-index.json` — base / sticky / overlay / modal / toast (per DESIGN §2.3)
- Update `specs/design/README.md` to list every new token

Run `pnpm design:build` and verify the generated outputs:
- `apps/web/assets/css/tokens.generated.css` regenerates
- `packages/ui/src/tokens/design-tokens.generated.ts` regenerates
- `apps/mobile/lib/core/theme/tokens.g.dart` regenerates

**Definition of done.**
- A throwaway `<div style="background: var(--surface-void)">` in a Nuxt page renders the deep-space indigo
- Storybook background plate matches
- `pnpm design:audit` is green

> Do **not** edit the `*.generated.*` files directly. Edit JSON, run `pnpm design:build`. The generated files are committed for review and CI determinism only.

---

## Step 4 — Seed the domain schema

PR title: `feat(phase-0): seed Coriolis domain schema`.

Replace the boilerplate's starter Prisma models with the Coriolis domain (PRD §8.2). **Keep Better Auth tables untouched** — `user`, `session`, `account`, `verification`, `jwks`. Custom user fields (`displayName`, `deletedAt`) go on the same `user` table via Better Auth's `additionalFields`, **not** as a parallel domain table.

Domain models to add:
- `Character`, `Item`, `Talent`, `Relationship`, `ShareLink`
- `Ship`
- `GameSession`, `Encounter`, `Combatant`
- `Npc`
- `Roll`, `DpEvent`

Reminder: the GM-side concept is `GameSession`, **never** `Session`. Better Auth owns the `Session` name.

Run:
```bash
pnpm --filter backend prisma migrate dev --name init-domain
pnpm --filter backend prisma generate
```

**Definition of done.**
- Migration applies clean against the docker postgres
- Prisma Studio shows the new tables
- No Better Auth table was touched
- `pnpm --filter backend test` (handler unit tests) still green

---

## Step 5 — Seed the OpenAPI skeleton

PR title: `feat(phase-0): seed OpenAPI skeleton for Phase 0/1 surface`.

Stub every Phase 0 + Phase 1 endpoint from PRD §9 with empty 501 responses, so the spec is the source of truth before any handler exists.

- Implement for real: `GET /api/v1/health` (returns `{ status, dependencies: { db, redis, centrifugo } }`)
- Stub at 501 with full request/response schemas:
  - `GET/PATCH/DELETE /api/v1/me`, `GET /api/v1/me/export`
  - `GET/POST /api/v1/characters`, `GET/PATCH/DELETE /api/v1/characters/:id`
  - `POST /api/v1/characters/:id/duplicate`
  - `GET/POST /api/v1/ships`, `GET/PATCH/DELETE /api/v1/ships/:id`
- Ensure RFC 9457 problem+json is the documented error shape on every route

Run the five-step loop end to end:
```bash
pnpm spec:validate
pnpm spec:bundle
pnpm spec:codegen
```

**Definition of done.**
- `codegen-drift` CI job green
- `apps/web` imports types from `@app/api-client-ts` without error
- `apps/mobile` builds with `app_api_client` dependency
- The runtime `express-openapi-validator` accepts the (limited) handlers and rejects malformed payloads in a smoke test

---

## Step 6 — Replace placeholder copy

PR title: `chore(phase-0): replace placeholder copy with Coriolis copy`.

Walk every `<i18n>` block in `apps/web` and every `slang` key in `apps/mobile`, replacing boilerplate copy with Coriolis copy from `landing.jsx` and the PRD (wordmark, tagline, "fan project" disclaimer, error messages, button labels).

**en and ru must stay in lockstep.** `pnpm check:i18n` enforces parity. If you don't have a Russian translation handy, use a placeholder marked with `[ru-todo]` so the audit at least sees the key — but don't ship `[ru-todo]` keys in a release tag.

**Definition of done.**
- `pnpm check:i18n` green
- The landing page renders the wordmark and tagline from `landing.jsx`
- The "fan project · not affiliated with the publisher" disclaimer renders in the footer

---

## Step 7 — Tag and hand off

Run the full local quality-gate sweep:

```bash
pnpm spec:validate && pnpm spec:codegen
pnpm lint && pnpm typecheck && pnpm test
pnpm design:audit && pnpm check:i18n
```

If everything is green, push and let CI confirm. Then tag:

```bash
git tag phase-0-complete
git push origin phase-0-complete
```

Append `docs/done/phase-0.md` with links to the PRs that landed in steps 1–6.

Open the **Phase 1 epic**: empty-sheet CRUD on the backend, Nuxt sheet skeleton, Flutter sheet skeleton, foundation primitives in `@app/ui` (Button, Card, Input, Badge, Chip, StatBlock).

---

## Working with Claude Code, day to day

For each Phase 1+ feature, prefer this loop:

1. **Branch.** `git switch -c feat/<area>-<short-desc>`.
2. **Open Claude Code.** `claude` in the repo root.
3. **One-line brief, with citation.** *"Implement PRD §5.2 attribute editing on the desktop sheet, behind the existing `characters/[id]` route. Mockup: `specs/design/source-bundle/project/components/CharacterSheet_Desktop.jsx`."*
4. **Let it run the loop autonomously**, reviewing each step:
   - For API surface changes: the five-step loop (§4 of `AGENTS.md`).
   - For UI changes: the design loop (§5 of `AGENTS.md`).
5. **`/precheck`** before pushing.
6. **After merge**, append `docs/done/<feature>.md` with the PR link.

### Anti-patterns to avoid

- **Bundling spec, design, and feature in one PR.** Review is much faster when each is its own commit, and codegen-drift is easier to debug when the spec change is isolated.
- **Letting the agent write tests after the fact.** Have it write the contract test first (against the spec) and the unit tests alongside the handler.
- **Skipping the JSX mockup.** If a `.jsx` exists for the screen you're touching, read it first. It is more authoritative than the `.md` in the design source-bundle.
- **Merging on a yellow CI.** The quality gates are tuned to the boilerplate's invariants. A red gate is telling you a real thing.

### When the agent goes off-track

If Claude Code starts producing diffs that violate the non-negotiables in `AGENTS.md` §3 (hex literals, `process.env` outside `AppConfig`, hand-written `$fetch` instead of `@app/api-client-ts`, etc.), interrupt and point it at the specific section. Don't let a "just this once" exception land — the next agent session will see it as precedent.

If the same drift happens twice on the same kind of task, that's a signal to add a slash command for it, or to extend `AGENTS.md` with a clarifying example.

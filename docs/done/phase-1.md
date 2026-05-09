# Phase 1 — Foundation

**Phase:** 1
**Tag:** `phase-1-complete`
**PRD section:** §11 (roadmap)
**Date:** 2026-05-08

## What shipped

End-to-end empty-sheet CRUD on the backend, the design system at
production strength on web, sheet skeletons on web and mobile, full
account-management vertical (display name + soft-delete with cron + email
templates in Coriolis voice), and forty-five-plus PRs landed across two
sessions.

A logged-in user can:

- Land on the marketing page, sign in, and reach `/app/characters`.
- Create a character ("name only" is enough — backend defaults the rest;
  rules-engine fills `hp.max` / `mp.max` / `encumbrance.max`).
- Edit `name` and `concept` inline with 500 ms debounced auto-save.
- Delete a character (with confirmation) and return to the list.
- Open `/app/settings`, edit display name (auto-save), switch locale and
  high-contrast theme, and run the double-confirm account-deletion flow
  (sessions revoke immediately; 30-day grace before cascade).
- Receive verification and password-reset emails in the Coriolis voice
  (en or ru).

The Flutter app does the same on mobile (modulo polishing the eight
deferred Flutter primitives — see Follow-ups).

## What landed (by epic)

### Epic 2 — UI Foundation Library

#### Vue (`@app/ui`) — 26 primitives total, **all green at 655 vitest specs**

| Family                    | Components                                                                                                                                                                                                                                                 |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Foundation (20)**       | `AppButton`, `AppBadge`, `AppCard`, `AppChip`, `AppInput`, `AppSwitch`, `AppProgress`, `AppIcon`, `AppAvatar`, `AppBanner`, `AppTab`, `AppTooltip`, `AppKbd`, `AppDots`, `AppDivider`, `AppSegControl`, `AppLabel`, `AppField`, `AppSelect`, `AppTextarea` |
| **Coriolis-specific (6)** | `AppDie`, `AppDiePool`, `AppConditionPill`, `AppIconCoriolis` (with 9 placeholder Icon SVGs), `AppStarOrnament`, `AppArabesqueCorner`                                                                                                                      |

Each has `*.vue` + `*.stories.ts` + `*.spec.ts` + `index.ts`, BEM class
names, Coriolis design tokens only (no hex literals; Stylelint enforces),
and a row in `specs/design/README.md`'s component inventory.

#### Flutter (`app_ui`) — 12 of 20 widgets shipped, 8 deferred

Shipped: `AppButton`, `AppBadge`, `AppChip`, `AppInput`, `AppSwitch`,
`AppProgress`, `AppCard`, `AppLabel`, `AppField`, `AppDivider`, `AppDots`,
`AppAvatar`. 91 Flutter widget tests passing under
`flutter test test/widgets/`.

Deferred to Phase 2: `AppIcon`, `AppTab`, `AppBanner`, `AppTooltip`,
`AppKbd`, `AppSegControl`, `AppSelect`, `AppTextarea`. They have
Material/Cupertino idiom analogues that need a per-widget evaluation pass
before mirroring blindly. The mobile sheet skeleton (Epic 3.4) renders
fine without them.

### Epic 3 — Empty-Sheet CRUD end-to-end

- **Spec** (Epic 3.1): `/api/v1/characters` CRUD + nested
  `items` and `talents`. Discriminated `Item` union (six type variants —
  WEAPON / ARMOR / GEAR / CYBERNETIC / SHIP_MODULE / OTHER) with
  RFC 9457 problem+json on every error and named codes
  (`CHARACTER_NOT_FOUND`, `ATTRIBUTE_OUT_OF_RANGE`, `ITEM_TYPE_MISMATCH`,
  …). info.version landed at `0.5.1`.
- **Backend** (Epic 3.2): `apps/backend/src/modules/characters/` with
  full CQRS layout — commands (`create`, `update`, `delete`,
  `duplicate`), queries (`list` paginated/cursor, `get`, `export`),
  events (`character-updated.event`), ownership guards, nested
  `items/` and `talents/` sub-modules. Domain models in Prisma:
  `Character`, `Item`, `Talent`, `Relationship`, `CriticalInjury`.
  JSON columns for attributes / skills / conditions / item.data
  (documented trade-off vs one-table-per-type).
- **Rules-engine**: pure functions in
  `apps/backend/src/modules/rules-engine/` per PRD §5.2 / §10 —
  `computeHpMax(STR + AGI)`, `computeMpMax(WIT + EMP)`,
  `computeEncumbranceMax(STR × 2)`, `computeEncumbranceCurrent(items)`,
  `canPush(conditions, alreadyPushed)`. Wired into the read mapper.
  `ReadOnlyFieldError` (422 `READ_ONLY_FIELD`) defends `UpdateCharacter`
  against attempts to set derived fields.
- **Web sheet skeleton** (Epic 3.3): pages `/app/characters` (list with
  loading / empty / error / loaded states), `/app/characters/new`
  (minimal name form), `/app/characters/[id]` (header with avatar +
  inline name+concept editable, 500 ms debounced auto-save with
  saving/saved/error indicator, native `<dialog>` delete confirmation).
  `useDebounceFn` / `useCharactersApi` composables. `auth-required`
  global middleware guards `/app/**`.
- **Mobile sheet skeleton** (Epic 3.4): mirror of the above on Flutter
  with `flutter_bloc` cubits (`CharactersListCubit`, `CharacterSheetCubit`)
  and feature-first layering under
  `apps/mobile/lib/features/characters/{domain,data,presentation}/`.
  Repository adapter mapping `app_api_client.Character` → domain model.

### Epic 4 — Auth Vertical Extensions

- **`/api/v1/me` GET / PATCH** (Epic 4.1): backend `UsersModule`,
  `displayName` + `deletedAt` columns added via Better Auth's
  `additionalFields`, web settings page consumes `useMeApi` with
  auto-save + locale switcher + high-contrast theme toggle.
- **`/api/v1/me` DELETE + cron + UI** (Epic 4.2): spec idempotent
  (no 404 on already-deleted), backend `DeleteMeCommand` revokes BA
  sessions and stamps `deletedAt`, daily cron job
  (`@nestjs/schedule`, `@Cron(EVERY_DAY_AT_3AM)`) cascade-deletes users
  whose `deletedAt < now − 30d`. Web settings: native `<dialog>`
  double-confirm with locale-aware confirmation phrase.
- **Email mailer + Coriolis voice** (Epic 4.3): `IMailer` port with
  `MockMailer` (dev — ring buffer, `getLastSent()`) and `ResendMailer`
  (`node:fetch`, behind `AppConfig.mailer.provider='resend'` feature
  flag with boot-time guard). Four inline-TS templates
  (`verification` + `password-reset` × `en/ru`). `email-shell.ts`
  inline-CSS shell — the only backend file that uses hex literals,
  explicitly justified (email clients don't support CSS custom
  properties). Domain-error copy refreshed across users/characters/
  items/talents for the warm-but-not-corny baseline.

### Bonus — Phase 5 prep

- **Ships OpenAPI surface** (Epic 5 prep): authored ahead of schedule
  using ST3001 ГЛАВА 7 as the canonical game-rule source. 12 operations
  (`listShips`, `createShip`, `…`, `unassignCrew`); discriminated
  `ShipModule` union with five named variants
  (Weapon/Torpedo/Hold/Sensor/Other) covering the 21 slot types per
  the rulebook; six new enums. Codegen produced clean class names
  (the spec tech-debt fix below ensured no `Model0..N` orphans).

### Spec tech debt cleared

- Inline `oneOf` discriminator branches on `Item*` / `ShipModule*`
  Create/Update were producing `dart-dio` orphans
  (`ItemCreateOneOf{,1..5}.dart`, `Model0..5.dart`,
  `ShipModuleCreateOneOf{,1..4}.dart`, `Model0{2..42}.dart`). Replaced
  with 22 named create/update variant schemas; codegen output now
  intent-revealing. info.version 0.4.0 → 0.5.0.

## Quality gates (verified at tag time)

- `pnpm --filter @app/specs run validate` — OpenAPI 3.1 + AsyncAPI 3.0 clean.
- `pnpm --filter @app/design-tokens typecheck` — clean.
- `pnpm --filter @app/ui test` — **655 tests across 26 files** pass.
- `pnpm --filter @app/backend test` — **191 tests across 25 files** pass.
- `pnpm stylelint "{apps/web,packages/ui}/**/*.{vue,scss,css}"` — clean.
- `node --experimental-strip-types scripts/check-i18n-parity.ts` —
  mobile 4 locales × 101 keys; web 4 locales × 87 keys; **zero drift**.
- `flutter test test/widgets/` — 91 widget tests pass (run by the
  flutter-engineer agent under SDK 3.5; CI / production runs under the
  pinned 3.41).

## Notable decisions

- **Path A on the design pipeline (carried from Phase 0).** All
  primitives author against the dark-first `surface/brand/text/state`
  token shape; the web/ui CSS+TS mirrors stay gitignored and only the
  Flutter Dart artefact is committed.
- **`oneOf` named variants.** Any spec with a discriminator must
  reference `$ref` schemas, not inline branches — locked into convention
  by ADR-equivalent commit message in the spec PR.
- **`ReadOnlyFieldError` server guard.** Belt-and-suspenders on top of
  the spec's `readOnly: true` declarations; keeps PATCH bodies from
  silently accepting derived-field edits.
- **`MockMailer` ring buffer.** Pattern to test email flows without a
  network stub — every mailer call is observable through `getLastSent()`.
- **Locale-aware confirmation phrase for delete-account.** The user
  types the localized literal phrase ("DELETE MY ACCOUNT" /
  "УДАЛИТЬ МОЙ АККАУНТ"). Comparison is `===` against the resolved
  i18n key — language-aware gate.
- **Per-feature / per-phase delivery rule (carried from Phase 0).**
  Domain models, OpenAPI endpoints, and i18n copy are added in the
  phase that needs them. Phase 1 added the schemas / endpoints / copy
  it actually consumed.
- **Cyrillic-safe initials.** Both web (`String.codePointAt`) and
  mobile (`String.runes.first`) handle non-Latin names without lossy
  truncation.

## Notable judgement calls (carried forward as known caveats)

- **Web `pnpm typecheck` is environmentally broken** locally on macOS
  due to `oxc-parser` native bindings (documented in
  `docs/troubleshooting.md`). CI under Linux is unaffected. Docker stack
  smoke-test is the de-facto local typecheck.
- **`AppTextarea autosize` content-grow is deferred** — the prop accepts
  the BEM modifier but doesn't yet implement `field-sizing: content` +
  JS recompute polyfill. Plain `rows` baseline ships.
- **`AppProgress` circular variant deferred** — the wizard-icon and
  sheet-desktop mockups only need linear; circular SVG arc is a Phase 2+
  task.
- **Theme persistence is local-only on web settings.** The
  high-contrast toggle stores in `localStorage('coriolis.theme')`. PRD
  expects eventual server-side persistence via `AppConfig` so mobile +
  web stay in sync. Hooked but TODO'd.
- **Mobile slang `strings.g.dart`** is gitignored; the agent's
  hand-written stub covers local development. The CI / build environment
  with Dart SDK 3.8 regenerates via `dart run slang` on each build.
- **8 Flutter widgets deferred.** The `app_ui` package ships 12/20
  primitives. The remaining 8 (`AppIcon`, `AppTab`, `AppBanner`,
  `AppTooltip`, `AppKbd`, `AppSegControl`, `AppSelect`, `AppTextarea`)
  have Material/Cupertino idiom analogues that need per-widget
  evaluation. Mobile sheet skeleton renders fine without them.
- **dart-dio docs / test stubs** are auto-regenerated; some sit alongside
  the model classes and aren't wired into CI yet. They're effectively
  scaffold-quality and don't block the codegen-drift CI guard.

## How Phase 1 was delivered

After Phase 0's local-merge-only flow, an `origin` was added and from
PR #2 onward changes shipped through the Forgejo PR cycle. Mid-Phase 1
the user opted for direct-merge-on-main (no PR) once the cadence proved
itself. From there on, branches → ff-merge → push, with
`specs/tasks/done.md` taking the role of the reviewable change ledger.

Subagents (`spec-writer`, `codegen-runner`, `frontend-engineer`,
`backend-engineer`, `flutter-engineer`) ran in parallel under
`isolation: "worktree"` for most of Phase 1. Conflicts almost always
landed on `specs/tasks/active.md` because every agent pushed its own
task entry — once the parent stopped letting agents touch the task
stack, conflicts went to zero. (See ledger entries with the
`Foundation tail` and onward batches.)

Two recurring environmental blockers:

1. **Worktree Node version.** The agent harness spawned worktree shells
   under Node 20; the project's `engines.node` is `>=24` and `.npmrc` is
   `engine-strict=true`. Agents that touched `pnpm install` failed
   without an explicit `PATH="…/v24.15.0/bin:$PATH"` prefix. Fixed by
   threading the prefix into agent prompts.
2. **Bash permission prompt.** A small fraction of `codegen-runner` and
   `frontend-engineer` agent dispatches failed at the first Bash call
   waiting for permission. Standard recovery: re-dispatch (rarely
   re-failed), or fall back to running the work in the parent session.

## Phase 2 follow-ups

Pushed to the top of `specs/tasks/active.md` (none in flight at tag
time) — these are the natural starting items for the next epic:

- **Epic 2.5 tail — 8 Flutter widgets.** `AppIcon`, `AppTab`, `AppBanner`,
  `AppTooltip`, `AppKbd`, `AppSegControl`, `AppSelect`, `AppTextarea` —
  evaluate Material vs custom per widget, then ship.
- **Storybook visual smoke-test.** Run `pnpm storybook` once and confirm
  every primitive renders. Wire into CI (a11y panel pass + visual
  regression).
- **Web `pnpm typecheck` fix.** The `oxc-parser` native binding bug needs
  either an upstream patch or a vite plugin swap. Without it, full local
  parity with CI is brittle.
- **`AppTextarea autosize`** — implement the content-grow.
- **`AppProgress` circular variant** — when the wizard-icon flow needs it.
- **Theme persistence sync** — extend `Me` schema with `themePreference`
  and persist on the backend.
- **Phase 2 Epic 5 — full Character Sheet.** Spec has the schemas, the
  primitives are ready, the sheet skeleton has the auto-save loop. Time
  to fill in the body.

## Local merge ledger

The session shipped 47 PRs / branches across Phase 1. Key ones (most
recent first; full history in `git log` and `specs/tasks/done.md`):

- `bf6d158` — Email mailer + voice (Epic 4.3)
- `5afef03` — Web delete-account UI (Epic 4.2.c)
- `8db8a7f` — DeleteMe backend + cron (Epic 4.2.b)
- `ff53323` — Coriolis decorative primitives (Epic 2.2 final 4)
- `cc012c0` — Flutter foundation widgets (Epic 2.5 — 12 of 20)
- `df5194b` — Mobile sheet skeleton (Epic 3.4)
- `f3a799a` — AppTooltip + AppKbd + AppSegControl (Epic 2.1 tail)
- `dbc3e58` — Ships OpenAPI spec (Phase 5 prep)
- `e12f2b5` + `fbfcd41` — Spec named oneOf variants + codegen (tech debt)
- `64db2d0` — CharactersModule backend (Epic 3.2 Story 3.2.1)
- `c423dc2` — Rules engine (Epic 3.2 Story 3.2.2)
- `e8a0a7a` — Web sheet skeleton (Epic 3.3)
- `691e9de` + `d2f1751` — Characters spec + codegen (Epic 3.1)
- `8db8a7f` and friends — auth vertical (Epic 4.1)
- 26 primitive PRs (Epic 2.1 + 2.2)

`specs/tasks/done.md` carries the per-task entries with judgement-call
notes from the agents.

# Coriolis Companion App — Implementation Plan

**Audience:** Claude Code (and any human reviewer)
**Source documents:** `docs/PRD.md` v2.0, `docs/DESIGN.md` v2.0, JSX mockups in `specs/design/mockups/*.jsx`
**Boilerplate:** `claude-driven-nest-nuxt-flutter-monorepo`

---

## How to use this plan

The work is decomposed in four levels:

- **Epics** map ~1:1 to PRD phases. Complete an epic before moving to the next.
- **Features** are deliverable slices inside an epic. Each ends with green CI.
- **Stories** are user-visible capabilities (or developer-facing capabilities for infra epics).
- **Tasks** are concrete, branch-sized units of work for Claude Code.

**Non-negotiable execution rules** (from PRD §7.2, §12 and DESIGN §15):

1. **Spec first.** Every API change starts in `packages/specs/openapi/openapi.yaml` (or `asyncapi/centrifugo.yaml`). Run `pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen` before any backend or client code.
2. **No hex literals.** All colors via tokens. Edit `specs/design/tokens/*.json` then run `pnpm design:build`. Stylelint enforces.
3. **No untracked components.** Every `@app/ui` component needs `*.vue + *.stories.ts + *.spec.ts + index.ts`, and an entry in `specs/design/README.md`.
4. **No literal user-facing strings.** Use `t()` (web) or `context.t.*` (mobile). `pnpm check:i18n` enforces en/ru parity.
5. **Pages are thin.** No ad-hoc markup in `apps/web/app/pages/` past one `<section>` wrapping an `@app/ui` composition.
6. **Foundation primitives are native.** `AppButton`, `AppInput`, etc. do **not** wrap Nuxt UI. Only `AppModal`, `AppDropdown`, etc. (behavior-heavy) wrap Nuxt UI.
7. **Backend reads no `process.env`.** Use `AppConfig`.
8. **JSX mockups win.** When a `.md` spec contradicts a JSX in `specs/design/mockups/`, the JSX is canon.

**CI gates that block every PR:**

`spec:validate`, `codegen-drift`, `express-openapi-validator` runtime, Stylelint, `@app/ui` audit, `design:audit`, `check:i18n`, Vitest (backend + ui + web), TruffleHog secret scan, license check.

---

# EPIC 1 — Adoption (Phase 0, ~1 week)

**Goal:** Convert the boilerplate into a Coriolis-branded shell with the right schema, tokens, and locale skeleton. No product features yet.

**Exit criteria:** `docker compose up -d` brings up the stack, the landing page loads with Coriolis branding and the brass/indigo palette, `pnpm design:audit` and `pnpm check:i18n` pass, the Prisma schema has all domain tables migrated, the auth vertical from the boilerplate still works end-to-end on web and mobile.

---

## Feature 1.1 — Boilerplate provisioning

**Story 1.1.1** — As a developer, I can clone the repo and run `scripts/setup.sh` with project name "coriolis" so that all package names, slugs, Docker container names, and CI badges reference Coriolis.

**Tasks:**
- T-1.1.1.a Run `scripts/setup.sh` with name=`coriolis`, slug=`coriolis-companion`. Verify it rewrites `package.json` names (`@app/*`), `pubspec.yaml`, Docker container names, and the `README` title.
- T-1.1.1.b Update root `README.md`: replace boilerplate intro with one paragraph describing the Coriolis Companion App, link to `PRD.md` and `DESIGN.md`.
- T-1.1.1.c Add `LICENSE` (MIT or chosen OSI license — confirm with PRD §13 risk on Free League IP) and a `NOTICE` file with the fan-project disclaimer required for the landing footer.
- T-1.1.1.d Verify `docker compose -f docker/compose.yml up -d` brings up postgres / redis / centrifugo / backend / web / grafana cleanly. Document the local URLs in `README.md`.

**Story 1.1.2** — As a developer, I can run the boilerplate's existing auth vertical (sign-up / sign-in / sign-out) on web and mobile and it still passes after the rename.

**Tasks:**
- T-1.1.2.a Run web e2e auth happy path. Fix any references to old project name that broke.
- T-1.1.2.b Run mobile auth widget tests + manual sign-in on the Flutter app pointed at the local backend.
- T-1.1.2.c Confirm `pnpm spec:validate && pnpm spec:codegen` produces no drift after the rename.

---

## Feature 1.2 — Design tokens seeded from DESIGN.md

**Story 1.2.1** — As a designer/developer, all colors, typography scales, spacing, radii, motion, and z-index values from DESIGN §2 exist as W3C Design Tokens in `specs/design/tokens/`, and `pnpm design:build` emits them to web (`tokens.generated.css`, `design-tokens.generated.ts`) and Flutter (`tokens.g.dart`).

**Tasks:**
- T-1.2.1.a Author `specs/design/tokens/color.json`: surfaces (void/night/dawn/parchment), brand brass (light/standard/deep/shadow), text (primary/secondary/ink/on-brass), semantic (crimson/crimson-bright/mystic-teal/success/darkness). Hex values per DESIGN §2.1 — these are the only place hex literals are allowed.
- T-1.2.1.b Author `specs/design/tokens/typography.json`: families (Forum, Inter, JetBrains Mono), the `--type-display-*`, `--type-body-*`, `--type-mono-stat-*` scale rows from `tokens.jsx`.
- T-1.2.1.c Author `specs/design/tokens/spacing.json`: `--space-1` … `--space-12` (4/8/12/16/20/24/32/40/48/56/64/80).
- T-1.2.1.d Author `specs/design/tokens/radius.json`, `motion.json`, `z-index.json`, `layout.json` (breakpoints sm 640 / md 768 / lg 1024 / xl 1280) per DESIGN §2.3 and §5.1.
- T-1.2.1.e Add the high-contrast theme override (`[data-theme='high-contrast']`) per DESIGN §2.2.
- T-1.2.1.f Wire self-hosted Forum, Inter, JetBrains Mono via the boilerplate's font pipeline. Latin + Cyrillic subsets only for v1; uk/el subsets stubbed but not loaded.
- T-1.2.1.g Run `pnpm design:build` and commit the generated files in a separate codegen-only commit. Run `pnpm design:audit` — fix any unreferenced or missing tokens.

**Story 1.2.2** — As a developer, the JSX mockups are placed in `specs/design/mockups/` so they remain the visual source of truth.

**Tasks:**
- T-1.2.2.a Place all 12 JSX files (landing, dashboard, wizard-icon, sheet-desktop, sheet-mobile, ship-sheet, combat-tracker, dice-roller, share-viewer, gm-session, primitives, tokens) into `specs/design/mockups/`.
- T-1.2.2.b Update `specs/design/mockups/README.md` cross-referencing each mockup to its target screen and `@app/ui` composition.

---

## Feature 1.3 — Domain Prisma schema

**Story 1.3.1** — As a backend developer, the Prisma schema in `apps/backend/prisma/schema.prisma` contains all domain tables from PRD §8.2, alongside the Better-Auth-managed tables, with one migration that applies cleanly to a fresh database.

**Tasks:**
- T-1.3.1.a Run `npx @better-auth/cli generate` to (re)materialize `user`, `session`, `account`, `verification`, `jwks`. Add `displayName String?` and `deletedAt DateTime?` via Better Auth's `additionalFields` config — do not edit the generated tables directly.
- T-1.3.1.b Append the domain models from PRD §8.2 verbatim: `Character`, `Item` + `ItemType` enum, `Talent`, `Relationship`, `Ship`, `CrewAssignment`, `ShareLink`, `GameSession`, `Encounter`, `Npc`, `Roll`, `DpEvent`. Use cuid IDs and the cascade rules shown.
- T-1.3.1.c `pnpm prisma migrate dev --name init-domain` against the local Postgres. Confirm rollback works.
- T-1.3.1.d Add a Prisma seed script at `apps/backend/prisma/seed.ts` that creates one demo user, two demo characters, one demo ship, and one archived game session — for local dev only, gated behind `NODE_ENV !== 'production'`.

---

## Feature 1.4 — i18n skeleton (en/ru active, uk/el stubbed)

**Story 1.4.1** — As a developer, every existing user-facing string in the boilerplate is keyed in en + ru, and `pnpm check:i18n` passes for the two active locales.

**Tasks:**
- T-1.4.1.a Web: replace boilerplate copy in `<i18n lang="json">` blocks of every existing `apps/web/app/**` page/component with Coriolis-appropriate text. Both `en` and `ru` populated.
- T-1.4.1.b Mobile: populate `apps/mobile/lib/i18n/<locale>/auth.i18n.json`, `common.i18n.json`, `settings.i18n.json` for en + ru. Add a new `coriolis.i18n.json` namespace stub (empty object) for upcoming Coriolis-specific strings.
- T-1.4.1.c Backend: populate `apps/backend/src/i18n/en/*.json` and `ru/*.json` — error messages, email templates.
- T-1.4.1.d Confirm uk/el stubs exist as empty `{}` files where the pipeline expects them, but `check:i18n` configured to require parity only for en + ru.
- T-1.4.1.e Run `pnpm check:i18n` — fix gaps.

---

# EPIC 2 — UI Foundation Library (Phase 1, ~3 weeks, runs in parallel with Epic 3)

**Goal:** Build the complete `@app/ui` (Vue) and `app_ui` (Flutter) inventories listed in DESIGN §11. Every component has its story, spec, and entry in `specs/design/README.md`.

**Exit criteria:** `pnpm storybook` renders every component listed in DESIGN §11.1–§11.4 in light + dark, every component has a passing `*.spec.ts`, Storybook's `addon-a11y` panel is clean, `pnpm design:audit` passes.

---

## Feature 2.1 — Vue foundation primitives (DESIGN §11.1)

**Story 2.1.1** — As a frontend developer, I can `import { AppButton } from '@app/ui'` and get a fully tokenized, themed button with all variants from `primitives.jsx` and the JSX mockups.

**Tasks** (one task per component — each task creates `packages/ui/src/components/<Name>/{<Name>.vue, <Name>.stories.ts, <Name>.spec.ts, index.ts}` and adds it to the package barrel + `specs/design/README.md`):

- T-2.1.1.a `AppButton` — variants: primary (brass fill), ghost (transparent + brass border), danger (crimson). Sizes sm/md/lg. Native SCSS, no Nuxt UI dependency. Reference `cor-btn`, `cor-btn--ghost` classes in `primitives.jsx`.
- T-2.1.1.b `AppBadge` — small label chip; variants for state colors.
- T-2.1.1.c `AppChip` — see `cor-chip` and `cor-chip--mystic` styling in JSX. Used for conditions and ship-status pills.
- T-2.1.1.d `AppInput` — text + numeric, with embedded label slot. Inline error state.
- T-2.1.1.e `AppSwitch` — boolean toggle, brass-on-night styling.
- T-2.1.1.f `AppProgress` — linear bar; used for HP/MP and wizard step progress.
- T-2.1.1.g `AppIcon` — wraps Lucide with `stroke-width: 1.5` and `currentColor: var(--brand-brass)` defaults per DESIGN §4.3.
- T-2.1.1.h `AppCard` — base + `--featured` variant (DESIGN §5.4 beveled brass plate).
- T-2.1.1.i `AppAvatar` — initials variant + image variant for portraits. Match `Portrait` helper in JSX mockups.
- T-2.1.1.j `AppBanner` — used for share-viewer "read-only" notice; surface-parchment background variant on dark.
- T-2.1.1.k `AppTab` — see `cor-tab` styling in JSX. Underline-on-active variant.
- T-2.1.1.l `AppTooltip` — minimal positional tooltip; native, not Nuxt UI's.
- T-2.1.1.m `AppKbd` — keyboard-shortcut pill for the combat tracker `?` overlay.
- T-2.1.1.n `AppDots` — rank dots for stat blocks (5-dot row, filled count = value). Aria `valuenow` / `valuemax` per DESIGN §10.
- T-2.1.1.o `AppDivider` — horizontal rule + vertical variant; brass-deep color.
- T-2.1.1.p `AppSegControl` — segmented control for binary/ternary choices in the wizard.

---

## Feature 2.2 — Vue Coriolis-specific primitives (DESIGN §11.2)

**Tasks:**
- T-2.2.a `AppIconCoriolis` — renders one of the Nine Icon glyphs by name. SVGs live in `packages/ui/src/assets/icons/`. Aria-label uses the localized Icon name (passed in as prop).
- T-2.2.b `AppDie` — single d6 face SVG. Variants for values 1–6 + "hit" (6 with teal glow per DESIGN asset list #6).
- T-2.2.c `AppDiePool` — collection wrapper that takes an array of values and renders `AppDie` instances, counting hits, with pushed-die positioning per `dice-roller.jsx`.
- T-2.2.d `AppConditionPill` — condition variants: Exhausted, Sleepless, Thirsty, Hungry. Localized labels via prop. Toggle state.
- T-2.2.e `AppStarOrnament` — eight-pointed star, sizes sm (16) / md (24-32) / lg (48-56). See `StarOrnament` helper in JSX. Decorative-only `aria-hidden`.
- T-2.2.f `AppArabesqueCorner` — orientations tl/tr/bl/br. See `ArabesqueCorner` helper. Decorative-only.

---

## Feature 2.3 — Vue compositions (DESIGN §11.3)

**Tasks:**
- T-2.3.a `AppPageHero` — generic page hero with brass plate treatment per the dashboard / sheet header. Slots: pre-title, title, swash, descriptor, right-aligned actions.
- T-2.3.b `AppEmptyState` — centered illustration + headline + sub + CTA. Four illustration slots from DESIGN asset list #5.
- T-2.3.c `AppSkeleton` — loading shimmer for cards, rows, stat blocks. Brass shimmer on night surface.
- T-2.3.d `AppStatBlock` — see DESIGN §6.3. Forum uppercase label, JetBrains Mono value, optional `AppDots`. Click-to-edit-inline on desktop, tap-to-edit on mobile.
- T-2.3.e `AppSheetHeader` — composite of portrait, name, swash, Icon medallion, and HP/MP counter blocks. Match `sheet-desktop.jsx` hero treatment.
- T-2.3.f `AppCombatRow` — see DESIGN §6.5 and `combat-tracker.jsx`. Drag handle, initiative number, name, condition pills, HP/MP +/- controls, action menu. Active-turn variant: 4px brass left border + "▶" prefix + faint inner glow. Reduced-motion variant required (per DESIGN §9 spec).
- T-2.3.g `AppDiceRoller` — see DESIGN §6.4 and `dice-roller.jsx`. Pool selector, roll button, result display, push button (only when push is legal). Reduced-motion variant required.
- T-2.3.h `AppShareViewer` — see DESIGN §6.6 and `share-viewer.jsx`. Parchment chrome, watermark, no edit affordances rendered.
- T-2.3.i `AppDpCounter` — Darkness Points display per `gm-session.jsx`. Uses `--state-darkness` color and a pulsing dot when DP changes (motion reduces to static color shift).
- T-2.3.j `AppShipStatBlock` — ship-specific stat tile (hull, armor, signature, EP, maneuverability, acceleration). Per `ship-sheet.jsx`.
- T-2.3.k `AppCrewRow` — crew assignment row: avatar + name + assigned role dropdown.
- T-2.3.l `AppNpcCard` — NPC library card: name, tags, condensed stats, action menu.
- T-2.3.m `AppRollHistoryItem` — single row in the roll history list: timestamp, label, pool, hits, pushed indicator.

---

## Feature 2.4 — Vue behavior-wrapping (DESIGN §11.4) — Nuxt UI inside, AppXxx outside

**Tasks** (each wraps the named Nuxt UI primitive — that wrapper is the *only* place the Nuxt UI symbol is imported in the entire monorepo):
- T-2.4.a `AppModal` (over `UModal`) — used for confirm dialogs, dice roller on small screens, and any focus-trapped overlay.
- T-2.4.b `AppSlideover` (over `USlideover`) — used for wizard steps on narrow viewports and the GM combat side panel.
- T-2.4.c `AppDropdown` (over `UDropdownMenu`) — used for combatant action menu and avatar menu.
- T-2.4.d `AppPopover` (over `UPopover`) — used for inline edit popovers on stats.
- T-2.4.e `AppCommandPalette` (over `UCommandPalette`) — used for quick-jump within the app (cmd+K).
- T-2.4.f `AppTable` (over `UTable`) — used for inventory list and roll history.
- T-2.4.g `AppCalendar` (over `UCalendar`) — used for session date pickers.

**Story 2.4.1** — As a reviewer, I can grep the entire `apps/web` tree for `from '#components'` Nuxt UI imports and find zero hits — every use goes through an `AppXxx` wrapper.

**Tasks:**
- T-2.4.1.a Add an ESLint rule (or a CI grep step) to fail on `import { U[A-Z]` from `#components` outside `packages/ui/src/components/App<Name>/`.

---

## Feature 2.5 — Flutter mirror library (`app_ui`)

**Story 2.5.1** — As a Flutter developer, every Vue component listed in §2.1–§2.3 has a matching widget under `packages/ui_flutter/lib/src/widgets/<name>/` with widget tests.

**Tasks:**
- T-2.5.1.a Foundation widgets mirroring §2.1 (AppButton/Badge/Chip/Input/Switch/Progress/Icon/Card/Avatar/Banner/Tab/Tooltip/Kbd/Dots/Divider/SegControl). Reference `tokens.g.dart` for all values.
- T-2.5.1.b Coriolis-specific widgets mirroring §2.2 (IconCoriolis/Die/DiePool/ConditionPill/StarOrnament/ArabesqueCorner).
- T-2.5.1.c Compositions mirroring §2.3 (PageHero/EmptyState/Skeleton/StatBlock/SheetHeader/CombatRow/DiceRoller/ShareViewer/DpCounter/ShipStatBlock/CrewRow/NpcCard/RollHistoryItem).
- T-2.5.1.d Each widget has at least one widget test covering rendering + variant logic. Run `flutter test` clean.

---

# EPIC 3 — Backend Foundation: Empty-Sheet CRUD (Phase 1, ~3 weeks, parallel with Epic 2)

**Goal:** Stand up the spec-first character CRUD path end-to-end. The character at this point is a flat record with name + a few attributes — full sheet detail comes in Epic 5.

**Exit criteria:** A logged-in user can `POST /api/v1/characters`, `GET` it back, `PATCH` it, and `DELETE` it. The request/response shapes are spec-validated. Both the web client (via `@app/api-client-ts`) and the mobile client (via `app_api_client`) compile and call the endpoints successfully.

---

## Feature 3.1 — OpenAPI character contract

**Story 3.1.1** — As a developer, the OpenAPI spec defines `/characters` CRUD with the v1 character DTO, validates clean, and codegens TS + Dart clients with no drift.

**Tasks:**
- T-3.1.1.a Edit `packages/specs/openapi/openapi.yaml`: add `Character`, `CharacterCreate`, `CharacterUpdate` schemas; the discriminated `Item` union (per PRD §5.3, with `oneOf` + `discriminator: type` covering WEAPON/ARMOR/GEAR/CYBERNETIC/SHIP_MODULE/OTHER); `Talent`, `Relationship`, `ConditionFlags`, `CriticalInjury` schemas.
- T-3.1.1.b Add paths: `GET /characters` (list, paginated), `POST /characters`, `GET /characters/{id}`, `PATCH /characters/{id}`, `DELETE /characters/{id}`, `POST /characters/{id}/duplicate`, `GET /characters/{id}/export`.
- T-3.1.1.c Add nested item/talent paths from PRD §9: `POST /characters/{id}/items`, `PATCH /items/{id}`, `DELETE /items/{id}`, and the talent equivalents.
- T-3.1.1.d All error responses use `application/problem+json` per RFC 9457. Add the shared `ProblemDetails` schema.
- T-3.1.1.e Run `pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen`. Commit the generated TS and Dart clients in a separate codegen-only commit.

---

## Feature 3.2 — NestJS CharactersModule (CQRS)

**Story 3.2.1** — As a player, when I `POST /api/v1/characters` with a name, the server creates a character owned by my user and returns the canonical Character DTO with derived stats already populated.

**Tasks:**
- T-3.2.1.a Scaffold `apps/backend/src/modules/characters/` with `commands/`, `queries/`, `events/`, controller, module file. Wire into `AppModule`.
- T-3.2.1.b Implement commands: `CreateCharacterCommand`, `UpdateCharacterCommand`, `DeleteCharacterCommand` (soft delete? — PRD says cascade-delete on user grace expiry, but character delete is hard delete; confirm in implementation), `DuplicateCharacterCommand`. Each is a class + handler.
- T-3.2.1.c Implement queries: `GetCharacterQuery`, `ListCharactersQuery` (paginated, owner-scoped), `ExportCharacterQuery`.
- T-3.2.1.d Implement event: `CharacterUpdatedEvent` — published whenever a character is mutated. Handler will later publish to Centrifugo `character.<id>.private` channel (added in Epic 7).
- T-3.2.1.e Controller: thin, dispatches through `CommandBus`/`QueryBus`. Decorated with `@UseGuards(BetterAuthBearerGuard)` (provided by the boilerplate's `AuthModule`).
- T-3.2.1.f Authorization: every query/command checks `ownerId === currentUser.id` and throws RFC 9457 403 if not. Add a `CharacterOwnershipGuard` for parameterized routes.

**Story 3.2.2** — As a player, my character's `hpMax`, `mpMax`, and `encumbranceLimit` are computed server-side and present in every Character response.

**Tasks:**
- T-3.2.2.a Create `apps/backend/src/modules/rules-engine/rules-engine.module.ts` with pure functions: `computeHpMax(strength, agility)`, `computeMpMax(wits, empathy)`, `computeEncumbrance(items)`, `canPush(character, lastRoll)`. Per PRD §5.2 and §10.
- T-3.2.2.b Add unit tests for every formula at the boundary (min/max attribute values, empty inventory, conditions effect, exhausted cap on push).
- T-3.2.2.c In the Character read mapper, decorate the entity with the computed fields before returning.
- T-3.2.2.d Validate writes server-side: reject any payload that tries to set `hpMax`/`mpMax`/`encumbranceLimit` directly — they are read-only derived fields in the spec.

---

## Feature 3.3 — Web sheet skeleton

**Story 3.3.1** — As a player, I can navigate to `/app/characters`, see my list, click "New", get a blank character, and edit `name` (no other fields yet) with auto-save.

**Tasks:**
- T-3.3.1.a Add page `apps/web/app/pages/app/characters/index.vue` — calls `apiClient.characters.list()`, renders `AppEmptyState` when empty or a grid of `AppCard`s otherwise.
- T-3.3.1.b Add page `apps/web/app/pages/app/characters/[id].vue` — calls `apiClient.characters.get(id)`, renders `AppSheetHeader` with name editable inline. Wire `AppInput` debounced auto-save (500ms) → `apiClient.characters.patch(id, { name })`.
- T-3.3.1.c Add page `apps/web/app/pages/app/characters/new.vue` — minimal "name + create" form for now. The full wizard arrives in Epic 5.
- T-3.3.1.d Add an auth guard middleware that redirects unauthenticated visits to `/auth/sign-in`.
- T-3.3.1.e i18n: every label keyed in en + ru.

---

## Feature 3.4 — Mobile sheet skeleton

**Story 3.4.1** — As a player, I can open the Flutter app, sign in (already wired), and see a Characters list feature that mirrors §3.3.

**Tasks:**
- T-3.4.1.a Scaffold `apps/mobile/lib/features/characters/{domain,data,presentation}/`. The data layer uses the generated `app_api_client`; presentation uses `flutter_bloc`.
- T-3.4.1.b `CharactersListCubit` — emits states for `loading`, `empty`, `loaded(List<CharacterSummary>)`, `error`. Page renders via `app_ui`'s widgets.
- T-3.4.1.c `CharacterSheetCubit` — loads a character, debounces local edits (500ms), calls patch.
- T-3.4.1.d Add routes to `apps/mobile/lib/core/router/`.
- T-3.4.1.e Widget tests for cubit happy paths and the rendering of the sheet skeleton page.

---

# EPIC 4 — Auth Vertical Extensions (Phase 1, ~½ week, slots in alongside Epic 3)

**Goal:** Round out the boilerplate's auth vertical with the v1-specific deltas (display name, account deletion, verification email copy).

**Exit criteria:** A user can update their display name, delete their account (soft-delete with 30-day grace), and the verification email reads in Coriolis voice in en + ru.

---

## Feature 4.1 — Display name & profile

**Story 4.1.1** — As a user, I can set and update my display name, and it shows in the share-link banner and the avatar menu.

**Tasks:**
- T-4.1.1.a Spec: add `GET/PATCH /api/v1/me` to `openapi.yaml`. The `Me` schema includes `id`, `email`, `displayName`, `createdAt`. Codegen.
- T-4.1.1.b Backend: implement `UsersModule` with `MeQuery` and `UpdateMeCommand`. Reads from / writes to the Better-Auth-owned `user` row via Prisma (writes only the additional fields like `displayName`, never the BA-managed columns).
- T-4.1.1.c Web: add `/app/settings` page that loads `me` and edits `displayName`.
- T-4.1.1.d Mobile: add `Settings` feature page mirroring §4.1.1.c.

---

## Feature 4.2 — Account deletion (soft-delete + grace)

**Story 4.2.1** — As a user, I can delete my account; sessions revoke immediately, characters/ships persist for 30 days then cascade-delete.

**Tasks:**
- T-4.2.1.a Spec: add `DELETE /api/v1/me`. Codegen.
- T-4.2.1.b Backend: implement `DeleteMeCommand` — sets `deletedAt = now()` on the user row, revokes all Better Auth sessions for the user (call BA's revocation API), and schedules a cascade-delete job 30 days out.
- T-4.2.1.c Backend: add a daily cron job (`@nestjs/schedule`) that hard-deletes users whose `deletedAt < now - 30d`. Cascades through Prisma to characters, ships, etc.
- T-4.2.1.d Web + mobile: settings has a "Delete account" path with double-confirm modal. Localized.
- T-4.2.1.e Tests: command-level test for deletion + revocation; integration test for the cron job using a test clock.

---

## Feature 4.3 — Email & error copy in Coriolis voice

**Story 4.3.1** — As a new user, the verification email and password-reset email read in the Coriolis voice in en + ru.

**Tasks:**
- T-4.3.1.a Email templates in `apps/backend/src/mailer/templates/` — verification + reset, both locales. Voice: warm, slightly ceremonial, no Star-Trek tech-speak.
- T-4.3.1.b RFC 9457 problem-detail `title`/`detail` are English-canonical (per PRD NFR §6 errors); localized client-side via i18n keyed off `type`.
- T-4.3.1.c Add the `MailerPort` mock implementation for dev (boilerplate-provided) and the Resend/Postmark adapter behind a feature flag in `AppConfig`.

---

# EPIC 5 — Full Character Sheet (Phase 2, ~4 weeks)

**Goal:** Ship the full character sheet — every field, derived stats, conditions, inventory, talents, auto-save, and the creation wizard.

**Exit criteria:** A player can create a character through the 6-step wizard, fill in every field on `sheet-desktop.jsx`, and watch derived stats update live as they edit attributes. Conditions toggle with a 1-tap pill. Inventory adds/edits/removes items of every type. Auto-save round-trips ≤500ms p95. Cyrillic strings reviewed by a native speaker. Mobile sheet (§sheet-mobile.jsx) works at 375×812.

---

## Feature 5.1 — Attributes & skills section

**Story 5.1.1** — As a player, I can edit Strength, Agility, Wits, Empathy on the desktop sheet and watch HP max + MP max update live; I can also edit all general and advanced skills inline.

**Tasks:**
- T-5.1.1.a Spec: extend `Character` schema in OpenAPI with attribute fields (1–5 ints), `skills` JSON object (general 0–5, advanced 0–3), `derivedStats` read-only object. Codegen.
- T-5.1.1.b Backend: extend `UpdateCharacterCommand` validation to enforce attribute and skill bounds. Reject out-of-range with RFC 9457 422.
- T-5.1.1.c Web: build attribute and skill panels of `sheet-desktop.jsx` (center column) using `AppStatBlock` + `AppDots`. Inline-edit popover via `AppPopover`. Optimistic UI with rollback on error.
- T-5.1.1.d Web mobile breakpoint: stacked layout per `sheet-mobile.jsx` with skill rows.
- T-5.1.1.e Mobile (Flutter): mirror via `app_ui.AppStatBlock`.
- T-5.1.1.f i18n: every skill name keyed (note: `sheet-mobile.jsx` already shows the Russian labels).

---

## Feature 5.2 — Talents

**Story 5.2.1** — As a player, I can add free-form talents (`name`, `description`, optional `iconAffinity`), edit, and remove them.

**Tasks:**
- T-5.2.1.a Spec: add talent paths from §3.1.1.c (already in spec from Epic 3). Confirm they're wired.
- T-5.2.1.b Backend: implement `AddTalentCommand`, `UpdateTalentCommand`, `RemoveTalentCommand`.
- T-5.2.1.c Web: Talents tab on the sheet renders a list of `AppCard` items with edit affordances. "Add talent" CTA opens an `AppModal` with the form.
- T-5.2.1.d Mobile: same flow with `app_ui` widgets.
- T-5.2.1.e i18n.

---

## Feature 5.3 — Conditions & critical injuries

**Story 5.3.1** — As a player, I can toggle Exhausted/Sleepless/Thirsty/Hungry on a single tap; I can add free-form critical injury entries.

**Tasks:**
- T-5.3.1.a Web sheet: render four `AppConditionPill`s in the left column. Tap toggles via `PATCH /characters/:id` with optimistic UI.
- T-5.3.1.b Web sheet: critical injuries list with add/remove. Free-form text entries.
- T-5.3.1.c Mobile: condition strip in the sticky header per `sheet-mobile.jsx`.
- T-5.3.1.d Backend rules engine: condition toggles affect dice-roll pools (−1 die per active condition, capped at the character's pool). Add `applyConditions(character, basePool)` to `RulesEngineModule`.

---

## Feature 5.4 — Inventory & gear

**Story 5.4.1** — As a player, I can add weapons / armor / gear / cybernetics / ship modules / "other" items to my character; type-specific fields render correctly per the discriminated union.

**Tasks:**
- T-5.4.1.a Web: Gear tab uses `AppTable` (over `UTable`) for the inventory list. "Add item" opens an `AppModal` with a type selector that swaps the form fields per type.
- T-5.4.1.b Web: equipped-only quick view in the right column of `sheet-desktop.jsx`.
- T-5.4.1.c Backend: `AddItemCommand`, `UpdateItemCommand`, `RemoveItemCommand`. Validate the discriminated union shape matches the declared `type`.
- T-5.4.1.d Encumbrance UI warning when over limit (PRD §5.3 — "warn, do not block").
- T-5.4.1.e Mobile: simplified inventory list with type-specific item editor pages.

---

## Feature 5.5 — Auto-save & save-state indicator

**Story 5.5.1** — As a player, every edit auto-saves with a visible single brass-dot pulse; the round-trip is ≤500ms p95.

**Tasks:**
- T-5.5.1.a Web: extract the debounced-save logic into a `useAutoSave(entity, patcher)` composable. Used by every editable surface.
- T-5.5.1.b Save-state indicator: `AppSavePulse` micro-component (1-line story, dot pulse animation) inside the sheet header. Reduced-motion variant: brass dot fades in/out instead of pulsing.
- T-5.5.1.c Mobile: equivalent BLoC + widget.
- T-5.5.1.d Add a Vitest perf test that mocks the API and asserts auto-save round-trip stays within 500ms over 100 sequential edits in test conditions.

---

## Feature 5.6 — Character creation wizard

**Story 5.6.1** — As a new player, I can go through a 6-step wizard (Concept → People & Background → Icon → Attributes → Skills → Talents → Gear → Relationships per PRD epic B, condensed visually to 6 steps in DESIGN §7.3) and end up with a complete character.

Note: PRD B lists 8 conceptual steps; DESIGN §7.3 says "Six steps". `wizard-icon.jsx` shows multi-step UI. Treat the canon as 8 steps with shared screens for fast steps; the JSX progression is canon for visual styling and exact step grouping.

**Tasks:**
- T-5.6.1.a Page route `/app/characters/new` becomes a multi-step flow. Step state persists to a draft record server-side so reload resumes mid-wizard.
- T-5.6.1.b Spec: add `POST /api/v1/characters/draft` and `PATCH /api/v1/characters/draft/:id`, with a `Character` record having a `status: 'draft' | 'active'`. Or use existing characters with a draft flag — choose one and document the choice in an ADR.
- T-5.6.1.c Implement each step using `AppCard`, `AppSegControl`, the icon-grid pattern from `wizard-icon.jsx`, and `AppProgress` for the bar in `--brand-brass`.
- T-5.6.1.d Icon step (`wizard-icon.jsx`): 3×3 grid of Icons. Selecting one pulses with teal aura. Reduced-motion variant: instant color change, no pulse.
- T-5.6.1.e Final "Forge character" button transitions draft → active and lands on the new character's sheet.
- T-5.6.1.f Mobile: same flow as a series of `Slideover`-shaped pages.
- T-5.6.1.g Cyrillic review: have a native Russian speaker (or LLM proofreader at minimum) walk every wizard string. Document outcome in `done.md` for this feature.

---

# EPIC 6 — Sharing & Polish (Phase 3, ~2 weeks)

**Goal:** Public read-only share links, Open Graph image route, mobile pass on the whole sheet, and a top-to-bottom accessibility audit.

**Exit criteria:** A player can generate a share link, send it to a GM, and the GM (signed in or not) can view the read-only sheet. The link's preview in Discord/Twitter renders the OG image. Storybook a11y panel green for every component. Lighthouse on the share viewer ≥ 90 across all four scores.

---

## Feature 6.1 — Share-link backend

**Story 6.1.1** — As a player, I can `POST /api/v1/characters/:id/share` and get back a `ShareLink` with a 24-char slug; the same character's existing links are listed via `GET /api/v1/characters/:id/shares`; I can revoke any link.

**Tasks:**
- T-6.1.1.a Spec: add `ShareLink` schema, the share creation/list/revoke paths, the public read paths (`GET /api/v1/public/character/:slug`, `GET /api/v1/public/ship/:slug`), and the OG image paths. Public paths have no auth requirement. Codegen.
- T-6.1.1.b Backend: `SharingModule`. Slug generation uses `nanoid` length 24, alphabet excluding ambiguous chars. Lookup by unique slug. Revocation sets `revokedAt`; revoked links return 410 Gone.
- T-6.1.1.c Backend: `lastViewedAt`/`viewCount` updated lazily on read (one update per view, can batch via background job to avoid hot-path writes).
- T-6.1.1.d `includeGmNotes` flag controls whether `notes` field flagged "gm-only" is filtered server-side before responding (PRD §5.4).
- T-6.1.1.e Integration tests for the read path with revoked / expired / valid slugs.

---

## Feature 6.2 — Public read-only viewer (web)

**Story 6.2.1** — As an anonymous viewer, opening a share URL shows me a parchment-chrome read-only sheet with the disclaimer banner.

**Tasks:**
- T-6.2.1.a Add page `apps/web/app/pages/shared/character/[slug].vue` — fetches the public payload, renders an `AppShareViewer` composition that wraps the same sheet primitives in light theme.
- T-6.2.1.b Add page `apps/web/app/pages/shared/ship/[slug].vue` — same pattern.
- T-6.2.1.c Set dynamic `<meta property="og:image">` client-side pointing to `/api/v1/public/og/character/:slug.png`, and `og:title` / `og:description` from the payload. Bots see the OG image regardless (PRD §5.4).
- T-6.2.1.d No edit affordances rendered at all — not disabled, *absent*. Verify by snapshot test.
- T-6.2.1.e Lighthouse on the share page: target ≥ 90 across all scores. Optimize fonts (subset), images, and JS bundle for this route.

---

## Feature 6.3 — Open Graph image route

**Story 6.3.1** — As a sharer, when I paste my character link into Discord, the unfurl shows a 1200×630 brass-on-indigo card with the character's name and Icon glyph.

**Tasks:**
- T-6.3.1.a Pick the rendering tool: Satori + Resvg (Node) or Puppeteer headless Chrome. Recommend Satori for cold-start speed and predictable output.
- T-6.3.1.b Implement `GET /api/v1/public/og/character/:slug.png` in the `SharingModule`. The renderer reads the character + Icon glyph and produces a PNG.
- T-6.3.1.c Implement `GET /api/v1/public/og/ship/:slug.png`.
- T-6.3.1.d Cache headers: `Cache-Control: public, max-age=3600, stale-while-revalidate=86400`. Invalidation on character update is OK to be eventual.
- T-6.3.1.e Snapshot tests for OG output (write the PNG to disk and assert dimensions + non-empty pixel sum).

---

## Feature 6.4 — Mobile pass

**Story 6.4.1** — As a player using the Flutter app at the table, the entire sheet experience matches `sheet-mobile.jsx` — sticky header, condition strip, tab bar at the bottom, all stats reachable.

**Tasks:**
- T-6.4.1.a Audit every page in `apps/mobile/lib/features/characters/presentation/` against `sheet-mobile.jsx`. Fix gaps.
- T-6.4.1.b Confirm the Cyrillic strings render in Forum/Inter/JetBrains Mono (font subsets loaded for `ru`).
- T-6.4.1.c Test on a real mid-range Android (or emulator) — cold start ≤ 2.0s per PRD NFR §6.

---

## Feature 6.5 — Accessibility audit

**Story 6.5.1** — As a screen-reader user, every interactive element on the sheet, dice roller, combat tracker (when shipped), and wizard is reachable, labeled, and announces state changes.

**Tasks:**
- T-6.5.1.a Run Storybook's `addon-a11y` for every `@app/ui` story. Fix every violation. Block merges on this from now on.
- T-6.5.1.b Manual screen-reader pass with VoiceOver (macOS Safari) and NVDA (Windows Firefox) on: landing, sign-in, dashboard, character sheet, wizard, share viewer.
- T-6.5.1.c Verify contrast: PRD requires 4.5:1. Run `axe-core` on the rendered pages. Fix any < 4.5:1.
- T-6.5.1.d Add the high-contrast theme toggle in settings. Persist via `PATCH /api/v1/me`.
- T-6.5.1.e Reduced-motion variants confirmed for all motion-bearing components (AppCombatRow, AppDiceRoller, AppDpCounter, AppSavePulse, the wizard Icon-pulse).

---

# EPIC 7 — Dice & Sessions (Phase 4, ~2 weeks)

**Goal:** Ship the dice roller (web + mobile), the push mechanic, the `GameSession` container, Darkness Points, and the Centrifugo channel that broadcasts DP changes to subscribed clients in real time.

**Exit criteria:** A player can roll dice from any auth screen, push a roll, and the GM's session view reflects the +1 DP within 500ms over Centrifugo. The roll history is persisted server-side.

---

## Feature 7.1 — Dice roller UX (web + mobile)

**Story 7.1.1** — As a player, I can open the dice roller from any auth screen, set a pool size, label the roll, see results with hits highlighted, and push if appropriate.

**Tasks:**
- T-7.1.1.a Spec: add `POST /characters/:id/rolls` (creates a Roll), `PATCH /rolls/:id/push` (triggers reroll of non-6s and DP increment). Add `Roll` schema. Codegen.
- T-7.1.1.b Backend: `DiceModule` with `CreateRollCommand`, `PushRollCommand`. PushRollCommand uses `RulesEngine.canPush()`, performs the reroll, persists, and emits a `RollPushedEvent` with the `gameSessionId` (if any) so the realtime layer can rebroadcast.
- T-7.1.1.c Web: `AppDiceRoller` is mounted as a floating panel anchored bottom-right (DESIGN §6.4 + `dice-roller.jsx`). Wired via a global Pinia store / `useDiceRoller()` composable.
- T-7.1.1.d Mobile: `AppDiceRoller` widget surfaces as a bottom sheet via Flutter's `showModalBottomSheet`, mirroring the web design.
- T-7.1.1.e Roll history (last 50 per character) — query and render in a `Notes`-adjacent panel on the sheet, using `AppRollHistoryItem`.

---

## Feature 7.2 — GameSession container

**Story 7.2.1** — As a GM, I can create a `GameSession`, add player characters and an optional ship, and archive it when the campaign ends.

**Tasks:**
- T-7.2.1.a Spec: add `GameSession` schema and CRUD paths (`GET/POST /api/v1/game-sessions`, `GET/PATCH /api/v1/game-sessions/:id`). Naming is **always** `GameSession` to avoid collision with Better Auth's `Session`. Codegen.
- T-7.2.1.b Backend: `GameSessionsModule` with CRUD commands/queries. Owner-scoped.
- T-7.2.1.c Web: `/app/game-sessions` list and `/app/game-sessions/:id` overview matching `gm-session.jsx`. Tab strip Overview / Encounters / Crew (encounters tab is empty for now — populated in Epic 9).
- T-7.2.1.d Mobile: feature scaffold under `lib/features/game_sessions/`.

---

## Feature 7.3 — Darkness Points + push wiring

**Story 7.3.1** — As a player, when I push a roll while linked to a `GameSession`, that session's DP increments by 1. As a GM, I can spend DP with a reason text logged to session history.

**Tasks:**
- T-7.3.1.a Spec: `POST /api/v1/game-sessions/:id/dp` body `{ delta: number, reason?: string }`. Codegen.
- T-7.3.1.b Backend: `UpdateDpCommand` increments/decrements on `GameSession`, persists `DpEvent` row. Validates: only the GM (owner) may apply negative deltas; positive deltas come from the push pipeline.
- T-7.3.1.c Wire `RollPushedEvent` → the events handler issues a `+1` `UpdateDpCommand` against the linked session.
- T-7.3.1.d Web GM view: `AppDpCounter` matches `gm-session.jsx` styling.

---

## Feature 7.4 — Centrifugo realtime DP channel

**Story 7.4.1** — As a player viewing a GM's session screen, I see the DP counter increment within 500ms of a push, with no polling.

**Tasks:**
- T-7.4.1.a Spec: edit `packages/specs/asyncapi/centrifugo.yaml`. Add channel `session.<gameSessionId>` with payloads `dp.changed`, `encounter.updated`, `combatant.updated`, `roll.pushed`. Run `pnpm spec:codegen` — channel constants land in `packages/api-client-ts/src/realtime/channels.ts` and the Dart equivalent.
- T-7.4.1.b Backend: `RealtimeModule` exposing `POST /api/v1/realtime/token` returning a Centrifugo JWT scoped only to channels the user is authorized to subscribe to. ACL checks: GM owns session ⇒ session channel; user owns character ⇒ private character channel.
- T-7.4.1.c Backend: every `DpEvent` insert publishes `dp.changed` to `session.<id>` with the latest counter value.
- T-7.4.1.d Web: Centrifugo client wired in a Pinia store; subscribes/unsubscribes per route. The `AppDpCounter` reactively reflects channel updates.
- T-7.4.1.e Mobile: Centrifugo client in `core/realtime/`. Same subscribe pattern.
- T-7.4.1.f Integration test: spin Centrifugo, push a roll via API, assert subscriber receives `dp.changed` within 500ms.

---

# EPIC 8 — Ships (Phase 5, ~2 weeks)

**Goal:** Ship sheets at parity-with-character fidelity: CRUD, sheet UI, crew assignment, ship sharing.

**Exit criteria:** A player can create a ship, fill out hull/armor/signature/EP/etc., add modules and weapons, assign crew (their own characters), and share the ship via a public link.

---

## Feature 8.1 — Ship CRUD

**Tasks:**
- T-8.1.a Spec: `Ship`, `ShipModule`, `ShipWeapon`, `ShipProblem` schemas; CRUD paths. Codegen.
- T-8.1.b Backend: `ShipsModule` with CQRS analog of `CharactersModule`. Owner-scoped.
- T-8.1.c Web: `/app/ships`, `/app/ships/:id`. Sheet matches `ship-sheet.jsx`.
- T-8.1.d Mobile: `lib/features/ships/`.

## Feature 8.2 — Crew assignment

**Tasks:**
- T-8.2.a Spec: `POST /api/v1/ships/:id/crew`, `DELETE /api/v1/ships/:id/crew/:characterId`. The `CrewAssignment` includes a `role` enum: Captain, Pilot, Sensor Op, Gunner, Engineer, Service Crew. Codegen.
- T-8.2.b Backend: `AssignCrewCommand`, `UnassignCrewCommand`. Validate that the assigned character belongs to the same user.
- T-8.2.c Web: `AppCrewRow` populates the Crew tab on the ship sheet.

## Feature 8.3 — Ship sharing

**Tasks:**
- T-8.3.a Reuse `SharingModule` — add a `shipId` branch to share-link generation. (Spec already covered in §6.1.1.a.)
- T-8.3.b `/shared/ship/:slug` page in web. OG image variant.

---

# EPIC 9 — GM Tools (Phase 6, ~3 weeks)

**Goal:** Combat tracker (desktop-shaped), NPC library, and the realtime combatant updates that broadcast over the session channel. Mobile is the read-along card.

**Exit criteria:** A GM can run a full encounter from the tracker — build initiative, advance turns, apply damage, end the encounter, and the players' phones reflect changes within 500ms.

---

## Feature 9.1 — Combat tracker (desktop)

**Story 9.1.1** — As a GM, I can build initiative for an encounter from the linked PCs and ad-hoc NPCs, advance turns, apply damage / heal / conditions to any combatant, and end the encounter.

**Tasks:**
- T-9.1.1.a Spec: `Encounter`, `Combatant` schemas; `POST /api/v1/game-sessions/:id/encounters`, `PATCH /api/v1/encounters/:id`. Codegen.
- T-9.1.1.b Backend: `CombatModule`. Commands: `CreateEncounter`, `UpdateCombatant`, `AdvanceTurn`, `EndEncounter`. Each emits an event consumed by the realtime publisher.
- T-9.1.1.c Web: `/app/game-sessions/:id/combat` matches `combat-tracker.jsx`. Header: session name, round counter, DP counter. Body: stack of `AppCombatRow` instances. Bottom toolbar: Next turn / End round / End encounter.
- T-9.1.1.d Keyboard shortcuts: `n` next turn, `r` end round, `d` damage focused. `?` overlay listing them. Per DESIGN §10.
- T-9.1.1.e Reduced-motion: row damage flash replaced with static color shift.

## Feature 9.2 — Combat tracker (mobile read-along)

**Story 9.2.1** — As a player at the table, I see one combatant card at a time on my phone, can swipe prev/next, and can press "push" to send +1 DP.

**Tasks:**
- T-9.2.1.a Mobile combat page: subscribes to the `session.<id>` channel, renders the active combatant card.
- T-9.2.1.b Push button hits the dice roller flow with the active session linked.

## Feature 9.3 — NPC library

**Tasks:**
- T-9.3.a Spec: `Npc` schema, CRUD paths. Codegen.
- T-9.3.b Backend: `NpcsModule`. Owner-scoped (GM-private).
- T-9.3.c Web: `/app/npcs` page with `AppTable` of NPCs, tag filter, search. NPC editor uses a simplified subset of the character form.
- T-9.3.d Mobile: list-only view (NPCs aren't created on mobile in v1).

## Feature 9.4 — Realtime combatant updates

**Tasks:**
- T-9.4.a Backend: every combatant write publishes `combatant.updated` to `session.<id>`.
- T-9.4.b Web GM tracker: optimistic local edits, reconciled on echoed channel event.
- T-9.4.c Web/mobile player views: subscribe and re-render on each event.
- T-9.4.d Latency test: assert end-to-end < 500ms.

---

# EPIC 10 — Hardening & Beta (Phase 7, ~2 weeks)

**Goal:** Offline support on both clients, JSON export from settings, performance tuning, beta release.

**Exit criteria:** A player who loses connectivity at the table can still view their sheet and queue edits that sync on reconnect. The user can export all their characters and ships from settings. Lighthouse mobile-3G TTI ≤ 2.5s on the SPA. Mobile cold start ≤ 2.0s. Beta tag pushed to the deploy environment.

---

## Feature 10.1 — Offline (web)

**Tasks:**
- T-10.1.a Service worker via Workbox: cache `app shell` + last-loaded character payloads. Stale-while-revalidate for read paths.
- T-10.1.b Edit queue: when offline, write through to IndexedDB; on reconnect, replay PATCHes against the API in order. Conflict policy: server wins, surface a toast on rejection.
- T-10.1.c Visual indicator: `AppBanner` "Offline — edits will sync when you reconnect."

## Feature 10.2 — Offline (mobile)

**Tasks:**
- T-10.2.a SQLite via Drift (or `sqflite`): local cache of character/ship rows. Repository pattern bridges cache + remote.
- T-10.2.b Edit queue identical contract to web.

## Feature 10.3 — JSON export

**Tasks:**
- T-10.3.a Spec: `GET /api/v1/me/export` returns an application/json bundle with all characters + ships + game sessions owned by the user. Codegen.
- T-10.3.b Backend: `ExportMeQuery`. Stream the JSON for memory safety on large accounts.
- T-10.3.c Web settings: "Export my data" downloads the file.

## Feature 10.4 — Performance tuning

**Tasks:**
- T-10.4.a Lighthouse pass on mobile-3G profile for: landing, dashboard, character sheet, share viewer, dice roller. Target TTI ≤ 2.5s. Fix images, font subsets, JS chunk sizes.
- T-10.4.b Backend: hot-path query review (`GET /characters`, `GET /game-sessions/:id`). Add indexes per Prisma migration. Cache JWKS per the `CommonModule`. Confirm `express-openapi-validator` not regex-blowing-up on large payloads.
- T-10.4.c Mobile cold-start profile via Flutter DevTools. Target ≤ 2.0s on a mid-range Android.

## Feature 10.5 — Beta release

**Tasks:**
- T-10.5.a CI release workflow: tag-on-merge to `main` produces a versioned API + web build. Mobile is a manual `flutter build` step in v1 (no store submission).
- T-10.5.b Hosting: Vercel/Netlify for the SPA, Railway/Fly/VPS for API + Postgres + Redis + Centrifugo. Daily DB backups.
- T-10.5.c Sentry projects (web, mobile, backend) live with `beforeSend` PII scrubbing per PRD NFR §6 privacy.
- T-10.5.d Grafana dashboards: p95 latency, error rate, DP-event volume per session. Alerts: 5xx > 1% over 5m, p95 latency > 1s over 5m.
- T-10.5.e `done.md` entries for every feature with PR links. README updated with "Beta" badge.

---

# Cross-cutting CI checklist (every PR)

Run before requesting review:

```bash
pnpm spec:validate
pnpm spec:codegen        # commit any drift in a separate codegen-only commit
pnpm design:build
pnpm design:audit
pnpm check:i18n
pnpm lint                # includes Stylelint
pnpm typecheck
pnpm test                # backend + ui + web
pnpm storybook:build     # a11y addon clean
```

Mobile separately:

```bash
cd apps/mobile && flutter test && flutter analyze
```

If any of the following fail, the PR is blocked at review:

- Hex literal in a `.vue` or `.scss` file (Stylelint).
- A new `@app/ui` component without `*.stories.ts` + `*.spec.ts` + entry in `specs/design/README.md`.
- A `Nuxt UI` (`U*`) symbol imported outside `packages/ui/src/components/App<Name>/`.
- A user-visible string not keyed in en + ru.
- An OpenAPI drift commit mixed with implementation in the same commit.
- Backend reading `process.env.X` directly instead of via `AppConfig`.
- A direct edit to `tokens.generated.css`, `design-tokens.generated.ts`, or `tokens.g.dart`.
- A direct edit to a Better-Auth-managed table outside the BA `additionalFields` config.

---

# Recommended execution order for Claude Code

1. **Epic 1** end-to-end — establishes the foundation everything else depends on.
2. **Epic 2 (UI library) and Epic 3 (backend CRUD) in parallel** — they share no files and unblock Epic 5.
3. **Epic 4 (auth deltas)** — small, slot it in alongside Epic 3 (a few days work).
4. **Epic 5** — biggest chunk. Sub-features 5.1 → 5.6 in order; the wizard last because it depends on every editable surface working.
5. **Epic 6** — sharing + a11y polish. Run a real screen-reader audit, not just axe.
6. **Epic 7** — dice + sessions + Centrifugo. The first realtime work; expect a learning curve.
7. **Epic 8** — ships. Mostly a copy of the character pattern with different fields.
8. **Epic 9** — GM tools. Combat tracker is the largest single screen in the app.
9. **Epic 10** — hardening. Don't skip the Lighthouse passes; PRD targets are explicit.

Single-engineer steady pace: ~19 weeks. Two engineers (one backend-leaning, one frontend-leaning sharing the generated clients): ~12 weeks.

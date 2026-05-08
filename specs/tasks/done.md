# Done tasks

_Archive of shipped tasks. Never delete entries — cancelled tasks go here with reason._

## Mobile sheet skeleton (Epic 3.4)

- Completed: 2026-05-08
- Owner: claude (flutter-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 3.4, T-3.4.1.a–e
- Result: merged at `df5194b`. Four commits: domain layer + repository (`2cd0fc1`), CharactersListCubit + list page (`82649ce`), CharacterSheetCubit + detail page (`c25e0c3`), creation page + routing + DI + i18n (`a159931`).
- Mirror of Epic 3.3 web skeleton on Flutter. Feature-first layering under `apps/mobile/lib/features/characters/{domain,data,presentation}/`. `flutter_bloc` cubits with 500ms debounce auto-save. New `characters` slang namespace (en/ru populated; uk/el `[xx-todo]`). `auth_gate.dart` updated to gate the route surface.
- Note from agent: hand-written stub `apps/mobile/lib/i18n/strings.g.dart` is gitignored; CI/build env regenerates via `dart run slang` (project SDK 3.8 vs. local 3.5 — agent used a SDK-constraint workaround for analyze-only verification).

## Foundation tail — AppTooltip + AppKbd + AppSegControl

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2 Feature 2.1 (T-2.1.1.l + .m + .p)
- Result: merged at `f3a799a`. Six commits — one component + one specs/stories per primitive plus a final barrel update.
- AppTooltip: hover/focus + ESC-dismiss; native `useId()`, `aria-describedby`. No edge-flip in v1; consumer responsible for placement. AppKbd: semantic `<kbd>` element(s) with mono typography. AppSegControl: `role="radiogroup"` with roving focus and arrow-key navigation between segments.
- 558 vitest specs pass total (60+ new across the three).
- Note: agent root-cause fixed initial test failures: the components had HTML comments outside the root element making `@vue/test-utils` see multiple roots; comments moved inside the root.

## Codegen — DELETE /api/v1/me

- Completed: 2026-05-08
- Owner: claude (main thread)
- Result: merged at `75a213a`. New `deleteMe` operation in TS sdk and Dart `UsersApi`. info.version 0.5.1 reflected.

## DELETE /api/v1/me spec (Epic 4.2.a)

- Completed: 2026-05-08
- Owner: claude (spec-writer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 4.2, T-4.2.1.a
- Result: merged at `12c6b43`. Single new operation under `users` tag; 204 idempotent (no 404 on already-deleted); 401 problem+json. info.version 0.5.0 → 0.5.1.
- Open questions for the backend implementer (T-4.2.1.b-c) — captured in the agent's report:
  - Cron anchor: 30-day window from exact `deletedAt` timestamp (recommended) vs start-of-calendar-day.
  - Cascade ordering: single-transaction `deleteMany` on Character (Cascade FKs handle children) vs explicit ordered cascade with Centrifugo / share-slug invalidation hooks.

## Flutter foundation widgets (Epic 2.5 — partial: 12 of 20)

- Completed: 2026-05-08
- Owner: claude (flutter-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2 Feature 2.5, T-2.5.1.a
- Result: merged at `cc012c0`. Four commits batched by primitive cluster: `f9637f6` (Button/Badge/Chip), `cf52b8b` (Input/Switch/Progress), `7462813` (Card/Label/Field/Divider/Dots), `78c0dbf` (Avatar + barrel + app_ui export).
- Widgets shipped (12): `AppButton`, `AppBadge`, `AppChip`, `AppInput`, `AppSwitch`, `AppProgress`, `AppCard`, `AppLabel`, `AppField`, `AppDivider`, `AppDots`, `AppAvatar`. All token-driven via `tokens.g.dart` — no hex literals, no Material `Colors.foo`. 44×44 tap targets via `ConstrainedBox` wrapper. AnimatedContainer transitions use `AppEasing.standard` + `AppDuration.fast`/`dDefault`.
- Deferred (8 next milestone): AppIcon, AppTab, AppBanner, AppTooltip, AppKbd, AppSegControl, AppSelect, AppTextarea — they have Flutter idioms (TabBar / SnackBar / Tooltip / DropdownButton) needing separate consideration.
- Verified: `flutter analyze lib/` clean, `flutter test test/widgets/` 91/91 pass.
- Dependency note: image loading uses `Image.network` with `errorBuilder` fallback rather than `cached_network_image` (no new dep). Cyrillic-safe initials via `String.runes.first`.

## AppDie + AppConditionPill (Epic 2.2.b + 2.2.d)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent — second attempt; first hit a Bash permissions block)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2 Feature 2.2 — first two Coriolis-specific primitives.
- Result: merged at `489604f` (committed directly to main due to worktree-isolation slip; work fully verified).
- AppDie: 100×100 SVG viewBox with absolute pip coordinates; canonical d6 face layouts; states `normal`/`hit`/`pushed`/`failed`; `hit` uses an SVG `<filter>` (feGaussianBlur + feFlood) tinted with `var(--state-mystic-teal)` plus a stroke overlay for the brass ring; sm/md/lg sizes (24/32/48 px).
- AppConditionPill: `<button aria-pressed>` for the four PRD §5 conditions (exhausted/sleepless/thirsty/hungry); per-condition Lucide icons (battery-low/moon/droplet/apple); active state filled mystic-teal with `--shadow-icon-glow`; default capitalized fallback when no slot.
- 498/498 vitest specs pass across 19 files.

## Spec tech-debt — extract named oneOf variants for Item + ShipModule

- Completed: 2026-05-08
- Owner: claude (spec-writer agent + main-thread codegen)
- Result: spec merged at `e12f2b5`, codegen merged at `fbfcd41`. info.version 0.4.0 → 0.5.0.
- 22 new named schemas: 12 for Item (ItemWeaponCreate/Update, ItemArmorCreate/Update, ItemGearCreate/Update, ItemCyberneticCreate/Update, ItemShipModuleCreate/Update, ItemOtherCreate/Update); 10 for ShipModule (ShipModuleWeaponCreate/Update, ShipModuleTorpedoCreate/Update, ShipModuleHoldCreate/Update, ShipModuleSensorCreate/Update, ShipModuleOtherCreate/Update). Discriminator `mapping` blocks added.
- Codegen output now uses intent-revealing class names. The previous dart-dio orphans (`ItemCreateOneOf{,1..5}.dart`, `Model0{,1..5}.dart`, `ShipModuleCreateOneOf{,1..4}.dart`, `Model0{2..42}.dart`) are removed in the same codegen commit.
- Wire format unchanged — only client class names differ.
- Two pre-existing path examples (`PATCH /items/{id}`, `PATCH /ship-modules/{id}`) were missing the discriminator field; fixed to keep validation clean.

## Codegen — /api/v1/ships

- Completed: 2026-05-08
- Owner: claude (main thread; codegen-runner agent hit a permissions block)
- Result: merged at `75a6ee8`. 113 files / +14K lines. New ShipsApi (TS + Dart), Ship/ShipCreate/ShipUpdate/ShipList types, discriminated ShipModule union, CrewSlot, six new enums.
- Note: dart-dio still emits `ShipModuleCreateOneOf{,1..4}` and `Model0{2..42}` duplicate names for the inline `oneOf` discriminator branches (same pattern as Items). When a ShipsModule backend is dispatched (Phase 5), follow up with a spec PR to extract `ShipModuleWeaponCreate`/`ShipModuleTorpedoCreate`/etc. as named schemas.

## AppTab Coriolis primitive (Epic 2.1.k)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Result: merged at `5508b02`. `<button role="tab">` with `aria-selected` per ARIA-1.2; underline-on-active via `::after` pseudo. 27 vitest specs, 10 stories. Brass + mystic tones, sm/md sizes.

## AppBanner Coriolis primitive (Epic 2.1.j)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Result: merged at `f0914c7`. Inline notice panel with 5 tones (info/success/warning/danger/parchment), default-icon-per-tone via AppIcon, optional dismiss + actions slot. `role="alert"` for danger, `role="status"` otherwise. 32 vitest specs. Parchment variant verified WCAG AAA contrast (text-ink #1A1810 on surface-parchment #F2E8D0 ≈ 12.5:1).

## Web settings page (Epic 4.1.c)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Result: merged at `ee9b8d9`. New `/app/settings` route, behind the existing `/app/**` auth guard.
- `apps/web/app/composables/useMeApi.ts` — CRUD wrapper around `getMe`/`updateMe`. Throws RFC 9457 `Problem` on error.
- `apps/web/app/pages/app/settings.vue` — four `AppCard` panels: Profile (avatar + displayName editable + email/createdAt read-only with debounced auto-save mirroring the sheet header), Locale (`AppSelect` for en/ru/uk/el; uk/el labeled `[uk-todo]`/`[el-todo]`), Theme (`AppSwitch` for high-contrast persisted to `localStorage('coriolis.theme')` — server-side persistence pending Phase 2), Account (delete button visibly disabled with help text referencing T-4.2.1).
- 78 i18n keys × 4 locales clean. Stylelint clean.

## T-2026-05-08-022 — Ships OpenAPI surface (Epic 5 / Feature 8.1+8.2)

- Created/Completed: 2026-05-08
- Owner: claude (spec-writer agent)
- Spec: docs/PRD.md §6 + ST3001 ГЛАВА 7
- Result: merged at `dbc3e58`. info.version 0.3.0 → 0.4.0. New `ships` tag with 12 operations (listShips, createShip, getShip, updateShip, deleteShip, duplicateShip, exportShip, addShipModule, updateShipModule, deleteShipModule, assignCrew, unassignCrew). 13 new schemas including discriminated `ShipModule` union. Six enums (ShipClass=20 hull types, ShipModuleSlot=21, ShipWeaponRange=5, CrewPosition=6).
- Open questions / divergences from PRD captured in commit body: `signature` field naming kept English while ГЛАВА 7 uses "Заметность"; `energyPoints` modeled as `{current, max}` per ГЛАВА 7 reactor mechanics (PRD silent); added `cargoCapacity` aggregate for class-derived hold sizing.
- Codegen pending — separate `chore(codegen): regenerate clients for /api/v1/ships` task.

## T-2026-05-08-020 — Add AppAvatar primitive

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.i
- Result: merged at `17c4257`. Image variant with lazy loading + initials fallback on `@error`. 5 sizes (xs/sm/md/lg/xl), 4 tones (brass/mystic/crimson/darkness), 2 shapes (circle/squircle). Cyrillic-safe initials algorithm. Visually-hidden full-name span for screen readers. 16+ specs.

## T-2026-05-08-019 — AppTextarea primitive

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2 Feature 2.1
- Result: merged at `580132e`. Multi-line counterpart to AppInput; mirrored prop shape (size/disabled/readonly/invalid/placeholder/inputId/maxlength + `rows`). 14 vitest specs. Note: `autosize` prop accepts the BEM modifier but content-grow behavior is deferred — TODO comment in component for `field-sizing: content` + JS recompute polyfill.

## T-2026-05-08-021 — Web sheet skeleton (Epic 3.3)

- Created: 2026-05-08
- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 3.3 Feature 3.3.1 (T-3.3.1.a–e)
- Branch: feat/phase-1/web-sheet-skeleton
- Result: 4 commits on branch, ready for PR.
  - `auth-required.global.ts` — global middleware guards `/app/**`; redirects to `/login?redirect=…`
  - `useCharactersApi.ts` — character CRUD composable wrapping `@app/api-client-ts` SDK
  - `useDebounceFn.ts` — minimal local debounce composable (no @vueuse/core dependency)
  - `pages/app/characters/index.vue` — grid + skeleton + empty + error states, en/ru/uk/el i18n
  - `pages/app/characters/new.vue` — name form, inline validation, POST → redirect
  - `pages/app/characters/[id].vue` — header with initials avatar + editable name/concept, 500ms debounced auto-save, saving/saved/error indicator, native `<dialog>` delete confirmation, body placeholder for Epic 5

## T-2026-05-08-018 — build AppSelect primitive

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2 Feature 2.1
- Result: merged at `88e27d8`. Native `<select>` styled to Coriolis chrome with chevron, sm/md/lg sizes, disabled/invalid states, options via prop with placeholder support, 28 vitest specs.

## T-2026-05-08-017 — AppField primitive

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: IMPLEMENTATION_PLAN.md Epic 2 Feature 2.1
- Result: merged at `44488bf`. Form-row composer using Vue 3.5 `useId()` for auto-id, scoped slot exposing `slotAttrs` with `id` + `aria-describedby` + `aria-invalid`, error replaces help, role="alert" on error span. 26 specs, 11 stories.

## T-2026-05-08-016 — implement AppLabel primitive

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2 Feature 2.1
- Result: merged at `9160271`. `<label for>` or `<span>` based on `for` prop. Tones default/eyebrow/stat-block. Required marker with `aria-label="required"`. helpText support. 21 specs, 11 stories.

## T-2026-05-08-015 — Add rules-engine module and wire derived stats into CharactersModule

- Created/Completed: 2026-05-08
- Owner: claude (backend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 3.2 Story 3.2.2, T-3.2.2.a..d
- Result: merged at `c423dc2` — three commits `1f6a869` (module), `a0578dc` (wire into character.repo.ts), `c423dc2` (specs).
- Formulas (PRD §5.2): `hpMax = STR + AGI`, `mpMax = WIT + EMP`, `encumbranceMax = STR × 2`, `encumbranceCurrent = sum(item.weight)`, `canPush(conditions, alreadyPushed) = !exhausted && !alreadyPushed`.
- ReadOnlyFieldError (422 `READ_ONLY_FIELD`) added to UpdateCharacterHandler — rejects PATCH bodies that try to set `hp.max`, `mp.max`, `encumbrance.max`, or `encumbrance.current`. Defence-in-depth alongside spec's `readOnly: true` declarations.
- 39 new specs (33 rules-engine + 6 ReadOnlyFieldError); 144/144 backend tests pass.

## T-2026-05-08-014 — Build AppProgress Coriolis primitive

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.f
- Result: merged at `f230d4c` (`chore(ui): register`); preceded by `00a47f2` (component+stories+spec) and `b68ffa3` (task entry).
- Linear-only — circular variant deferred. 5 tones, 3 sizes, role="progressbar" with full aria-value attrs. 36 vitest specs.
- Notes: circular variant deferred; wizard-icon.jsx and sheet-desktop.jsx need only the linear bar.

## T-2026-05-08-013 — Implement AppChip Coriolis primitive

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md §Epic 2.1.c
- Result: merged at `d64d72b` (`docs(design)`); preceded by `fcf03d6` (component) and `644d667` (task entry).
- `<button type="button">` with `aria-pressed`. Five Coriolis variants × 2 sizes. Toggleable `update:modelValue` + optional `removable` with `remove` event. 28 vitest specs.

## T-2026-05-08-012 — AppSwitch Coriolis primitive

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md §Epic 2.1.e
- Result: merged at `940d115` — three commits `9fb6b2b` (task) + `1bdba04` (component) + `940d115` (specs+stories).
- `<button role="switch">` with `aria-checked`. Brass-on-night track, brass-light thumb. Slot wins over `label` prop when both present. 19 specs, 11 stories.

## T-2026-05-08-011 — Implement CharactersModule backend (Epic 3.2 Story 3.2.1)

- Created/Completed: 2026-05-08
- Owner: claude (backend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 3.2 Story 3.2.1
- Result: merged at `64db2d0` — three commits `d94d8fe` (Prisma schema) + `8ab5452` (CharactersModule + nested ItemsModule and TalentsModule) + `64db2d0` (105 handler specs).
- Files: 57 files, +3873 lines. Full Coriolis domain (Character, Item, Talent, Relationship, CriticalInjury) Prisma models with cascade-delete on character delete. CQRS layout under `apps/backend/src/modules/characters/` with sub-modules for `items/` and `talents/`. Ownership guards on every parameterized route. JSON columns for attributes/skills/conditions/item.data per design judgement. 105 vitest specs across 20 files, all green.
- Notes: derived stats (hp.max/mp.max/encumbrance.max) returned as placeholders 14/10/5 with `TODO(rules-engine, T-3.2.2)` comments. Encumbrance current = 0 placeholder pending rules-engine. Item.type stored as enum + `data: Json` column for the discriminated union (alternative to 6-table-per-type schema; documented in module).

## T-2026-05-08-010 — Add AppDivider primitive to @app/ui

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.o
- Result: merged at `02e3ecb` (`docs(design)`); preceded by `834bc21` (specs+stories) and `fbfdb99` (component rewrite).
- Variants: `horizontal` (`<hr>`) / `vertical` (`<div role="separator" aria-orientation="vertical">`); tone `brass-deep`/`brass-shadow`/`brass`; weight `hairline`/`thin`/`medium` via SCSS variables; optional `inset` margin.

## T-2026-05-08-009 — Add AppDots primitive to @app/ui

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.n
- Result: merged at `9c19faa` (`docs(design)`); preceded by `6d2732e` (component+stories+spec) and `de126f7` (task entry).
- Markup: `<div role="meter">` with `aria-valuenow`/`aria-valuemin`/`aria-valuemax` per DESIGN §10. Props: `value`, `max=5`, `size sm/md/lg`, `tone brass/mystic/crimson/darkness`, optional `label`. `value` clamped silently.
- Tests: 22 vitest specs, 222/222 pass.

## T-2026-05-08-008 — Implement AppIcon Coriolis primitive (Epic 2.1.g)

- Created/Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md §2.1.g, docs/DESIGN.md §4.3
- Result: merged at `1a5b299` (`docs(design)`); preceded by `8edd14c` (component) and `b70441f` (lucide-vue-next dep + task entry).
- Dependency: `lucide-vue-next@0.511.0` added to `packages/ui/package.json`.
- Strategy: static `import * as lucideIcons from 'lucide-vue-next'` + runtime PascalCase lookup; unknown names → `console.warn` + empty `<span>` (no crash).
- Props: `name`, `size xs/sm/md/lg/xl`, `color brass/mystic/crimson/success/darkness/inherit`, `strokeWidth=1.5`. Default `aria-hidden="true"` unless consumer passes `aria-label`.
- Tests: 8 specs, all pass; 258/258 total in @app/ui.

## T-2026-05-08-007 — Codegen follow-up for /api/v1/characters

- Created/Completed: 2026-05-08
- Owner: claude (codegen-runner agent)
- Spec: post-merge of T-006 (691e9de). `pnpm spec:bundle && pnpm spec:codegen` against info.version 0.3.0.
- Result: merged at `d2f1751`. 141 files, +15750 / −70.
- TS: 13 new operations in sdk.gen.ts, +1383 lines in types.gen.ts, openapi-types.ts +1528 lines.
- Dart: new `CharactersApi` class (40K), 36 new model classes, 46 doc files + 46 stub tests, serializers updated.
- **Open lint: dart-dio generated `ItemCreateOneOf{,1..5}` AND `Model{0..5}` duplicate type names** for the inline `oneOf` discriminator branches the spec-writer used. Backend can use these names; if the mobile app finds them confusing, a follow-up spec PR can extract `ItemWeaponCreate`/`ItemArmorCreate`/etc. as named schemas.

## T-2026-05-08-006 — Add /api/v1/characters CRUD + nested items/talents to OpenAPI spec

- Created: 2026-05-08
- Completed: 2026-05-08
- Owner: claude (spec-writer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 3.1, T-3.1.1.a..d
- Result: merged at `691e9de`. info.version bumped 0.2.0 → 0.3.0.
- Goal: Define the full character API surface in OpenAPI so backend and generated clients have an unambiguous contract to implement against.
- Acceptance — all met:
  - [x] `pnpm spec:validate` green (Redocly + AsyncAPI)
  - [x] 13 new operations under `characters` tag (listCharacters, createCharacter, getCharacter, updateCharacter, deleteCharacter, duplicateCharacter, exportCharacter, addCharacterItem, updateItem, deleteItem, addCharacterTalent, updateTalent, deleteTalent)
  - [x] ~15 new schemas (Character + Create/Update, CharacterList, IconId, Attributes, Skills, ConditionFlags, CriticalInjury, Talent + Create/Update, Relationship, ItemBase + 6 type variants + Item discriminated union + ItemCreate/Update)
  - [x] RFC 9457 problem+json on every 4xx with named codes
  - [x] info.version is 0.3.0
- Open questions raised by the agent (deferred):
  - **ItemRangeEnum naming** — used `arm/near/short/long/distant` per the task brief; PRD §5.3 lists "Engaged/Short/Medium/Long/Extreme". Worth aligning before backend lands the wire validation.
  - **Skill max** — set to 5 uniformly; PRD §5.2 says "0–3 typical for advanced skills". Backend can layer a soft warning.
  - **Reputation / birr** fields — not in Character DTO; PRD §5.2 mentions them. Add in Epic 5 (full sheet).
  - **Relationship.kind** — task brief enumerated `ally/rival/family/mentor/debtor/creditor`; PRD §5.2 leaves it free-text. Followed task brief.

## T-2026-05-08-005 — build AppBadge Coriolis primitive

- Created: 2026-05-08
- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md §Feature 2.1 T-2.1.1.b
- Result: merged at `bc50700` (docs); preceded by `36844a5` (specs + stories) and `92bde7e` (component rewrite).
- Goal: Replace the boilerplate AppBadge with a native Coriolis-token badge chip covering 5 state-color variants and 2 sizes, with story + spec.
- Acceptance — all met:
  - [x] `pnpm --filter @app/ui typecheck` green
  - [x] `pnpm --filter @app/ui test` 181 specs pass (11 new AppBadge)
  - [x] `pnpm stylelint "packages/ui/src/components/AppBadge/**/*.{vue,scss,css}"` green
  - [x] AppBadge row in `specs/design/README.md`
  - [x] 10 variant × size stories + WithIcon + LongLabel + InlineWithText + AllVariants
- Variants: `brass` (default), `mystic`, `crimson`, `success`, `darkness` × `sm` / `md`. `<span>` root, decorative `tabindex="-1"`.

## T-2026-05-08-004 — Replace AppInput with Coriolis-token implementation

- Created: 2026-05-08
- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2.1.d; docs/DESIGN.md §11.1
- Result: merged at `4b0f644` (docs); preceded by `cf2817a` (specs + stories) and `c35d0fe` (component rewrite).
- Goal: Deliver a fully-styled AppInput primitive that uses Coriolis design tokens, matching the cor-input / cor-input--invalid contract from primitives.jsx.
- Acceptance — all met:
  - [x] `pnpm --filter @app/ui typecheck` green
  - [x] `pnpm --filter @app/ui test` 199 specs pass (30 new AppInput)
  - [x] `pnpm stylelint` green for AppInput files
  - [x] 13 stories covering variant × size matrix + states + types
  - [x] AppInput row in `specs/design/README.md`
- Note: `inputmode` prop typed as explicit union literal rather than `HTMLInputElement['inputMode']` to avoid vue-tsc TS2322 widening to `string`.

## T-2026-05-08-003 — UsersModule backend (T-4.1.1.b)

- Created: 2026-05-08
- Completed: 2026-05-08
- Owner: claude (backend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md T-4.1.1.b
- Result: PR #8 — merged. Branch `feat/phase-1/me-endpoint-backend`; final tip `995264e` (`feat(backend): UsersModule with GetMeQuery and UpdateMeCommand handlers`); preceded by `82bb772` (Prisma schema + Better Auth additionalFields).
- Goal: Implement `UsersModule` under `apps/backend/src/modules/users/` with CQRS layout. Add `displayName` and `deletedAt` to Prisma `User` model, wire `additionalFields` in Better Auth config, expose `GET /api/v1/me` and `PATCH /api/v1/me` per the OpenAPI spec.
- Acceptance — all met:
  - [x] `pnpm --filter @app/backend prisma:generate` exits 0; client picks up `displayName` + `deletedAt`
  - [x] `pnpm --filter @app/backend typecheck` exits 0
  - [x] `pnpm --filter @app/backend test` 10 files / 44 tests pass (4 GetMeHandler + 10 UpdateMeHandler new)
- Sub-steps:
  - [x] Push entry to active.md
  - [x] Add `displayName` and `deletedAt` to schema.prisma
  - [x] Wire `additionalFields` in Better Auth config
  - [x] Create domain/{ports,errors}, queries/get-me.{query,handler}, commands/update-me.{command,handler}, infra/user.repo, users.controller, users.module
  - [x] Register UsersModule in app.module.ts
  - [x] Write handler spec files
  - [x] Verify prisma:generate + typecheck + test green

## T-2026-05-08-002 — implement AppCard Coriolis primitive

- Created: 2026-05-08
- Completed: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.h
- Result: PR #6 — merged at `b50b80f` (`docs(design): list AppCard in @app/ui component inventory`); preceded by `5beaabe` (specs + stories) and `c6dfee2` (component rewrite).
- Goal: Replace the boilerplate AppCard with a Coriolis-token-driven component (default / featured variants, optional header/footer slots, `as` polymorphic prop) that passes typecheck, Vitest, and Stylelint.
- Acceptance — all met:
  - [x] `pnpm --filter @app/ui typecheck` (vue-tsc) exits 0
  - [x] `pnpm --filter @app/ui test` (vitest, 185 tests) exits 0
  - [x] `pnpm stylelint "packages/ui/src/components/AppCard/**/*.{vue,scss,css}"` exits 0
  - [x] AppCard row appears in `specs/design/README.md` component inventory
- Sub-steps:
  - [x] Push task entry to active.md
  - [x] Rewrite AppCard.vue with Coriolis tokens (default + featured variants, header/footer slots, `as` prop)
  - [x] Write AppCard.stories.ts with 8 stories (Default, Featured, WithHeader, WithFooter, WithHeaderAndFooter, BodyWithLongText, Polymorphic, AllVariants)
  - [x] Write AppCard.spec.ts with full coverage (13 specs)
  - [x] Update specs/design/README.md component inventory
  - [x] Verify typecheck + test + stylelint green

## T-2026-05-08-001 — implement AppButton Coriolis primitive

- Created: 2026-05-08
- Completed: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.a
- Result: PR #3 — merged at `2708ce2` (`docs(design): list AppButton in @app/ui component inventory`); preceded by `1466dba` (specs + stories) and `127a157` (component rewrite).
- Goal: Replace the boilerplate AppButton with a Coriolis-token-driven component (primary / ghost / danger variants, sm / md / lg sizes) that passes typecheck, Vitest, and Stylelint.
- Acceptance — all met:
  - [x] `pnpm --filter @app/ui typecheck` (vue-tsc) exits 0
  - [x] `pnpm --filter @app/ui test` (vitest, 186 tests) exits 0
  - [x] `pnpm stylelint "packages/ui/**/*.{vue,scss,css}"` exits 0 for AppButton files
  - [x] AppButton row appears in `specs/design/README.md` component inventory
- Sub-steps:
  - [x] Push task entry to active.md
  - [x] Rewrite AppButton.vue with Coriolis tokens
  - [x] Rewrite AppButton.stories.ts with variant/size matrix (14 stories)
  - [x] Rewrite AppButton.spec.ts with full coverage (18 specs)
  - [x] Update specs/design/README.md component inventory
  - [x] Verify typecheck + test + stylelint green

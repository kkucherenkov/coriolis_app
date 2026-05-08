# Done tasks

_Archive of shipped tasks. Never delete entries — cancelled tasks go here with reason._

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

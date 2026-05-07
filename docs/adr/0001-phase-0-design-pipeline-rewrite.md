# 0001 — Phase 0 design pipeline rewrite, deferred component restyle

- **Status:** accepted
- **Date:** 2026-05-07
- **Deciders:** @kirill, @claude
- **Tags:** frontend, design-system, phase-0

## Context

The boilerplate (`claude-driven-nest-nuxt-flutter-monorepo`) ships a generic
multi-theme design pipeline (`packages/design-tokens/src/{types,load,emit-*}.ts`)
keyed on `light/dark/sepia/forest` themes, `brand/surface/border/text/status/vertical`
color groups, a typography role layer that references `font.size/leading/tracking`
slots, and z-index embedded inside `motion.json`. The boilerplate also ships 11
foundation `@app/ui` Vue components (`AppButton`, `AppInput`, `AppCard`, etc.)
that consume that schema via `--surface-bg`, `--brand-accent`, `--text-fg`,
`--font-sans`, `--text-xs`, `--dur-fast`, `--ease-default`, `--border-default`,
`--surface-bg-{subtle,muted}`, `--brand-accent-{hover,active,soft,fg}`.

The Coriolis design language ([`docs/DESIGN.md`](../DESIGN.md) §2/§3) is
fundamentally different:

- **Dark-first**, with a single `[data-theme='high-contrast']` override (and
  a parchment-mode share viewer planned for Phase 3); no light/sepia/forest.
- Color groups are `surface/brand/text/state` (not `border/status/vertical`).
  Borders are derived from `--brand-brass-*` and opacity, not their own token
  group.
- Typography composites are `--type-{display-xl,display-lg,display-md,display-sm,
  body-lg,body-md,body-sm,mono-stat-xl,mono-stat-md}` decomposed to their CSS
  properties (DESIGN §3.2). The role-via-slot indirection used by the
  boilerplate doesn't carry the composite naming the JSX mockups already
  assume.
- The default duration emits as bare `--motion-duration` (so consumers can
  write `transition: var(--motion-duration)` for the common path), with
  `--motion-duration-{fast,slow,ceremony}` for the rest.
- z-index is its own first-class file (`z-index.json`).

`specs/design/mockups/tokens.jsx` (the canonical visual contract per
[`AGENTS.md`](../../AGENTS.md) "JSX wins") authors against the Coriolis token
names, not the boilerplate ones.

## Decision

**Rewrite the design-tokens pipeline** (`types.ts` / `load.ts` /
`emit-{scss,typescript,dart}.ts`) end-to-end to Coriolis's dark-first schema
in Phase 0, and **defer the rewrite of the 11 boilerplate `@app/ui`
components** to Phase 1's UI Foundation Library epic
([`IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md) Epic 2 — Feature 2.1,
T-2.1.1.a through T-2.1.1.p).

Phase 0 ships the new pipeline, the regenerated Coriolis `tokens.g.dart`, a
minimal `default.vue` layout that uses Coriolis tokens directly, and the
Tailwind-v4 `@theme inline` mapping in `apps/web/app/assets/css/main.css`
and `packages/ui/src/styles.css`. Phase 1 reskins the foundation primitives
(and `apps/web/app/pages/login.vue`) against the new tokens as part of the
broader sheet skeleton work.

## Consequences

### Positive

- The design pipeline is one-to-one with `docs/DESIGN.md` and
  `specs/design/mockups/tokens.jsx`. No translation layer, no compat
  aliases, no debt that has to be argued away on every PR.
- The Phase 0 landing page (the only user-facing surface in Phase 0) renders
  with Coriolis chrome — wordmark, brass header rule, fan-project disclaimer
  — using `--surface-void`, `--brand-brass-shadow`, `--type-display-sm-*`,
  etc. directly. No detour through legacy tokens.
- Phase 1's component rewrite is a clean replacement, not a token migration
  inside a broken transition state. Each component arrives with its
  `*.stories.ts` / `*.spec.ts` already targeting the canonical tokens.

### Negative

- The 11 boilerplate `@app/ui` components and `apps/web/app/pages/login.vue`
  reference token names that no longer exist (`--surface-bg`, `--brand-accent`,
  `--text-fg`, `--font-sans`, `--text-xs`, `--dur-fast`, `--ease-default`,
  `--border-default`). They render **unstyled** (CSS custom properties
  resolve to their `unset` fallbacks) until Phase 1's Feature 2.1 lands.
- Storybook stories for those components are visually broken in the same
  window. `*.spec.ts` continues to pass — those tests cover component logic,
  not rendered colors.
- The login route (`/login`) is reachable but presents an unstyled form.
  Phase 0 is "Adoption" per [`PRD.md`](../PRD.md) §11; the login UX rewrite
  is bundled into Phase 1's auth-vertical extensions
  ([`IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md) Epic 4).

### Neutral

- `tokens.g.dart` ships the new Coriolis Dart classes (`AppColors`,
  `AppColorsHighContrast`, `AppTypography`, `AppZIndex`, `AppEasing`,
  `AppShadows` with inset BoxShadow parts dropped — Flutter has no inset
  mode). The Flutter app does not yet consume them; the Phase 1 mobile
  Foundation widgets work (T-2.5.1.a in IMPLEMENTATION_PLAN.md) is where
  they get used.
- The web/ui CSS+TS mirrors stay gitignored per `.gitignore` policy; only
  the Flutter Dart artefact is committed.

## Alternatives considered

### Option A — Restructure Coriolis JSON to fit the boilerplate emitter

For each color, invent `light` / `dark` themed values to satisfy the
boilerplate's `ThemedLeaf` shape; rename `state` → `status`; populate empty
`border`/`vertical`/`lift` sections; flatten composite typography into
`role.{name}` referencing slots. **Rejected:** Coriolis is dark-first by
design (DESIGN §2). Inventing parchment-light values for `--surface-void`
that no mockup specifies is design work the engineering branch shouldn't
make up unilaterally; "what's the light-mode equivalent of the void?" is a
product question, not a token question.

### Option B — Backward-compat alias layer

Have the new emitter output Coriolis tokens **plus** a block of aliases
(`--surface-bg: var(--surface-void)`, `--brand-accent: var(--brand-brass)`,
…) so existing components keep rendering. **Rejected:** the global
`CLAUDE.md` instructions and `AGENTS.md` non-negotiables disallow
backwards-compat shims (`# Don't add backwards-compatibility hacks`). The
alias block would be ~40 lines of debt, easy to lean on, hard to remove
without tracking every consumer. The unstyled boilerplate components are a
*more visible* signal that Phase 1's foundation work is the next step.

### Option C — Adapter loader

Keep the boilerplate emitters; write a `coriolis-adapter.ts` that maps
Coriolis-shaped JSON into the boilerplate's expected shape before emit.
**Rejected:** indirection without payoff. Renaming/redesigning
boilerplate-emitted CSS custom property names (e.g. `--brand-accent` →
`--brand-brass`) requires touching the emitter anyway, and the adapter adds
a parallel translation table that rots faster than the emitter itself.

### Option D — Full Phase 0 rewrite (also reskin the boilerplate components)

Reskin all 11 boilerplate components and `login.vue` against the new tokens
as part of Phase 0. **Rejected:** Phase 1 is already scoped to do exactly
this work
([`IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md) Epic 2 — Feature 2.1,
~3 weeks). Pulling it forward into Phase 0 collapses the phase boundary,
delays the `phase-0-complete` tag, and contradicts the "по фичам и фазам"
principle the project has been operating under (domain models, OpenAPI
endpoints, copy — all added in the phase that needs them).

## Related

- [`docs/DESIGN.md`](../DESIGN.md) §2 (token inventory) and §3 (typography).
- [`docs/IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md) Epic 2 (UI
  Foundation Library), Feature 2.1 — task list T-2.1.1.a..p.
- [`specs/design/mockups/tokens.jsx`](../../specs/design/mockups/tokens.jsx)
  — canonical token visual contract.
- [`specs/design/README.md`](../../specs/design/README.md) — token
  inventory (regenerated for Coriolis).
- Branch commits:
  - `83d731e` feat(design-tokens): rewrite pipeline for Coriolis dark-first design
  - `adc58df` chore(design-tokens): regenerate Flutter artifact and drop orphan TS stub
  - `c0930d0` feat(phase-0): apply Coriolis tokens to web layout and design README
  - `94c5814` feat(phase-0): align @app/ui storybook CSS with Coriolis tokens

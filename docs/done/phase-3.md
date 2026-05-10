# Phase 3 — Sharing & Polish

**Phase:** 3
**Tag:** `phase-3-complete`
**PRD section:** §11 (roadmap)
**Date:** 2026-05-09

## What shipped

A character owner can now share a sheet via a slug-addressable URL,
read by anyone (authenticated or not), with an OG image rendered
server-side for link previews. Phase 2 left a wizard-driven sheet that
required a session for every read; Phase 3 cracks that open behind an
explicit, revocable share-link mechanism — and uses the round trip to
clean up the rest of the polish backlog from PRD §11. The
high-contrast toggle now persists server-side via `Me.theme`,
reduced-motion fallbacks were audited across `@app/ui`, the Flutter
sheet got a layout pass with a bottom tab bar, and `flutter analyze`
came back clean. Thirty-five commits across backend, web, mobile,
specs, codegen, ADR, and bookkeeping.

A character owner can:

- Create a share link via `POST /api/v1/characters/{id}/shares` —
  returns a 24-character `nanoid` slug from a 56-symbol unambiguous
  alphabet (no `0/O/I/l/1`), with optional `expiresAt`,
  `includeGmNotes`, and `label`.
- List active links (`GET …/shares`) and revoke any of them
  (`DELETE …/shares/{id}`) — soft-deleted via `revokedAt`, never
  removed; revoked slugs respond `410 Gone` so the caller can
  distinguish "never existed" from "existed and was revoked".
- Watch a per-link view counter and `lastViewedAt` populated by the
  in-memory `ViewTracker` flushed by a one-minute cron (no DB write
  on the read path).
- Toggle high-contrast in the user menu and have the choice
  persisted via `PATCH /api/v1/me` — the localStorage-only state
  from Phase 2 is gone.

Anyone with a share URL can:

- Open `/shared/character/{slug}` and see the read-only sheet via
  the new `AppShareViewer` composition; OG meta tags resolve to the
  server-rendered PNG so Slack / Discord / Telegram previews work.
- Hit `GET /api/v1/public/og/character/{slug}.png` directly — a
  `satori` + `@resvg/resvg-js` pipeline renders the character card
  template to PNG without a browser.
- See the same flow stubbed for ships at `/shared/ship/{slug}`
  (placeholder; ship sharing returns in Phase 5).

The Flutter app got the sheet polish that Phase 2 deferred: a
bottom-tab navigation, private-class extractions per the
`MOBILE_AUDIT.md` plan, and a Flutter 3.41 SDK compat sweep that
brought `flutter analyze` to zero errors.

## What landed (by feature group)

### Flutter 3.41 SDK compatibility (carried from Phase 2 tail)

Mobile built against Flutter 3.41 strictness before Phase 3 work
started so the rest of the phase had a green analyzer baseline.

- `31a54d3` — fix(flutter): Flutter 3.41 SDK compatibility

### ADR-0003 — share-link design

Four open design questions resolved before the spec edit: slug
strategy, revocation, view tracking, multi-link policy.

- `cadfbbc` — docs(adr): 0003 — share-link design

### Share-link backend (Epic 6 Feature 6.1)

Spec, Prisma migration, generated clients, and the `SharingModule`
(slug + create + list + revoke + public read paths). The 501-stubbed
OG route lands in 6.3.

- `59a0d92` — feat(specs): ShareLink + share endpoints + public read paths (v0.7.0)
- `fc5643d` — chore(codegen): regenerate clients after share-link spec (v0.7.0)
- `f01c16a` — feat(backend): Prisma ShareLink migration
- `f11cd55` — feat(backend): SharingModule — slug + create + list + revoke
- `6ab7519` — chore(backend): apply lint --fix auto-corrections from ESLint run
- `f450098` — docs(tasks): bookkeep Epic 6 Feature 6.1 (share-link backend)
- `6712c5d` — fix(backend): clear ESLint debt across modules
- `a537b77` — fix(backend): restore Json-field casts for Prisma create() typecheck

### Public read-only viewer — web (Epic 6 Feature 6.2)

The `usePublicSharingApi` composable, `AppShareViewer` read-only
composition, and the two `/shared/[slug]` SPA pages. Snapshot +
api-client tests cover the viewer.

- `7c61d67` — feat(web): usePublicSharingApi composable
- `a7ff434` — feat(web): AppShareViewer composition (read-only sheet)
- `cc0184c` — feat(web): /shared/character/[slug] page with OG meta
- `bf8bba0` — feat(web): /shared/ship/[slug] page placeholder
- `08f00f6` — test(web): share viewer snapshot + api specs
- `62cf903` — style(web): apply ESLint auto-fixes (vue formatting)
- `b1f53f8` — docs(tasks): bookkeep Epic 6 Feature 6.2 (public read-only viewer)

### OG image renderer — backend (Epic 6 Feature 6.3)

`satori` + `@resvg/resvg-js` + `react` deps, the renderer service
with the character template, and the route that replaces the 501
stub from Feature 6.1.

- `601a24c` — chore(backend): add satori + @resvg/resvg-js + react deps for OG renderer
- `bd7df16` — feat(backend): OG image renderer service + character template (T-6.3.x)
- `d247051` — feat(backend): GET /public/og/character/:slug.png replaces 501 stub
- `a6536eb` — docs(tasks): bookkeep Epic 6 Feature 6.3 (OG image renderer)

### Mobile pass — sheet polish (Epic 6 Feature 6.4)

Sheet vs sheet-mobile.jsx audit, then the bottom tab bar +
private-class extractions per the audit doc.

- `f38792e` — docs(mobile): MOBILE_AUDIT — sheet vs sheet-mobile.jsx audit (T-6.4.1)
- `63893e9` — feat(mobile): bottom tab bar + private-class extractions per MOBILE_AUDIT

### Theme persistence — `Me.theme` (Epic 6 Feature 6.5)

The high-contrast toggle moved from localStorage to a server-side
`User.theme` column. Spec → codegen → backend → web in the
spec-first order.

- `a2d1053` — feat(specs): add Me.theme dark|high-contrast (v0.7.1)
- `d084396` — chore(codegen): regenerate clients after Me.theme
- `eaf7f0c` — feat(backend): persist theme on User + Me query/update
- `2cb08fe` — feat(web): persist high-contrast toggle via PATCH /me
- `df5d9ee` — docs(tasks): bookkeep Epic 6 Features 6.4 + 6.5

### Accessibility audit + reduced-motion fallbacks

Page-level axe + screen-reader pass plan, and the
`prefers-reduced-motion` fallback audit across `@app/ui` with the
missing fixes.

- `1792682` — fix(ui): reduced-motion fallbacks audit + missing fixes
- `4e89d98` — docs(a11y): A11Y_AUDIT — page-level axe + SR pass plan

### Mobile analyzer cleanup tail

The api-client-dart wiring was structurally broken (outer vs. inner
generated package); fixing it turned a 166-error analyze into
0 errors and let the warning + info noise be cleaned in a single
follow-up.

- `d6c231d` — fix(mobile): repoint app_api_client at the inner generated package + repo_impl
- `916c66b` — chore(mobile): clear remaining flutter analyze info + warning
- `03e2c6c` — docs(tasks): bookkeep mobile flutter analyze cleanup (Phase 3 tail)

### Auto-format sweeps

Prettier + Stylelint + ESLint passes across web; no behaviour
changes.

- `dd7caa5` — chore: apply prettier + stylelint auto-format
- `cc86c2e` — style(web): apply ESLint auto-fixes (vue formatting, batch 2)

## Notable decisions

- **ADR-0003 — share-link design (slug + revocation + tracking +
  multi-link).** Four orthogonal choices made up-front so the
  Feature 6.1 spec edit was mechanical. (1) Slugs are
  `nanoid(24)` over a 56-symbol unambiguous alphabet — ~139 bits of
  entropy, safe to print and copy from physical media. (2)
  Revocation is soft-delete via `revokedAt: DateTime` so audit
  history survives; revoked / expired slugs respond `410 Gone` so
  callers can distinguish "never existed" from "existed and was
  revoked". (3) View tracking is an in-memory `Map<slug,
pendingCount>` flushed by a `* * * * *` cron in a single batched
  Prisma transaction — the read path does not hit the DB. (4)
  Multi-link per character is allowed (each with its own
  `includeGmNotes` / `expiresAt` / `label`), so audience-specific
  links don't force a revoke-and-recreate cycle that would destroy
  analytics history. (See `cadfbbc`.)
- **Public read paths off `SessionGuard`.** The `public` controller
  has no auth; `express-openapi-validator` enforces this via the
  spec — `GET /api/v1/public/character/{slug}` has no `security`
  block. Same pattern is reused for `…/og/character/{slug}.png`.
- **OG renderer is server-side, headless, no browser.** `satori`
  produces SVG from a React component, `@resvg/resvg-js` rasterises
  to PNG. No Puppeteer / Playwright in the runtime — the sharing
  domain stays in-process and pod-portable. Trade-off: any layout
  CSS the satori subset doesn't support has to be reworked, but the
  character card template was simple enough for the constraint to
  be cheap.
- **Theme persistence followed the spec-first loop.** `Me.theme`
  was added to the spec (v0.7.1) before the User column or the web
  PATCH — `a2d1053` → `d084396` → `eaf7f0c` → `2cb08fe`. The
  localStorage fallback from Phase 2 was removed in the same
  commit, not deferred.
- **`api-client-dart` outer-vs-inner package fix as the unblocker.**
  166 `flutter analyze` errors traced to `mobile/pubspec.yaml`
  pointing at the outer `packages/api-client-dart/`, which has no
  `lib/<barrel>.dart` — the openapi-generator output lives in the
  inner `lib/generated/` package. Repointing fixed the analyzer in
  one structural change instead of papering over each error with
  ignores. (`d6c231d`.)
- **Lint debt cleared in dedicated commits, not hidden inline.**
  `6712c5d` (backend) and `62cf903` / `cc86c2e` / `dd7caa5` (web)
  isolate the auto-fixer output so the feature commits stay
  reviewable.
- **Reduced-motion fallbacks audited as a single sweep.** Rather
  than per-component fixes, `1792682` walked every animated
  primitive, recorded the `prefers-reduced-motion` behaviour in
  each spec, and added the missing fallbacks in one pass — same
  pattern as the Phase 2 a11y panel sweep.
- **Mobile audit doc before mobile pass.** `MOBILE_AUDIT.md`
  (T-6.4.1) enumerated every divergence between the live sheet
  page and the `sheet-mobile.jsx` mockup, then `63893e9` worked
  through the list. The audit doc is the deliverable on follow-ups.

## Follow-ups

- **uk + el wizard translations.** Carried from Phase 2 — both web
  and mobile still ship en + ru full and uk + el placeholders. Real
  copy is Phase 4+ work.
- **`AppTextarea` autosize.** Still BEM-modifier-only; content-grow
  unimplemented. Carried since Phase 1.
- **`AppProgress` circular variant.** Still deferred.
- **Ship share viewer.** `/shared/ship/[slug]` is a placeholder page
  — ship sharing returns in Phase 5 with the ship sheet itself.
- **`?includeRevoked` on share-link list endpoint.** Documented in
  ADR-0003 §4 as deferred; the default-only listing is what shipped.
- **Share-link analytics surface.** The `viewCount` /
  `lastViewedAt` are stored but no owner-facing dashboard renders
  them yet.
- **8 Flutter primitives from Phase 1.** `AppIcon`, `AppTab`,
  `AppBanner`, `AppTooltip`, `AppKbd`, `AppSegControl`, `AppSelect`,
  `AppTextarea` still pending the per-widget Material/Cupertino
  evaluation pass. Phase 3 mobile pass rendered without them.
- **Storybook visual regression.** Still TODO; a11y panel remained
  the only automated design check this phase.
- **Web `pnpm typecheck` local breakage.** macOS `oxc-parser`
  binding bug from Phase 1 still in `docs/troubleshooting.md`. CI
  under Linux remains the source of truth.
- **Phase 4 entry point.** Dice & Sessions — dice roller (web +
  mobile), push mechanic, `GameSession`s, Darkness Points,
  Centrifugo channels for live DP. Per PRD §11 Phase 4.

## Local merge ledger

Thirty-five commits across the phase-2-complete..phase-3-complete
range, landed under the same push-per-block cadence adopted
mid-Phase-2 (see `feedback_block_workflow.md` in auto-memory).
Most recent first; the per-feature task entries with judgement-call
notes live in `specs/tasks/done.md`.

- `03e2c6c` + `916c66b` + `d6c231d` — mobile flutter analyze cleanup tail
- `df5d9ee` — Epic 6 Features 6.4 + 6.5 bookkeeping
- `cc86c2e` + `dd7caa5` — formatter sweeps (web ESLint + repo-wide prettier/stylelint)
- `4e89d98` — A11Y_AUDIT plan doc
- `1792682` — reduced-motion fallbacks across `@app/ui`
- `2cb08fe` + `eaf7f0c` + `d084396` + `a2d1053` — theme persistence (web → backend → codegen → spec)
- `63893e9` + `f38792e` — mobile bottom tabs + audit doc
- `a6536eb` + `d247051` + `bd7df16` + `601a24c` — OG renderer (bookkeeping → route → service → deps)
- `a537b77` — Json-field cast restore (Prisma typecheck)
- `b1f53f8` + `08f00f6` + `62cf903` — Feature 6.2 bookkeeping + viewer specs + ESLint sweep
- `bf8bba0` + `cc0184c` + `a7ff434` + `7c61d67` — public viewer pages + composition + composable
- `f450098` + `6712c5d` + `6ab7519` — Feature 6.1 bookkeeping + lint debt + lint --fix
- `f11cd55` + `f01c16a` + `fc5643d` + `59a0d92` — SharingModule + Prisma migration + codegen + spec
- `cadfbbc` — ADR-0003 share-link design
- `31a54d3` — Flutter 3.41 SDK compat (carried from Phase 2 tail)
  </content>
  </invoke>

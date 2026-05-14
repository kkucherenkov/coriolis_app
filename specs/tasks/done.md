# Done tasks

_Archive of shipped tasks. Never delete entries — cancelled tasks go here with reason._

## T-2026-05-14-002 — Reconcile typography token schema

- Created: 2026-05-14
- Completed: 2026-05-14
- Owner: claude
- Spec: [`docs/audits/design-2026-05-14.md`](../../docs/audits/design-2026-05-14.md) §1.2
- Decision: [`docs/adr/0004-typography-token-schema.md`](../../docs/adr/0004-typography-token-schema.md)
- Outcome:
  - Adopted handoff atom-refs schema: composite roles consume `{font.size.N}`, `{font.line-height.X}`, `{font.tracking.X}` via DTCG ref syntax. Top-level role bucket renamed `type` → `typography`. Project role-name vocabulary retained (`display-{xl,lg,md,sm}` / `body-{lg,md,sm}` / `mono-stat-{xl,md}`) — handoff vocabulary deferred to avoid 50-file rename + visible visual diff in a schema-only PR.
  - Pipeline (`packages/design-tokens/src/{parse,types,emit-*,emit-typescript}.ts`) gained `resolveRef()` + `resolveTypographyValue()`: family/weight refs return the bucket key (preserves `var(--font-X)` / `var(--fw-X)` emit), size/line-height/tracking refs return literal `$value`. Unknown refs throw at build.
  - Two referenced-but-undefined roles added — `body-xs` (12px Inter regular, ratio 1.4) and `label-sm` (12px Inter medium uppercase, tracking 0.06em) — back ~26 silently broken `--type-body-xs-*` / `--type-label-sm-*` consumer references.
  - Zero CSS drift on the 9 pre-existing roles. Dart artefact diff is purely additive (`bodyXs`, `labelSm` new TextStyles). Web + UI typecheck green. Design audit clean. Lint baseline improved 26 → 19 errors (autofix touched pre-existing code; my code is lint-clean).
- Follow-ups staged in active.md: `T-FOLLOWUP-FONT-VAR-DRIFT`, `T-FOLLOWUP-BARE-TYPE-VARS`, `T-FOLLOWUP-DESIGN-TOKENS-LINT`.
- Unblocks: T-2026-05-14-003 (atom layer needed for v1 atoms).
- PR: pending

## T-2026-05-14-001 — Design/UI audit vs handoff bundle (v1 scope)

- Created: 2026-05-14
- Completed: 2026-05-14
- Owner: claude
- Spec: `~/Downloads/Coriolis App-handoff.zip`
- Result: `docs/audits/design-2026-05-14.md` on branch `chore/design-audit-2026-05-14`
- Goal: surface every drift between the handoff design system and what's shipped, scoped to v1 (Phase 8 deferred).
- Outcome:
  - Tokens: 5/8 aligned; `color.json` drift is 100% Phase 8 (defer); `typography.json` schema-level refactor needs a decision.
  - Docs: `PATTERNS.md` + `CONTENT.md` missing wholesale; `FOUNDATIONS / COMPONENTS / SURFACES / A11Y / I18N` partial.
  - Components: 4 critical v1 atoms missing (`AppPanelTitle`, `AppSwash`, `AppWordmark`, `AppSkillRow`) + `AppButton` `secondary`/`mystic` variants.
  - Surfaces: Bridge dashboard not shipped; wizard step inventory 8/7/6 mismatch (handoff/web/mobile); mobile missing ship sheet and full combat tracker.
- 17 follow-up tickets staged in the report.

## T-2026-05-11-010 — Phase 7: Lighthouse CI gate + backend p95 save-latency alert

- Created: 2026-05-11
- Completed: 2026-05-11
- Owner: claude
- Spec: PRD §6 (NFR performance) + PRD §11 (Phase 7 — "performance tuning"). Closes the two perf items deferred from T-006.
- Result: [PR #18](http://code.homelab.local/kkucherenkov/coriolis_app/pulls/18) on Forgejo — branch `feat/phase-7/perf-gates`, merged. Two commits: initial gate (`f04e9cb`) + Chrome `--no-sandbox` fix for the act_runner (`312e37c`). 7 files / +1126 / −12.
- Acceptance — all met:
  - `pnpm --filter @app/web lighthouse` runs `@lhci/cli autorun` against the static-generated SPA, asserts 4 budgets, exits non-zero on regression.
  - `apps/web/.lighthouserc.json` — single URL `/`, mobile preset (PRD §6's "3G mobile"), 3 runs, lhci median.
  - Assertions (today's baseline → ceiling):
    - perf score: 0.89 → **≥ 0.85** (error)
    - CLS: 0.0004 → **≤ 0.1** (error)
    - LCP: 3186 ms → **≤ 3500 ms** (error)
    - TBT: 0 ms → **≤ 300 ms** (warn)
  - `.forgejo/workflows/ci.yml` `quality` job installs `google-chrome-stable` from Google's apt repo, runs `pnpm --filter @app/web generate`, then both `lighthouse` and `size` against the one build.
  - Bundle-size step moved from `checks` → `quality` so one `nuxt generate` powers both gates.
  - `docker/grafana/provisioning/alerting/app-alerts.yaml` gains `backend-p95-save-latency`: histogram_quantile(0.95, ...) filtered to PATCH/PUT/DELETE on `/api/v1/(me|characters|ships|npcs|sessions|combat).*`, threshold 500 ms (PRD §6), warning severity.
- Spec diff: none
- Codegen impact: no
- Design impact: none
- Tests: 445/445 web specs green; full quality-gate sweep clean; Lighthouse gate passes locally with the locked thresholds.
- Notable decisions:
  - **LCP threshold 3500 ms is intentionally LOOSER than PRD §6's 2500 ms.** Today's mobile baseline is 3.2 s; the gate is a regression-catcher, not a PRD-compliance assertion. Closing the 700 ms gap is its own follow-up (likely font preload + smaller initial JS chunk + route-level code splitting once Nuxt 4 stabilises chunk-naming).
  - **`--no-sandbox` + `--disable-dev-shm-usage` chromeFlags.** Forgejo's act_runner runs the workflow as root; Chrome refuses to start its zygote there (crbug.com/638180). The `/dev/shm` flag is a defensive companion — containers often ship a tmpfs too small for Chrome's IPC.
  - **Backend p95 = Grafana alert, not CI-fail.** PRD treats latency as a prod signal; matches courseShelf's "gate = alert, not synthetic-load assertion" stance. No k6/autocannon CI step.
  - **Google Chrome over playwright's chromium.** The Playwright container ships `chrome-headless-shell` only; Lighthouse needs full Chrome for several perf insights.
- Status: shipped
- Blockers: —

## Open follow-up (Phase 7 backlog after T-010)

- **Flutter SQLite offline mirror + sync engine (mobile).** Last "🔴 not started" pillar.
- **Close LCP 700 ms gap to PRD §6.** Font preload + smaller initial JS chunk + route-level code splitting.
- First **beta tag push** (`v0.1.0-release`) — workflow is armed; needs operator to push.
- Drop `.github/dependabot.yml` (dead config on Forgejo origin).
- `AppPopover` `role` prop refactor.
- Restore secret scanning (trufflehog binary à la trivy).
- POST queueing + ETag/If-Match conflict resolution (deferred offline edges).

## T-2026-05-11-009b — Phase 7: release workflow on Forgejo (tag → GHCR + Release page)

- Created: 2026-05-11
- Completed: 2026-05-11
- Owner: claude
- Spec: PRD §11 (Phase 7 — Hardening · "beta release"). Half-2 of the courseShelf release-flow port; built on T-009a's production packaging.
- Result: [PR #17](http://code.homelab.local/kkucherenkov/coriolis_app/pulls/17) on Forgejo — branch `feat/phase-7/release-workflow`, merged as `16d03af`. 2 files / +352.
- Acceptance — all met:
  - `.forgejo/workflows/release.yml` triggers on `push: tags: ['v*.*.*-release']`. Tag-parse step rejects malformed tags before docker runs.
  - Builds + pushes `coriolis-backend` + `coriolis-web` to `${REGISTRY}/${GHCR_USER}/<name>` under `:semver` / `:major.minor` / `:major` / `:latest`.
  - Renders `compose-release-vX.Y.Z.yml` from `docker/compose.release.yml`, validates with `docker compose config --quiet` from inside `STAGE/`.
  - Generates release notes via `git-cliff --current` against the just-pushed tag.
  - Creates a Forgejo release (`draft: false`, `prerelease: false`) via curl + `GITEA_TOKEN`, uploading four assets (tarball + standalone compose + .env example + raw notes).
- Spec diff: none
- Codegen impact: no
- Design impact: none (CI-only)
- Tests:
  - `yq eval` parses the workflow clean.
  - Local dry-run of the stage-bundle shell logic against `SEMVER=0.1.0` produces a valid rendered compose; `docker compose config --quiet` exits 0; image refs resolve to `ghcr.io/kkucherenkov/coriolis-{backend,web}:0.1.0`.
  - First real verification happens when the operator pushes the first tag.
- Notable decisions:
  - **`git-cliff` installed as a binary**, not via an action — same pattern as Trivy in `.forgejo/workflows/trivy.yml`; no dependency on a (possibly unmirrored) action repo.
  - **Source label `code.homelab.local/<user>/coriolis_app`**, not a github URL. GHCR shows it verbatim on the package page; matches truth that the source lives on Forgejo.
  - **Re-pushing the same tag fails at `docker push`** — registries reject overwriting an immutable tag. Bump-and-retag is the only way to re-cut.
  - **Operator must set `GHCR_USER` + `GHCR_TOKEN`** in Forgejo Settings → Actions → Secrets before the first tag push; documented in both the workflow header and the PR.
- Status: shipped (release flow now armed; not yet fired — needs an operator to push a tag)
- Blockers: —

## T-2026-05-11-009a — Phase 7: release packaging (Dockerfiles + compose.release + nginx)

- Created: 2026-05-11
- Completed: 2026-05-11
- Owner: claude
- Spec: PRD §11 (Phase 7 — Hardening · "beta release"). Half-1 of the courseShelf release-flow port; T-009b adds the actual `release.yml` workflow on top.
- Result: [PR #16](http://code.homelab.local/kkucherenkov/coriolis_app/pulls/16) on Forgejo — branch `feat/phase-7/release-packaging`, merged as `365c8d5`. 13 files / +835 / −4.
- Acceptance — all met:
  - `docker build -f apps/backend/Dockerfile -t coriolis/backend:test .` succeeds locally (~3 min cold).
  - `docker build -f apps/web/Dockerfile -t coriolis/web:test .` succeeds locally (~5 min cold).
  - `docker compose -f docker/compose.release.yml config` exits clean against placeholder env.
  - Web image smoke: `docker run -e APP_API_BASE_URL=… -e APP_AUTH_BASE_URL=… coriolis/web:test` serves `/_app-config.js` with the templated URLs and `GET /` returns 200.
  - Reverse proxy folds `/api/`, `/centrifugo/`, `/` onto a single host.
  - `cliff.toml` config + `.env.release.example` operator guide in place.
- Spec diff: none
- Codegen impact: no
- Design impact: none (infra only)
- Tests: 445/445 web specs green; size-limit clean; lint / typecheck / format clean.
- Notable decisions:
  - **Moved `prisma` from devDeps to deps** in `apps/backend/package.json`. `pnpm deploy --prod` strips devDeps and the runtime container needs the CLI for `migrate deploy`. CourseShelf's setup is the same.
  - **Skipped `pnpm --filter @app/api-client-ts build`** in both Dockerfiles. Coriolis's api-client-ts has no build step (it exports `./src/index.ts` directly via `main`), so it's consumed by Nest / Nuxt as-is.
  - **Renamed `centrifugoUrl` → `realtimeWsUrl`** in the runtime-config plugin to match coriolis's convention (`nuxt.config.ts:runtimeConfig.public.realtimeWsUrl`).
  - **No release-bundle README in this PR.** The release workflow (T-009b) will write it; baking it into the source tree would lie about whether it's been materialised yet.
  - **No streaming endpoint in the proxy** (no `/api/v1/stream/`). Coriolis serves no media.
- Status: shipped
- Blockers: —

## T-2026-05-11-008 — Phase 7: web offline write-queue (PATCH/PUT/DELETE)

- Created: 2026-05-11
- Completed: 2026-05-11
- Owner: claude
- Spec: PRD §11 (Phase 7 — Hardening · "Offline support"); follow-up to T-2026-05-11-007.
- Goal: PATCH / PUT / DELETE attempted while disconnected (or that fail with a network error mid-flight) get persisted to an IDB queue and replayed sequentially on reconnect, so a player editing their character on the train doesn't lose work when the tunnel ends.
- Result: [PR #15](http://code.homelab.local/kkucherenkov/coriolis_app/pulls/15) on Forgejo — branch `feat/phase-7/web-offline-writequeue`, merged as `a25b63a`. 8 files / +588 / −39.
- Acceptance — all met:
  - PATCH / PUT / DELETE while offline → enqueued to IDB via `idb-keyval`, fetch returns synthetic `200 {}`, caller spread-merge is a no-op against already-optimistically-updated local state.
  - POST + GET intentionally NOT queued (creates need server ids; GETs use the SW read-cache from T-007).
  - On `online` event, FIFO drain via direct `fetch`; successful entries delete, failures stay and surface `status: 'error'`.
  - Banner across 4 states: offline (with / without pending count), syncing, synced (~2 s success pulse), error. en + ru populated; uk + el `[*-todo]`.
  - Queue survives reload (IDB).
  - Total JS: 387 → **389 kB** (+2 kB for `idb-keyval`); under the 410 kB ceiling from T-006.
- Spec diff: none
- Codegen impact: no
- Design impact: no new components.
- Tests: `tests/unit/offlineQueue.spec.ts` (7 cases via `fake-indexeddb/auto`). 445/445 web specs green.
- Notable decisions:
  - **Intercept at the SDK fetch override**, not at every API composable. One choke point, works for every generated endpoint uniformly.
  - **Synthetic 200 `{}`**, not a custom `OfflineQueuedError`. Callers already spread-merge optimistic local state; an empty echo doesn't disturb anything. Avoids changing every page's error-handling path.
  - **`Authorization` stripped on persist.** The bearer at replay time is current, not the (possibly expired) one from when the request was queued.
  - **Pending-count over input-blocking.** The original brainstorm option B mentioned "блокирует input"; in practice that hurts the single-player offline session. Users keep typing, edits queue, banner counts.
- Status: shipped
- Blockers: —

## Open follow-up (Phase 7 backlog)

- **Flutter SQLite offline mirror + sync engine** (mobile). Heaviest item left in the phase; needs a feature spec.
- Lighthouse CI gate (LCP / CLS / TBT) — deferred from T-006.
- Backend p95 targets per PRD §6 — deferred from T-006.
- **Beta release workflow** — coming next (port courseShelf's `release.yml` to Forgejo + adapt for our two images).
- Drop `.github/dependabot.yml` (dead config).
- `AppPopover` `role` prop refactor.
- Restore secret scanning (trufflehog binary or runner outbound github.com).
- ETag / If-Match conflict resolution (deferred 3rd offline PR).
- POST queueing (deferred — id reconciliation problem).

## T-2026-05-11-007 — Phase 7: web offline (read-only cache + SW shell)

- Created: 2026-05-11
- Completed: 2026-05-11
- Owner: claude
- Spec: PRD §11 (Phase 7 — Hardening · "Offline support (web SW + Flutter SQLite)")
- Goal: a player who loses connectivity at the table can still navigate to characters / ships / NPCs / sessions and read everything they had loaded once. Mutations stay best-effort (network error → toast); explicit write-queue + replay engine deferred to next PR.
- Result: [PR #14](http://code.homelab.local/kkucherenkov/coriolis_app/pulls/14) on Forgejo — branch `feat/phase-7/web-offline-readcache`, merged as `2d1b69f`. 7 files / +721 / −13.
- Acceptance — all met:
  - SW (`@vite-pwa/nuxt` + `workbox-window`) registers with `registerType: 'autoUpdate'`. Build emits `/sw.js` + `/workbox-<hash>.js`.
  - App shell precached: `**/*.{js,css,html,svg,ico,woff2}` from the Workbox build manifest.
  - `GET /api/v1/me*` → `StaleWhileRevalidate`, cap 100 entries / 7 days. `urlPattern` matches by `url.pathname` so it works for both the dev cross-origin layout and any prod proxy.
  - Mutations + `/auth/*`, `/realtime/*`, `/public/*` go straight to network — no caching.
  - Site-wide `<AppBanner tone="warning">` driven by `useOnline()`; en + ru populated, uk + el `[*-todo]` placeholders.
  - Total JS: 384 → **387 kB** (+3 kB workbox-window shim). Within the 410 kB ceiling locked in T-006.
- Spec diff: none
- Codegen impact: no
- Design impact: no new `@app/ui` component (inline `<AppBanner>` composition, no Flutter parity question — Flutter handles connectivity differently).
- Tests: 438/438 web specs green (+5 from `tests/unit/useOnline.spec.ts`: default-true, mount-mirrors-false, online ← event, offline ← event, listener cleanup).
- Notable decisions:
  - **Path-based `urlPattern`, not full URL.** Dev runs web on :3001 + API on :3010 (cross-origin); production probably proxies. Matching `url.pathname.startsWith('/api/v1/me')` works in both.
  - **No `OfflineBanner` component.** The whole banner is one inline `<AppBanner>` in the layout — wrapping it would have been over-abstraction. Flutter has no reason to mirror it (different connectivity idioms).
  - **`globalThis.addEventListener`, not `window.*`.** Project ESLint config (unicorn/prefer-global-this) requires it; consistent with other composables.
  - **Default `online: true` on mount.** Avoids a one-frame banner flash before `navigator.onLine` is read.
- Status: shipped
- Blockers: —

## T-2026-05-11-006 — Phase 7: web bundle-size budgets

- Created: 2026-05-11
- Completed: 2026-05-11
- Owner: claude
- Spec: PRD §11 (Phase 7 — Hardening · "performance tuning"); PRD §6 (NFR — performance budgets)
- Goal: lock today's `apps/web` JS / CSS sizes behind a CI gate so the upcoming Phase-7 service-worker work can't silently inflate the wire payload that the SW will end up caching.
- Result: [PR #13](http://code.homelab.local/kkucherenkov/coriolis_app/pulls/13) on Forgejo — branch `feat/phase-7/web-bundle-budgets`, merged as `3e4b556`. 5 files / +120 / −1.
- Acceptance — all met:
  - `pnpm --filter @app/web size` exits non-zero when any tracked bucket exceeds its budget. Verified by dropping the Total-JS limit from 410 kB → 300 kB (size-limit returned 1).
  - 4 buckets locked, all brotli-compressed: Total JS 384 → **410 kB** (~7 % headroom), Total CSS 54 → **60 kB** (~12 %), Entry CSS 23 → **25 kB** (~9 %), `_id_` route CSS 8 → **10 kB** (~21 %).
  - Budgets live in `apps/web/.size-limit.json` so the value, glob, and rationale are one diff.
  - `.forgejo/workflows/ci.yml` `checks` job runs `pnpm --filter @app/web build && pnpm --filter @app/web size` — adds ~30 s, no new job.
- Spec diff: none
- Codegen impact: no
- Design impact: none
- Tests:
  - 4 size-limit assertions act as the test suite.
  - Manual regression: lower a budget → exit 1; restore → exit 0.
- Notable decisions:
  - **Per-chunk JS budgets skipped.** Nuxt 4 names client JS chunks by content hash only (`DdLCW58Z.js`), so `vendor.*.js`-style globs don't exist. Coarse Total-JS ceiling instead. CSS chunks DO keep human prefixes (`entry.`, `_id_`, `new.`, `app.`), so individual budgets exist where they matter for first paint.
  - **Brotli, not gzip.** size-limit's default; matches what modern CDN-edge serves to real clients.
  - **5–21 % headroom**, not a flat number — small bundles need more wiggle (one feature can spike `_id_` CSS).
- Status: shipped
- Blockers: —

## Open follow-up (Phase 7 backlog)

Same list as before plus the bundle-budget consequence:

- **Web offline service-worker + IndexedDB cache** — the immediate next PR. The new size budgets make the SW cache strategy bounded.
- Lighthouse CI gate (LCP / CLS / TBT) — deferred from T-006.
- Backend p95 targets per PRD §6 — deferred from T-006.
- Drop `.github/dependabot.yml` (dead config on Forgejo origin).
- `AppPopover` `role` prop so menus / listboxes don't have to mimic dialog.
- Restore secret scanning (trufflehog binary or runner outbound github.com).

## T-2026-05-11-005 — CI consolidation: port courseShelf 2-job structure to Forgejo

- Created: 2026-05-11
- Completed: 2026-05-11
- Owner: claude
- Spec: none (infra)
- Goal: shrink the per-PR CI cost on Forgejo by collapsing the 7 separate jobs in `.github/workflows/ci.yml` into 2 fat jobs (`checks` + `quality`), mirroring the optimisation already shipped in `../courseShelf/.forgejo/workflows/`.
- Result: [PR #12](http://code.homelab.local/kkucherenkov/coriolis_app/pulls/12) on Forgejo — branch `chore/ci-forgejo-consolidation`. Three commits: initial port (`fe449eb`), homelab adaptation (`17ff768`: drop trufflehog action, full-URL flutter-action, fast-uri/fast-xml-builder vuln bumps via pnpm overrides), runtime fixes (`68d5c12`: AppPopover aria-label via UserMenu, JRE install for codegen-drift). Final tip merged green.
- Acceptance — all met:
  - `.forgejo/workflows/ci.yml` runs two jobs (`checks` + `quality`); each does one `pnpm install`. Both green on the homelab act_runner.
  - `.forgejo/workflows/codegen-drift.yml` is path-filtered to `packages/specs/**` and `packages/api-client-*`; only fires when wire contracts change.
  - `.forgejo/workflows/e2e.yml` runs in `mcr.microsoft.com/playwright:v1.59.1-jammy` — no `playwright install --with-deps` step.
  - `.forgejo/workflows/trivy.yml` (fs + config scans) replaces CodeQL on Forgejo. `.github/workflows/codeql.yml` deleted.
  - `.github/workflows/{ci.yml, e2e.yml}` deleted — origin is Forgejo, no GitHub mirror, and the act_runner scans both dirs by default.
  - Coverage: backend lint/typecheck/test:coverage, web lint/typecheck/test, specs validate+bundle, UI components audit, plus the three quality gates we manually fix today (`pnpm stylelint`, `pnpm design:audit`, `pnpm format:check`).
- Spec diff: none
- Codegen impact: no
- Design impact: none (CI-only)
- Side-effects baked into PR #12:
  - **trufflehog dropped.** code.forgejo.org doesn't mirror `trufflesecurity/trufflehog`, and using a full GitHub URL still requires the runner to have outbound `github.com`. courseShelf made the same call. Secret scanning is a deferred follow-up — install via the official binary script (same pattern as trivy) when we want it back.
  - **flutter-action via full URL.** `https://github.com/subosito/flutter-action@v2` resolves through the runner's host fallback instead of the missing `code.forgejo.org/subosito/flutter-action` mirror.
  - **JRE install in codegen-drift.** `openapi-generator-cli` shells out to `java -jar`; `catthehacker/ubuntu:act-22.04` ships without one. `apt-get install default-jre-headless` runs as root in the container.
  - **Vuln bumps via pnpm.overrides.** `fast-uri ^3.1.2` (CVE-2026-6321, CVE-2026-6322 via ajv) and `fast-xml-builder ^1.1.7` (CVE-2026-44665 via @nodable/entities). Trivy fs back to clean.
  - **`aria-dialog-name` fix on UserMenu.** Pre-existing axe violation surfaced by the new quality job — `<AppPopover>`'s `role="dialog" aria-modal="true"` needs an accessible name. Reused `labels.triggerAriaLabel` ("Open user menu" / "Открыть меню пользователя") instead of adding a new label slot.
- Tests: 33 storybook test suites / 318 a11y assertions green locally; both Forgejo jobs green on the merged commit; codegen-drift skipped on this PR (no `packages/specs/**` touched).
- Status: shipped
- Blockers: —

## Open follow-up (out of scope, for next PR)

- `.github/dependabot.yml` is still dead config on a Forgejo-only origin (Dependabot is a GitHub service). Leave in place; remove together with any other GitHub-only metadata next time we touch `.github/`.
- AppPopover currently hard-codes `role="dialog" aria-modal="true"`. For menu / listbox / tooltip consumers the dialog role is semantically wrong. Add a `role` prop (or split the component) when the next consumer hits the same axe rule.
- Restore secret scanning once a path is decided — either give the runner outbound github.com access (so `https://github.com/trufflesecurity/trufflehog@main` resolves), or install the trufflehog binary via the official install script (mirrors how trivy is bootstrapped).

## T-2026-05-11-004 — Stylelint + design:audit drift cleanup

- Created: 2026-05-11
- Completed: 2026-05-11
- Owner: claude
- Spec: none (maintenance)
- Goal: `pnpm stylelint` and `pnpm design:audit` exit clean on `main`.
- Result: [PR #11](http://code.homelab.local/kkucherenkov/coriolis_app/pulls/11) on Forgejo — branch `chore/stylelint-audit-drift`, merged as `e161606`. 41 files / +584 / −2039.
- Acceptance — all met:
  - `pnpm stylelint` — 0 errors / 0 warnings (was 30 errors).
  - `pnpm design:audit` — clean Vue + Flutter + inventory (phantom `AppWidgets` row gone).
- Spec diff: none
- Codegen impact: no
- Design impact:
  - `specs/design/README.md`: 4 inventory rows added — `AppHeader`, `AppMobileDrawer`, `AppSavePulse` (Flutter ✓), `UserMenu`. Category column widened to fit `Composition`.
  - `packages/design-tokens/scripts/audit-inventory.ts`: `flutterDir` corrected to `lib/src/widgets/` (was `lib/src/`, which only saw the two top-level subfolders and surfaced a phantom `AppWidgets`). The audit now actually checks per-widget parity.
- Tests: lint + audit gates only. UserMenu unit suite stayed green (33 files / 778 cases) after the `.user-menu` → `.app-user-menu` rename.
- Sub-steps:
  - [x] AppMobileDrawer: 36px → `$close-button-size`; reduce-motion `0ms` → `transition: none`; transition `150ms` fallbacks dropped.
  - [x] AppHeader: `#15193f` hex fallback dropped; 40px → `var(--space-8)`; all `150ms` transition fallbacks dropped.
  - [x] UserMenu: rename `.user-menu` → `.app-user-menu` in template / SCSS / spec; literal `min-width: 200px` → `$panel-min-width`; `font-size: 10px` → `$section-label-font-size`.
  - [x] apps/web: skip-link `top: -40px` → `calc(-1 * var(--space-8))`, `z-index: 1000` → `var(--z-max)`, `transition: top 200ms` → tokens; CombatTracker `0.15s` → `var(--motion-duration-fast)`; six page files: literal `max-width` / `min-width` / `width` → named SCSS vars or `var(--space-12)`.
  - [x] Inventory rows + audit-script path fix.
  - [x] Carry-over: prettier multi-attribute reformat across remaining `apps/web/**/*.vue` (same drift class as PR #10) — bundled in the same commit.
- Status: shipped
- Blockers: —

## T-2026-05-11-003 — Phase 7 entry-point: JSON export (`/api/v1/me/export`)

- Created: 2026-05-11
- Completed: 2026-05-11
- Owner: claude
- Spec: [docs/superpowers/specs/2026-05-11-me-export-design.md](../../docs/superpowers/specs/2026-05-11-me-export-design.md)
- Plan: [docs/superpowers/plans/2026-05-11-me-export.md](../../docs/superpowers/plans/2026-05-11-me-export.md)
- Goal: an authenticated user can download a versioned JSON bundle of every character, ship, and game session they own from the settings page.
- Result: [PR #9](http://code.homelab.local/kkucherenkov/coriolis_app/pulls/9) on Forgejo — branch `feat/phase-7/me-export`, final tip `89338b2` (`chore(lint): clear web ESLint blockers carried over from drift commit`). 22 commits across spec, codegen, backend, web, tests, format catch-up, and final lint cleanup. No conflicts.
- Acceptance — all met:
  - `GET /api/v1/me/export` (bearer auth) returns `200 application/json` with `$schemaVersion: "1"`; `401` without auth (smoke-confirmed via curl).
  - Bundle contains characters / ships / npcs / gameSessions for the authenticated user only, with canonical read-model shape (delegates to existing `List{Resource}Query` handlers via QueryBus so `express-openapi-validator` accepts the response).
  - Web settings page has a working "Data" section. en + ru real copy; uk + el use `[xx-todo]` placeholders. All 4 locales pass `pnpm check:i18n`.
  - `pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen` clean. Codegen drift committed separately per repo rule.
- Commits:
  - **Block 0 (T entry):** `61669c9` chore(tasks).
  - **Block 1 (spec + codegen):** `4c90569` (initial spec), `a5c4627` (allOf wrappers + examples fix per spec-reviewer), `8f3a46b` (codegen), `d48a6c2` (npcs hoist to bundle top-level — NPCs are user-owned, not session-owned), `3e5a772` (re-codegen for npcs hoist), `60cbab5` (active.md tick).
  - **Block 2 (backend):** `c4b2a81` (initial backend), `1ca91a2` (review fixes: drop `User.locale` from spec + types + adapter — `locale` doesn't exist on the User Prisma model; soft-delete-safe `findFirst` + `UserNotFoundError`; sanitize filename; derive date from bundle).
  - **Block 3 (web):** `80d6a4c` (`useMeApi.exportMe()` + Settings Data section + 4-locale i18n + SCSS), `9defee8` (review polish: `parseFilename` handles unquoted form + WHY-comment on synchronous URL.revokeObjectURL), `1153331` chore(format) lint-fix drift catch-up in apps/web, `3de695e` chore(format) prettier-apply to the design + plan docs, `04fbb1d` (active.md tick).
  - **Block 4 (smoke + critical fix):** `438274f` (Playwright smoke at `tests/e2e/settings-export.spec.ts`, auto-skip pattern), `9d75410` (final reviewer caught raw-Prisma vs canonical-readmodel shape mismatch — rewrote handler to delegate to ListQuery handlers via QueryBus; IExportRepo slimmed to user-only).
- Architectural decisions encoded in the branch:
  - **No `MeExportModule`.** `/me/export` is owned by the existing `UsersController` — extends `UsersModule` instead.
  - **No HTTP e2e test.** Project has zero HTTP-level e2e; runtime contract enforcement comes from `express-openapi-validator` (dev/test) + codegen-drift CI + handler unit spec + Playwright smoke.
  - **QueryBus delegation in the handler.** Avoids cross-module Prisma reads in `ExportRepo` and reuses each domain's canonical mapper. `IExportRepo` is now user-only.
  - **NPCs at bundle top level.** NPCs are user-owned in Prisma (`ownerId` only — no `gameSessionId`), so the bundle exposes them flat rather than nested per session.
  - **`User.locale` not exported.** Field doesn't exist on the User model; removed from spec + types.
  - **Email omitted from `MeExportUser`.** The dump may be saved or shared; auth-side identifiers should not leak.
- Follow-ups (filed in this entry, not blocking the PR):
  - `@Delete('me')` on `users.controller.ts:70` registers `DELETE /api/v1/me/me` (the controller already has `path: 'me'`). Pre-existing bug — open a separate T-2026-05-11-NNN to audit and fix.
  - Pagination of the export bundle: each `List{Resource}Query` is called with `limit: 1000`. Covers >99.9% of v1 users. If real-user data exceeds this, fold a cursor loop into the handler.
  - Streaming delivery / compression: deferred per design (`Out of scope` list). Trigger only if real-user bundles exceed ~1 MB.
  - Mobile (Flutter) export button: separate task, spec already wired.
  - `GET /characters/:id/export`: PRD §9 lists it; not blocking 10.3. File as a follow-up if needed.

## T-2026-05-11-002 — Phase 6 mobile: read-along combat card (Flutter)

- Created: 2026-05-11
- Owner: claude
- Spec: PRD §11 Phase 6 scope ("Combat tracker —
  desktop-shaped; mobile read-along card") + §7.6 Flutter
  feature map. Wire contract already published in
  OpenAPI v0.16+ + AsyncAPI `combat.updated` from T-006.
- Goal: a player on mobile, viewing an active session, sees
  a live, read-only card showing the current encounter —
  turn order, active row, status flags, combatant HP /
  armor / weapon — that re-renders as the GM advances
  turns, rerolls initiative, or edits combatants on web.
- Depends on: T-2026-05-10-008 (web combat tracker —
  first end-to-end consumer of the wire shape; if T-008
  surfaces a contract gap, that gets fixed before mobile
  consumes it). Soft dep — can start in parallel with
  T-008's last block once the realtime payload shape is
  known to be stable.
- Acceptance:
  - On the mobile session detail screen, when the session
    has at least one active encounter, an `ActiveCombatCard`
    renders below the existing DP counter. Clean empty
    state when no active encounter, error state with
    retry on fetch failure.
  - The card lists combatants ordered by `turnOrder`,
    highlights the active row, renders status-flag chips
    (canonical `incapacitated` / `prone` / `covered` get
    themed icons; other free-form tags render as plain
    chips per T-010 Block B).
  - Read-only — no roll, reorder, or add/remove. GM ops
    stay on web for v1.
  - Realtime: subscribes to the existing `session.{id}`
    channel via the centrifuge client added in T-003.
    Branches on `payload.type` — DP updates feed the
    existing DP cubit, `combat.updated` snapshots replace
    the local combat state wholesale (no client diff).
  - i18n: every visible string keyed in
    `apps/mobile/lib/i18n/` with ru + en + el + uk parity
    (matches the existing locale set).
  - Tests: cubit unit tests (load / realtime /
    error transitions), widget golden tests for the card in
    3 states (empty / active / ended), one integration
    smoke driving the realtime path with a fake
    centrifuge client.
- Spec diff: none — wire already shipped in T-006.
- Codegen impact: none — Dart client already exposes
  the Phase 6 ops.
- Design impact: new `ActiveCombatCard` widget — capture in
  the mobile widget catalogue. No new design tokens; reuse
  the existing role / size scales.
- Tests: cubit unit + widget goldens + 1 integration smoke.
- Sub-blocks (one `feat(mobile)` commit per block + one
  active.md follow-up commit, per
  `feedback_block_workflow.md`):
  - [x] Block 1 — `lib/features/combat/` skeleton
        (data + domain + presentation), `CombatRepository`
        over the generated Dart client, fixture-backed
        widget catalogue entry. 8 unit tests on the
        repository impl. Codegen-drift follow-up noted:
        the generated Dart client has stale .g.dart files
        post-T-010 Block H (ShipModuleSlot import missing
        in 4 ship-module modules) — flagged for a separate
        `chore(codegen)` task; NOT fixed in this block since
        the combat module doesn't depend on those models.
  - [x] Block 2 — `ActiveCombatCubit` (load by sessionId →
        resolve active encounter → fetch combatants),
        states (loading / empty / ready / error), unit
        tests. State union uses Dart 3 sealed/final
        class idiom (matches sessions/characters cubits,
        no freezed). 8 cubit tests added — total combat
        scope 15/15 passing.
  - [x] Block 3 — `ActiveCombatCard` widget integrated
        into the session detail screen. Empty / active /
        ended state widget tests (11 widget tests). Card
        listens to ActiveCombatCubit, renders read-only
        combatant list ordered by turnOrder, canonical
        flag chips (incapacitated / prone / covered) with
        themed icons + free-form chips. Mounted below the
        DP counter via MultiBlocProvider. i18n: 4 new
        combat_*.i18n.json source files (ru full, uk + el
        placeholders); strings_*.g.dart regenerated via
        `dart run slang`.
  - [x] Block 4 — Realtime: extended the existing
        `session.{id}` subscription router (T-003) — new
        `combat_updated_payload.dart` isolates the wire →
        domain boundary, `_onPublication` in
        `session_realtime.dart` branches on `payload.type`
        before structural fallback. session_detail_page
        subscribes to the new `combatUpdated` stream and
        calls `ActiveCombatCubit.replaceSnapshot(...)` on
        each emission. AsyncAPI `name` → OpenAPI
        `displayName` mapped at the parser boundary;
        AsyncAPI `status` → domain `state`,
        `combatantType` → `source`, `referenceId` →
        `sourceId`. 12 new tests (8 payload + 4 cubit
        integration). Total combat scope 40/40.
  - [x] Block 5 — i18n + a11y pass. 4 new Semantics keys
        (semanticsCurrentTurn, semanticsStatusPrefix,
        semanticsHp, semanticsMp) added to all 4 combat
        locale files; ru fully translated, uk + el
        placeholders per convention. Active-combatant name
        wrapped in Semantics(liveRegion: true) scoped to the
        name widget (not the full row) so HP/MP remain
        independent nodes. Each status chip has
        Semantics(label: "Status: X"). Each stat label has
        Semantics(label: "Hit points: A of B" / "Mystic
        Darkness Points: N"). EdgeInsets.only(top: 5) →
        EdgeInsetsDirectional.only(top: 5). RTL: project
        does not declare any RTL locale (no ar/he/fa in
        AppLocaleUtils.supportedLocales) so RTL routing via
        Localizations.localeOf is not yet a real concern;
        noted for follow-up when an RTL locale is added.
        7 new widget tests in active_combat_card_a11y_test.dart.
        Total combat scope: 38/38 (31 + 7).
- Status: done
- Completed: 2026-05-11
- Result: 5 commits — feat(mobile): T-2026-05-11-002 Block 1..5
  (Block 1 skeleton + CombatRepository; Block 2 ActiveCombatCubit;
  Block 3 ActiveCombatCard widget mounted below DP counter; Block 4
  combat.updated realtime wiring with AsyncAPI→OpenAPI name→displayName
  normalisation at the parser boundary; Block 5 a11y +
  EdgeInsetsDirectional + 4 new Semantics keys). Combat+realtime
  test scope 47/47 (8 repo + 8 cubit + 4 cubit-realtime + 8 payload
  + 11 widget + 7 a11y). i18n: 4 combat_*.i18n.json source files
  with ru full + uk/el placeholders.
- Follow-up: cut phase-6-complete tag now that both T-008 (web) and
  this task are landed. Update docs/done/phase-6.md to reflect the

## T-2026-05-10-008 — Phase 6 web: NPC library + GM combat tracker

- Created: 2026-05-10
- Owner: claude
- Spec: T-006 locked the wire contract; T-007 lands the backend
  implementation. This task wires the web SPA against both.
- Goal: GM-facing combat tracker UX — NPC library page,
  inline encounter creation on the session view, combatant
  picker (PC + NPC), initiative roll/reorder/advance, live
  combat re-render via the existing centrifuge subscription
  on `session.{id}` (DP composable already subscribes; reuse
  the channel, branch on payload type).
- Depends on: T-2026-05-10-007 (Phase 6 backend).
- Acceptance:
  - `/app/npcs` index — list + filter + inline create form +
    per-card Open / Duplicate / Delete + empty state, mirrors
    `/app/ships` index pattern.
  - `/app/npcs/[id]` sheet — full editable stat block with
    `useAutoSave` debounce on blur, header with rename +
    duplicate + delete + AppSavePulse.
  - On the session view (`/app/sessions/[id]`): an
    `EncounterPanel` that lists encounters for the session,
    inline create (name + notes), per-card open which expands
    a `CombatTracker` widget.
  - `CombatTracker` widget — combatant list ordered by
    `turnOrder`, active row highlighted, GM-only Roll
    Initiative / Advance Turn / Reorder (drag-and-drop)
    buttons. Add Combatant flyout with two tabs (PC picker
    pulling characters from the session, NPC picker pulling
    from `/api/v1/npcs`). Status-flag chips render the
    canonical tags (`incapacitated`, `prone`, `covered`) with
    themed icons and accept free-form additions per the
    T-010 Block B free-form policy. No client-side
    enum gate.
  - Realtime: subscribe to `session.{id}` (already done for
    DP) — branch on `payload.type` to update DP counter or
    re-render the combat tracker from the lazy snapshot. No
    diff computation in the client — replace local state
    wholesale.
  - i18n: every user-visible string keyed; ru + en strings
    in the existing `apps/web/i18n/locales/{ru,en}.json`.
  - Storybook: `CombatTracker` and `EncounterPanel` get
    stories (states: empty / setup / active / ended).
  - Vitest count climbs by ≥40.
- Spec diff: none.
- Codegen impact: none — generated TS client already exposes
  the Phase 6 ops from T-006.
- Design impact: combat tracker is a new pattern — capture
  tokens / spacing in the Storybook stories, no new design
  tokens needed (reuse existing role / size scales).
- Tests: vitest @testing-library/vue specs per page +
  composable; Storybook visual stories; one Playwright
  smoke flow (create encounter → add 2 combatants → roll
  initiative → advance turn → realtime update arrives).
- Sub-blocks (one feat-web commit per block + one
  active.md follow-up commit, per `feedback_block_workflow.md`):
  - [x] Block 1 — `useNpcsApi` composable + `/app/npcs`
        index page (list, inline create, per-card actions,
        empty state, error retry). Nav link from characters
        AppBar.
  - [x] Block 2 — `/app/npcs/[id]` sheet with auto-save
        on blur, header actions, problems card.
  - [x] Block 3 — `useEncountersApi` composable +
        `EncounterPanel` on the session view. Inline create,
        list, open / delete. State-machine UI hints
        (e.g. "Add ≥1 combatant before rolling initiative").
  - [x] Block 4 — `useCombatantsApi` + `CombatTracker`
        widget. PC + NPC picker, status chips, drag reorder.
        No initiative actions yet — picker + list only.
  - [x] Block 5 — Initiative ops + realtime wire-up.
        Roll / Advance Turn buttons, drag reorder dispatch
        to backend, branch the existing `session.{id}`
        subscription on payload type to update tracker
        from `combat.updated` snapshots. Storybook
        deferred — components are app-specific (see Result
        below); vitest snapshot coverage across all 4
        encounter states (empty / setup / active / ended)
        substitutes.
- Status: done
- Blockers: —

- Completed: 2026-05-11
- Result: 5 commits — feat(web): T-2026-05-10-008 Block 1..5 (c4dc69b useNpcsApi + npcs index; Block 2 sheet; Block 3 EncounterPanel; Block 4 CombatTracker; Block 5 initiative + realtime + reorder). Storybook coverage skipped — components are app-specific (depend on useNpcsApi / useCombatantsApi / useEncountersApi); vitest specs cover all 4 encounter states (empty / setup / active / ended). Wire-shape note: AsyncAPI CombatUpdated.combatants[].name vs OpenAPI Combatant.displayName — confirmed at runtime; the realtime payload's combatant snapshot replaces local state wholesale (no diff). T-2026-05-11-002 unblocked.

## T-2026-05-11-001 — Backfill `phase-{2..6}-complete` tags + `docs/done/` summaries

- Created: 2026-05-11
- Owner: claude
- Spec: PRD §11 ("Phased Roadmap") +
  [`docs/done/README.md`](../../docs/done/README.md)
  ("phase-N.md summary entries written when the
  phase-N-complete tag is cut").
- Goal: reconcile the phase-tag history with what's actually
  shipped on `main`. Phase 2 (character sheet + wizard),
  Phase 3 (sharing + polish), Phase 4 (dice + sessions +
  Darkness Points + push), Phase 5 (ships), and Phase 6
  backend (T-006 spec + T-007 backend + T-010 canon
  remediation) are all merged, but the most recent tag is
  `phase-3-complete` and `docs/done/` only contains
  `phase-0.md` + `phase-1.md`. Close the drift now while
  the PR-to-feature mapping is still legible from `git log`.
- Why now: T-008 (Phase 6 web combat tracker, next on the
  stack) is going to land soon. Better to land it on top
  of an honest phase ledger than improvise the Phase 6
  summary at merge time. The cost is one quiet hour
  today; the cost six months from now is reverse-engineering
  the timeline from commit messages.
- Depends on: nothing.
- Acceptance:
  - `docs/done/phase-2.md`, `phase-3.md`, `phase-4.md`,
    `phase-5.md`, `phase-6.md` exist, each following the
    template in `docs/done/README.md`. Each lists the PRs /
    task IDs that closed the phase, links to them, and names
    the deferred follow-ups.
  - Tags `phase-2-complete`, `phase-4-complete`,
    `phase-5-complete`, `phase-6-be-complete` cut at the
    correct commits (`phase-3-complete` already exists —
    leave it alone). `phase-6-complete` reserved — it is cut
    only when T-008 + T-2026-05-11-002 (mobile read-along)
    both land.
  - `docs/done/README.md` is unchanged; entries follow its
    template verbatim.
  - No code changes outside `docs/done/`.
- Spec diff: none.
- Codegen impact: none.
- Design impact: none.
- Tests: none — documentation + tagging only.
- Sub-blocks (one `chore(docs)` commit per block + one
  active.md follow-up commit, per
  `feedback_block_workflow.md`):
  - [x] Block 1 — `phase-2.md` (full character sheet,
        attributes / skills / talents / conditions, inventory,
        derived stats, auto-save, creation wizard,
        Cyrillic review). Tag `phase-2-complete` already
        cut at `a47e535`; only the summary doc was new.
        Doc landed; 50 commits classified into 8 feature
        groups (a11y CI, primitives, auto-save, sheet body,
        inventory, draft-state ADR, web wizard, mobile
        parity).
  - [x] Block 2 — `phase-3.md` (share links, public
        read-only views, OG image route, mobile pass, a11y
        audit). Tag already at `03e2c6c`; only the summary
        doc is new. 35 commits classified into 5 feature
        groups (Flutter 3.41 compat, share-link backend +
        ADR-0003, public viewer + OG renderer, mobile pass,
        theme persist + a11y/reduced-motion sweep).
  - [x] Block 3 — `phase-4.md` (dice roller web + mobile,
        push mechanic, GameSession, Darkness Points,
        Centrifugo channel for live DP). Tag
        `phase-4-complete` cut at `dbc22c9` (boundary
        commit — archives T-003 mobile, pushes T-004
        Phase 5 backend). Doc classifies ~60 commits into
        9 feature groups (dice spec, dice + push backend,
        GameSessions, DP audit log, Centrifugo realtime,
        web dice + sessions + DP + live, mobile parity,
        bearer-auth cutover, character-rules + locale-aware
        follow-ups).
  - [x] Block 4 — `phase-5.md` (ship sheets, modules,
        crew). Tag `phase-5-complete` cut at `39595f8`
        (boundary commit — archives T-005 web, pushes T-006
        Phase 6 spec). 21 commits classified into 2 task
        groups (T-004 backend ShipsModule + T-005 web ship
        list + sheet + module editor + crew widget +
        polish). Ship-share parity captured as a deferred
        follow-up — Phase 5 PRD scope ("ship sharing") did
        not ship.
  - [x] Block 5 — `phase-6.md` (NPC + Encounter +
        Combatant + initiative + combat realtime backend,
        ST3001 canon remediation). Tag `phase-6-be-complete`
        cut at `5c04d49` (HEAD before this task's docs ran)
        — final backend commit covering all Phase 6 backend
        + canon remediation + Block J spin-offs. 119 commits
        classified into 6 groups (T-006 spec, T-007 backend,
        T-010 + T-012..T-016 canon remediation crowned by
        OpenAPI v1.0.0 major bump, T-011 wizard role picker,
        T-017 Playwright bootstrap, T-018 web global nav).
        `phase-6-complete` deliberately deferred — reserved
        for when T-008 + T-2026-05-11-002 (web tracker + mobile
        read-along) land.
- Status: done
- Blockers: —
- Completed: 2026-05-11
- Result: 5 commits — docs(done): T-2026-05-11-001 Block 1..5 +
  4 new annotated tags (phase-4-complete @ `dbc22c9`,
  phase-5-complete @ `39595f8`, phase-6-be-complete @ `5c04d49`;
  phase-2-complete + phase-3-complete already existed). 5 phase
  summary docs added under `docs/done/`. No code changes outside
  `docs/done/`.

## T-2026-05-10-010 — Canon alignment: librarian audit remediation (ST3001)

- Created: 2026-05-10
- Owner: claude
- Source: 4-agent librarian sweep ran 2026-05-10 against the
  whole game-mechanic surface. 10 hard violations + 9 soft
  mismatches + 11 spec-silences captured. Full report in the
  session transcript.
- Goal: reconcile the implementation with the Russian ST3001
  rulebook (`/Users/kkucherenkov/Documents/vaults/obsidian/`
  `70.01 Areas/TRPG/Coriolis/ST3001/`). Hard violations are
  spec-first changes; soft mismatches need a PRD/code comment
  explaining the deliberate divergence; silences need either
  a comment or a deferred follow-up task.
- Why now: T-2026-05-10-008 (web combat tracker) is queued on
  T-007. Shipping the tracker on top of d10 + agility-tiebreak +
  non-canonical statusFlags + 5-band weapon ranges would compound
  the drift with i18n, Storybook, and Flutter UI. Fix the
  contract before the consumers wire up.
- Depends on: T-2026-05-10-007 (already done — gives us a known
  baseline to rebase the spec on). **Blocks: T-2026-05-10-008.**
- Acceptance:
  - Every hard violation closed in the spec + backend + tests.
  - Every soft mismatch carries an inline `// PRD override:`
    comment with the canon quote and the product reason
    (no silent drift).
  - Every spec silence either gets a one-line comment naming
    the rulebook section the implementation chose to defer to,
    or becomes a tracked follow-up task in `done.md` /
    `active.md`.
  - `pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen`
    runs clean — codegen artefacts shipped in their own commit.
  - Backend test count holds or grows (no regressions); new
    rule-fix specs added per block.
- Spec diff: large — touches `Encounter`, `Combatant`,
  `RollCreate`, `Attributes`, `Skill`, `ItemRangeEnum`,
  `ItemCybernetic`. **Major bump** of the OpenAPI semver
  (breaking changes to enum values + tightened ranges).
- Codegen impact: TS + Dart clients regenerated; web + mobile
  consumers will surface compile errors where the old enum
  literals are used — fix-forward in the same PR.
- Design impact: combat tracker mockups (T-008) referenced the
  `[broken, exposed, covered, prone]` status chips —
  redraw with the canonical taxonomy
  (`incapacitated, prone, covered`) before T-008 starts.
- Tests: per-block vitest specs; one e2e flow exercising a
  combat round end-to-end with the corrected rules.
- Sub-blocks (one feat-* commit per block + one
  active.md follow-up commit, per `feedback_block_workflow.md`):
  - [x] Block A — **Initiative die + tie-break.** Hard
        violations H1, H2. **Done in d0e553b (spec) +
        bf41a9a (backend).**
        Spec change: `Combatant.initiative.maximum` 10 → 6 in
        OpenAPI and AsyncAPI; descriptions cite ГЛАВА 5
        «Бросьте по кубику…»; `rollInitiative` and
        `InitiativeRollResult` rewritten to describe a bounded
        d6 reroll loop (≤3 passes) and drop the agility
        tie-break narrative; example values repointed into
        the 1..6 range.
        Backend: `roll-initiative.handler.ts` switched to
        `randomInt(1, 7)`; new pure `rerollTies(items, rollD6)`
        in `domain/initiative.ts`; `sortInitiative` simplified
        to initiative-desc + createdAt-asc; `getAgility`
        deleted. Tests added: 7 `rerollTies` cases
        (no-tie short-circuit, first-pass resolve, multi-pass
        resolve, give-up after MAX_REROLL_PASSES, partial tie
        among three, single combatant, no-mutation invariant)
        plus a reroll-tiebreak handler test and a d6-range
        guard. Backend vitest count grew by +5 (tied to
        Block A).
        Round-wrap canon citation already in
        `advance-turn.handler.ts:14-15` (landed with
        T-007 Block 5).
        Baseline collateral fix shipped on the way:
        a7367f4 imports `RealtimeModule` into
        `EncountersModule` (the T-007 Block 5 publisher
        couldn't resolve `CENTRIFUGO_CLIENT` because the
        module was never `@Global()`); 7a09ee5 exempts
        `specs/tasks/{active,done}.md` from prettier so
        the next `pnpm format` doesn't collapse the nested
        list outline.
  - [x] Block B — **Combatant statusFlags taxonomy.** Hard
        violation H3. **Done in c0fcba9 (spec) +
        9e3d0dd (backend fixtures).**
        Decision: kept `statusFlags: string[]` free-form (no enum
        lock) per the librarian audit's greenfield recommendation —
        GMs need scene-specific tags and a hard schema would force
        migrations every time a campaign needs a new condition.
        Description rewritten on `Combatant`, `CombatantUpdate`,
        and the AsyncAPI combatant snapshot to cite ГЛАВА 5
        «Раунды, ходы и инициатива» and name the canonical tags
        (`incapacitated`, `prone`, `covered`) without constraining
        the field. Removed the fabricated «`broken` halves all
        attributes per ST3001 p.77» one-liner — no such rule exists
        in the rulebook.
        Wire examples scrubbed of the dropped taxonomy:
        `Combatant.statusFlags` example `[broken, exposed]` →
        `[incapacitated]`; `CombatantUpdate` example `[broken]` →
        `[incapacitated]`; the GET-encounter NPC combatant fixture
        moved from `[exposed]` (also non-canonical) to `[covered]`;
        the PATCH-combatant `applyDamage` example summary,
        request, and response payload all switched to
        `incapacitated`.
        No Prisma migration: schema shape is unchanged
        (`String[]` Postgres array, same as before). Backend code
        is untouched — there was never an enum guard. Test
        fixtures in
        `combatants/commands/update-combatant.handler.spec.ts` and
        `combatants/queries/list-combatants.handler.spec.ts`
        rewritten to use `['incapacitated']` so they stop
        perpetuating the dropped taxonomy. 172 combatants +
        encounters specs pass inside the dev container.
        TS + Dart codegen: doc-comment-only diff (no schema break);
        consumers compile clean. T-008 design follow-up
        (combat-tracker status chips redrawn against canonical
        tags) is already noted in that task's «Design impact».
  - [x] Block C — **Dice pool min/max.** Hard violations
        H4, H5. **Done in 8a27aef (spec) + 8d8c30a (codegen)
        + 457fe42 (backend).**
        Spec: `Roll.pool.minimum` and `RollCreate.pool.minimum`
        lowered 1 → 0; `.maximum` widened 10 → 20 with a
        PRD-override note explaining 20 is a payload cap (no
        canonical upper bound exists in ST3001, realistic stacks
        max out around 12–14). The «Ноль кубиков» rule
        (ГЛАВА 3 line 161) is now documented on `RollCreate`
        and `Roll.dice` flags that the array still has 2
        elements when `pool === 0`.
        Backend: `rollPool(0)` rolls 2d6; `countHits` gained a
        `pool` parameter and only counts a success when every
        die is a 6 in the zero-dice case (returns 0 or 1, never
        the raw count). `CreateRollDto` now `@Min(0) @Max(20)`;
        `RollPoolOutOfRangeError` detail updated to "0–20"; the
        belt-and-suspenders check in `CreateRollHandler` mirrors
        the DTO. `PushRollHandler` passes `roll.pool` so a
        pushed zero-pool roll keeps the double-six rule.
        Tests added: 10 new `roll-engine.spec.ts` cases (no
        existing engine spec — file created), 5 new
        `create-roll.handler.spec.ts` cases (pool=0 stores 2
        dice, double-six invariant across 50 trials, pool=20
        accepted, pool=21 + pool=-1 rejected), 1 new
        `push-roll.handler.spec.ts` case (pushed zero-pool
        preserves the leading 6 and reports hits=1 only when
        the rerolled die also lands on 6). Backend vitest count
        739 → 749 (+10).
  - [x] Block D — **Attribute min + advanced skill cap.**
        Hard violations H6, H7. **Done in 345e0e4 (spec) +
        381ddef (codegen) + 05b6a2c (backend) + aac0dca
        (NPC fixture cleanup).**
        H6 applied: `Attributes.{strength,agility,wits,empathy}`
        `minimum` lifted 1 → 2 in OpenAPI. Schema description
        rewritten to cite ГЛАВА 2 «ХАРАКТЕРИСТИКИ» / §РАЗВИТИЕ
        ПЕРСОНАЖА — the rulebook scale is 1..5 in the abstract,
        but the active-PC invariant is 2..5 (creation distributes
        2..4, key-attr exception lifts to 5; no in-game mechanic
        lowers an attribute below 2). The 5-cap stays as the
        canonical lifetime maximum.
        H7 **rejected** as non-canonical. The audit asked for
        `AdvancedSkill 0..3`, but ГЛАВА 3 «Перечень навыков»
        («значения характеристик могут варьироваться от 1 до 5,
        а навыков — от 0 до 5») and ГЛАВА 2 §РАЗВИТИЕ ПЕРСОНАЖА
        («максимально возможное значение навыка равно 5»)
        explicitly cap every skill at 5 with no general/advanced
        distinction. The audit conflated the **creation-time**
        cap (key skills up to 3, others up to 1, ГЛАВА 2
        «НАВЫКИ») — already enforced by `validateSkillsAtCreation`
        — with a lifetime cap. The `Skills` schema description
        was rewritten to call this out and to document the actual
        general/advanced distinction (the value-≥-1 gate to roll
        an advanced skill, ГЛАВА 3 §«Специальные навыки», lives
        in the dice engine, not the schema). No range change on
        any skill.
        Backend: `validateAttributes` (update path) and
        `validateAttributesAtCreation` (create path) floors lifted
        1 → 2; `AttributeOutOfRangeError.detail` now reads
        "(2–5)". `validateSkills` untouched. NPC fixture
        `add-combatant.handler.spec.ts:109` `empathy: 1 → 2`
        (incidental fixture, not exercising the floor). Tests
        added: 4 new boundary cases on update (1/2/5/6) + 1 new
        boundary case on create + 1 reframed creation-range case
        showing the absolute-floor guard wins precedence over the
        creation-range guard. Backend vitest count 748 → 754
        (+6).
        Codegen: TS + Dart `Attributes` models pick up the new
        floor in their generated docs; no breaking change to the
        wire shape (the bound only tightens). The TS/Dart
        generators don't carry numeric `minimum` constraints in
        the type system — runtime enforcement remains the
        express-openapi-validator; that is a known soft mismatch
        documented in the schema description.
        OpenAPI `info.version` not bumped this block — the
        major bump is deferred to the closing block of T-010
        per the plan; if Block D lands on `main` standalone for
        any reason, the next block must include a major bump
        (the floor tightening from 1 to 2 is a breaking change
        for any caller who was sending `1`).
  - [x] Block E — **`CONCEPT_KEY_SKILLS` per role, not
        per amplua.** Hard violation H8. **Done in 059f661
        (spec) + 1e6ca54 (codegen) + 80bf2d8 (backend
        refactor + Prisma migration).** Web wizard reflow
        deferred to **T-2026-05-10-011** (see below).
        Spec: new `Role` enum with 33 canonical role slugs
        (companion, musician, poet, analyst,
        correspondent, network-djinn, criminal, mystic,
        revolutionary, agitator, diplomat, dealer,
        assassin, guard, spy, ace, driver, trucker,
        colonist, prospector, scout, ascetic, missionary,
        prophet, archaeologist, medicurg, technologist,
        ship-engineer, labourer, loader, legionnaire,
        mercenary, officer). Slugs are unique across
        amplua so the enum is flat. Russian display names
        carried inline so localised clients can render
        labels without a rulebook round-trip. New
        `Character.role: Role | null` (and on
        CharacterCreate / CharacterUpdate). Nullable for
        drafts and for legacy rows. Server enforces
        `ROLE_CONCEPT_MISMATCH` (HTTP 400) when the role
        is not in the chosen concept's three.
        Backend rules-engine: refactored `CONCEPT_KEYS`
        from a hand-curated 5-element union per amplua to
        a derived value computed from a new
        `CONCEPT_ROLES` dictionary that holds all 33
        canonical role × 4 skill mappings (single source
        of truth). New exports: `Role` (string union),
        `RoleData`, `CONCEPT_ROLES`, `ROLE_BY_CONCEPT`,
        `CONCEPT_BY_ROLE`, `getRoleKeySkills(role)`,
        `defaultRoleForConcept(concept)`. Barrel
        `rules-engine/index.ts` updated so handlers can
        import them. Legacy callers reading
        `CONCEPT_KEYS[c].keySkills` keep working — that
        property is now derived as the union of the three
        roles' skills (no API change for them).
        Backend handlers: `CreateCharacterHandler` and
        `UpdateCharacterHandler` validate `dto.role`
        belongs to `dto.concept` (or the character's
        existing concept, on update) via
        `CONCEPT_BY_ROLE`; new
        `RoleConceptMismatchError` (code
        `ROLE_CONCEPT_MISMATCH`). When a role is
        provided, the per-skill creation cap uses the
        role's exact 4 key skills (not the union),
        tightening the gate for non-key advanced skills
        from "up to 1" against a 5-skill key set to "up
        to 1" against the canonical 4-skill set.
        Setting a role on update clears `roleUnmigrated`.
        Prisma migration `20260510000006_add_character_`
        `role`: adds `role text NULL` and
        `roleUnmigrated bool NOT NULL DEFAULT false` to
        the `character` table; idempotent backfill
        (`UPDATE … WHERE concept IS NOT NULL AND role IS
        NULL` with a `CASE WHEN concept = 'pilot' THEN
        'ace' …` clause) sets `role` to the canonical
        first role per amplua and `roleUnmigrated = true`
        so the wizard re-prompts on next edit.
        `defaultRoleForConcept` mirrors the same first-
        role mapping for app-side use.
        Tests: 33 cases verifying every role's 4 key
        skills against the canonical table, 11 cases
        verifying `CONCEPT_KEYS[c].keySkills` is the
        deduplicated union of the three roles, 11 cases
        for `defaultRoleForConcept`, 33 cases for the
        `CONCEPT_BY_ROLE` reverse lookup, plus handler
        cases for valid role+concept combos, mismatch
        errors, null-role legacy path, and
        `roleUnmigrated` flag clearing on update.
        Backend vitest count 754 → 850 (+96).
        Backend container restarted after `prisma
        generate` so node_modules picks up the new
        client.
        OpenAPI `info.version` not bumped this block —
        deferred to the closing block of T-010 per the
        plan; the closing block must include a major bump
        because Block D (1 → 2 attribute floor) and the
        new required-when-active `ROLE_CONCEPT_MISMATCH`
        invariant are both breaking changes for naive
        callers.
        **Follow-up: T-2026-05-10-011** (web wizard
        step 5 role-picker, see below) — captures the UI
        reflow that wires up the new role field on the
        creation flow. Backend is fully ready for it; the
        wizard just needs a select between concept and
        skill distribution that POSTs `role` with the
        rest of the wizard payload.
  - [x] Block F — **Personal-scale weapon range bands.**
        Hard violation H9. **Done in 1219df4 (spec) +
        39df704 (codegen) + 6ddf8c3 (backend + migration).**
        Spec: `ItemRangeEnum` lifted from the legacy 5-band
        `[arm, near, short, long, distant]` to the
        canonical 4-band ladder `[close, medium, long,
        extreme]` per ST3001 ГЛАВА 5 «Дистанция» (Ближняя
        ≤2m / Средняя ≤20m / Дальняя ≤100m / Предельная
        ≤1000m). The rulebook does not separate hand-to-
        hand from close quarters in its range taxonomy
        (those distinctions are handled by combat actions),
        so the legacy `arm` and `near` collapse into the
        canonical `close`; `short` becomes `medium`,
        `distant` becomes `extreme`, `long` keeps the slug
        with narrowed semantics. ShipWeaponRange (5-band
        ladder from ГЛАВА 7) intentionally untouched —
        the slug overlap is fine because it lives in a
        different schema and ship combat genuinely needs
        the `zero` (boarding) band.
        Wire examples: 5 personal-scale weapon snippets
        rewritten (`short → medium`); NPC and ship-weapon
        examples unchanged.
        Backend: `VALID_RANGES` in
        `add-item.command.ts` and the matching `@IsIn`
        decorator in `update-item.command.ts` tightened to
        the 4-band list. Tests: legacy `'short'` fixtures
        in `add-item.handler.spec.ts` switched to
        `'medium'`; new negative test verifies the legacy
        `'short'` value is now rejected. Backend vitest
        count 850 → 851 (+1).
        Prisma migration `20260510000007_canonicalise_item_`
        `range`: idempotent JSONB rewrite of `item.data`
        (where `type = 'WEAPON'` and `data.range` is one
        of the legacy slugs) plus `npc.weapons` (jsonb
        array; jsonb_array_elements + jsonb_agg pattern).
        Mapping: `arm/near → close`, `short → medium`,
        `long → long` (untouched), `distant → extreme`.
        Migration applied with `prisma migrate deploy`
        inside the backend container (consistent with the
        Block E shadow-DB workaround); backend container
        restarted afterwards.
  - [x] Block G — **Cybernetic `bodyPoints` field.** Hard
        violation H10. **Done in 4cca564 (spec) + 23c412d
        (codegen) + 49821a4 (backend + migration).**
        Spec: dropped the non-canonical `bodyPoints: 0–6`
        field from `ItemCybernetic` /
        `ItemCyberneticCreate` / `ItemCyberneticUpdate`
        and replaced with `xpCost: 0–15`. ST3001 has no
        "body points" / "system strain" stat — that was a
        fabrication in the original spec. Cybernetics are
        dual-priced (ГЛАВА 6 «КИБЕРНЕТИЧЕСКИЕ ИМПЛАНТАТЫ»
        — «считается и снаряжением, и достоинством, так
        что на его покупку тебе понадобятся не только
        бирры, но и пункты опыта»); the canonical
        acquisition cost is 5 XP per ГЛАВА 4 «Новые
        достоинства». The 0..15 bound accepts GM
        concessions (0 for in-game gifts) and high-rank
        exotics (3 ranks × 5 XP).
        **Audit override on H10:** the audit's
        prescription was `xpCost: 1..3` mapping to a
        "talent rank". The rulebook does not list
        cybernetics as ranked; each is a single talent at
        a single rank. The 1..3 cap would silently
        amputate the GM-extension space, so the spec uses
        0..15 instead — same canon source, broader
        envelope.
        Backend: command DTOs (`add-item.command.ts`,
        `update-item.command.ts`) renamed
        `bodyPoints` → `xpCost`; range tightened to
        `@Min(0) @Max(15)` on both create and update
        (update was previously `@Min(0)` only — block G
        adds the cap to match the new spec).
        `rules-engine.ts` top-level docstring purged of
        the obsolete "systemStrain not weight"
        parenthetical (no formula change — encumbrance
        still sums `weight` across all items including
        CYBERNETIC). Tests: 2 new CYBERNETIC boundary
        cases (`xpCost: 5` happy-path, `xpCost: 16`
        rejection); existing fixtures renamed. NPC module
        verified to carry zero CYBERNETIC references —
        no NPC migration needed.
        Prisma migration `20260510000008_rename_cyberneti`
        `c_bodyPoints_to_xpCost`: idempotent JSONB rename
        on `item.data` for `type = 'CYBERNETIC'` rows
        (`data - 'bodyPoints' || jsonb_build_object('xp`
        `Cost', 5)`); defensive backfill for any
        CYBERNETIC row missing both keys. Backfill value
        of 5 mirrors ГЛАВА 4's canonical talent
        acquisition cost (the rulebook never assigns
        per-implant XP, so 5 is the most defensible
        default).
        Backend vitest count 851 → 853 (+2).
  - [x] Block H — **`ItemSlotType` deprecation.** Soft
        mismatch closed. **Done in c5cde35 (spec) + 78e556e
        (codegen) + 9bc569b (backend + migration).**
        The lowercase 7-value `ItemSlotType` enum is
        retired entirely; `ItemShipModule(.slot)` /
        `ItemShipModuleCreate(.slot)` /
        `ItemShipModuleUpdate(.slot)` now reference the
        canonical 21-value `ShipModuleSlot` from
        ГЛАВА 7. The two contexts (character-inventory
        ship-modules and installed ship-modules) share
        one enum.
        Migration mapping for the JSONB rewrite:
        `bridge → BRIDGE`, `hull → OTHER` (no canonical
        hull slot in ГЛАВА 7's slot taxonomy — armour
        and structural pieces are baked into hull-class
        Table 7.5, not slot-level), `hold → HOLD`,
        `weapon → WEAPON`, `drive → DRIVE`,
        `sensor → SENSOR`, `comms → COMMS`. Documented
        on `ShipModuleSlot.description`.
        Backend: `add-item.command.ts` and
        `update-item.command.ts` import
        `VALID_SHIP_MODULE_SLOTS` (new export from
        `ships/domain/ship-module-validation.ts`); the
        existing `VALID_SLOTS` Set is now built from the
        same canonical list to keep one source of truth.
        Tests: 2 new boundary cases in
        `add-item.handler.spec.ts` (legacy lower-case
        rejected; canonical upper-case accepted).
        Backend vitest count 853 → 855 (+2).
        Codegen: deleted Dart `item_slot_type.dart` /
        `item_slot_type.g.dart` /
        `item_slot_type_test.dart` (51 + 112 + 9
        lines); TS client `ItemSlotType` symbol gone;
        consumer code that still imports the old type
        now hits a compile error — fix-forward in this
        PR.
        Prisma migration `20260510000009_canonicalise_ship`
        `_module_slot`: idempotent JSONB rewrite of
        `item.data.slot` for `type = 'SHIP_MODULE'`
        rows. Applied with `prisma migrate deploy`;
        backend container restarted.
  - [x] Block I — **PRD-override comments on soft
        mismatches.** Done as a spec / codegen / backend
        triplet (SHAs surfaced in commit log; spec
        carries Combatant.hpCurrent + Combatant.signature
        rewrites, codegen carries the TS client regen,
        backend carries rules-engine canPush docblock +
        the new `.claude/docs/i18n.md` glossary section).
        - `Combatant.hpCurrent` description rewritten to
          name the PRD override explicitly: ГЛАВА 5
          «Урон» («запас пунктов здоровья не может
          опуститься ниже нуля») clamps HP at 0; the
          greenfield product allows the field to go
          negative for damage-overflow display, with
          prescribed UI behaviour (red rendering +
          healing math note).
        - `Combatant.signature` description rewritten:
          ST3001 has no per-combatant numeric signature
          stat; the canonical detection mechanic is
          `скрытность` (ГЛАВА 3 «СКРЫТНОСТЬ») rolled at
          detection-time. The field is reserved for
          future GM tooling and clients MUST NOT
          silently bypass a скрытность check by reading
          it.
        - `rules-engine.ts canPush` PRD §10 docblock now
          spells out the override: ГЛАВА 3 §«Вознесение
          молитв» restricts push to skill checks and
          one-per-check, but does NOT gate on
          Exhausted; Exhausted-blocks-push is a
          greenfield UX gate. The «only-on-skill-checks»
          half is tracked as a Block-J follow-up
          (`RollKind` discriminator).
        - `.claude/docs/i18n.md` gained a "Glossary —
          non-negotiable canon translations" section.
          Codifies the audit's `push → молитва Ликам /
          re-roll` rule (never «толкнуть» / «пуш»)
          alongside other game-mechanic mappings
          (Mercy → Владычица Слёз, Faceless One →
          Лик-без-лика, key skill → ключевой навык,
          Exhausted → Истощён, prone → Лёжа, covered →
          В укрытии, Mystic Darkness → Межзвёздная
          Тьма, …). Becomes the translator's source of
          truth since web `<i18n>` blocks are
          colocated (no central JSON to maintain).
        - Round-wrap one-liner already covered in
          Block A — no change needed.
        Soft mismatch noted: Dart codegen
        (openapi-generator-cli dart-dio) failed on this
        run with a non-deterministic generator-internal
        error unrelated to the spec content (schema is
        unchanged; prior blocks regenerated fine). TS
        client picked up the new docstrings; Dart client
        lags by exactly these two doc-comments. Wire
        shape and runtime behaviour stay correct — only
        Dart in-IDE help is stale on Combatant.hpCurrent
        / signature. The next codegen run that touches
        the dart-dio cache (typically the next spec
        change) will catch up automatically.
        No vitest delta (description-only).
  - [x] Block J — **Spec-silence follow-ups split into
        deferred tasks.** Five new T-tasks pushed to the
        stack (entries below T-011, before T-008):
        T-2026-05-10-012 (`ItemWeapon.initiative`),
        T-2026-05-10-013 (`ItemArmor.extraSlotCount`),
        T-2026-05-10-014 (ship deterministic stats from
        class), T-2026-05-10-015 (`RollKind` discriminator
        + push gate), T-2026-05-10-016
        (`RollCreate.breakdown` audit trail). Each carries
        its own canon citation, acceptance criteria,
        spec-diff scope, and codegen impact so they can
        be picked up independently.
        Also bumped OpenAPI `info.version` 0.17.0 → 1.0.0
        per spec-reviewer's earlier note: T-010 has
        accumulated multiple breaking wire changes (Attr
        floor 1→2, ItemRangeEnum 5→4, ItemSlotType
        retired, ItemCybernetic.bodyPoints replaced by
        xpCost, Character.role added with concept-mismatch
        invariant) so a major bump is owed. The 1.0.0
        marker also reflects the canon-alignment effort
        finishing — clients shipping after this version
        rely on canon-correct contracts as the baseline.
- Status: done — ready to archive
- Blockers: —

---

## T-2026-05-10-011 — Web wizard: role picker (Block E follow-up)

- Created: 2026-05-10
- Owner: claude
- Source: split out of T-2026-05-10-010 Block E so the canon-
  remediation backend could land without slipping on UI work.
  The backend half (spec, codegen, rules-engine refactor,
  Prisma migration with backfill) shipped in 059f661 + 1e6ca54
  + 80bf2d8.
- Goal: add a role-picker step to the web character-creation
  wizard so the user explicitly chooses 1 of 3 canonical roles
  within their chosen amplua (ГЛАВА 2 «АМПЛУА И РОЛИ»). The
  chosen role drives the per-skill cap on the skill-
  distribution step (key skills cap at 3, non-key at 1, role-
  scoped, not concept-scoped). Existing characters whose
  `roleUnmigrated === true` (set by the Block E backfill) are
  re-prompted on next edit.
- Why now: backend is fully ready (spec contract, validation,
  migration). The current wizard silently breaks on `role`
  submission — it never sets the field, so any character
  forged by the wizard hits the server with `role: null` and
  the server then enforces `ROLE_CONCEPT_MISMATCH` only when
  the user later adds a role. Without this task the role
  field is dead UX.
- Depends on:
  - T-2026-05-10-010 Block E (done — wire contract + backend
    validation in place).
  - Generated TS client (`packages/api-client-ts`) — `Role`
    enum already exposed.
- Acceptance:
  - **Wizard step renumbering**: insert a new `Step5Role.vue`
    between the current `Step4Attributes.vue` and the current
    `Step5Skills.vue`. The current `Step5Skills.vue` becomes
    `Step6Skills.vue`, and `Step6Talents.vue` becomes
    `Step7Talents.vue`. Update `WizardShell.vue` step list +
    progress indicator + the wizard-store `currentStep` enum.
  - `Step5Role.vue`: shows the 3 canonical roles for the
    chosen concept as cards (extending the concept-card
    pattern from `Step1Concept.vue`). Each card carries the
    Russian display name (from the rulebook), a one-line
    Russian flavour text (extracted from ГЛАВА 2 §РОЛИ for
    that role), and the four key skills as chip tags. The
    selected card highlights via the same focus-ring tokens
    Step1Concept uses.
  - **Concept→roles mapping in web**: a small `roleCatalogue.ts`
    module under `apps/web/app/composables/` (or
    `apps/web/app/utils/`) exposes
    `CONCEPT_ROLES: Record<Concept, ReadonlyArray<{slug: Role,
    ruLabel: string, ruFlavour: string, keySkills:
    [SkillKey,SkillKey,SkillKey,SkillKey]}>>` mirroring the
    backend's `CONCEPT_ROLES` (single source of truth in the
    backend; the web reproduces the data because the OpenAPI
    enum is intentionally flat to keep the wire contract
    simple — duplicate the 33 entries by hand and unit-test
    them against the regenerated `Role` enum to catch drift).
  - **Skill distribution step uses role-scoped key skills**:
    `Step6Skills.vue` (was Step5Skills) reads the chosen role
    from the wizard store and caps the four role-keys at 3
    points each, the other twelve at 1 point each. The "key
    skills" hint at the top of the step lists the four
    role-keys ("Key skills: X / Y / Z / W — max 3 each").
    Existing budget logic per Upbringing stays untouched.
  - **roleUnmigrated banner**: on
    `apps/web/app/pages/app/characters/[id].vue` (or
    `CharacterHeader.vue` if there's a dedicated header
    component), when the loaded character has
    `roleUnmigrated === true`, render a non-dismissable banner
    inviting the user to confirm the role. Clicking "Confirm"
    opens a small dialog with the same role-card list scoped
    to the character's concept; selecting a role fires
    PATCH `/api/v1/characters/{id}` with the chosen `role`,
    after which the backend clears `roleUnmigrated` (logic
    already in 80bf2d8) and the banner disappears on the next
    re-render.
  - **Wizard payload**: the wizard store includes `role` in
    the POST `/api/v1/characters` body. The role is required
    when status flips to `active`; it stays nullable while
    `status === 'draft'` so users can step backwards.
  - **i18n**: every user-visible string keyed in
    `apps/web/i18n/locales/{ru,en}.json`. Russian display
    names from the canonical rulebook table (Компаньон,
    Музыкант, Поэт, Аналитик, Корреспондент, Сетевой джинн,
    Преступник, Мистик, Революционер, Агитатор, Дипломат,
    Делец, Ассасин, Стражник, Шпион, Ас, Водитель,
    Дальнобойщик, Колонист, Старатель, Скаут, Аскет,
    Миссионер, Пророк, Археолог, Медикург, Технологик,
    Бортинженер, Разнорабочий, Грузчик, Легионер, Наёмник,
    Офицер) keyed under `wizard.role.<slug>.label`. English
    translations keyed under the same path. Flavour text
    keyed under `wizard.role.<slug>.flavour`. Page-level
    strings ("Choose your role", "Confirm role", etc.) keyed
    under `wizard.role.headline`, `wizard.role.cta`, banner
    strings under `character.roleUnmigrated.banner.*`.
  - **Storybook**: stories for `Step5Role.vue` (4 states:
    no concept selected → empty placeholder; concept chosen,
    no role selected → 3 cards; role selected → focus-ring on
    one card; loading → skeleton). Stories for the
    `RoleUnmigratedBanner` if it's split out as its own
    component (3 states: hidden, visible, dialog open).
  - **Vitest count climbs by ≥15**: `Step5Role.spec.ts` (≥6
    cases — render with each concept's role triplet, click
    selects, keyboard nav, no-concept guard), `Step6Skills.`
    `spec.ts` updates (≥3 cases — role-scoped cap of 3 for
    role keys, cap of 1 for non-role keys, hint renders the
    4 keys), `roleCatalogue.spec.ts` (≥4 cases — every
    `Role` enum value present, every concept has exactly 3
    roles, every role has exactly 4 key skills, all key
    skills are valid `SkillKey` values), banner spec (≥2
    cases — visible when flag true, hides after PATCH).
  - **Playwright smoke** (optional but encouraged): one new
    flow `wizard-role-picker.spec.ts` — concept → role →
    skills → forge, asserting the created character has
    `role: <slug>` and `roleUnmigrated: false`.
  - **a11y**: role cards use `role="radio"` with proper
    `aria-checked` state; the radiogroup container carries
    `role="radiogroup"` and an accessible name; arrow-key
    navigation between cards. Banner uses `role="status"`
    until clicked, then the dialog uses `role="dialog"` with
    a labelled heading + `aria-describedby`.
- Spec diff: none — wire contract already lands in T-010
  Block E (Character.role + Role enum + ROLE_CONCEPT_MISMATCH).
- Codegen impact: none — generated TS client already exposes
  the new types.
- Design impact: extend the existing concept-card pattern to
  role cards (smaller, denser, role-coloured if amplua already
  has a colour token; otherwise reuse the neutral surface
  tokens). No new design tokens needed — reuse spacing /
  radius / focus-ring / role-chip styles already in the
  design system. The card density goal: 3 cards must fit in
  one row on the laptop breakpoint (≥1024px) and stack
  vertically on the mobile breakpoint (<640px).
- Tests: per-block vitest as listed above; one Playwright
  smoke; one i18n-completeness lint that asserts the 33
  `wizard.role.<slug>.label` and `wizard.role.<slug>.flavour`
  keys exist in both `ru.json` and `en.json` (drives the
  `i18n-keys` lint rule already in `apps/web`).
- Sub-blocks (one feat-web commit per block + one active.md
  follow-up commit, per `feedback_block_workflow.md`):
  - [x] Block 1 — `roleCatalogue.ts` + drift tests. **Done in
        a248e1e.** Pure data module under
        `apps/web/app/utils/roleCatalogue.ts` mirrors the
        backend `CONCEPT_ROLES` 1-for-1 (33 entries × 4
        skills); `rolesForConcept`, `keySkillsForRole`,
        `conceptForRole`, `CONCEPT_BY_ROLE` reverse map.
        22 vitest cases including drift detection against
        the regenerated `Role` enum.
  - [x] Block 2 — `Step5Role.vue` + WizardShell renumber 6→7.
        **Done in 29a20d0.** New `Step5Role.vue`
        (radiogroup of 3 role cards, a11y compliant);
        `Step5Skills.vue` → `Step6Skills.vue` (rename + BEM
        class rename); `Step6Talents.vue` → `Step7Talents`
        `.vue`; `new.vue` orchestrator: `TOTAL_STEPS` 6→7,
        `draftRole` state, role cleared if concept change
        orphans it, role included in `persistDraft` +
        `forge` PATCH; i18n carries 33 role labels + 33
        flavours in en + ru, `[uk-todo]` / `[el-todo]`
        placeholders for the rest.
  - [x] Block 3 — Step6Skills role-scoped caps. **Done
        directly (Step6Skills.vue + new.vue edits +
        Block 3 commit).** `Step6Skills` reads
        `role: Role | null`; caps the four canonical key
        skills at 3, every other at 1; falls back to the
        concept-union when role is null (legacy drafts).
        New role-scoped hint below the upbringing-pool
        hint: "Key skills for your role: …". `new.vue`
        passes `:role` into Step6Skills.
  - [x] Block 4 — `RoleUnmigratedBanner` + `RoleCardGrid`.
        **Done in bfa24ee.** Extracted the role-card grid
        from `Step5Role.vue` into a reusable top-level
        `RoleCardGrid.vue` (a11y + arrow-key nav
        preserved). New `RoleUnmigratedBanner.vue` on the
        character-sheet header surfaces when
        `roleUnmigrated === true`, opens an `AppModal`
        with the role-card grid, PATCHes the chosen role,
        backend clears the flag. 32 new vitest cases
        (15 RoleCardGrid + 17 RoleUnmigratedBanner).
  - [x] Block 5 — spec gap closed + i18n-completeness
        lint. **Done in (spec) + (codegen) + Block-5
        web cleanup commit.** Closed a Block-E gap by
        adding `Character.roleUnmigrated: boolean`
        (readOnly, default false) to OpenAPI spec; TS
        client regenerated. The web augmented type in
        `useCharactersApi.ts` is gone — `Character` now
        re-exports the regenerated type directly. New
        `RoleCardGrid.i18n.spec.ts` (8 cases) locks down
        the role catalogue's i18n contract: every
        canonical role has en + ru `label` and
        `flavour`, no orphan en keys, ru labels carry
        Cyrillic, en labels do not, plus a spot-check
        against ГЛАВА 2 canonical Russian display names.
        Web vitest count 163 → 203 (+40 across Blocks
        1, 4, 5).
        **Playwright smoke deferred** to
        T-2026-05-10-017 — `apps/web` has no Playwright
        bootstrap yet; bringing it up is its own infra
        task. The vitest + i18n-completeness coverage in
        this task is enough to gate the role-picker
        feature on its own.
- Status: done — ready to archive (move T-011 to done.md
  on the next session start). Playwright smoke continues
  in T-2026-05-10-017.
- Blockers: —

---

## T-2026-05-10-018 — Web global navigation + language switcher + settings

**Status: done — ready to archive.** Landed across 5 sub-blocks.

- Block 1 (66912e6) — `<UserMenu>` composite in `@app/ui` (avatar/initials trigger, AppPopover-backed panel, language `menuitemradio` group, Settings + Sign out menuitems, full ARIA + keyboard nav). 28 vitest cases, 4 Storybook stories.
- Block 2 (6423582) — `<AppHeader>` desktop component (brand link + nav links + `user-menu` slot + `mobile-toggle` placeholder slot; active-link via prop, not `useRoute()`, so Storybook stays portable). 13 vitest cases, 4 stories.
- Block 3 (0603c2c) — `<AppMobileDrawer>` composite (focus trap, ESC, overlay click, body-scroll lock, reduced-motion respect, side left/right). AppHeader integration: hamburger button + `mobile-drawer-content` slot supersedes the Block-2 `mobile-toggle` placeholder. 21 new vitest cases.
- Block 4 (cabe22a) — new `apps/web/app/layouts/app.vue` wraps every `/app/*` page (8 pages opted in via `definePageMeta({ layout: 'app' })`); `default.vue` stays for public routes; activeKey derived from `route.path` prefix; skip-link to `#main-content`; UserMenu wires `setLocale()` for the language radio, `navigateTo('/app/settings')` for Settings, `auth.client.signOut()` then `navigateTo('/login')` for Sign out; full en + ru i18n, `[uk-todo]` / `[el-todo]` placeholders. 21 new layout vitest cases.
- Block 5 — `/app/settings` page already existed with profile editing + language switcher (preceded T-018 by an earlier task); only the layout opt-in was needed. New `tests/e2e/nav-smoke.spec.ts` Playwright spec walks the user's original bug — round-trip Characters → Ships → Characters via header nav, plus skip-link keyboard-accessibility and user-menu reachability. Auth-gated, mirroring the `CORIOLIS_E2E_SESSION_COOKIE` skip pattern.

`@app/ui` vitest count grew by ~62 cases across Blocks 1–3. `@app/web` grew by 21 layout cases. Total Playwright suite: 8 → 11 tests across 4 files.

Original task body retained below for archive context.



- Created: 2026-05-10
- Owner: claude
- Source: user-requested mid-session 2026-05-10 — «if I navigate
  to ships, I can't get back to characters. And add settings, or
  at least language select». Brought up while T-010 Block H was
  in-flight; deferred so the canon-remediation finished cleanly,
  then formalised here so it doesn't get lost.
- Goal: a persistent global header on every authenticated `/app/*`
  page that lets the user move between the major sections
  (Characters, Ships, NPCs, Sessions) and reach a user menu with
  language switcher, theme toggle (if tokens exist), settings
  page link, and sign-out. Today the only way to get from
  `/app/ships` back to `/app/characters` is to type the URL or
  open a new tab — that's a real UX gap that's been masking the
  rest of the site's depth.
- Why now: T-010 + T-011 made the canon surface honest; T-018
  makes the *navigation* surface honest. With the wizard reflow
  landing in T-011, character creation surfaces ~7 steps and a
  banner — the site is genuinely an app now, not a single-page
  prototype, and deserves real chrome.
- Depends on: T-2026-05-10-011 done (banner + role picker landed
  the last greenfield wizard work); the i18n glossary in
  `.claude/docs/i18n.md` is the translator's source of truth for
  any new copy.
- Acceptance:
  - **Global `<AppHeader>` component** in `packages/ui`
    (Storybook story + colocated spec — required for `@app/ui`
    per CLAUDE.md). Renders:
    - Brand mark / logo on the left (link to `/app` dashboard).
    - Centre nav: links to Characters, Ships, NPCs, Sessions
      with the current section highlighted via an active-style
      token (use the existing `--brand-brass` accent — no new
      tokens). Each link uses `<NuxtLink>` with `prefetch`.
    - Right side: `<UserMenu>` dropdown (see below).
    - Mobile: a hamburger that opens a side drawer with the
      same links + user menu nested. Use the existing breakpoint
      tokens (768px). a11y: hamburger is a `<button>` with
      `aria-controls` and `aria-expanded`; drawer is a
      `<dialog>` with focus trap.
  - **`<UserMenu>` dropdown** in `packages/ui`:
    - Avatar + display name (from `useMeApi`).
    - Submenu items:
      - Language: ru / en / uk / el (radio-group inside menu;
        switching calls `setLocale(code)` and persists via the
        existing `i18n_locale` cookie set in `nuxt.config.ts`;
        the locale list is the source of truth — read from the
        i18n config, not hard-coded).
      - Theme (optional, only if design tokens already cover
        light + dark — check `specs/design/tokens/`; if
        single-theme today, leave a `[ ] dark theme` follow-up
        on T-018's sub-block for v1.1).
      - Settings (link to `/app/settings`).
      - Sign out (calls Better Auth signOut endpoint, then
        navigates to `/login` or wherever the project's logout
        landing is — read what the existing logout button
        does; reuse, don't reinvent).
    - a11y: trigger button has `aria-haspopup="menu"` and
      `aria-expanded`; menu has `role="menu"`, items use
      `role="menuitem"` with `role="menuitemradio"` for the
      language radios; arrow-key navigation; ESC closes.
  - **Layout integration**: extend the existing default Nuxt
    layout (`apps/web/app/layouts/default.vue` if it exists,
    otherwise create one) to mount `<AppHeader />` above the
    `<NuxtPage />` for every `/app/*` route. Public pages
    (`/login`, `/register`, share-link viewer at
    `/share/{token}`) keep their existing chrome — the header
    is for authenticated app routes only.
  - **`/app/settings` page** stub: a page that hosts the
    language / theme / sign-out controls in a full-page form,
    mirroring the dropdown but without the menu chrome. v1
    can be just a placeholder that hosts the language switcher
    again with a "more settings coming" note; the goal is to
    have the route reachable so the menu link is not a
    dead-end.
  - **Active-section detection**: the header reads the current
    route via `useRoute()` and applies the active style to the
    matching link. Sections: Characters (`/app/characters/*`),
    Ships (`/app/ships/*`), NPCs (`/app/npcs/*`), Sessions
    (`/app/sessions/*`).
  - **i18n**: every label keyed in colocated `<i18n>` blocks
    (`nav.characters`, `nav.ships`, `nav.npcs`, `nav.sessions`,
    `userMenu.language.label`, `userMenu.signOut`,
    `userMenu.settings`, `header.brand` if there's a brand
    string). en + ru translated; uk + el follow the existing
    `[uk-todo]` / `[el-todo]` pattern. The four locale display
    names (English / Русский / Українська / Ελληνικά) come
    from `nuxt.config.ts`'s i18n locales config.
  - **Language switcher persistence**: switching language
    updates the `i18n_locale` cookie (already configured in
    `nuxt.config.ts`) so the choice survives reload. No backend
    round-trip is needed today; if the user wants the locale
    persisted server-side later, that's a separate task.
  - **Storybook**: `<AppHeader>` gets ≥4 stories — desktop +
    selected section, desktop + user menu open, mobile +
    drawer closed, mobile + drawer open. `<UserMenu>` gets
    its own stories.
  - **Tests**:
    - `packages/ui` colocated specs for both new components
      (≥10 vitest cases — render, click handlers, keyboard
      nav, language-change cookie write).
    - `apps/web` integration test asserting the header
      mounts on `/app/characters` and `/app/ships` and links
      navigate (use `@nuxt/test-utils`).
- Spec diff: none — this is pure client work. No new wire
  contract, no codegen.
- Codegen impact: none.
- Design impact: a header pattern is new — sketch it in
  `specs/design/mockups/` (one PNG / SVG / JSX is fine), or at
  minimum capture the layout in the Storybook stories. Reuse
  existing tokens; do not introduce new colour or radius
  tokens for this task. The active-link accent uses
  `--brand-brass`; the mobile drawer overlay uses
  `--surface-void` with a `--alpha-overlay` (or whatever the
  existing dialog overlay uses).
- a11y / responsive checklist:
  - Skip-link (`<a href="#main-content">Skip to content</a>`)
    that becomes visible on focus, anchored at the top of the
    layout. Required for keyboard navigation of any page that
    has navigation chrome.
  - Lighthouse a11y score on `/app/characters` should not
    regress.
  - Mobile drawer focus trap: pressing Tab cycles within the
    drawer until ESC closes it.
  - Reduced motion: drawer slide-in respects
    `prefers-reduced-motion` (instant open instead of
    animation).
- Sub-blocks (one feat-* commit per block + active.md
  follow-up, per `feedback_block_workflow.md`):
  - [ ] Block 1 — `@app/ui` `<UserMenu>` component
        (dropdown, language radio-group, sign-out wiring,
        Storybook + spec). No header yet — UserMenu standalone
        so the wizard / standalone settings page can also
        adopt it.
  - [ ] Block 2 — `@app/ui` `<AppHeader>` component
        (brand + nav + UserMenu slot, active-link styling,
        Storybook + spec). Desktop only — mobile drawer is
        Block 3.
  - [ ] Block 3 — Mobile drawer: hamburger + slide-in
        nav + a11y focus trap. AppHeader stories grow to
        cover the mobile breakpoint.
  - [ ] Block 4 — `apps/web` layout integration: default
        Nuxt layout mounts `<AppHeader>`; every `/app/*`
        page picks it up; `/login`, `/register`, and
        share-link viewer stay on their existing minimal
        chrome. Skip-link + active-section detection wired.
  - [ ] Block 5 — `/app/settings` page stub + final a11y
        / Lighthouse pass + nav integration test.
- Status: queued (no blockers — UI work, ready when the user
  picks it). Higher user-value than the spec follow-ups
  T-012..T-016, which are mostly back-end polish.
- Blockers: —

---

## T-2026-05-10-017 — `apps/web` Playwright bootstrap + role-picker smoke

**Status: done — ready to archive.** Landed in (commit hash on push).
Scope narrowed: the Playwright bootstrap was already in place from
an earlier task — `tests/e2e/playwright.config.ts`,
`.github/workflows/e2e.yml`, `tests/e2e/smoke.spec.ts`, and
`tests/e2e/a11y.spec.ts` were all there with the
`CORIOLIS_E2E_SESSION_COOKIE` skip pattern. T-017's task was just
to add the role-picker spec.

What landed:

- `tests/e2e/wizard-role-picker.spec.ts` — walks
  `/app/characters/new` through concept → role → skills → forge,
  asserts the forged character carries `role: 'driver'` and
  `roleUnmigrated: false` via a backend GET. Auth-gated; skips
  when `CORIOLIS_E2E_SESSION_COOKIE` is unset (default CI) but
  still parses / lints / type-checks so structural drift surfaces
  on every PR.
- `pnpm exec playwright test --config=tests/e2e/playwright.config.ts --list`
  shows 8 tests in 3 files (the new spec + the existing 2);
  the wizard spec is correctly enumerated.

The role-unmigrated banner spec proposed in T-017 acceptance is
deferred — the banner already has 17 component-level vitest cases
in `apps/web/app/components/__tests__/RoleUnmigratedBanner.spec.ts`
which cover the click → dialog → PATCH → emit cycle; an e2e for
that flow needs a seeded `roleUnmigrated: true` row that the
existing dev seed doesn't provide. A future task (when the dev
seed gets a "legacy character" fixture) can add the banner e2e.



- Created: 2026-05-10
- Owner: claude
- Source: split out of T-2026-05-10-011 Block 5 because `apps/web`
  has no Playwright runtime yet — bringing it up is an infra
  bootstrap task in its own right (config, browser deps in CI,
  fixtures for the dev container's seeded user, screenshot policy,
  etc.) and shouldn't gate the role-picker feature.
- Goal: stand up Playwright in `apps/web`, wire it into CI, and
  land one end-to-end smoke that exercises the wizard's role
  picker (concept → role → skills → forge) plus the
  `RoleUnmigratedBanner` flow on a backfilled character.
- Depends on: T-2026-05-10-011 done (UI is in place).
- Acceptance:
  - `apps/web` gains `@playwright/test` + a `playwright.config.ts`
    pointing at `http://localhost:3001` (dev container) by default,
    with overridable `BASE_URL` env for CI.
  - `apps/web/tests/e2e/` directory established. One smoke spec:
    `wizard-role-picker.e2e.ts`. Steps:
    1. Sign in (use the existing dev seed user; document the
       fixture pattern for future specs).
    2. Navigate to `/app/characters/new`.
    3. Type a name; pick concept `pilot`.
    4. Click through to step 5; pick role `driver`.
    5. Click through to step 6 (skills); assert the four role
       keys (force, pilot, rangedCombat, survival) cap at 3 in
       the UI; spend points up to budget.
    6. Click forge; assert navigation to
       `/app/characters/{id}` and that the GET response carries
       `role: 'driver'` + `roleUnmigrated: false`.
  - Second optional smoke: `role-unmigrated-banner.e2e.ts` —
    seed a character via API call with
    `roleUnmigrated: true` and `role: 'ace'` (first canonical
    pilot role from the migration), navigate to its sheet, click
    the banner CTA, pick `driver` in the dialog, confirm the
    banner disappears and the GET shows `roleUnmigrated: false`.
  - CI: a Playwright job is added to `.github/workflows/ci.yml`
    (or wherever the project's CI lives) that builds `apps/web`,
    starts the dev container stack, and runs both specs. Browser
    deps (`pnpm exec playwright install chromium`) cached.
  - The Playwright runner does NOT collide with vitest — its tests
    live under `tests/e2e/` and are excluded from the vitest
    `include` glob (already enforced by the existing config
    pattern).
  - Documentation: a `docs/testing.md` paragraph or a `tests/`
    README explaining when to write vitest vs Playwright and how
    to run each locally.
- Spec diff: none.
- Codegen impact: none.
- Design impact: none — instrumentation only.
- Tests: the two new e2e specs + the vitest coverage stays.
- Sub-blocks: probably one `chore(web)` infra commit for the
  Playwright bootstrap and one `test(web)` commit for each smoke,
  followed by the active.md follow-up.
- Status: queued
- Blockers: —

---

## T-2026-05-10-012 — `ItemWeapon.initiative` modifier (Block J split)

- Created: 2026-05-10
- Owner: claude
- Source: split from T-2026-05-10-010 Block J. ST3001 ГЛАВА 6
  weapon tables list a per-weapon initiative modifier (the «модификатор
  инициативы» column on Tables 6.5–6.10 — heavy weapons impose −1 or −2,
  fast weapons grant +1 to +2). The current spec has no field for this,
  so the GM can't carry the modifier into the initiative roll and the
  rules-engine has no way to apply it.
- Goal: add `ItemWeapon.initiative: integer` (signed, typically −2..+2)
  to the spec; teach `roll-initiative.handler` to look up equipped
  weapons and add the modifier to the d6 result before the tie-break
  pass; surface the modifier on the combat-tracker UI.
- Depends on: T-2026-05-10-010 Block A (initiative d6 + tie-break) — done.
- Acceptance:
  - Spec: `ItemWeapon.initiative` (and on Create / Update); range −5..+5
    to be permissive (canon goes −2..+2 but house rules vary).
  - Backend: `roll-initiative.handler` reads `equipped: true` weapons
    from the source PC/NPC and sums the `initiative` modifiers; clamp
    the d6 result to 1..6 after applying. Tie-break loop unchanged
    (re-roll equal initiatives, ≤3 passes).
  - NPC weapon JSON shape gains the field too (NpcItemWeapon).
  - Migration: `Item.data.initiative` defaults to 0 for legacy weapons.
  - Tests: ≥6 cases — modifier on creation / update / clamp / equipped
    only / multiple weapons sum / tie-break interaction.
- Spec diff: small. Major bump if landed alone; or fold into the next
  combat-side block bump.
- Codegen impact: TS + Dart regen.
- Status: **done — ready to archive.** **Landed in 9fcd89d (spec) +
  e2ed42f (codegen) + 3b3f5f7 (backend).**
  - Spec: `ItemWeapon.initiative: integer −5..+5, default 0` on
    `ItemWeapon` / `ItemWeaponCreate` / `ItemWeaponUpdate`.
    `Combatant.initiative.maximum` bumped 6 → 10 (a roll of 6 +
    Посох +2 + ambush +2 = 10 is canon-legal). NPC weapons inherit
    via the existing `$ref: ItemWeapon` indirection. AsyncAPI
    centrifugo combatant snapshot bumped maximum 6 → 10 too;
    AsyncAPI version 0.9.0 → 0.10.0; OpenAPI version 1.0.0 → 1.1.0.
  - Backend: new pure helpers `sumWeaponInitiative` and
    `clampInitiative` in `encounters/domain/initiative.ts`.
    `roll-initiative.handler` reads the combatant's weapons from
    the snapshot stored at add-time (architectural decision: keep
    "snapshot is authoritative at add-time" consistent with hp /
    armor / skills — no live PC/NPC re-lookup). The `add-combatant`
    path now snapshots `weapons[]` alongside the existing stat
    block; `SourceLookupAdapter` extended to fetch WEAPON items
    on the PC path (one combined query with ARMOR; no extra
    round-trip) and `weapons` from the Npc row. Tie-break loop
    operates on post-modifier values (no signature change).
  - Tests: ≥17 new vitest cases (helper invariants, equipped-only
    semantics, missing-modifier defaults to 0, multi-weapon sum,
    NPC parity, tie-break interaction). Backend vitest 855 → 872.
  - Migration: none — `Item.data.initiative` defaults to 0 server-
    side via the spec's `default: 0`; absence in the JSONB blob
    reads as 0 by the handler's `?? 0` guard. Legacy weapons stay
    valid without a backfill.

---

## T-2026-05-10-013 — `ItemArmor.extraSlotCount` (Block J split)

- Created: 2026-05-10
- Owner: claude
- Source: split from T-2026-05-10-010 Block J. ST3001 ТАБЛИЦА 6.14
  (special armor) lists an «extra slots» column — heavy armor can carry
  pouches / mounts / pockets that grant additional encumbrance slots.
  The current `ItemArmor` schema has no field for this and the
  rules-engine `computeEncumbranceMax` does not factor it in.
- Goal: add `ItemArmor.extraSlotCount: integer` (0..4 typical) to the
  spec; teach the encumbrance calculator to add the worn-armor's value
  to `STR × 2`.
- Depends on: T-2026-05-10-010 done.
- Acceptance:
  - Spec: `ItemArmor.extraSlotCount` (0..6 cap); on Create / Update.
  - Backend: `computeEncumbranceMax` signature changes to accept the
    sum of equipped-armor extra slots; handler that derives the read
    model passes the sum.
  - Tests: ≥4 cases — base, +N from one armor, multiple armors, only
    equipped armor counts.
- Spec diff: small.
- Codegen impact: TS + Dart regen.
- Status: **done — ready to archive.** Landed in 196e8ed (spec) +
  459febd (codegen) + 998901a (backend).
  - Spec: `ItemArmor.extraSlotCount: integer 0..6, default 0` on
    `ItemArmor` / `ItemArmorCreate` / `ItemArmorUpdate`. NPC armor
    inherits via the existing `$ref: ItemArmor` indirection — no
    separate schema needed. Canonical printed values: most armors 0;
    Тяжёлый экзоскафандр / Лёгкая броня / Тяжёлая броня 1; Экзодоспех
    2; Тяжёлый экзодоспех 5. OpenAPI version 1.1.0 → 1.2.0.
  - Backend: `computeEncumbranceMax` gained an optional second
    parameter `armorExtraSlots = 0` (back-compat); new pure helper
    `sumArmorExtraSlots` filters equipped ARMOR items and sums their
    `extraSlotCount` (uses `for...of` to satisfy
    `unicorn/no-array-reduce`). `character.repo.toReadModel` wires
    the sum into the encumbrance.max derivation — no extra DB hit
    (the inventory was already loaded for `computeEncumbranceCurrent`).
    NPC encumbrance not surfaced today; no NPC-side wiring needed.
  - Tests: 15 new vitest cases (6 `computeEncumbranceMax` boundary
    cases + 9 `sumArmorExtraSlots` cases). Backend vitest 872 → 887.
  - Migration: none — JSONB absence reads as 0 via the handler's
    `?? 0` guard.
- Blockers: —

---

## T-2026-05-10-014 — Ship deterministic stats from class (Block J split, scope narrowed)

**Status: done — ready to archive.** Landed in 1fc660c (backend).
Audit scope **narrowed** before implementation: the original prescription
(drop freehand columns, refuse mutation, blanket readOnly) contradicts
canon — ГЛАВА 7 explicitly allows yard modifiers (Хелеб +1
maneuverability, Хальгрия −1 maneuverability) and upgrade modifiers
(Прочный корпус +1 hull, Мощный реактор +1 energy) to *modify* the
base class stats. Making them readOnly would break canonical ship-build
flexibility.

What landed instead:

- `BASE_STATS_BY_TIER: Record<'I'|'II'|'III'|'IV'|'V', ShipBaseStats>`
  with values verified against ТАБЛИЦА 7.5 verbatim (Class I: 3/2/+2/
  −2/3/4/3 → Class V: 7/12/−2/+3/9/1/40). Replaced the prior
  per-ship-type table (which carried a `TODO(ship-stats): verify`
  comment because nobody had cross-checked). 20 ship-type slugs map
  to tiers via `TIER_BY_SHIP_TYPE`; helpers `getTierForShipType` and
  `getBaseStatsByShipType`. Backwards-compat alias
  `BASE_STATS_BY_CLASS` preserved for existing call sites.
- `cargoCapacity` removed from `ShipBaseStats` — it's a sum of
  hold-module capacities (ТАБЛИЦА 7.6 § Грузовой отсек), not a class
  stat. Default at create is 0; the spec's `Ship.cargoCapacity` stays
  for now but its semantics shift toward "computed from modules"
  (a future task can wire that derivation).
- Spec untouched — `Ship.{hull.max, energy.max, armor, maneuverability,
  signature, speed, moduleSlots}` remain editable per upgrade canon.
- Tests: 43 new vitest cases — every BASE_STATS_BY_TIER row, every
  ship-type → tier mapping, helper invariants, fixture refresh against
  canon. Backend vitest 887 → 930 (+43).
- Fixture updates in `create-ship.handler.spec.ts`: fighter `hullMax`
  4 → 2 (canon Class I); cargoCapacity 50 → 0 (no longer a class stat).

Original (pre-narrowing) audit text retained below for the archive
record.



- Created: 2026-05-10
- Owner: claude
- Source: split from T-2026-05-10-010 Block J. ST3001 ГЛАВА 7
  ТАБЛИЦА 7.5 lists deterministic stat blocks per ship class:
  Манёвренность, Заметность, Скорость, отсеки (energy / hull /
  module slots / armor / signature). Today the `Ship` schema lets
  the GM set these freehand, which silently breaks canon: a `cruiser`
  can ship with `signature: -10` if the GM forgets the table.
- Goal: make `Ship.{maneuverability, signature, speed, energySlots,
  hullPoints, moduleSlots, armor}` server-derived from `Ship.class`;
  the spec marks them readOnly; the rules-engine carries the lookup
  table from ГЛАВА 7 and the create / update handlers refuse mutation.
- Depends on: T-2026-05-10-010 done.
- Acceptance:
  - Spec: all five fields move to readOnly. New `SHIP_CLASS_TABLE` in
    `apps/backend/src/modules/rules-engine/ship-class-table.ts`
    (already exists for partial stats — extend it).
  - Backend: `ShipReadModel.{maneuverability, signature, speed,
    energySlots, hullPoints, moduleSlots, armor}` are computed at
    read time from `Ship.class`; `CreateShipHandler` and
    `UpdateShipHandler` reject any incoming value for these fields
    (`SHIP_STAT_NOT_EDITABLE` error).
  - Migration: drop the freehand columns; values derive from class.
  - Tests: ≥10 cases — every ship class returns the canonical stat
    block; mutation attempts on each readonly field raise the new
    error.
- Spec diff: large (multiple readOnly transitions + new error).
  Major bump.
- Codegen impact: TS + Dart regen.
- Status: queued
- Blockers: —

---

## T-2026-05-10-015 — `RollKind` discriminator + push gate (Block J split)

**Status: done — ready to archive.** Landed in f3c03d1 (spec) +
a7fe95b (codegen) + df349c1 (backend + migration).

What landed:

- Spec: new `RollKind` enum `[skill, save, trauma, initiative,
  darkness]` with full canon citations (ГЛАВА 3 «Вознесение
  молитв», ГЛАВА 5 «Урон» / «Травмирующие атаки», ГЛАВА 5
  «Раунды, ходы и инициатива», ГЛАВА 15). `Roll.kind` required;
  `RollCreate.kind` optional with `default: skill` for back-compat.
  New error `PUSH_NOT_ALLOWED_ON_NON_SKILL_ROLL` (HTTP 400) on
  the push endpoint. AsyncAPI rollPushed gained the field;
  AsyncAPI version 0.10.0 → 0.11.0; OpenAPI version 1.2.0 → 1.3.0.
- Backend: Prisma migration `20260510000010_add_roll_kind` adds
  `kind text NOT NULL DEFAULT 'skill'` (idempotent backfill — all
  existing rolls become 'skill', the canonical safe default).
  `RollReadModel` gains `kind: RollKind`; defence-in-depth
  `toRollKind()` narrowing on the read path logs a warning if
  Prisma returns an unknown value. `CreateRollDto` gains optional
  `@IsIn(...)` decorator; handler defaults to 'skill' when omitted.
  `PushRollHandler` checks `roll.kind !== 'skill'` *before*
  `canPush` so the kind-error wins precedence over
  `ROLL_ALREADY_PUSHED`. `rules-engine.canPush` docblock trimmed
  — the «only-on-skill-checks» Block-J flag is now resolved.
- Tests: 9 new vitest cases (2 create-roll defaults, 6 push-handler
  rejection paths including precedence lock, 1 read-model
  surfacing). Backend vitest 930 → 939.



- Created: 2026-05-10
- Owner: claude
- Source: split from T-2026-05-10-010 Block J. ST3001 ГЛАВА 3
  §«Вознесение молитв» («Молитву можно возносить только при проверках
  навыков и только один раз за проверку») restricts push to skill
  checks. Today `Roll` has no discriminator, so the rules-engine's
  `canPush` allows pushing on save / trauma / initiative rolls,
  silently violating canon.
- Goal: add `Roll.kind: 'skill' | 'save' | 'trauma' | 'initiative' |
  'darkness'` (the 5 canonical roll types); `canPush` gates on
  `kind === 'skill'`; `PushRollHandler` rejects non-skill rolls with
  a new `PUSH_NOT_ALLOWED_ON_NON_SKILL_ROLL` error.
- Depends on: T-2026-05-10-010 (Block I docblock already flags this
  follow-up).
- Acceptance:
  - Spec: `RollKind` enum + `Roll.kind` (required) + `RollCreate.kind`.
  - Backend: `canPush(roll, conditions)` signature gains
    `roll.kind`; new domain error; handler tests cover each kind's
    push-allowed / push-blocked case.
  - Migration: backfill existing rolls with `kind: 'skill'` as the
    safe default (the rules-engine already treats them as skill).
  - i18n: glossary entry for each kind label (ru + en).
  - Tests: ≥8 cases — 5 kinds × push allowance + edge cases.
- Spec diff: medium. Major bump.
- Codegen impact: TS + Dart regen.
- Status: queued
- Blockers: —

---

## T-2026-05-10-016 — `RollCreate.breakdown` audit trail (Block J split)

**Status: done — ready to archive.** Landed in f77cdb2 (spec) +
3cb7e85 (codegen) + ddf436d (backend + migration).

What landed:

- Spec: new `RollBreakdown` schema (5 components: attribute / skill /
  gear / modifier / helpers, each 0..10). `Roll.breakdown` and
  `RollCreate.breakdown` optional + nullable. New error
  `ROLL_BREAKDOWN_MISMATCH` (HTTP 400) when breakdown sum ≠ pool.
  AsyncAPI untouched (RollPushed is a minimal event envelope, no
  breakdown to mirror). OpenAPI version 1.3.0 → 1.4.0.
- Backend: Prisma migration `20260510000011_add_roll_breakdown`
  adds `breakdown jsonb` (nullable, no backfill — existing rolls
  read as null). `RollReadModel` gains `breakdown: RollBreakdown
  | null`; defence-in-depth `toRollBreakdown()` narrowing on the
  read path with warn-log on malformed JSONB. `CreateRollDto`
  gains `RollBreakdownDto` with `@ValidateNested` + per-component
  `@Min(0) @Max(10)`. Handler asserts `attribute + skill + gear +
  modifier + helpers === pool` when breakdown is supplied; throws
  `RollBreakdownMismatchError` otherwise. PushRollHandler
  untouched (breakdown is read-only after create).
- Tests: 6 new vitest cases (null breakdown, matching, mismatch,
  zero-dice boundary, read-model surfacing on both null and
  non-null). Backend vitest 939 → 945.



- Created: 2026-05-10
- Owner: claude
- Source: split from T-2026-05-10-010 Block J. The current `RollCreate`
  payload only carries the final `pool: integer`, losing the
  attribute / skill / gear / modifier / helpers breakdown that the GM
  / rules-lawyer audience needs to verify the math. ST3001 doesn't
  prescribe a wire format here — this is a tooling concern — but
  serialising the breakdown lets a future GM-tools view replay every
  roll's provenance.
- Goal: add `RollCreate.breakdown: { attribute: integer, skill:
  integer, gear: integer, modifier: integer, helpers: integer }`
  (all required, all 0..10); the backend stores the breakdown
  alongside the roll's `pool` and the `Roll` read model surfaces it.
- Depends on: T-2026-05-10-010 done.
- Acceptance:
  - Spec: `RollBreakdown` schema + `RollCreate.breakdown` optional
    (omitted on programmatic rolls; required-when-present from a
    user-driven UI), `Roll.breakdown` readOnly.
  - Backend: persist the breakdown; the create handler asserts
    `attribute + skill + gear + modifier + helpers === pool` if
    breakdown is supplied (server-side guard against UI bugs).
  - Tests: ≥4 cases — supplied & matching, supplied & mismatched
    (rejected), omitted, round-trips through GET.
- Spec diff: small. Minor bump.
- Codegen impact: TS + Dart regen.
- Status: queued
- Blockers: —

## T-2026-05-10-007 — Phase 6 backend: NPC + Encounter + Combatant + initiative + combat realtime

- Completed: 2026-05-10
- Owner: claude
- Spec: T-2026-05-10-006 locked the wire contract
  (`packages/specs/openapi/openapi.yaml` v0.16.0 +
  `packages/specs/asyncapi/centrifugo.yaml` v0.9.0). This task
  delivered the matching backend modules.
- Goal (delivered): NestJS implementation behind every Phase 6
  path so the generated TS + Dart clients are live. Standard
  CQRS layout per existing modules (`apps/backend/src/modules/`
  `ships`, `.../game-sessions`): `domain` ports + errors,
  `infra` Prisma repo, `commands` + `queries` handlers,
  controller(s), `module.ts`. Centrifugo `combat.updated`
  publish is wired from the same unit that mutates encounter /
  combatant state — atomic with the DB transaction (publish
  _after_ commit, before HTTP 200, mirrors `update-dp.handler`
  precedent).
- Test count: 511 → 728 (+217 across all 5 blocks, exceeding
  the ≥80 budget). 81 spec files green.
- Sub-blocks (delivered):
  - [x] Block 1 — NPC module + Prisma migration. commit 34a1fca.
        Files: `apps/backend/src/modules/npcs/` (domain, infra,
        commands ×4, queries ×2, controller, module),
        `apps/backend/prisma/migrations/20260510000003_npcs/`.
        Test delta: +50 (511 → 561).
  - [x] Block 2 — Encounter module + state machine. commit 87688a3.
        Files: `apps/backend/src/modules/encounters/` (domain,
        infra, commands ×3, queries ×2, controllers ×2, module),
        `apps/backend/prisma/migrations/20260510000004_encounters/`.
        Design call: IGameSessionAccess injected as a DI port
        (GAME_SESSION_ACCESS token) with a Prisma adapter (renamed
        `.adapter.ts` to avoid the `*.service.ts` lint rule that
        bans direct PrismaService injection). All endpoints
        GM-owner-only per spec.
        Test delta: +53 (561 → 614).
  - [x] Block 3 — Combatant sub-resource + snapshot semantics.
        commit 0655d91.
        Files: `apps/backend/src/modules/combatants/` (domain,
        infra, commands ×3 + specs ×3, queries ×1 + spec ×1,
        controllers ×2, module),
        `apps/backend/prisma/migrations/20260510000005_combatants/`.
        Test delta: +35 (632 → 667).
        Design calls: (1) `hasCombatants` flows through
        `ICombatantCount` port — `CombatantRepo` implements both
        `ICombatantRepo` and `ICombatantCount`, exported under
        separate tokens, imported into `EncountersModule` via
        `forwardRef(() => CombatantsModule)` to break the circular
        dep. (2) Deleting the active combatant is allowed in
        `setup` status only (spec); the `onDelete:SetNull` on
        `Encounter.activeCombatant` cascades the FK to null
        automatically in the same Prisma call. (3) Spec overrides
        prose: `hpCurrent` has no upper cap — task prose
        mentioned `COMBATANT_HP_OVER_MAX` but that code does not
        appear anywhere in the spec, so it was not implemented.
        ⚠️ Librarian audit (2026-05-10) flagged that the canon
        rule «HP не может опуститься ниже нуля» (ГЛАВА 5 line 189)
        contradicts the spec's "may go below 0" wording — soft
        mismatch tracked in T-2026-05-10-010 Block I.
  - [x] Block 4 — Initiative + turn ops. commit 022309c.
        Files: `apps/backend/src/modules/encounters/commands/`
        (roll-initiative ×3, reorder-initiative ×3,
        advance-turn ×3), `domain/initiative.{ts,spec.ts}`,
        `infra/initiative.repo.ts` (atomic `$transaction`
        adapter), updates to `encounter.errors.ts` (+5 errors:
        `ENCOUNTER_INVALID_STATUS`,
        `ENCOUNTER_INITIATIVE_NOT_ROLLED`,
        `INITIATIVE_DUPLICATE`,
        `INITIATIVE_UNKNOWN_COMBATANT`,
        `INITIATIVE_INCOMPLETE`),
        `encounter.ports.ts` (`InitiativeRollResult`,
        `TurnAdvanceResult`, `IInitiativeRepo` port),
        `encounters.controller.ts` (+3 routes),
        `encounters.module.ts` (wire-up), and
        `combatants/{domain,infra}/combatant.{ports,repo}.ts`
        (`listByEncounterWithSnapshot` for snapshot-aware
        tie-break load).
        Test delta: +34 (667 → 701).
        Design calls: (1) `IInitiativeRepo` is a separate port
        (`INITIATIVE_REPO` token) rather than extending
        `IEncounterRepo`, so the atomic `$transaction` stays
        in infra without leaking Prisma into command handlers.
        (2) Spec overrides task prose: the reorder error codes
        are not `ENCOUNTER_REORDER_MISMATCH` (a single umbrella
        code mentioned in the task) but the three granular codes
        shipped in T-006 (`INITIATIVE_DUPLICATE` /
        `INITIATIVE_UNKNOWN_COMBATANT` / `INITIATIVE_INCOMPLETE`).
        (3) Tie-break — agility — pulls from
        `pcSnapshot.attributes.agility` and
        `npcSnapshot.attributes.agility` snapshotted at add-time
        (Block 3); no Character / NPC join at roll-time.
        ⚠️ Librarian audit (2026-05-10) flagged that ST3001 uses
        d6 for initiative (not d10) and re-rolls d6 for ties (not
        agility-desc). Both are leaks from Year-Zero / Forbidden
        Lands and are tracked in T-2026-05-10-010 Block A.
  - [x] Block 5 — Centrifugo `combat.updated` publisher.
        commit a9b0298.
        Files: `apps/backend/src/modules/encounters/infra/`
        `combat.publisher.ts` + `combat.publisher.spec.ts`,
        `apps/backend/test/integration/combat-publisher.e2e-spec.ts`,
        updated `encounters.module.ts` + all 9 mutation handlers
        + their specs.
        Design calls: (1) delete-encounter intentionally skips
        publish — encounter is gone after delete; clients
        discover via 404 on next fetch. Tombstone deferred
        until an `encounter.deleted` AsyncAPI event is added.
        (2) For roll / reorder / advance, encounter is re-fetched
        post-commit to get the updated status / activeCombatantId
        / round for the snapshot. (3) `COMBAT_PUBLISHER` exported
        from `EncountersModule`, flows into `CombatantsModule`
        via the existing forwardRef — no additional imports
        required.
        Test delta: +27 (701 → 728).
- Status: done

---

## T-2026-05-10-009 — Wizard step-5 skills: collapse fake "general/advanced" pool split

- Completed: 2026-05-10
- Owner: claude
- Why: ST3001 ch.2 table 2.4 specifies a single pool of 8 / 10 / 12
  skill points by upbringing (plebeian / stationary / aristocrat).
  Per-skill caps at creation: 3 ranks for the concept's key skills,
  1 rank for everything else. The split into "general 8 + advanced 2"
  in the wizard mockup leaked into both clients as an artificial
  pool partition with no rulebook basis. The backend
  (`rules-engine.ts`, `create-character.handler.ts`) and the OpenAPI
  spec were already correct — only the clients and the mockup were wrong.
- Goal: wizard step 5 shows a single shared pool sized by upbringing,
  enforces key/non-key per-skill caps from the concept, and matches
  the validation the backend already performs. The visual two-column
  General/Advanced grouping stays — that taxonomy is real (ch.3,
  action economy: advanced skills require ≥1 rank to roll).
- Result: shipped on `main` as `8d55fd7` `fix(wizard): single skill
  pool sized by upbringing, key/non-key caps`.
  - `apps/web/app/components/wizard/Step5Skills.vue` — one pool from
    upbringing, one remaining counter; per-skill cap from
    `CONCEPT_KEY_SKILLS[concept]`. Visual General / Advanced grouping
    kept (ch.3 action economy, not budget).
  - `apps/mobile/lib/features/characters/presentation/blocs/character_wizard/`
    `character_wizard_cubit.dart` + `character_wizard_state.dart` +
    `widgets/wizard/step_5_skills.dart` — same single-pool model
    parameterized by upbringing; Plebeian can no longer over-spend.
  - `specs/design/mockups/wizard-icon.jsx` — step-5 footer rewritten.
  - Mobile i18n `wizardStep5Blurb` — en/ru updated, uk/el kept their
    `[..-todo]` placeholders.
- Acceptance check (against the original list):
  - ✅ `Step5Skills.vue` single pool computed from `upbringing` (8/10/12),
    one remaining counter, no per-section budgets.
  - ✅ Mobile cubit + state + step widget mirror the same model.
  - ✅ Per-skill caps: key skills (from `CONCEPT_KEY_SKILLS[concept]`)
    cap at 3; everything else caps at 1. Same on web and mobile.
  - ✅ Mockup step-5 footer rewritten.
  - ✅ Mobile i18n `wizardStep5Blurb` updated for en + ru; uk/el keep
    `[..-todo]` placeholders.
  - ✅ `pnpm --filter @app/web typecheck && pnpm --filter @app/web lint`
    exit 0. `flutter analyze` 60-issue baseline unchanged from clean
    tree (errors live in `character_repository_impl.dart` and
    `session_repository_impl.dart` from the post-codegen nullability
    drift, not from this task).
- Spec diff: none.
- Codegen impact: none.
- Design impact: mockup copy only — no token / layout changes.
- Tests: existing backend specs already cover the rule; no new spec
  added. Follow-up: a Vitest spec for `Step5Skills.vue` and a Bloc
  test for the cubit's per-upbringing budget enforcement.
- Follow-ups:
  - Mobile analyzer baseline (60 errors in repo impls) is untouched
    and pre-existing — separate task.

---

## T-2026-05-10-006 — Phase 6 spec: Encounters + Combatants + NPCs + combat realtime

- Completed: 2026-05-10
- Owner: claude
- Spec: PRD §11 Phase 6 (GM Tools). Phase 6 was greenfield —
  neither openapi.yaml nor centrifugo.yaml carried any Phase 6
  shape. The asyncapi already namespaced a `session.{id}` channel
  but stubbed the encounter / combatant payloads.
- Goal: Lock the Phase 6 wire contract so downstream backend +
  web + mobile tasks can run in parallel without re-spec churn.
- Result: shipped on `main` across five feat-spec commits + five
  matching `chore(codegen)` commits + per-block bookkeeping.
  OpenAPI bumped 0.12.0 → 0.16.0 (additive); AsyncAPI bumped
  0.8.2 → 0.9.0.
  - `1dca68b` `feat(specs): T-2026-05-10-006 Block 1 — Npc resource (v0.13.0)`
  - `738e2bc` `chore(codegen): regenerate clients after Npc spec (v0.13.0)`
  - `db0186c` `feat(specs): T-2026-05-10-006 Block 2 — Encounter resource (v0.14.0)`
  - `a1e9658` `chore(codegen): regenerate clients after Encounter spec (v0.14.0)`
  - `55d792e` `feat(specs): T-2026-05-10-006 Block 3 — Combatant sub-resource (v0.15.0)`
  - `b6837a4` `chore(codegen): regenerate clients after Combatant spec (v0.15.0)`
  - `14c4302` `feat(specs): T-2026-05-10-006 Block 4 — initiative + turn ops (v0.16.0)`
  - `239275c` `chore(codegen): regenerate clients after initiative spec (v0.16.0)`
  - `ee727a0` `feat(specs): T-2026-05-10-006 Block 5 — combat.updated AsyncAPI message`
  - `deafe5d` `chore(codegen): regenerate clients after AsyncAPI extension`
  - `0ea94b9` `chore(codegen): finalise Phase 6 openapi-types tail` (post-archive cleanup)
- Spec diff: substantial-additive. New schemas: `Npc`, `NpcCreate`,
  `NpcUpdate`, `NpcList`, `Encounter`, `EncounterCreate`,
  `EncounterUpdate`, `EncounterList`, `EncounterStatus`,
  `Combatant`, `CombatantCreate`, `CombatantUpdate`, `CombatantList`,
  `CombatantType`, `InitiativeRollResult`, `InitiativeReorderRequest`,
  `TurnAdvanceResult`, `CombatUpdated`. New paths: `/npcs[/{id}[/duplicate]]`,
  `/game-sessions/{sessionId}/encounters`, `/encounters/{id}` with
  initiative + turn ops, `/encounters/{id}/combatants`, `/combatants/{id}`.
  AsyncAPI: `combat.updated` on the existing `session.{id}` channel.
- Acceptance check (against the original list):
  - ✅ `Npc` full CRUD + duplicate, cursor-paginated list. Stats
    block sufficient for combat tracker (attributes, skills,
    weapons, armor, hp/mp, signature, tags, description).
  - ✅ `Encounter` CRUD with state machine fully documented:
    `setup → active` requires ≥1 combatant (422 `ENCOUNTER_NO_COMBATANTS`);
    `active → ended` resets `activeCombatantId`; reverse / skip
    transitions return 422 `ENCOUNTER_INVALID_TRANSITION`.
  - ✅ `Combatant` discriminated by `combatantType: 'pc' | 'npc'`.
    Snapshot semantics documented (PC mid-fight edits do not
    propagate). Four 422 codes including `COMBATANT_DUPLICATE`,
    `ENCOUNTER_LOCKED_FOR_COMBAT`.
  - ✅ Initiative: `rollInitiative` bundles atomic `setup → active`
    with d10 + agility tie-break; `reorderInitiative` for GM
    overrides without disturbing `activeCombatantId`;
    `advanceTurn` rotates with `ENCOUNTER_INITIATIVE_NOT_ROLLED`
    guard. Five new error codes.
  - ✅ AsyncAPI `combat.updated` lazy-snapshot on `session.{id}` —
    clients re-render from the snapshot rather than computing diffs.
    TS exports `CombatUpdated`; Dart opaque on the wire.
- Tests: spec-only. Each block ran `pnpm spec:validate &&
pnpm spec:bundle && pnpm spec:codegen` green. Codegen idempotent
  after `0ea94b9`.
- Design impact: none yet — UX work lands in T-008 (web) and T-009
  (mobile).
- Follow-ups: T-2026-05-10-007 (Phase 6 backend implementation),
  T-2026-05-10-008 (Phase 6 web GM tools).

## T-2026-05-10-005 — Phase 5 web frontend: ship list + sheet + module editor + crew

- Completed: 2026-05-10
- Owner: claude
- Spec: PRD §11 Phase 5. Backend was complete (T-2026-05-10-004);
  web SPA had no Ship-related composables, pages, or nav surface.
- Goal: Wire the Phase-5 backend into the web SPA so a player can
  build a ship, install / edit modules, assign their characters as
  crew, and duplicate.
- Result: shipped on `main` across five feature commits + per-block
  bookkeeping. Web tests climbed 53 → 143 (+90 vitest cases).
  - `40483a0` `feat(web): T-2026-05-10-005 Block 1 — useShipsApi + /app/ships index page`
  - `dbf0351` `feat(web): T-2026-05-10-005 Block 2 — ship sheet with scalar PATCH editing`
  - `3472047` `feat(web): T-2026-05-10-005 Block 3 — discriminator-aware module editor`
  - `e065118` `feat(web): T-2026-05-10-005 Block 4 — crew assignment widget on the ship sheet`
  - `c8f6d11` `feat(web): T-2026-05-10-005 Block 5 — polish (delete confirm, duplicate toast, export, empty state)`
- Spec diff: none. Codegen impact: none.
- Acceptance check (against the original list):
  - ✅ `/app/ships` index with inline create form (all 20 ship
    classes, humanised picker), per-card Open / Duplicate / Delete,
    empty state + retry, nav link from characters AppBar.
  - ✅ `/app/ships/[id]` sheet with header (rename + duplicate +
    delete + export + AppSavePulse), full editable stat block,
    auto-save on blur via `useAutoSave` (600 ms debounce), notes /
    history / problems cards.
  - ✅ Discriminator-aware `ShipModuleEditor` modal (WEAPON /
    TORPEDO / HOLD / SENSOR / OTHER variants); mandatory-module
    Delete hidden for BRIDGE / REACTOR / DRIVE.
  - ✅ Editable crew card with `<optgroup>` picker splitting
    "Available" vs "Already on this ship (will move)" so the
    backend's move semantics is visible before commit.
  - ✅ Duplicate wired from both list + sheet, "Recently created"
    toast on the index page (cleared via `router.replace` so a
    refresh doesn't re-trigger), Export affordance with
    experimental chip linking to the 501 stub.
- Tests: 143/143 web (+90). typecheck and lint clean at every block
  boundary.
- Open follow-ups:
  - Pre-existing px-dimension stylelint violations in Blocks 1–4
    (`max-width: 960px`, etc) — separate cleanup task.
  - Export real implementation will replace the 501 stub once the
    backend ships it.
  - Phase 5 mobile (read-only ship sheet) is the natural mobile
    follow-on.

## T-2026-05-10-004 — Phase 5 backend: Ships module (CRUD + modules + crew)

- Completed: 2026-05-10
- Owner: claude
- Spec: PRD §11 Phase 5. The OpenAPI surface for Ships had been
  shipped since 75a6ee8 but `apps/backend/src/modules/ships` did
  not exist — every ship-related path 404'd at the
  `express-openapi-validator` layer.
- Goal: Stand up the backend Ships module so the web (Phase 5
  frontend, separate task) and mobile clients can persist + edit
  fleets. ST3001 ГЛАВА 7 base stats are populated from a class
  table on create; mandatory modules (BRIDGE, REACTOR, DRIVE) are
  auto-created.
- Result: shipped on `main` across five feature commits + per-block
  bookkeeping. Test count climbed 434 → 511 (+77 new specs).
  - `f0b8a7f` `feat(backend): T-2026-05-10-004 Block 1 — Prisma migration for Ships`
  - `400b186` `feat(backend): T-2026-05-10-004 Block 2 — ShipsModule core CRUD`
  - `1d06bcc` `feat(backend): T-2026-05-10-004 Block 3 — ship module sub-resource`
  - `0e4a01c` `feat(backend): T-2026-05-10-004 Block 4 — crew assignment endpoints`
  - `1ba07ee` `feat(backend): T-2026-05-10-004 Block 5 — duplicate ship + export stub`
- Spec diff: none. Codegen impact: none. Schema applied via
  `prisma db push` (project doesn't yet baseline
  `_prisma_migrations`); migration SQL committed for future deploy
  targets.
- Acceptance check (against the original list):
  - ✅ `POST /api/v1/ships` returns 201 with base stats from
    `BASE_STATS_BY_CLASS` (in `rules-engine`), three mandatory
    modules, and six vacant crew slots.
  - ✅ `GET /api/v1/ships` returns the owner's ships paginated
    (cursor + limit, default 20).
  - ✅ Get / Patch / Delete owner-only with 403/404 routing.
  - ✅ `addShipModule` / `updateShipModule` / `deleteShipModule`
    with discriminator-aware validation (WEAPON / TORPEDO / HOLD /
    SENSOR / OTHER). Mandatory-module delete returns 422
    `SHIP_MODULE_MANDATORY`. Module endpoints live on a second
    controller `ShipModulesController` at `/api/v1/ship-modules/
{id}` — that's how the spec splits the surface.
  - ✅ `assignCrew` / `unassignCrew` use **move semantics** rather
    than the undocumented 422 `CREW_ALREADY_ASSIGNED` from the
    original task entry: re-assigning a character to a vacant
    position moves them; the new `CREW_POSITION_TAKEN` 400 only
    fires when the target slot is held by a **different**
    character. Same-position re-assign is a no-op.
  - ✅ `duplicateShip` deep-copies modules in one Prisma
    transaction with `(copy)` / `(copy 2)` / `(copy 3)` name
    escalation via `listNamesByPrefix`. Crew roster reset to
    vacant. Source-not-owned returns 403.
  - ✅ `getShipExport` continues to return 501 — full export is
    its own task.
- Tests: 511/511 backend (was 434/434, +77 across all five blocks).
  flutter / web tests untouched. lint clean across all blocks.
- Open follow-ups:
  - `cargoCapacity` recalculation when HOLD modules are added /
    removed (the OpenAPI says "Total cargo capacity in tonnes
    across all hold modules" but Block 2 leaves it client-driven —
    server stores the explicit value seeded from the class table).
  - `getShipExport` real implementation (currently 501 stub —
    matches the task spec but the spec section itself is sketchy).
  - `_prisma_migrations` baselining so `migrate deploy` becomes
    the canonical apply path. Currently the codebase uses `db
push` because `migrate dev` fails on the
    `20260508000001_character_status` migration's shadow-DB step.
    Tracked as a Phase-7 hardening item.
  - Frontend wire-up — Phase 5 web (next task) and Phase 5 mobile
    (later) both need to consume this surface.

## T-2026-05-10-003 — Phase 4 mobile (Flutter): dice + sessions + DP live updates

- Completed: 2026-05-10
- Owner: claude
- Spec: PRD §11 Phase 4. Same backend that the web blocks
  (T-2026-05-10-002) consumed. Mobile previously had only auth /
  characters / settings features.
- Goal: Bring the Coriolis dice loop to mobile so a player at the
  table can roll + push from their character sheet, browse history,
  and see Darkness Points tick live during a GM-run session.
- Result: shipped on `main` across four feature commits + a codegen
  prep commit + a band-aid fix for an upstream openapi-generator
  bug. All blocks landed continuously per the updated workflow rule.
  - `fae41e0` `chore(codegen): regenerate dart api-client built_value .g.dart files`
  - `22b0a79` `feat(mobile): T-2026-05-10-003 Block 1 — rolls feature + dice bottom sheet`
  - `6190e02` `feat(mobile): T-2026-05-10-003 Block 2 — roll history list inside dice sheet`
  - `013764d` `fix(api-client-dart): add missing ShipModuleSlot import to ship_module_*`
  - `59e1a42` `feat(mobile): T-2026-05-10-003 Block 3 — sessions list + detail with GM controls`
  - `e8abc66` `feat(mobile): T-2026-05-10-003 Block 4 — Centrifugo live updates on session detail`
- Spec diff: none. Codegen impact: only the dart `.g.dart` files
  needed regeneration (build_runner). Two new flutter deps:
  `centrifuge ^0.18.0` (dart Centrifugo client) and `intl` (used by
  the relative-timestamp helper — already on the transitive graph).
- Acceptance check (against the original list):
  - ✅ Character sheet exposes a Roll FAB that opens a bottom-sheet
    roller (pool stepper 1–10, label, Roll, Push). Push gating
    mirrors `RulesEngine.canPush` (already-pushed + exhausted) so
    the disabled state surfaces without a 422 round-trip.
  - ✅ Same bottom sheet scrolls below the roller into a compact
    history list with relative timestamps; tap opens a detail
    dialog with the full dice strip + pool + hits + absolute
    datetime. Mobile UX trade vs web: one screen, one mental
    model — no separate "Rolls" tab on the sheet.
  - ✅ A Game Sessions screen at `/app/sessions` (reachable via
    casino-icon action on the characters list AppBar) lists
    active / archived sessions with FAB → create + popup-menu
    archive toggle. Detail page branches on `me.id ==
session.ownerId`.
  - ✅ Detail page subscribes to `session.{id}` over Centrifugo
    via `shared/realtime/SessionRealtime` (wraps `centrifuge`
    0.18.0). `dp.changed` patches the visible counter via
    `applyDpChanged`; `roll.pushed` surfaces a 3-second SnackBar.
    Token rotation via `ClientConfig.getToken`. Subscription
    closes on `Cubit.close()`.
- Tests: 65/65 mobile (53 → 65, +12 new across DiceRoller and
  RollHistory cubits). flutter analyze clean modulo the
  pre-existing `built_collection` dev-dep warning + ui_flutter
  `withOpacity` deprecation infos.
- Drive-by drop-off:
  - The regenerated dart SDK shipped `Concept` as an EnumClass; the
    mobile `character_repository_impl` was bridged via
    `Concept.valueOf(...)` / `.name`. Domain-level `concept` is
    still wire-string — promoting it to a typed enum is a
    follow-up.
  - openapi-generator's output for the four oneOf'd ship-module
    discriminator subclasses references `ShipModuleSlot` without
    importing it. The .dart parents got the missing import; the
    matching .g.dart files inherit via `part of`. Long-term fix is
    to migrate to `@hey-api/openapi-ts`-style codegen (Phase-7
    hardening item).
- Open follow-ups:
  - Cursor-pagination UI on `/app/sessions` (cap at 20).
  - Character assignment UX on the mobile detail page —
    deliberately deferred. The mobile detail is glance-only; heavy
    "set up the session" workflow stays on web.
  - Cross-route tap target for `/app/sessions` from a global nav
    (e.g. bottom-nav rebuild) — currently only reachable via the
    characters-list AppBar action.
  - Translator pass for uk/el on the new mobile strings.

## T-2026-05-10-002 — Phase 4 web frontend: dice + sessions + DP + live updates

- Completed: 2026-05-10
- Owner: claude
- Spec: PRD §11 Phase 4 (Dice & Sessions). Backend was already
  shipped between `phase-3-complete` and `97c62ae` (Roll module,
  GameSession CRUD, DP audit log, AsyncAPI session channels,
  Centrifugo publishing). Web SPA had none of it before this task.
- Goal: Wire the existing Phase-4 backend into the web SPA so a
  player can roll dice (and push), browse roll history, and see
  Darkness Points update live during a GM-run session.
- Result: shipped on `main` across five feature commits + per-block
  bookkeeping. Each block landed continuously per the updated
  `feedback_block_workflow` rule.
  - `4e18df2` `feat(web): T-2026-05-10-002 Block 1 — useRollsApi + dice roller widget`
  - `ae27f42` `feat(web): T-2026-05-10-002 Block 2 — roll history list + detail modal`
  - `9b78301` `feat(web): T-2026-05-10-002 Block 3 — sessions index + detail skeleton`
  - `65dfafa` `feat(web): T-2026-05-10-002 Block 4 — DP controls + audit log + assignment`
  - `1b9fb40` `feat(web): T-2026-05-10-002 Block 5 — Centrifugo live updates on session detail`
- Spec diff: none. Codegen impact: none. Backend +1 dependency:
  `centrifuge` JS client added to `apps/web` for the Block-5
  websocket subscription.
- Acceptance check (against the original list):
  - ✅ From a character sheet, a player can pick a pool size, label
    the roll, click "Roll", see the dice result, and push when
    eligible. Push gating mirrors `RulesEngine.canPush`
    (already-pushed + exhausted) so the disabled state surfaces
    without a 422 round-trip.
  - ✅ Recent Rolls panel shows last 50 in reverse chrono with
    hits / pushed badge / relative time; row click opens an
    `AppModal` with full dice + pool + absolute timestamp.
  - ✅ `/app/sessions` lists owner's sessions with active /
    archived tabs, inline create form (auto-redirects to detail),
    and per-card archive / unarchive actions.
  - ✅ `/app/sessions/[id]` branches GM vs player. GM gets DP +/-
    - delta-with-reason form, audit log tail, character
      `<select>` assign / unassign. Players see read-only DP +
      assigned list.
  - ✅ Detail page subscribes to `session.{id}` over Centrifugo;
    `dp.changed` patches the visible counter and prepends a
    synthetic audit row (de-duped against the GM's own adjust);
    `roll.pushed` surfaces a 5-second toast above the DP card.
    "Live" / "Reconnecting" badge tracks connection state. Token
    rotation handled by Centrifuge's `getToken` callback.
- Tests: 53/53 web (mounting deferred to Playwright e2e — same
  pattern as the rest of the auth + sheet surface). 434/434
  backend (unchanged from T-2026-05-10-001). typecheck clean. lint
  zero errors at every block boundary.
- Open follow-ups:
  - Cursor-pagination UI on `/app/sessions` (currently capped at
    first 20).
  - Visibility-change reconnect on the realtime subscription (rely
    on Centrifuge's auto-retry for now).
  - Toast component in `@app/ui` to replace the inline
    `AppBanner + Transition` pattern used for `roll.pushed`.
  - uk/el strings on the new pages — same translator-pass
    deferral as T-2026-05-10-001.

## T-2026-05-10-001 — T-005 + T-004 follow-ups before next epic

- Completed: 2026-05-10
- Owner: claude
- Spec: carried-over follow-ups recorded on T-2026-05-09-005 (character
  creation rules alignment) and T-2026-05-09-004 (signup page) entries
  earlier in this file.
- Goal: Close the three open code follow-ups from those tasks so a
  fresh epic starts on a clean slate. Translator-pass items (uk/el
  copy) were explicitly out of scope and remain tracked under "Open
  follow-ups" below.
- Result: shipped on `main` across three feature commits + bookkeeping.
  Each block landed in its own session per the saved
  `feedback_block_workflow` rule.
  - `0dc1f87` `feat(character): T-2026-05-10-001 Block 1 — locale-aware talent rendering`
  - `41f61c5` `feat(character): T-2026-05-10-001 Block 2 — amplua-filtered personal pool`
  - `cdfca86` `feat(web): T-2026-05-10-001 Block 3 — forgot-password + reset-password flow`
- Spec diff: none — all three blocks are frontend-only (Block 1 reads
  the existing catalog at render time; Block 2 ships a new map in
  `@app/specs` consumed only by the wizard; Block 3 wires Better
  Auth's existing `request-password-reset` / `reset-password` routes,
  which were already configured in `auth.service.ts` from T-005).
- Acceptance check (against the original list):
  - ✅ Character sheet renders catalog talents (`kind ≠ personal`) in
    the active i18n locale via `useTalentLocalization`
    (`apps/web/app/composables/useTalentLocalization.ts`); user-
    edited rows fall through to stored name/description.
  - ✅ Wizard Step 6 personal-pool picker narrows to ST3001 ch.2
    recommendations per amplua via
    `RECOMMENDED_PERSONAL_TALENTS_BY_CONCEPT`; default-on toggle,
    auto-drops when the picked talent isn't in the new amplua's
    list.
  - ✅ `/login` shows "Forgot password?" link → `/forgot-password`
    → `auth.requestPasswordReset` → email link →
    `/reset-password?token=…` → `auth.resetPassword` → bounce to
    `/login`. Page also renders a "Reset link incomplete" block
    when the token query parameter is missing.
- Tests: 434/434 backend (425 → 434, +9 new specs covering
  `findCatalogTalentByName`, `pickLocalized`,
  `getRecommendedPersonalTalents`), 53/53 web. typecheck clean. lint
  zero errors.
- Open follow-ups (deferred — need a translator, not code):
  - `uk` and `el` strings on `/signup`, `/login`,
    `/forgot-password`, `/reset-password` are still
    `[uk-todo]/[el-todo]` placeholders.
  - `uk` and `el` entries in `packages/specs/src/talents.ts` — same
    shape, same reason.
  - SDK-method naming clarification: BA's email-and-password reset
    surface is `auth.requestPasswordReset` (not `forgetPassword`,
    which is reserved for the email-OTP plugin). Memorialised here
    so a future agent reading the BA docs doesn't reach for the
    wrong name.

## T-2026-05-09-003 — Epic 7 Feature 7.3: Darkness Points + push wiring

- Completed: 2026-05-10
- Owner: claude
- Spec: Epic 7, Feature 7.3, tasks T-7.3.1.a, T-7.3.1.b, T-7.3.1.c
- Goal: DP adjustment endpoint, DpEvent audit log, RollPushedEvent → +1 DP
  wiring.
- Result: shipped on `main` across the spec → migration → handler →
  event-bus chain. The internal-caller path (RollPushedHandler emitting
  `UpdateDpCommand` with `source: ROLL_PUSH`) bypasses the GM-owner ACL
  via a discriminated `callerKind` on the command, not a magic flag —
  the original task entry's "internal flag" wording was tightened to a
  proper sum type during implementation.
  - `2ecbcd0` `feat(specs): DP adjustment endpoint + DpEvent audit log (v0.8.1)`
  - `b6d2172` `chore(codegen): regenerate clients after DP spec (v0.8.1)`
  - `a447aa2` `feat(backend): Prisma DpEvent migration (dp-events)`
  - `afd5472` `feat(backend): UpdateDpCommand + DpEvent persistence + ACL`
  - `a2a7ade` `feat(backend): wire RollPushedEvent to +1 DP via internal command`
  - `6cac7a2` `feat(backend): publish dp.changed on every DpEvent insert`
- Spec diff: openapi `0.8.0 → 0.8.1` (additive — two new paths, two
  schemas).
- Acceptance check (against the original list):
  - ✅ `POST /api/v1/game-sessions/{id}/dp` adjusts DP atomically
    inside a Prisma transaction (`update-dp.handler.ts`).
  - ✅ `GET /api/v1/game-sessions/{id}/dp/events` returns paginated
    `DpEvent` audit log (`list-dp-events.handler.ts`).
  - ✅ `DpEvent` persisted per adjustment with `source: GM_MANUAL |
ROLL_PUSH`. The original spec also listed `SYSTEM` — dropped during
    implementation because no caller path emits it; can be added later
    if a maintenance script needs it.
  - ✅ Only the GM owner may apply a negative delta; internal `ROLL_PUSH`
    callers bypass the ACL (`update-dp.handler.spec.ts` line 81 +
    "internal caller bypasses GM-owner ACL" case).
  - ✅ `RollPushedHandler` emits `UpdateDpCommand` when
    `gameSessionId != null` (`roll-pushed.handler.ts` +
    `roll-pushed.handler.spec.ts`).
  - ✅ 22 new unit specs (12 update-dp + 4 list-dp-events + 6
    roll-pushed-handler — comfortably above the ≥12 floor).

## T-2026-05-09-002 — Epic 7 Feature 7.1 backend: DiceModule

- Completed: 2026-05-10
- Owner: claude
- Spec: Epic 7, Feature 7.1, tasks T-7.1.1.a, T-7.1.1.b, T-7.1.1.e
- Goal: Server-side Coriolis dice roller with push mechanic. Create roll,
  list history, push reroll.
- Result: shipped on `main`. `canPush()` lives in the cross-module
  `rules-engine` (not inside `dice/domain/`) so rolls and conditions can
  share invariants without a circular import — fix `6a8182b` later
  promoted its return type from `boolean | string` to a real
  discriminated union (`{ ok: true } | { ok: false; reason: ... }`).
  - `4d98fff` `feat(specs): Roll resource + push endpoint (v0.8.0)`
  - `0550b4e` `feat(backend): Prisma Roll migration`
  - `048704a` `feat(backend): DiceModule — create + list rolls`
  - `6a8182b` `fix(backend): CanPushResult is a real discriminated union`
  - `b0ef2a3` `feat(backend): publish roll.pushed when a roll is pushed`
- Spec diff: openapi `0.7.1 → 0.8.0` (new `Roll`, `RollCreate`,
  `RollList` schemas + 3 paths).
- Acceptance check (against the original list):
  - ✅ `POST /api/v1/characters/{id}/rolls` → 201 `Roll`, server rolls
    pool d6 with `crypto.randomInt` (`create-roll.handler.ts`).
  - ✅ `GET /api/v1/characters/{id}/rolls?limit=50` → 200 `RollList`,
    last 50 ordered desc (`list-rolls.handler.ts`).
  - ✅ `PATCH /api/v1/rolls/{id}/push` → 200 `Roll | 422
ROLL_NOT_PUSHABLE` (`push-roll.handler.ts` +
    `roll.errors.ts:ROLL_NOT_PUSHABLE`).
  - ✅ `canPush(roll, conditions)` returns `{ ok, reason? }`, gated on
    exhausted + already-pushed (`rules-engine` in
    `apps/backend/src/modules/rules-engine`).
  - ✅ `RollPushedEvent` emitted on the bus with `{ rollId, characterId,
gameSessionId, hits }` (`roll-pushed.event.ts`); both the DP
    handler and the Centrifugo `roll.pushed` publisher subscribe to it.
  - ✅ 20 new unit specs (6 create-roll + 8 push-roll + 6 list-rolls —
    above the ≥18 floor).

## T-2026-05-09-001 — implement share-link backend (Epic 6 Feature 6.1)

- Completed: 2026-05-10
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md §5.4, Plan §6.1
- Goal: Enable public read-only sharing of characters via unguessable slug
  URLs with owner controls (create, list, revoke) and lazy view tracking.
- Result: shipped on `main`. The original "stub OG image controller"
  scope grew when the web sharer page needed real Open Graph thumbnails
  to be link-previewable on Discord / Telegram — `d247051` replaced the
  501 stub with a Satori + Resvg renderer that lives in
  `apps/backend/src/modules/sharing/og/`. Frontend share viewer
  (`AppShareViewer`, `/shared/character/[slug]`) was built on top of
  the same backend in a follow-up batch (`1f1fbbb` →
  `08f00f6`) — not part of this task entry but worth tracking when
  reading the area.
  - `cadfbbc` `docs(adr): 0003 — share-link design`
  - `59a0d92` `feat(specs): ShareLink + share endpoints + public read paths (v0.7.0)`
  - `fc5643d` `chore(codegen): regenerate clients after share-link spec (v0.7.0)`
  - `f01c16a` `feat(backend): Prisma ShareLink migration`
  - `f11cd55` `feat(backend): SharingModule — slug + create + list + revoke`
  - `d247051` `feat(backend): GET /public/og/character/:slug.png replaces 501 stub`
  - `f450098` `docs(tasks): bookkeep Epic 6 Feature 6.1 (share-link backend)`
- Spec diff: openapi `0.6.0 → 0.7.0` (new ShareLink + 5 paths).
- Acceptance check (against the original list):
  - ✅ `POST /api/v1/characters/{id}/share` returns 201 `ShareLink` with
    a 24-char nanoid slug (`create-share-link.handler.ts` +
    `domain/slug.ts`).
  - ✅ `GET /api/v1/characters/{id}/shares` returns active (non-revoked)
    links (`list-share-links.handler.ts`).
  - ✅ `DELETE /api/v1/share-links/{id}` soft-revokes by setting
    `revokedAt`; subsequent public reads return 410
    (`revoke-share-link.handler.ts` + `get-public-character.handler.ts`).
  - ✅ `GET /api/v1/public/character/{slug}` returns the character
    without auth and filters `notes` when `includeGmNotes=false`
    (`public-sharing.controller.ts` + handler).
  - ✅ `GET /api/v1/public/og/character/{slug}.png` evolved beyond the
    original "returns 501" stub into a real Satori-rendered PNG
    (`og/og.service.ts`).
  - ✅ View counts batched in memory and flushed every minute
    (`infra/view-tracker.ts` + `jobs/flush-view-tracker.job.ts`).
  - ✅ 36 new unit specs across 7 files (≥15 floor).

## T-2026-05-09-004 — web: signup page + auth layout fixes

- Completed: 2026-05-10
- Owner: claude
- Spec: bug-fix on existing auth UI (no PRD/epic)
- Goal: Add missing `/signup` page, fix landing CTA wiring, improve auth-page
  layout proportions.
- Result: shipped on `main` across five commits as the work expanded into a
  full bearer-token migration (Better Auth's session cookie did not survive
  the SPA → backend round-trip on Forgejo's reverse proxy, so the signup
  flow had to switch to `Authorization: Bearer <token>` end-to-end before it
  could land green).
  - `91169bb` `fix(web): /signup page, landing CTA, and post-auth redirect`
  - `c962b8f` `fix(web): auth-required reads getSession() result directly`
  - `193c8e6` `fix(web): SDK client singleton sends session cookie`
  - `7e4ea73` `fix(backend): JSON body parser before OpenAPI validator`
  - `772509e` `feat(web): switch auth from session cookie to bearer token`
- Spec diff: none (auth surface untouched — the signup form was already
  served by Better Auth's `/api/v1/auth/sign-up/email` endpoint).
- Acceptance check (against the original list):
  - ✅ `/signup` route renders email + password + confirm form
    (`apps/web/app/pages/signup.vue`).
  - ✅ Successful submit calls `auth.signUp.email` and redirects (to
    `/app/characters` rather than `/` — `autoSignIn` is on, so dropping
    new accounts on the public landing felt wrong).
  - ✅ Landing "Create account" button navigates to `/signup`
    (`onCreateAccount → navigateTo('/signup')` in `app/pages/index.vue`).
  - ✅ Login + signup cards capped at 480 px, no `100dvh`, wordmark above
    card. Both pages share the same BEM scaffold (`page-login__shell` /
    `page-signup__shell`) so future restyles touch one set of tokens.
- Open follow-ups (carried in the feature backlog, not blockers):
  - `uk` and `el` strings on `/signup` are still `[uk-todo]` /
    `[el-todo]` placeholders — translator pass when those locales come
    online.
  - "Forgot password" link is not on the login card yet (Better Auth
    `forgetPassword` endpoint exists; the UI lands in Phase 1 Epic 4).

## T-2026-05-09-005 — character creation rules alignment with ST3001

- Completed: 2026-05-10
- Owner: claude
- Spec: Coriolis ST3001 — `ГЛАВА 2 Персонажи игроков` + `ГЛАВА 4 Достоинства`
  (Russian rulebook, canonical per
  `.claude/projects/.../memory/coriolis-rulebook-ru.md`). PRD §5.2 was silent
  / partially wrong on these mechanics.
- Goal: make web character creation enforce the rulebook's budget, caps,
  and talent model — upbringing-driven point pools, structured concept
  enum (амплуа), full talent catalog (icon gifts + crew + personal +
  stigmas), and the mutant flag.
- Result: shipped as 6 commits directly on `main` (ff push to
  `origin/main`). The original "single big PR" plan was abandoned in
  favour of per-block direct-to-main commits per the saved
  `feedback_block_workflow.md` rule (each block = its own commit + push +
  follow-up note + new session). The repo lives on a self-hosted
  Forgejo (`code.homelab.local`) — no GitHub PR equivalent was created.
  - `cf47ef1` `feat(character): T-2026-05-09-005 Block 1 — upbringing
field & budgets`
  - `91dac1d` `feat(character): T-2026-05-09-005 Block 2 — Concept
(amplua) enum`
  - `250e918` `feat(character): T-2026-05-09-005 Block 3 — Talent kind +
CrewConcept`
  - `db52555` `feat(character): T-2026-05-09-005 Block 4 — Talent
catalog data`
  - `8cd30ac` `feat(character): T-2026-05-09-005 Block 5 — Mutant flag +
stigma`
- Spec evolution: openapi `0.8.1 → 0.12.0` (4 minor bumps); asyncapi
  unchanged. Prisma migrations: `upbringing_fields`, `concept_enum`,
  `talent_kind_and_crew_concept`, `mutant_fields`. New
  `packages/specs/src/talents.ts` ships the canonical ST3001 ch.4
  catalog (9 icon gifts + 15 crew + 26 personal + 3 stigmas) and is the
  single source of truth for both backend seeding and web rendering.
- Test totals at end: **425/425** backend, **53/53** web. All 5 blocks
  cleared lint / typecheck / format on each commit.
- Acceptance check (against the original list):
  - ✅ Upbringing drives attribute/skill budgets, reputation, starting
    wealth (15/8 — 14/10 — 13/12; 2/4/6; 500/1000/5000 birrs).
  - ✅ Concept is a structured 11-amplua enum with key-attribute cap 5,
    other-attr cap 4, key-skill cap 3, other-skill cap 1, plus
    reputation modifier.
  - ✅ Talents at creation: personal + crew + iconGift; stigma when
    mutant=true. iconGift auto-seeded from icon; rest picked by player
    via the regular `addTalent` flow after `forge()`.
  - ✅ Talent catalog: 9 icon gifts, 15 crew (5 amplua × 3), 26
    personal, 3 stigmas — en/ru complete, uk/el placeholders.
  - ✅ Backend rejects budget / kind / mutant violations with structured
    400/422 + RFC 9457 codes (`ATTRIBUTE_BUDGET_EXCEEDED`,
    `SKILL_BUDGET_EXCEEDED`, `TALENT_KIND_DUPLICATE`,
    `MUTANT_LINEAGE_REQUIRED`, `MUTANT_LINEAGE_FORBIDDEN`,
    `MUTANT_IMMUTABLE`, `STIGMA_REQUIRES_MUTANT`,
    `UPBRINGING_IMMUTABLE`, `CONCEPT_IMMUTABLE`,
    `CREW_CONCEPT_IMMUTABLE`).
  - ✅ Web wizard surfaces budgets/caps/hints on Step 1/2/4/5/6.
  - ✅ Mobile out of scope (untouched).
- Follow-ups (open as separate tasks if/when needed):
  - `uk` and `el` translations across new i18n keys (Step1Concept
    mutant copy, Step2Background upbringing/crew copy, Step6Talents
    sections, talent catalog `name` + `description`) currently carry
    `[uk-todo]`/`[el-todo]` placeholders.
  - Personal-talent pool is rendered as a flat 26-card list. A future
    enhancement could filter by amplua per ST3001 if/when player
    feedback says the full pool is overwhelming.
  - Read-side localization: character sheet (`[id].vue`) renders
    `talent.name` raw — when the catalog ID convention is universal,
    we can resolve it through `findCatalogTalentById` for
    locale-aware display.

## Mobile flutter analyze cleanup (Phase 3 tail)

- Completed: 2026-05-09
- Owner: claude (parent session)
- Spec: open follow-up from Epic 6 Feature 6.4 bookkeeping (mobile flutter
  analyze drift after Flutter 3.41 SDK upgrade + dart codegen change).
- Result: ff-merged to main as `<mobile range>` (2 commits).
  - `<head-1>` `fix(mobile): repoint app_api_client at the inner generated
package + repo_impl`. Three structural fixes that cleared 166 errors: - `mobile/pubspec.yaml`: `app_api_client.path` now points at
    `packages/api-client-dart/lib/generated` (the inner Dart package
    produced by openapi-generator). The outer `packages/api-client-dart/`
    lib has only `generated/` subfolder — Dart resolves
    `package:app_api_client/app_api_client.dart` against the OUTER `lib/`,
    which has no barrel file. The inner package is the real one. - `character_repository_impl.dart`: split the `Character as
ApiCharacter` show-with-as combination (Dart syntax error) into two
    imports; drop `quantity` references on `ItemOther` (spec doesn't
    have the field); switch to top-level `updateTalent`/`deleteTalent`/
    `updateItem`/`deleteItem` API methods (the repo had been calling
    non-existent `updateCharacterTalent` etc). - Ran `dart run build_runner build` inside
    `packages/api-client-dart/lib/generated` to produce the missing
    `*.g.dart` built_value generated code (88 files committed; without
    them the builder fields type-resolve as nullable and 100+ cascade
    assignments fail to type-check).
  - `<head>` `chore(mobile): clear remaining flutter analyze info + warning`:
    drop unused `_weaponTypes` field; `withOpacity` → `withValues(alpha:)`;
    `dart fix --apply` (12 `prefer_const_constructors` auto-fixes); capture
    `Navigator` before `.then()` async gap; declare `built_collection` +
    `one_of` as mobile direct deps.
- Verification: `flutter analyze` reports **No issues found!** Mobile
  52/52 tests; ui_flutter 153/153 tests.

## Mobile pass + a11y audit + HC theme persist (Epic 6 Features 6.4, 6.5)

- Completed: 2026-05-09
- Owner: claude (flutter-engineer + frontend-engineer agents + parent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 6 Features 6.4 (T-6.4.1.{a,b,c}) and 6.5 (T-6.5.1.{c,d,e}).
- Result: ff-merged to main as `<6.4 + 6.5 range>`.

  **6.4 — Mobile pass:**
  - `f38792e` `docs(mobile): MOBILE_AUDIT — sheet vs sheet-mobile.jsx`. 8-item audit; 2 high-impact gaps fixed (bottom tab bar, RankStepperSheet extraction); 6 already match. Cyrillic decision: rely on Flutter's system-fallback (Roboto on Android, SF/Helvetica on iOS — both have full Cyrillic). Forum bundling deferred per audit. Cold-start measurement plan documented (no Android emulator at the bench; PRD NFR §6 target ≤ 2.0s, baseline Pixel 4).
  - `<head>` `feat(mobile): bottom tab bar + private-class extractions per MOBILE_AUDIT`. `_SheetTabBar` moved to `Scaffold.bottomNavigationBar`, `_RankStepperSheet` extracted to public `RankStepperSheet`, wizard `_StepHeader` made `WizardStepHeader` (private symbols don't cross library boundaries via `show`).

  **6.5 — A11y audit + HC theme:**
  - `4ff0e8c` `feat(specs): Me.theme dark|high-contrast (v0.7.1)`. Required field on Me with default `dark`; allowed transitions documented inline.
  - `270f73f` `chore(codegen): regenerate clients after Me.theme`.
  - `b80b489` `feat(backend): persist theme on User + Me query/update`. Prisma migration `me_theme`. `UpdateMeCommand` validates the enum with a new `InvalidThemeError`.
  - `cedc394` `feat(web): persist HC toggle via PATCH /me`. `settings.vue` now drives the toggle through `updateMe({ theme })` with optimistic UI + rollback. localStorage kept only as a hint to avoid FOIT during reload.
  - `302f234` `fix(ui): reduced-motion fallbacks audit + missing fixes`. AppButton spinner gained an opacity-pulse fallback; `settings.vue`, `characters/index.vue`, `shared/character/[slug].vue` skeletons gained `animation: none` under `prefers-reduced-motion: reduce`.
  - `d845fc7` `docs(a11y): A11Y_AUDIT — page-level axe + SR pass plan`. Playwright + axe smoke at `tests/e2e/a11y.spec.ts` covering `/`, `/login`, `/signup` (auth-gated routes documented as deferred with bypass instructions). Manual VoiceOver / NVDA checklist included.
  - `cd469ef` `chore: apply prettier + stylelint auto-format`.
  - `<head>` `style(web): apply ESLint auto-fixes (vue formatting, batch 2)` — 45 vue/max-attributes-per-line warnings introduced by the HC toggle wiring.

- Verification at merge time: backend 264 specs + lint clean + typecheck clean; web 53 specs + lint zero warnings; ui 713 specs.
- Open follow-ups (Phase 3 / Phase 4):
  - Mobile flutter analyze drift (codegen-related): the dart-codegen output is missing nullable annotations in some places; `character_repository_impl.dart` references API symbols that resolve through the inner generated package. **Pre-existing** (predates this batch). Move api-client-dart's outer `pubspec.yaml` to forward to `lib/generated` OR re-point mobile at `path: ../../packages/api-client-dart/lib/generated` and audit non-null access in the repo impl. Tracked separately.
  - Page-level axe pass on auth-gated routes — needs a session-cookie bypass in CI or a test account fixture (documented in `A11Y_AUDIT.md` §2).
  - Manual SR pass — checklist in `A11Y_AUDIT.md` §5; needs human runner.
  - Cyrillic Forum subset bundling — deferred per `MOBILE_AUDIT.md`.

## Open Graph image renderer (Epic 6 Feature 6.3)

- Completed: 2026-05-09
- Owner: claude (backend-engineer agent + parent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 6 Feature 6.3, T-6.3.1.{a,b,d,e}.
  T-6.3.1.c (ship OG) deferred until ship-share endpoints exist.
- Result: ff-merged to main as `<og range>` (3 commits).
  - `9b05ed6` `chore(backend): add satori + @resvg/resvg-js + react deps
for OG renderer`. Versions: `satori@0.26.0`, `@resvg/resvg-js@2.6.2`
    (prebuilt binaries for `darwin-arm64` + `linux-x64-gnu`),
    `react@19.2.6` (used only for `React.createElement` in the Satori
    template).
  - `17859f1` `feat(backend): OG image renderer service + character
template`. `og.service.ts` is stateless (Satori → Resvg pipeline) +
    embedded fallback PNG (1200×630 solid surface-void) for renderer
    failures. `og.fonts.ts` lazy-loads Forum + Inter from Google Fonts
    with in-process caching and graceful network degradation.
    `templates/character-og.ts` is the brass-on-indigo card layout via
    `React.createElement`.
  - `3b155b7` `feat(backend): GET /public/og/character/:slug.png
replaces 501 stub`. `OgService` injected via DI; cache headers
    `Cache-Control: public, max-age=3600,
stale-while-revalidate=86400`.
- 8 snapshot specs cover: PNG magic bytes, 1200×630 dimensions,
  non-empty pixel sum, long-name wrapping, null concept, null iconId,
  fallback on Satori error, the static fallback PNG. Backend total: 260
  tests passing.
- Notable design constraints (documented inline):
  - Satori CSS subset doesn't support `border` shorthand → use
    `border{Top,Bottom,Left,Right}{Width,Style,Color}`.
  - Satori doesn't support font fallback stacks (`'Forum, serif'`) → use
    primary family only.
  - Hex literals are explicitly justified inside the OG template
    (Satori needs concrete colors; can't read CSS custom properties).
- Open follow-ups (Phase 3+):
  - T-6.3.1.c ship OG endpoint (deferred with ship-share work).
  - Cache-warmup / persistent cache (currently the Cache-Control window
    is the only cache layer).

## Public read-only viewer — web (Epic 6 Feature 6.2)

- Completed: 2026-05-09
- Owner: claude (frontend-engineer agent + parent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 6 Feature 6.2, T-6.2.1.{a,c,d,e}.
  T-6.2.1.b (ship variant) shipped as a coming-soon placeholder; full
  implementation lands when ship-share endpoints exist.
- Result: ff-merged to main as `<viewer range>` (5 commits).
  - `d2c771f` `feat(web): usePublicSharingApi composable` — typed wrapper
    over `getPublicCharacter` from the generated SDK.
  - `1f1fbbb` `feat(web): AppShareViewer composition (read-only sheet)`
    — parchment AppBanner disclaimer, hero header, three-column layout
    with display-only AppConditionPill / AppStatBlock / AppDots /
    talents / inventory. NO edit affordances rendered.
  - `e0b20e4` `feat(web): /shared/character/[slug] page with OG meta`
    — SPA-friendly fetch, status routing (404 not-found, 410 revoked,
    5xx error). `useHead` reactively sets `og:title`, `og:description`,
    `og:image` → `/api/v1/public/og/character/:slug.png` (renderer
    landed in 6.3).
  - `744c2fc` `feat(web): /shared/ship/[slug] page placeholder`
    — coming-soon banner; no fetch (ship endpoints not yet shipped).
  - `cb9ca90` `test(web): share viewer snapshot + api specs` — 13 specs
    covering composable success/404/410, no-edit-affordance assertion
    (T-6.2.1.d), page status routing.
- Verification: web typecheck/lint/test all green; 53 web specs pass.
- Open follow-ups (Phase 3):
  - Lighthouse measurement on the share route (target ≥ 90 across all
    scores). Bundle-size and font-subset polishing land here.
  - Ship-share full implementation when the public ship endpoint exists.

## Share-link backend (Epic 6 Feature 6.1)

- Completed: 2026-05-09
- Owner: claude (backend-engineer agent + parent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 6 Feature 6.1, T-6.1.1.{a,b,c,d,e}.
- Result: ff-merged to main as `<sharing range>` (6 commits).
  - `d990682` `docs(adr): 0003 — character draft state`. Covers slug
    strategy (`nanoid(24)` w/ ambiguous-char-free alphabet), soft
    revocation (`revokedAt` → 410 Gone), lazy view tracking (in-memory
    ring-buffer flushed by 1-min cron), multi-link per character,
    `includeGmNotes` filter.
  - `99a9d07` `feat(specs): ShareLink + share endpoints + public read
paths (v0.7.0)`. New schemas (`ShareLink`, `ShareLinkCreate`,
    `ShareLinkList`); endpoints `POST /characters/{id}/share`, `GET
/characters/{id}/shares`, `DELETE /share-links/{id}`, `GET
/public/character/{slug}`; OG image path stubbed at 501.
  - `31d81d1` `chore(codegen): regenerate clients after share-link
spec`.
  - `cbbfe09` `feat(backend): Prisma ShareLink migration` — `ShareLink`
    model, FK to `Character` (cascade), `slug` UNIQUE,
    `@@index([characterId])` + `@@index([revokedAt])`.
  - `93b1d96` `feat(backend): SharingModule — slug + create + list +
revoke`. Includes the public-read query with notes filter +
    revoked/expired status checks, `view-tracker.ts` (in-memory
    `Map<slug, count>`), `flush-view-tracker.job.ts` (`@Cron('* * * *
*')` flushes via batched Prisma transaction), and `OG_NOT_IMPLEMENTED`
    501 stub for the OG image route.
  - `7d79173` `chore(backend): apply lint --fix auto-corrections`.
- 28 new vitest specs across the SharingModule. Backend total: 252 tests
  passing. Spec at v0.7.0; codegen up to date for both TS and Dart
  clients.
- Open follow-ups (Phase 3):
  - Feature 6.2 — public web viewer pages (`/shared/character/[slug].vue`,
    `/shared/ship/[slug].vue`).
  - Feature 6.3 — OG image renderer (Satori + Resvg) replacing the 501
    stub.
  - Ship-share endpoints (`/public/ship/{slug}`) — symmetric to character;
    deferred until ship feature is shipped (Phase 5 currently).

## Mobile sheet + wizard — Flutter tail (Epic 5 Features 5.1–5.6)

- Completed: 2026-05-09
- Owner: claude (flutter-engineer agents ×2 + parent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 5 T-5.1.1.e, 5.2.d, 5.3.c, 5.4.e,
  5.5.c, 5.6.f. T-5.6.1.g (native-speaker Cyrillic review) still
  outstanding.
- Result: ff-merged to main as `8c8efcd..` (14 commits across two
  flutter-engineer runs + codegen + parent fix).
  - **Sheet (5.1–5.5):** 4 commits.
    - `8c8efcd` `feat(ui-flutter): AppSavePulse widget` — 4-state animated
      dot mirroring the Vue primitive. 8 widget tests.
    - `e92e6fa` `feat(mobile): extend CharacterSheetCubit + domain` — full
      domain rewrite (`CharacterAttributes`, `CharacterSkills`,
      `CharacterConditions`, `DomainTalent`, `DomainItem` with 6-type
      discriminated union via `OneOfDynamic`); repo gains
      addTalent/updateTalent/removeTalent + addItem/updateItem/removeItem;
      cubit gains all debounced edit operations + optimistic CRUD with
      rollback; i18n extended for all 4 locales.
    - `cfe6ae0` `feat(mobile): full character sheet page` — sticky header
      (avatar, name/concept, AppSavePulse, condition strip), hero counters
      (HP/MP/ENC with ±, encumbrance warning), attributes block, skills
      block, conditions panel + critical injuries list, talents tab,
      inventory tab with 6-type ItemEditor bottom sheet, save error banner,
      delete confirm dialog. Stats / Gear / Talents / Notes tabs.
    - `fecf343` `test(mobile): BLoC + widget tests` — 11 BLoC + 11 widget
      tests for the sheet edit surfaces.
  - **Wizard (5.6.f):** 8 commits. - `bf4b4e7` `feat(mobile): CharacterWizardCubit + state machine + draft
persistence`. - `f99f7b8` `feat(mobile): wizard shell page` — brass progress, step
    labels, Back/Save & exit/Next/Forge. - `4070c17` `feat(mobile): wizard step 1+2` — concept + people /
    background. - `98857a7` `feat(mobile): wizard step 3 — Nine Icons grid + teal aura
pulse` (T-5.6.1.d). `MediaQuery.disableAnimations` →
    static teal halo fallback. - `6fd5713` `feat(mobile): wizard step 4+5` — attributes + skills point
    pools. - `7a6c164` `feat(mobile): wizard step 6 + Forge transition`. - `1c21436` `i18n(mobile): wizard en + ru full, uk + el placeholders`. - `08f2507` `test(mobile): wizard cubit + widget specs` — 8 cubit + 5
    widget tests.
  - **Codegen + status wiring**: 2 follow-up commits by parent. - `<head-1>` `chore(codegen): regenerate dart client + bundled types
after spec v0.6.0` — backfills the missing `status` enum on
    CharacterCreate / CharacterUpdate that the wizard-backend batch
    didn't propagate to dart. - `<head>` `fix(mobile): wire CharacterStatus through repo + wizard
forge` — wizard now creates with `status: 'draft'` and forges with
    `status: 'active'` explicitly. The earlier "concept-as-sentinel"
    workaround is removed.
- Verification: `flutter test` / `flutter analyze` could NOT run locally
  (system Dart 3.5 vs project floor 3.8; `fvm` not configured). CI under
  the target SDK is authoritative.
- Open follow-ups (Phase 2):
  - T-5.6.1.g native-speaker review of `ru` mobile copy (sheet + wizard).
  - Spec gap: wizard step 2 (origin / upbringing / age) is currently
    pickled into the `concept` field — the spec lacks dedicated fields.
    Add to a future spec batch.
  - `AppIconCoriolis` Flutter widget — wizard step 3 currently uses
    letter-medallion stand-ins; promote when an icon-glyph widget ships.

## Character creation wizard (Epic 5 Feature 5.6)

- Completed: 2026-05-09
- Owner: claude (backend-engineer agent + frontend-engineer agent + parent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 5 Feature 5.6, T-5.6.1.{a,b,c,d,e}.
  T-5.6.1.f (Flutter wizard) deferred. T-5.6.1.g (native-speaker Cyrillic
  review) flagged with a TODO; not gating the merge.
- Result: ff-merged to main as `<wizard range>` (12 commits across two
  worktree-isolated agent runs + spec fix).

  **Backend / spec / Prisma**:
  - `5d1af2e` `docs(adr): 0002 — character draft state via status flag`
    chooses option B (status flag on Character) over a separate
    `/draft` resource. ADR enumerates the 5-point rationale.
  - `3a7a1c0` `feat(specs): add Character.status (draft|active) +
includeDrafts query` — bumps spec to **0.6.0**. Required `status` on
    `Character`; optional on `CharacterCreate`/`CharacterUpdate`. New
    `?includeDrafts=false` query on `GET /characters`. Forge transition is
    a plain `PATCH` with `{ status: 'active' }`; `active → draft` is
    rejected with 422 `INVALID_STATUS_TRANSITION`.
  - `a3ad6aa` `chore(codegen): regenerate clients after Character.status`
    — codegen-only commit per CLAUDE.md.
  - `4e2eb90` `feat(backend): Prisma Character.status migration` —
    `CharacterStatus` enum (`ACTIVE`, `DRAFT`), `@@index([status])`.
  - `459d453` `feat(backend): wizard support — draft status +
status-transition guard + listings + cleanup-abandoned-drafts cron`.
    The cron runs at `EVERY_DAY_AT_3:05` (offset from user-cleanup) and
    deletes drafts older than 30 days. 22 new specs across 4 files.
  - `<head>` `fix(backend): align legacy list-characters specs with
includeDrafts param` — two pre-existing specs needed expectations
    updated since the handler now always passes the param.

  **Web wizard UI**:
  - `be06e2a` `feat(web): wizard shell — progress, header, footer,
navigation` — `WizardShell.vue` skeleton (AppProgress in
    `--brand-brass`, Back / Save & exit / Next + Forge footer).
  - `88c9eba` `feat(web): wizard step 1+2 — concept + people/background`.
  - `4307e65` `feat(web): wizard step 3 — Nine Icons grid + teal aura
pulse` (T-5.6.1.d). 3×3 grid; selected icon pulses
    `--state-mystic-teal`; `prefers-reduced-motion` strips animation.
  - `6c949f2` `feat(web): wizard step 4+5 — attributes + skills point
pools`. Soft point-pool guidance (rulebook-derived); enforcement is
    backend-side via `Attributes` 1–5 / `Skills` 0–5 schema bounds.
  - `19a9820` `feat(web): wizard step 6 — talents + Forge transition`
    (T-5.6.1.e). Final step PATCHes `{ status: 'active' }` and
    `navigateTo(\`/app/characters/${id}\`)`.
  - `e2b1eec` `i18n(web): wizard en + ru full, uk + el placeholders`.
  - `2f440ab` `test(web): wizard orchestration specs` — 7 wizard-specific
    describe blocks; final web-suite total at 40 specs.

- Wizard architecture:
  - `/app/characters/new` reads `?id=` to resume mid-wizard. With no `id`
    it POSTs `{ name: 'Untitled', status: 'draft' }` and `replaceState`s
    so refresh stays on the same draft.
  - Each step PATCHes the draft on advance via the `useAutoSave` composable.
  - Forge = PATCH `{ status: 'active' }` then redirect.

- Verification at merge time: `@app/backend` 224 tests; `@app/web` 40
  tests; `@app/ui` a11y smoke 306/306; typecheck/lint/stylelint/format
  clean across all packages.

- Open follow-ups (Phase 2 / Phase 3):
  - T-5.6.1.f Flutter mobile wizard (deferred with the rest of the
    Flutter sheet tail).
  - T-5.6.1.g native-speaker review of `ru` wizard copy (TODO).
  - Step 7 (Relationships) deferred to v1.1+ with a
    `TODO(wizard-step-7-relationships)` marker in `new.vue` /
    `Step6Talents.vue`.

## Character sheet — Inventory & gear (Epic 5 Feature 5.4)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent + parent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 5 Feature 5.4, T-5.4.1.{a,b,d}.
  T-5.4.1.c (backend item commands) was already shipped in Phase 1.
  T-5.4.1.e (Flutter inventory) deferred.
- Result: ff-merged to main as `<inventory range>` (4 commits).
  - `14cdcf6` `feat(ui): AppModal primitive` — Teleport-to-body, focus
    trap, Esc/backdrop close, sm/md/lg sizes, default+trigger+footer
    slots, reduced-motion fade fallback. 14 specs, 4 stories.
  - `0d4d15d` `feat(web): useItemsApi composable` — addItem / updateItem /
    removeItem against existing backend endpoints.
  - `3ceecc1` `feat(web): Gear tab + ItemEditor (6 types) + equipped
quick view + encumbrance warning` — adds the Gear tab to the sheet
    tab row; ItemEditor handles WEAPON / ARMOR / GEAR / CYBERNETIC /
    SHIP_MODULE / OTHER with per-type field sets; equipped right-column
    panel replaces the placeholder; encumbrance warning ("warn, do not
    block" per PRD §5.3) renders on `current > max`. TalentEditor
    refactored from native `<dialog>` to AppModal in the same diff.
  - `2fa8ada` `test(web): inventory orchestration specs + typecheck fix
in test union` — 11 new vitest specs (addItem, isEncumbered,
    equippedItems, type-discriminated payload).
- Verification: `@app/ui` 711 tests, a11y smoke 306/306 green;
  `@app/web` 28 tests; typecheck/lint clean.
- Open follow-ups (Phase 2):
  - T-5.4.1.e Flutter mobile inventory (deferred with the Flutter sheet
    tail).
  - Type-specific summary columns are placeholders for slots/range
    presentation; full polish lands during the Phase 3 share viewer pass.

## Character sheet — Talents, conditions, save-pulse (Epic 5 Features 5.2, 5.3, 5.5)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent + backend-engineer agent + parent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 5 Features 5.2 / 5.3 / 5.5.
- Result: ff-merged to main as `cb58fcf..` (6 commits).
  - `55f17f7` `feat(backend): rules-engine.applyConditions — −1 die per active
condition` (Feature 5.3 T-5.3.1.d). Pure helper, 12 specs.
  - `9cf488c` `feat(ui): AppSavePulse primitive` — 4 lifecycle states
    (idle/saving/saved/error), pulse animation, `prefers-reduced-motion`
    fade fallback. 4 specs, 5 stories.
  - `e057615` `feat(web): useTalentsApi composable` — addTalent /
    updateTalent / removeTalent against the existing backend endpoints.
  - `9325608` `feat(web): conditions panel + critical injuries +
talents tab + AppSavePulse wire` — replaces three placeholders on
    `[id].vue`: - Conditions: 4 `AppConditionPill`s with optimistic toggle + rollback. - Critical injuries: list + inline-input add + remove. PATCH the full
    array. - Talents: list + native `<dialog>` `TalentEditor` (add / edit / delete
    with confirm). - Save indicator: text → `AppSavePulse` with sr-only fallback.
  - `79982b8` `test(web): condition / talent / save-pulse orchestration
specs` — 11 new vitest specs (4 condition-toggle, 4 talent-list,
    1 save-pulse perf — Feature 5.5 T-5.5.1.d, 100-cycle 50ms-per-call
    budget under fake timers, plus 2 misc).
  - `<head>` `fix(ui): drop redundant story-local a11y override on
AppSavePulse` — story used the array form of axe rules (broken) and
    duplicated the global `color-contrast` disable.
- Verification at merge time: `@app/ui` 693 tests + a11y smoke 302/302
  green; `@app/web` 17 tests; backend 191 tests; typecheck/lint clean.
- Open follow-ups (Phase 2):
  - `AppModal` primitive — TalentEditor uses native `<dialog>` (per agent
    brief). Promote to a real primitive when a third dialog surface lands.
  - Mobile (Flutter) talents/conditions/save-pulse mirrors (Feature 5.2.d,
    5.3.c, 5.5.c) — deferred with the rest of the Flutter sheet tail.

## Character sheet — Attributes & skills section (Epic 5 Feature 5.1)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent ×2 + parent session)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 5, Feature 5.1, T-5.1.1.{a,b,c,d,f}.
  T-5.1.1.e (Flutter mirror) deferred to a later batch.
- Result: ff-merged to main as `43d2e87..ba6b7ee` (5 commits across two
  worktree-isolated agent runs + one spec fix).
  - `a646cf5` `feat(ui): AppStatBlock` — attribute/derived-stat block primitive
    (button-or-div, brass/mystic tones, sm/md sizes, hideDots, aria-label
    forwarding). 16 specs, 6 stories.
  - `082ebc5` `feat(ui): AppPopover` — controlled tokens-styled popover
    (4 placements, focus trap, Escape + click-outside close, reduced-motion
    aware). 14 specs, 4 stories.
  - `b508bac` `chore(ui): export AppStatBlock + AppPopover from @app/ui barrel`
    - `specs/design/README.md` inventory rows.
  - `43d2e87` `fix(ui): align AppBanner spec with <div> root` (regression
    from the a11y CI batch — the `<aside>`→`<div>` change had not been
    mirrored in the spec).
  - `63882b2` `feat(web): extract useAutoSave composable from sheet skeleton`
    — preempts Feature 5.5 T-5.5.1.a (composable only; no save-pulse
    component yet). Lifecycle: idle / saving / saved / error; flush + cancel.
  - `ba6b7ee` `feat(web): character sheet — three-column layout, hero
counters, attributes + skills panels`. Rewrites `[id].vue` from the
    name+concept skeleton into the full sheet. Includes 8 vitest specs.
- Backend: T-5.1.1.b is free — `express-openapi-validator` enforces
  Attributes 1–5 and Skills 0–5 bounds at runtime from the OpenAPI schema.
  No code change needed.
- Open follow-ups (Phase 2):
  - Flutter sheet (T-5.1.1.e).
  - Conditions & critical injuries panel (Feature 5.3) — currently a
    placeholder card on the desktop sheet.
  - Equipped / Talents / Recent rolls right-column cards — placeholders;
    implemented under Features 5.2 (talents) and 5.4 (inventory).
  - `AppSavePulse` micro-component (Feature 5.5 T-5.5.1.b) — current sheet
    uses plain text "saving / saved / error".
- Agent-discipline notes: the second agent (sheet build) ignored two
  guardrails — touched `packages/ui/` (legitimate lint/typecheck fixes
  in AppPopover/AppStatBlock; kept) and committed a self-bookkeeping entry
  to `done.md` (dropped at merge time; re-written by parent here).

## Storybook a11y CI smoke (Phase 2 follow-up)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent + parent session)
- Spec: Phase 1 ledger follow-up "Storybook visual smoke + a11y panel CI".
- Result: ff-merged to main as `4f352b0..ec99ba3` (2 commits).
  - `ci(ui): wire Storybook a11y smoke via test-runner + axe-playwright` —
    new `ui-storybook` CI job (build static Storybook → install Chromium →
    run test-runner). `axe-playwright` injected via `preVisit` hook;
    `postVisit` calls `checkA11y` against `#storybook-root`. Visual snapshot
    block kept but gated behind `STORYBOOK_VISUAL=1` until baselines are
    seeded from a Linux runner. preview.ts decorator themes aligned with
    Coriolis (`dark` + `high-contrast`, dropping stale `light/sepia/forest`
    that ADR-0001 retired). Two axe rules globally disabled with WHY
    comments + Phase 2 follow-ups: `color-contrast` (design-intentional
    dark palette; AA gate lives on `[data-theme='high-contrast']`) and
    `nested-interactive` (AppChip-removable refactor needed).
  - `fix(ui): a11y violations in 8 component stories (61 → 0)` — story-level
    fixes for AppDots/AppProgress (`label` prop), AppInput/AppTextarea
    (`aria-label` in meta render), AppSelect (paired `<label for>` +
    `selectId`), AppSwitch (label default + bare-toggle aria-label), AppTab
    (`<div role="tablist">` wrappers, `<nav>`→`<div>` to fix
    `aria-allowed-role`). One component change: AppBanner.vue
    `<aside>`→`<div>` (aside's implicit `complementary` role conflicts
    with `role="status"`/`alert`).
- Final state: 287 / 287 stories pass a11y smoke locally. CI job gates the
  same on every push.
- Open follow-ups (added to Phase 2 ledger):
  - Visual snapshot baselines on Linux runner.
  - `color-contrast` audit on `[data-theme='high-contrast']` and design
    refresh for failing combos.
  - AppChip-removable structural refactor (sibling buttons) to re-enable
    `nested-interactive`.

## Web typecheck unblock (Phase 1 tech-debt)

- Completed: 2026-05-08
- Owner: claude (parent session)
- Spec: Phase 1 ledger follow-up "Web pnpm typecheck fix (oxc-parser native
  binding)".
- Result: ff-merged to main as `e24690b..96fe7a8` (1 commit).
- Diagnosis: the previously-blocking `@oxc-parser/binding-darwin-universal`
  binding error self-resolved under the current pnpm 10.33 / Node 24.15
  toolchain. What remained were two real TypeScript errors blocking
  `pnpm --filter @app/web typecheck`:
  - `app/pages/app/settings.vue:137`: `setLocale` expected `LocaleCode`
    union, got widened `string`. Fix: `SUPPORTED_LOCALES` const tuple +
    `isLocaleCode()` type guard, narrowing happens at the call site.
  - `app/pages/login.vue:176`: AppButton was being passed boilerplate
    Nuxt UI props (`label`, `color`, `variant='solid'`, `block`). AppButton
    has none of those. Fix: switch to default slot, `variant='primary'`,
    page-scoped `&__submit { width: 100% }` for block-layout.
- Verification: `pnpm --filter @app/web typecheck` exits 0 (only
  pre-existing duplicate-import warnings remain — auto-import noise from
  Nuxt, harmless).

## Flutter foundation tail — 8 deferred widgets (Epic 2.5)

- Completed: 2026-05-08
- Owner: claude (flutter-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2.5 — first Phase 2 deliverable after `phase-1-complete` tag.
- Result: ff-merged to main as `7e7d1d0..a5832cd` (4 commits). Closes Epic 2.5 at 20/20 widgets.
  - `7e7d1d0` AppIcon (CustomPaint, zero-dep, 20-icon static map) + AppKbd.
  - `0378dce` AppTooltip (Flutter Tooltip wrapper; left/right placement falls back to bottom — API limitation, documented inline) + AppTab (brass/mystic underline-on-active, `Semantics(selected)`) + AppBanner (5 tones incl. parchment).
  - `0d5514b` AppSegControl<T> (2–5 options) + AppSelect (DropdownButton via InputDecorator, `dropdownColor: surfaceNight`; full menu-row theming deferred) + AppTextarea (`minLines: rows`, `maxLines: null` for unbounded growth).
  - `a5832cd` Barrel re-export.
- 50 new tests (13 + 20 + 17), tap targets ≥ 44×44, tokens-only, no hex literals, no new pubspec entries.
- Local `flutter analyze`/`flutter test` skipped — system Dart SDK 3.5 below project floor 3.8 (`fvm` not configured locally). CI under target SDK is authoritative.
- Pre-existing follow-up still open: AppTextarea autosize content-grow (Phase 2 ledger).

## Email mailer + Coriolis voice copy (Epic 4.3)

- Completed: 2026-05-08
- Owner: claude (backend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 4.3, T-4.3.1.a–c
- Result: merged at `bf6d158`. Four commits — MailerModule + ports + adapters (`ff6381d`), Better Auth callback wiring (`689618e`), domain-error voice refresh (`68527b6`), pnpm-lock resolution (`ce02ed6`).
- New module `apps/backend/src/modules/mailer/`:
  - `IMailer` port (`mailer.port.ts`) with `sendVerificationEmail` / `sendPasswordResetEmail`.
  - `MockMailer` adapter (default in dev/test) — ring-buffer of last 50 sends, `getLastSent()` for test inspection, debug logging.
  - `ResendMailer` adapter — `node:fetch` to Resend API, no new dep, throws on non-2xx.
  - `@Global()` `MailerModule` with factory selecting Mock vs Resend via `AppConfig.mailer.provider`. Boot-time guard throws if provider=`resend` without `RESEND_API_KEY`.
  - 31 new vitest specs (14 service + 17 templates).
- Email templates: 4 inline-TS templates (`verification` + `password-reset` × `en/ru`). HTML shell in `templates/email-shell.ts` is the only backend file with hex literals — explicitly justified (email clients don't support CSS custom properties).
- Better Auth wiring: `auth.service.ts` injects `MailerService` and wires `emailVerification.sendVerificationEmail` and `emailAndPassword.sendResetPassword` callbacks. Locale defaults to `'en'` for now (TODO when `user.locale` field arrives).
- Domain-error copy refreshed for Coriolis voice across `user.errors.ts`, `character.errors.ts`, `item.errors.ts`, `talent.errors.ts`. `code` strings unchanged (clients depend on them).
- 191 backend specs pass total (was 160).

## Web delete-account UI (Epic 4.2.c)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 4.2, T-4.2.1.d
- Result: merged at `5afef03`. Two commits — `useMeApi.deleteMe()` (`f79c226`) and the settings-page modal flow (`5afef03`).
- Native `<dialog>` confirmation modal with double-confirm via typing the exact phrase ("DELETE MY ACCOUNT" / "УДАЛИТЬ МОЙ АККАУНТ"). Locale-aware comparison.
- Inline error state — Problem.detail rendered above action buttons, modal stays open for retry.
- Post-delete redirect to `/`; auth guard handles the bounce to `/login`.
- 87 web i18n keys × 4 locales clean (was 78).

## Coriolis-decorative primitives (Epic 2.2 — final 4)

- Completed: 2026-05-08
- Owner: claude (frontend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2 Feature 2.2 (T-2.2.a, .c, .e, .f)
- Result: merged at `ff53323`. Nine commits — one component + one specs/stories per primitive plus a barrel/inventory commit and a typecheck fix.
- AppIconCoriolis: 9 SVG glyphs for the Nine Icons (placeholder designs ready for a publisher-aware illustration pass), `currentColor` stroke. Static map + `v-html` rendering with explicit ESLint suppression rationale (closed map, not user input).
- AppDiePool: composes AppDie; counts hits per ST3001 ГЛАВА 5 (all 6s count, including pushed); pushed dice get a translateY+opacity visual without losing their hit contribution.
- AppStarOrnament: single 12-point polygon on a 100×100 viewBox; filled rather than stroked for legibility at sm size.
- AppArabesqueCorner: single canonical TL path + `rotate()` for the four orientations.
- 655 vitest specs across the @app/ui package (all primitives green).

## Account deletion backend (Epic 4.2.b–c)

- Completed: 2026-05-08
- Owner: claude (backend-engineer agent)
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 4.2, T-4.2.1.b–c
- Result: merged at `8db8a7f`. Three commits: DeleteMeCommand handler (`6ea0835`), daily cron job (`cbf3822`), UserDeletedEvent + log handler (`8db8a7f`).
- New dep: `@nestjs/schedule@^6.1.3`. `ScheduleModule.forRoot()` registered at app level.
- Idempotent path: `repo.softDelete` uses `prisma.user.updateMany` with `where: { id, deletedAt: null }`; if `count === 0`, the handler returns 204 without re-stamping or emitting events.
- BA session revocation: `auth.api.revokeSessions` requires the caller's own session, so `AuthService.revokeAllSessions(userId)` instead clears `prisma.session` directly. Session FK to User has `onDelete: Cascade`, so the eventual hard-delete flushes any survivors.
- Cron: `@Cron(CronExpression.EVERY_DAY_AT_3AM)` deletes users with `deletedAt < now - 30d`. Cascade FKs handle children. TODO: Centrifugo channel cleanup + share-slug invalidation when those systems land (Epic 7).
- 160 backend specs pass total (+16 new across DeleteMe handler + cron job).

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

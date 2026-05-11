## T-2026-05-11-005 — CI consolidation: port courseShelf 2-job structure to Forgejo

- Created: 2026-05-11
- Owner: claude
- Spec: none (infra)
- Goal: shrink the per-PR CI cost on Forgejo by collapsing the 7 separate jobs in `.github/workflows/ci.yml` into 2 fat jobs (`checks` + `quality`) under `.forgejo/workflows/`, mirroring the optimisation already shipped in `../courseShelf/.forgejo/workflows/`.
- Acceptance:
  - `.forgejo/workflows/ci.yml` exists with two jobs (`checks`, `quality`) running one `pnpm install` each. ✓
  - Spec/codegen drift guard lives in its own path-filtered job (`codegen-drift.yml`) so the heavy Flutter setup only runs when `packages/specs/**` (or its api-client outputs) changes. ✓
  - `.forgejo/workflows/e2e.yml` runs inside `mcr.microsoft.com/playwright:…` so the `playwright install --with-deps` step (~90 s) is gone. ✓
  - `.forgejo/workflows/trivy.yml` replaces CodeQL on Forgejo. `.github/workflows/codeql.yml` deleted (CodeQL needs GitHub server for SARIF upload). ✓
  - `.github/workflows/{ci.yml, e2e.yml}` deleted — origin is Forgejo, no GitHub mirror, and the act_runner scans both dirs by default → keeping them would double every PR's CI bill. ✓
  - Coverage matches the pre-consolidation CI (backend lint/typecheck/test:coverage, web lint/typecheck/test, specs validate+bundle, UI components audit) and adds the three quality gates we manually fix today: `pnpm stylelint`, `pnpm design:audit`, `pnpm format:check`. ✓
- Spec diff: none
- Codegen impact: no
- Design impact: none (CI-only)
- Tests: YAML lints clean via `yq eval`; first real verification happens on the PR run.
- Sub-steps:
  - [x] Push entry to active.md.
  - [x] Add `.forgejo/workflows/ci.yml` (checks + quality, two jobs).
  - [x] Add `.forgejo/workflows/codegen-drift.yml` (path-filtered Flutter job).
  - [x] Add `.forgejo/workflows/e2e.yml` (Playwright container, port 3010).
  - [x] Add `.forgejo/workflows/trivy.yml` (fs + config scans).
  - [x] Add `.trivyignore.yaml` (ports the Dockerfile.dev `DS-0002` USER exemption from courseShelf).
  - [x] Delete `.github/workflows/{ci.yml, codeql.yml, e2e.yml}`.
- Status: ready-to-merge (PR pending)
- Blockers: —

## Open follow-up (out of scope, for next PR)

- `.github/dependabot.yml` is also dead config on a Forgejo-only origin (Dependabot is a GitHub service). Leaving in place; remove together with any other GitHub-only metadata next time we touch `.github/`.

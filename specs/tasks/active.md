## T-2026-05-11-009a — Phase 7: release packaging (Dockerfiles + compose.release + nginx)

- Created: 2026-05-11
- Owner: claude
- Spec: PRD §11 (Phase 7 — Hardening · "beta release"). Half-1 of the courseShelf release-flow port; T-009b adds the actual `release.yml` workflow on top of these.
- Goal: produce buildable production images for backend + web and a standalone-compose stack (postgres + redis + centrifugo + backend + web + nginx-proxy) that an operator can `docker compose pull && up` against on their own box. No CI workflow yet — that's T-009b.
- Acceptance:
  - `docker build -f apps/backend/Dockerfile -t coriolis/backend:test .` succeeds locally.
  - `docker build -f apps/web/Dockerfile -t coriolis/web:test .` succeeds locally.
  - `docker compose -f docker/compose.release.yml config` exits clean (YAML + relative-path sanity).
  - The web image, given `APP_API_BASE_URL` + `APP_AUTH_BASE_URL` at boot, serves `/` (SPA shell) and `/_app-config.js` with the injected URLs (Nuxt `00.runtime-config.client.ts` plugin overrides `runtimeConfig.public.*` before `api-client.client.ts` runs).
  - The backend image runs `prisma migrate deploy` then `node ./dist/main.js`; non-root `node` user.
  - Reverse proxy in front folds `/api/`, `/centrifugo/`, `/` onto a single host so the browser sees one origin.
  - `cliff.toml` matches our commitlint scopes; `.env.release.example` lists every required secret with `change-me` markers.
- Spec diff: none
- Codegen impact: no
- Design impact: none (infra)
- Tests:
  - Local `docker build` on both Dockerfiles.
  - Local `docker compose -f docker/compose.release.yml config` against placeholder env.
  - Optional: bring the stack up locally against the placeholder env to confirm health-check chain (postgres → backend → web → proxy).
- Sub-steps:
  - [x] Push task entry.
  - [x] `.dockerignore` (ports the courseShelf shape, adds `packages/ui_flutter` to the strip-list).
  - [x] `apps/backend/Dockerfile` — multi-stage (build → deploy → runtime). No ffmpeg, no `/data/courses`. `prisma` moved from devDeps to deps so the runtime image can run `migrate deploy`.
  - [x] `apps/web/Dockerfile` — Nuxt `generate` → static SPA + nginx-unprivileged.
  - [x] `apps/web/nginx.conf` (SPA serving with no-cache for `_app-config.js` + `/sw.js`, immutable cache for `/_nuxt/`, SPA fallback). `apps/web/docker-entrypoint.sh` templates `/_app-config.js` from env.
  - [x] `apps/web/app/plugins/00.runtime-config.client.ts` — reads `window.__APP_CONFIG__` and overrides `apiBaseUrl` / `authBaseUrl` / `realtimeWsUrl` before any later plugin.
  - [x] `docker/compose.release.yml` — pulls images from `${REGISTRY}/${REGISTRY_NAMESPACE}/coriolis-{backend,web}:${RELEASE_TAG}`, wires postgres / redis / centrifugo / proxy. Optional OTEL / Sentry / mailer env vars are pass-through-with-default.
  - [x] `docker/nginx/prod.conf` — reverse proxy. `/api/` → backend:3000, `/centrifugo/` → centrifugo:8000 (with WS upgrade), `/` → web:8080. No streaming endpoint.
  - [x] `.env.release.example` — every secret with a `change-me` marker.
  - [x] `cliff.toml` — same Conventional-Commits config as courseShelf; tag pattern `^v[0-9]+\.[0-9]+\.[0-9]+-release$`.
  - [x] Local verification:
        - `docker compose -f docker/compose.release.yml config` exits clean against placeholder env.
        - `docker build -f apps/backend/Dockerfile -t coriolis/backend:test .` succeeds (~3 min).
        - `docker build -f apps/web/Dockerfile -t coriolis/web:test .` succeeds (~5 min).
        - `docker run -p 18080:8080 -e APP_API_BASE_URL=… -e APP_AUTH_BASE_URL=… coriolis/web:test` serves `/_app-config.js` with the templated URLs and `GET /` returns 200.
  - [x] Full quality-gate sweep — format, stylelint, eslint, typecheck, vitest, size-limit all green.
  - [ ] PR.
- Status: ready-to-PR
- Blockers: —

## Out of scope (deferred — T-009b)

- `.forgejo/workflows/release.yml` — actual release workflow (tag trigger, GHCR push, Forgejo release page creation, asset upload).
- Multi-arch builds (amd64 only for v1).
- The `pnpm release:notes` helper (one-shot script that runs git-cliff locally).

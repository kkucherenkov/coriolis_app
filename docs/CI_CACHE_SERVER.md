# CI cache server for Forgejo `act_runner`

**Status:** Proposal — not yet implemented.
**Owner:** ops (homelab).
**Audience:** anyone deploying or upgrading the homelab `act_runner` host.
**Related docs:** `.forgejo/workflows/ci.yml`, `.forgejo/workflows/codegen-drift.yml`, `.forgejo/workflows/trivy.yml`, `.forgejo/workflows/e2e.yml`, `.forgejo/workflows/release.yml`.

## Why

Every CI workflow on this repo starts with `pnpm install --frozen-lockfile`. Live evidence from two consecutive `Checks` runs on `main`:

```
Lockfile is up to date, resolution step is skipped
Progress: resolved 1, reused 0, downloaded 0, added 0
Packages: +3422
…
Progress: resolved 3422, reused 0, downloaded 971, added 886
…
```

`reused 0` on **every line** of **every run** = the pnpm content-addressable store is **empty at the start of every job**. All 3422 packages download from `registry.npmjs.org` each time. Wall-clock cost: ~2 min per `pnpm install` × 5 workflows triggered by each push to `main` = **~10 min of avoidable download per merge wave**.

The workflows already declare `actions/setup-node@v6 with cache: pnpm` — but on Forgejo's `act_runner` that step needs a **cache backend** (an HTTP service that speaks the GitHub Actions cache API). Without one, the cache step is a silent no-op: nothing is restored, nothing is saved, no warning emitted.

This document specifies setting up a cache backend so `cache: pnpm` starts working — across all five workflows, **including the container-jobs** (`quality` runs inside the Playwright image; a host-side volume mount wouldn't reach it).

## Why this approach (Plan B) over Plan A

Two options were on the table:

| Plan                                         | Mechanism                                                                                                                                                                                             | Pros                                                                                                                                                                                                                                              | Cons                                                                                                                                                                                                                                              |
| -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **A** — persistent volume on the runner host | Bind `~/.local/share/pnpm/store` to a host directory; set `PNPM_STORE_DIR` in workflow steps.                                                                                                         | One config change, no extra service.                                                                                                                                                                                                              | **Does not reach container jobs** (`quality` runs inside `mcr.microsoft.com/playwright:v1.59.1-jammy`, isolated FS). Would need a second per-container volume mount in the workflow yml. Couples cache invalidation to host filesystem semantics. |
| **B** — HTTP cache server (chosen)           | One container alongside `act_runner` exposing the GH Actions cache HTTP API; `act_runner` sets `ACTIONS_CACHE_URL` to point at it. `actions/setup-node@v6`'s `cache: pnpm` then works out-of-the-box. | Works in container jobs the same way it works in host jobs. No per-workflow YAML changes needed. Standard GH Actions cache API — same mental model engineers already know. Cache invalidation handled by `actions/cache@v4`'s lockfile-hash keys. | Extra service to deploy + monitor. Disk usage to budget.                                                                                                                                                                                          |

**Decision: B.** The container-jobs case alone justifies the extra service. Phase 8 already established a precedent that quality gates need to scale to mixed host / container execution; locking ourselves into volume-only would re-cost itself the next time we add a job in a container.

## Architecture

```
            ┌───────────────────────────┐
            │  Forgejo                  │
            │  code.homelab.local       │
            │  (job orchestrator)       │
            └────────────┬──────────────┘
                         │ dispatches jobs over HTTPS
                         ▼
            ┌───────────────────────────┐
            │  act_runner               │  ← env: ACTIONS_CACHE_URL=http://act-cache:8088
            │  (host or container)      │
            └────────────┬──────────────┘
                         │ creates job containers
                         ▼
   ┌─────────────────────┴─────────────────────┐
   ▼                                           ▼
┌──────────────────┐                  ┌──────────────────────────┐
│ ubuntu-latest    │                  │ playwright:v1.59.1-jammy │
│ (Checks, Trivy…) │                  │ (Quality job)            │
└────────┬─────────┘                  └────────────┬─────────────┘
         │                                         │
         │  HTTP GET/PUT /api/cache/…              │
         └────────────────┬────────────────────────┘
                          ▼
            ┌───────────────────────────┐
            │  act-cache (NEW)          │
            │  GH Actions Cache HTTP    │  ← persistent volume → host disk
            │  :8088 (private network)  │     /var/lib/act-cache
            └───────────────────────────┘
```

Job containers and the cache server share an internal Docker network. The cache HTTP port stays **off the public-facing reverse proxy** — only `act_runner` and its job containers can reach it.

## Image choice

Pick **one** of:

- `falcondev-oss/forgejo-runner-cache-server` — small, Go binary, maintained, drop-in compatible with `actions/cache@v4`. Recommended default.
- `gitea/act_runner` invoked with the `cache-server` sub-command — already pulled if you run a Gitea-flavoured runner; one fewer image.
- `gitea/runner-cache-server` — alternative if you prefer Gitea's officially-versioned variant.

All three implement the same GH-Actions-compatible HTTP surface. The workflow side does **not** care which one runs.

> Verify the chosen image is mirrored on `code.forgejo.org` (the runner can't always pull from `ghcr.io` / `docker.io` without explicit network access). If not mirrored, pin the image by SHA and pre-pull it on the host.

## Implementation

### 1. Add `act-cache` to the runner's compose stack

The runner config lives on the homelab host (not in this repo). Add a compose service next to `act_runner`:

```yaml
# /opt/forgejo-runner/compose.yml  (host-side; example path)
services:
  act-cache:
    image: ghcr.io/falcondev-oss/forgejo-runner-cache-server:latest # or pin by SHA
    container_name: act-cache
    restart: unless-stopped
    networks: [runner-net]
    environment:
      CACHE_DIR: /data
      # Optional: cap to keep disk bounded.
      CACHE_SIZE_LIMIT_GB: '20'
    volumes:
      - act-cache-data:/data
    # Internal-only; do NOT expose 8088 on the host.
    # Other services on runner-net reach it as http://act-cache:8088
    healthcheck:
      test: ['CMD', 'wget', '-qO-', 'http://localhost:8088/healthz']
      interval: 30s
      timeout: 5s
      retries: 5

  act_runner:
    # … existing config …
    networks: [runner-net]
    environment:
      # Point the runner at the cache server.
      ACTIONS_CACHE_URL: 'http://act-cache:8088/'
      # The runner forwards ACTIONS_CACHE_URL into each job container
      # via the Actions toolkit; setup-node@v6 reads it automatically.
    depends_on:
      act-cache:
        condition: service_healthy

networks:
  runner-net:
    driver: bridge

volumes:
  act-cache-data:
    driver: local
```

Notes:

- `ACTIONS_CACHE_URL` must end with a trailing slash (Actions toolkit quirk).
- Container jobs inherit the env var because `act_runner` injects it into the spawned container's environment. Verify this by `docker exec` into a running job container and `echo $ACTIONS_CACHE_URL`.
- Bind-mount `act-cache-data` to a known host path (`/var/lib/act-cache`) if you want it accessible for backup / inspection outside Docker.

### 2. Restart the runner stack

```sh
# On the homelab host:
docker compose -f /opt/forgejo-runner/compose.yml up -d
docker compose -f /opt/forgejo-runner/compose.yml logs -f act-cache  # confirm healthy
```

### 3. Repo-side: nothing required

All five workflows already declare:

```yaml
- uses: actions/setup-node@v6
  with:
    node-version: ${{ env.NODE_VERSION }}
    cache: pnpm
```

Once `ACTIONS_CACHE_URL` is reachable, this step starts persisting and restoring. **No YAML edits needed.** If we wanted finer control we could swap to an explicit `actions/cache@v4` step with custom key — but the default is correct for pnpm and there's no reason to pre-empt.

Optional belt-and-suspenders: keep `--prefer-offline` on the install step in `ci.yml` and friends:

```yaml
- name: Install dependencies
  run: pnpm install --frozen-lockfile --prefer-offline
```

`--prefer-offline` makes pnpm reach for the store before hitting the registry — cheap insurance against a partial cache hit.

## Verification

After the cache server is up, trigger any PR or push that touches `apps/**` to fire a `Checks` run, then:

### A. First run after deployment — cache miss expected

Look in the `Install dependencies` step log for:

```
Progress: resolved 3422, reused 0, downloaded N, added N
```

Followed in `Post Setup Node.js` by:

```
Cache saved with key: node-cache-Linux-pnpm-<hash-of-pnpm-lock.yaml>
```

(If "Cache saved" is missing, the URL isn't reachable from inside the container — check the runner-net config and `ACTIONS_CACHE_URL` env in the job container.)

### B. Second run, **no lockfile change** — cache hit expected

```
Cache restored from key: node-cache-Linux-pnpm-<hash>
…
Progress: resolved 3422, reused 3422, downloaded 0, added 0
```

`reused 3422, downloaded 0` is the **target state**. `pnpm install` should drop from ~2 min to ~10–20 s.

### C. Lockfile change — cache miss expected, then new key

Bump any dependency in `pnpm-lock.yaml`. The cache key changes (it's hashed off the lockfile), the run misses, downloads, then saves a new entry. The previous entry stays around until evicted (size limit) — acceptable.

### D. Container job (`quality`) — confirm it sees the cache too

The `quality` job runs inside `mcr.microsoft.com/playwright:v1.59.1-jammy`. Its `Install dependencies` step must show the same `reused 3422` line on the second run. **This is the test that distinguishes Plan B from Plan A** — if `quality` still shows `reused 0` while `checks` shows `reused 3422`, the cache URL isn't propagating into the container (check `act_runner` env-forwarding config).

## Operational notes

### Sizing

The `.pnpm-store` for this repo is ~1.5 GB unpacked (pnpm dedups via CAS). With one entry per `pnpm-lock.yaml` hash and infrequent dep churn, expect 5–10 active entries = 7–15 GB. Start with `CACHE_SIZE_LIMIT_GB=20`; check fill ratio after two weeks.

### Eviction

The cache server is LRU on access time. Keys older than 7 days with no read access are first to evict when the size limit is reached. No human action required.

### Backups

The cache is **regenerable** — every entry can be rebuilt by re-running `pnpm install`. Do **not** include `act-cache-data` in the homelab's general backup rotation. If the volume is lost, the next CI wave is slow (cold), then recovers.

### Monitoring

- Healthcheck endpoint: `GET http://act-cache:8088/healthz` (already wired into the compose `healthcheck:` block).
- Disk usage: alert if `docker volume inspect act-cache-data` exceeds 80% of `CACHE_SIZE_LIMIT_GB`.
- Cache-hit ratio: parse runner logs for `Cache restored` vs `Cache saved` over the last 24 h. If hit ratio drops below ~80% on `main`-target PRs, something is wrong with the key derivation.

### Rollback

If the cache server misbehaves (corrupt entries, wrong hashing, network flakiness):

1. `docker compose -f /opt/forgejo-runner/compose.yml stop act-cache`
2. Remove or comment out `ACTIONS_CACHE_URL` from the runner's env.
3. `docker compose -f /opt/forgejo-runner/compose.yml up -d act_runner`

CI continues to work — the `cache: pnpm` step becomes a no-op again, install cost reverts to the current ~2 min. No workflow changes required.

To wipe the cache and start fresh: `docker volume rm act-cache-data` (after stopping the service).

## Out of scope / future

These are deliberately **not** part of this proposal — file them as follow-ups if and when they become real bottlenecks:

1. **Per-branch cache scoping.** GH Actions cache by default isolates caches per ref. Some forks of the cache server expose a knob; check before depending on it.
2. **Cross-runner cache.** If a second `act_runner` is added (parallelism > current 2), point both at the same `act-cache`. Already supported.
3. **Cache for Flutter pub artifacts.** `codegen-drift.yml` uses `subosito/flutter-action@v2` with `cache: true`; same backend.
4. **Cache for Playwright browser binaries.** `e2e.yml` reinstalls Chromium every run. Bucketing this through `actions/cache` is straightforward but adds a second large cache entry.
5. **Cache for Trivy DB.** Trivy fetches its vuln DB on every run. Same pattern.
6. **Pre-built CI base image.** Bakes `node_modules` into a versioned image keyed on `pnpm-lock.yaml` hash. Strict upgrade over caching, but heavier to operate. Only worth it if the cache-server route hits limits.

## Acceptance

This proposal is "done" when, on **two consecutive `Checks` runs against the same `pnpm-lock.yaml`**, the second run's `Install dependencies` step prints `reused 3422, downloaded 0` and the wall-clock for that step is ≤ 25 s. Verified on both `checks` (host runner) and `quality` (Playwright container).

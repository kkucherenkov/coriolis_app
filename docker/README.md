# docker/

Local dev stack. Launch from the repo root:

```sh
docker compose -f docker/compose.yml up -d
```

`compose.yml` is the base; `compose.override.yml` is picked up automatically.

## Services

| Service    | Image                         | Port | Notes                                                          |
| ---------- | ----------------------------- | ---- | -------------------------------------------------------------- |
| postgres   | `postgres:18.1-alpine`        | 5432 | PGDATA is `/var/lib/postgresql/18/docker` (Postgres 18 layout) |
| redis      | `redis:8.6-alpine`            | 6379 | `--appendonly yes`                                             |
| centrifugo | `centrifugo/centrifugo:v6`    | 8000 | HMAC secret + API key from `centrifugo/config.json`            |
| backend    | `apps/backend/Dockerfile.dev` | 3010 | Mounts repo, runs `nest start --watch`                         |
| web        | `apps/web/Dockerfile.dev`     | 3001 | Mounts repo, runs `nuxt dev`                                   |

## Before deploying

- Update `centrifugo/config.json` with production channel namespaces.
- Replace `BETTER_AUTH_SECRET`, `CENTRIFUGO_API_KEY`, `CENTRIFUGO_TOKEN_HMAC_SECRET`, and the postgres credentials with values issued for the target environment — the values in `compose.yml` are local-dev defaults only.

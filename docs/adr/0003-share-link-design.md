# 0003 — Share-link design (Epic 6 Feature 6.1)

- **Status:** accepted
- **Date:** 2026-05-09
- **Deciders:** @kirill, @claude
- **Tags:** backend, sharing, public-read, epic-6

## Context

Epic 6 (Feature 6.1) introduces public read-only sharing of character sheets via
slug-addressable URLs. Any user (authenticated or anonymous) who knows the URL can
read the character. The character owner controls creation, listing, and revocation of
share links.

Four design decisions were open: slug strategy, revocation mechanism, view tracking
granularity, and multi-link policy per character.

## Decision 1 — Slug strategy: nanoid(24) with unambiguous alphabet

**Choice:** `nanoid({ size: 24, alphabet: '23456789ABCDEFGHJKMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz' })`

Alternatives considered:

- **UUID v4 (hyphenated)** — 36 chars with hyphens, URL-unfriendly. 36 chars of alphabet
  including `[0OIl1-]` makes copy-paste from printed material error-prone.
- **UUID v4 (compact, 32 hex)** — URL-safe but 32 chars of hex alphabet (only 4 bits/char)
  means lower entropy per visible character.
- **nanoid(12)** — short but collision risk rises into single-digit probability at tens of
  millions of links. This app does not expect that scale in v1 but headroom is free.
- **nanoid(24) unambiguous** — 24 chars from 56-symbol alphabet ≈ 139 bits of entropy.
  Effectively unguessable. Ambiguous characters (`0`, `O`, `I`, `l`, `1`) are excluded so
  the slug is safe to print and copy from physical media. URLs remain compact.

`nanoid` is already a dependency (`apps/backend/package.json`). The alphabet is a pure
function exposed as `generateSlug()` in `domain/slug.ts` so it is trivially unit-tested.

## Decision 2 — Revocation: soft-delete via `revokedAt` timestamp

**Choice:** Setting `revokedAt: DateTime` on the `ShareLink` row; the row is never deleted.

Alternatives considered:

- **Hard delete** — simple but loses audit history. If a user suspects misuse, they cannot
  tell the server when a link was live.
- **Separate revoked table** — over-engineered for v1 volume.
- **Soft-delete flag (boolean)** — timestamps are strictly more useful at the same cost.

The read endpoint returns `410 Gone` (not `404`) for revoked slugs so the caller can
distinguish "never existed" (404) from "existed and was revoked" (410). Expired links
also return 410 for the same reason (the slug existed; access is gone).

## Decision 3 — View tracking: lazy in-memory ring buffer, flushed every minute

**Choice:** `ViewTracker` service accumulates a `Map<slug, pendingCount>` in memory.
A `@Cron('* * * * *')` job flushes all pending counts in a single batched Prisma
`$transaction` of `UPDATE` statements. The read path does **not** hit the database.

Alternatives considered:

- **Synchronous per-view UPDATE** — adds a write to every anonymous request. Under burst
  traffic this serialises reads through a single row lock. Rejected.
- **Redis counter + periodic sync** — correct and scalable, but adds Redis I/O on the
  read path and couples the sharing domain to Redis. At current scale (single pod),
  in-memory is equivalent with no added infrastructure.
- **Event-sourced view log** — correct but heavyweight. The product only needs an
  approximate count, not an audit trail.

The flush cadence (1 minute) means view counts may lag by up to 60 seconds. This is
acceptable for a display metric; the PRD says nothing about real-time counts. If the
process restarts between records, at most one minute of counts is lost — also acceptable.

`lastViewedAt` is updated alongside `viewCount` in the same flush transaction.

## Decision 4 — Multiple links per character: yes

**Choice:** A character may have any number of active `ShareLink` rows. Each link has an
independent `includeGmNotes` flag and optional `expiresAt` / `label`, enabling owners to
create audience-specific links (e.g. one for the GM, one for the public).

Alternative considered: **exactly one active link per character** — simpler list UI but
forces the owner to revoke before changing settings, which destroys analytics history.

The list endpoint (`GET /api/v1/characters/{id}/shares`) returns all non-revoked links by
default. The choice to add `?includeRevoked` is deferred to a future iteration; the
default is documented in the spec description.

## Consequences

- `ShareLink` table has a `UNIQUE` index on `slug` (DB-level collision detection).
- The `Character` model gains a `shareLinks ShareLink[]` inverse relation.
- The `public` read path requires no authentication, so the controller does **not** use
  `SessionGuard`. `express-openapi-validator` enforces this via the spec (no `security`
  block on the `GET /api/v1/public/character/{slug}` path).
- OG image generation (`GET /api/v1/public/og/character/{slug}.png`) is stubbed at 501 and
  implemented in Feature 6.3.
- The `FlushViewTrackerJob` runs at `* * * * *` (every minute) — a different cadence than
  the 03:00/03:05 UTC daily jobs already registered. NestJS Schedule registers all cron
  expressions independently; no conflict.

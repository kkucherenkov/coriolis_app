/**
 * Pure helpers for the `auth-required.global` middleware.
 *
 * Kept side-effect-free so the decision logic is unit-testable without
 * mounting Nuxt / Better Auth. The middleware passes the raw
 * `getSession()` result here and acts on the verdict.
 *
 * See T-UX-2026-05-15-AUTH-THROTTLE — the catch-all backend throttle on
 * `/auth/{*rest}` can return 429 on the hot `get-session` endpoint after
 * a burst of route navigations. Before this helper the middleware
 * treated any error from `getSession()` as "no session" and redirected
 * to `/login`, which manifested to users as a silent sign-out. The
 * helper now distinguishes "definitely no session" from "we couldn't
 * verify right now" and only redirects in the first case.
 */

/**
 * Shape of the value Better Auth's `getSession()` resolves with.
 *
 * The narrow `{ message }` type in `useAuth.ts` understates the runtime
 * payload — `better-fetch` (Better Auth's underlying client) exposes the
 * HTTP status on the error object as `status` (and the legacy
 * `statusCode` in some versions). We widen here to read whichever shape
 * is present without leaking the loose type to the rest of the codebase.
 */
export interface SessionResult {
  data: unknown;
  error:
    | {
        message?: string;
        status?: number;
        statusCode?: number;
      }
    | null
    | undefined;
}

/**
 * `true` if the error from `getSession()` represents an HTTP 429
 * Too Many Requests response (or a textual equivalent for clients
 * that surface only `message`).
 *
 * Defense-in-depth: we check the numeric status fields first, then
 * fall back to a permissive regex against the human-readable message
 * (covers ad-hoc throttler implementations that don't populate
 * `status`, plus the upstream RFC 9457 `detail: "ThrottlerException:
 * Too Many Requests"` shape our backend emits).
 */
export function isRateLimitedError(error: SessionResult['error']): boolean {
  if (!error) return false;
  if (error.status === 429) return true;
  if (error.statusCode === 429) return true;
  if (typeof error.message === 'string' && /\b(429|too many|rate.?limit)/i.test(error.message)) {
    return true;
  }
  return false;
}

/**
 * Decide what `auth-required.global` should do with a `getSession()`
 * result. Three outcomes:
 *
 * - `allow` — there's a usable session; let the navigation proceed.
 * - `rate-limited-allow` — we couldn't verify the session because the
 *   backend rate-limited us; assume the session is still valid and
 *   let the navigation proceed. If the session is genuinely expired,
 *   the very next API call will return 401 and the page's own error
 *   handling will kick in. Crucially we do NOT bounce to `/login`,
 *   because that would feel like a silent sign-out triggered by
 *   normal browsing.
 * - `redirect` — no session and no rate-limit excuse; send to
 *   `/login?redirect=…`.
 *
 * The helper accepts `null` to cover the "network threw" branch of
 * the middleware's try/catch — treated as `redirect` (the original
 * behaviour, preserved).
 */
export type AuthDecision = 'allow' | 'rate-limited-allow' | 'redirect';

export function decideAuthAction(result: SessionResult | null): AuthDecision {
  if (!result) return 'redirect';
  const data = result.data as { user?: { id?: string } } | null;
  if (data?.user?.id) return 'allow';
  if (isRateLimitedError(result.error)) return 'rate-limited-allow';
  return 'redirect';
}

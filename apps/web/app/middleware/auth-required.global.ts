import { decideAuthAction, type SessionResult } from '~/utils/auth-redirect';

/**
 * auth-required.global — guards every route under /app/*.
 *
 * Calls Better Auth `getSession()` and inspects its return value directly.
 * The reactive `useSession()` ref is not always synchronously updated after
 * a fresh page load (it's driven by an internal nanostore), so on the very
 * first navigation after sign-in it can still report `data: null` even
 * though the cookie is valid. Reading the explicit fetch result avoids that
 * race entirely.
 *
 * Three outcomes (see `decideAuthAction`):
 *   - session present → allow.
 *   - no session AND backend rate-limited us (429 from the auth
 *     catch-all throttle) → allow optimistically; the next API call
 *     will surface the real auth state. This stops the SPA from
 *     silently signing the user out after a burst of route navigations
 *     consumes the `/auth/get-session` throttle budget.
 *     See T-UX-2026-05-15-AUTH-THROTTLE.
 *   - anything else → redirect to /login with the original target.
 */
export default defineNuxtRouteMiddleware(async (to) => {
  if (!to.path.startsWith('/app')) return;

  const auth = useAuth();

  let result: SessionResult | null = null;
  try {
    result = (await auth.getSession()) as SessionResult;
  } catch {
    // Network failure — treat as unauthenticated (decideAuthAction
    // maps `null` to 'redirect').
  }

  const decision = decideAuthAction(result);
  if (decision === 'redirect') {
    const redirect = encodeURIComponent(to.fullPath);
    return navigateTo(`/login?redirect=${redirect}`);
  }
  // 'allow' and 'rate-limited-allow' both fall through.
});

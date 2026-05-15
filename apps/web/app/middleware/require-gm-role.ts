/**
 * require-gm-role — per-route guard for /app/game-sessions/:id.
 *
 * Verifies the authenticated user holds the 'gm' role for the requested
 * game session. Redirects to the player shell (/app/sessions/:id) if the
 * user is a player member but not the GM. On network error the user is
 * let through optimistically — the next API call will surface the real
 * auth state.
 *
 * Loaded via definePageMeta({ middleware: ['require-gm-role'] })
 * on the GM session page.
 */
export default defineNuxtRouteMiddleware(async (to) => {
  const m = /^\/app\/game-sessions\/([^/]+)$/.exec(to.path);
  if (!m) return;
  const sessionId = String(m[1]);
  const api = useMyMembershipsApi();
  try {
    const memberships = await api.list();
    const gm = memberships.find((x) => x.gameSessionId === sessionId && x.role === 'gm');
    if (!gm) return await navigateTo(`/app/sessions/${sessionId}`);
  } catch {
    // Network error — don't lock the user out; the page's API calls
    // will fail with an appropriate error if the user is genuinely unauthorised.
  }
});

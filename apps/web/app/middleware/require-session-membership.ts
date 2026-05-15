/**
 * require-session-membership — per-route guard for /app/sessions/:id.
 *
 * Verifies the authenticated user has an active membership in the requested
 * game session. Redirects to /app/sessions on a missing membership or a
 * network error.
 *
 * Loaded via definePageMeta({ middleware: ['require-session-membership'] })
 * on the player session shell page.
 */
export default defineNuxtRouteMiddleware(async (to) => {
  const m = /^\/app\/sessions\/([^/]+)$/.exec(to.path);
  if (!m) return;
  const sessionId = String(m[1]);
  const api = useMyMembershipsApi();
  try {
    const memberships = await api.list();
    const member = memberships.find((x) => x.gameSessionId === sessionId);
    if (!member) return await navigateTo('/app/sessions');
  } catch {
    return await navigateTo('/app/sessions');
  }
});

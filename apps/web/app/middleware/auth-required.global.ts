/**
 * auth-required.global — guards every route under /app/*.
 *
 * Waits for the Better Auth session to settle (isPending → false) before
 * deciding whether to allow navigation. If the session has no authenticated
 * user the visitor is redirected to /login with a `redirect` query param so
 * the login page can send them back after successful sign-in.
 */
export default defineNuxtRouteMiddleware(async (to) => {
  if (!to.path.startsWith('/app')) return;

  const auth = useAuth();
  const session = auth.useSession();

  // If the reactive state is still resolving, do an explicit fetch to settle it.
  if (session.value.isPending) {
    try {
      await auth.getSession();
    } catch {
      // Network failure — treat as unauthenticated.
    }
  }

  if (!session.value.data?.user) {
    const redirect = encodeURIComponent(to.fullPath);
    return navigateTo(`/login?redirect=${redirect}`);
  }
});

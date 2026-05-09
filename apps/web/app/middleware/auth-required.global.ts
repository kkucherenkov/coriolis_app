/**
 * auth-required.global — guards every route under /app/*.
 *
 * Calls Better Auth `getSession()` and inspects its return value directly.
 * The reactive `useSession()` ref is not always synchronously updated after
 * a fresh page load (it's driven by an internal nanostore), so on the very
 * first navigation after sign-in it can still report `data: null` even
 * though the cookie is valid. Reading the explicit fetch result avoids that
 * race entirely.
 */
export default defineNuxtRouteMiddleware(async (to) => {
  if (!to.path.startsWith('/app')) return;

  const auth = useAuth();

  let userId: string | undefined;
  try {
    const result = await auth.getSession();
    const data = result.data as { user?: { id?: string } } | null;
    userId = data?.user?.id;
  } catch {
    // Network failure — treat as unauthenticated.
  }

  if (!userId) {
    const redirect = encodeURIComponent(to.fullPath);
    return navigateTo(`/login?redirect=${redirect}`);
  }
});

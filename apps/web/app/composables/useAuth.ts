import type { Ref } from 'vue';
import { createAuthClient } from 'better-auth/vue';

interface SessionData {
  user?: { id: string; name?: string; email?: string; role?: string };
}

interface SessionState {
  data: SessionData | null;
  isPending: boolean;
  error: { message?: string } | null;
}

// Narrowed interface over the email+password surface we use from the base
// auth client. The full better-auth inferred type is not directly castable,
// so we cast through `unknown` — the cast is intentional and safe because
// these methods are part of the core API and are always present at runtime
// when emailAndPassword is enabled on the server.
interface AuthClientLike {
  signIn: {
    email(opts: {
      email: string;
      password: string;
    }): Promise<{ data: unknown; error: { message?: string } | null }>;
  };
  signUp: {
    email(opts: {
      email: string;
      password: string;
      name: string;
    }): Promise<{ data: unknown; error: { message?: string } | null }>;
  };
  changePassword(opts: {
    newPassword: string;
    currentPassword?: string;
    revokeOtherSessions?: boolean;
  }): Promise<{ data: unknown; error: { message?: string } | null }>;
  /**
   * Triggers Better Auth's password-reset email. `redirectTo` is the URL
   * BA bounces the user back to after verifying the token from the email
   * link — BA appends `?token=<token>` so the SPA can finish the flow
   * with `resetPassword`.
   *
   * Hits POST `/api/v1/auth/request-password-reset`. `forgetPassword` is
   * BA's older / OTP-plugin name; the email-and-password method is
   * `requestPasswordReset`.
   */
  requestPasswordReset(opts: {
    email: string;
    redirectTo?: string;
  }): Promise<{ data: unknown; error: { message?: string } | null }>;
  /**
   * Completes the password-reset flow with the token captured from the
   * URL the user landed on (BA forwards it as `?token=...`). Hits POST
   * `/api/v1/auth/reset-password`.
   */
  resetPassword(opts: {
    newPassword: string;
    token: string;
  }): Promise<{ data: unknown; error: { message?: string } | null }>;
  getSession(): Promise<{ data: unknown; error: { message?: string } | null }>;
  signOut(): Promise<{ data: unknown; error: { message?: string } | null }>;
  useSession(): Ref<SessionState>;
}

/**
 * localStorage key holding the Better Auth bearer token. Mobile and web both
 * authenticate via `Authorization: Bearer <token>` against the backend's
 * `bearer()` plugin (see `apps/backend/src/common/auth/auth.service.ts`); the
 * token is issued in the `set-auth-token` response header on signin/signup
 * and rotated on every authenticated response.
 */
export const BEARER_TOKEN_KEY = 'app.auth.bearerToken';

export function readBearerToken(): string | null {
  return globalThis.localStorage.getItem(BEARER_TOKEN_KEY);
}

export function clearBearerToken(): void {
  globalThis.localStorage.removeItem(BEARER_TOKEN_KEY);
}

let client: AuthClientLike | null = null;

export function useAuth(): AuthClientLike {
  if (!client) {
    const { public: pub } = useRuntimeConfig();
    // Cast through `unknown` — the base createAuthClient already exposes
    // signIn.email and changePassword at runtime; the cast is intentional.
    client = createAuthClient({
      baseURL: `${pub.authBaseUrl}/api/v1/auth`,
      fetchOptions: {
        // Send Bearer on every auth-client call (signIn/signUp don't need it,
        // getSession/signOut/changePassword do). Token getter runs lazily, so
        // the very first call (signin) sees `null` and is unauthenticated —
        // exactly what we want.
        auth: {
          type: 'Bearer',
          token: () => readBearerToken() ?? '',
        },
        // Capture the token Better Auth emits on signin/signup. The header is
        // exposed by the backend via `access-control-expose-headers`.
        onSuccess: (ctx: { response: Response }) => {
          const token = ctx.response.headers.get('set-auth-token');
          if (token) {
            globalThis.localStorage.setItem(BEARER_TOKEN_KEY, token);
          }
        },
      },
    }) as unknown as AuthClientLike;

    // Wrap signOut so the bearer token is removed from localStorage too.
    // Better Auth's signOut invalidates the session server-side; without this
    // wrapper the now-stale token would linger in storage and be replayed on
    // the next request, hitting 401.
    const originalSignOut = client.signOut.bind(client);
    client.signOut = async (): Promise<{ data: unknown; error: { message?: string } | null }> => {
      const result = await originalSignOut();
      clearBearerToken();
      return result;
    };
  }
  return client;
}

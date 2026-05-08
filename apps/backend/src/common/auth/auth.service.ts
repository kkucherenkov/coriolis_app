import { Inject, Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { betterAuth } from 'better-auth';
import { prismaAdapter } from 'better-auth/adapters/prisma';
import { bearer, phoneNumber } from 'better-auth/plugins';

import { AppConfig } from '../config/app-config';
import { PrismaService } from '../prisma/prisma.service';
import { SMS_PORT } from '../../modules/integrations/domain/sms.port';
import { MailerService } from '../../modules/mailer/mailer.service';

import type { ISmsService } from '../../modules/integrations/domain/sms.port';
import type { Request } from 'express';

// TS2742: the phoneNumber() plugin exposes zod v4 core internals in its
// inferred return type. Casting through `unknown` to the base `betterAuth`
// return type erases the un-nameable generic while keeping `handler` and
// `api.getSession` — the only two methods this service and its callers use.
function createInstance(
  prisma: PrismaService,
  config: AppConfig,
  sms: ISmsService,
  mailer: MailerService,
): ReturnType<typeof betterAuth> {
  const { basePath, secret, baseUrl } = config.betterAuth;

  // Verification email expiry — BA defaults to 3600 s (1 h). We mirror that
  // so the template copy ("24 hours") matches the configured token TTL.
  // PRD §5.1: "verification token expires in 24h".
  const VERIFICATION_TTL_SECONDS = 24 * 60 * 60;
  // Password-reset TTL — PRD §5.1: "1h expiry".
  const RESET_TTL_SECONDS = 60 * 60;

  const instance = betterAuth({
    database: prismaAdapter(prisma, { provider: 'postgresql' }),
    secret,
    baseURL: baseUrl,
    basePath,
    // Use UUID v4 for all IDs so they satisfy the OpenAPI `format: uuid`
    // contract and are consistent with seed data.
    advanced: { database: { generateId: () => crypto.randomUUID() } },
    emailAndPassword: {
      enabled: true,
      autoSignIn: true,
      resetPasswordTokenExpiresIn: RESET_TTL_SECONDS,
      /**
       * Better Auth calls this when a user requests a password reset.
       * Locale: BA does not carry a user locale; we default to 'en' for v1.
       * TODO: read locale from a future `user.locale` field once T-4.3.2 lands.
       */
      sendResetPassword: async (data) => {
        const expiresAt = new Date(Date.now() + RESET_TTL_SECONDS * 1000);
        await mailer.sendPasswordResetEmail({
          toEmail: data.user.email,
          locale: 'en',
          resetUrl: data.url,
          expiresAt,
        });
      },
    },
    emailVerification: {
      sendOnSignUp: true,
      expiresIn: VERIFICATION_TTL_SECONDS,
      /**
       * Better Auth calls this immediately after registration and whenever
       * `/send-verification-email` is called. The `url` already includes the
       * token — forward it directly to the mailer.
       */
      sendVerificationEmail: async (data) => {
        const expiresAt = new Date(Date.now() + VERIFICATION_TTL_SECONDS * 1000);
        await mailer.sendVerificationEmail({
          toEmail: data.user.email,
          locale: 'en',
          verificationUrl: data.url,
          expiresAt,
        });
      },
    },
    user: {
      additionalFields: {
        // User-set display name shown in share-link banners and avatar menu.
        displayName: {
          type: 'string',
          required: false,
          input: true,
          defaultValue: null,
        },
        // Soft-delete timestamp. Server-only: never accepted from client input.
        deletedAt: {
          type: 'date',
          required: false,
          input: false,
          defaultValue: null,
        },
      },
    },
    plugins: [
      bearer(),
      phoneNumber({
        sendOTP: async ({ phoneNumber: phone, code }) => {
          await sms.sendOtp(phone, code);
        },
        // Required so the plugin creates a new user on first OTP verification.
        // The email is a synthetic non-deliverable placeholder; the phone number
        // is the primary credential. Users update their display name in /me.
        signUpOnVerification: {
          getTempEmail: (phone: string) =>
            `phone-${phone.replace(/^\+/, '')}@noreply.app.internal`,
          getTempName: (phone: string) => phone,
        },
      }),
    ],
    trustedOrigins: config.runtime.corsOrigins,
  });
  return instance as unknown as ReturnType<typeof betterAuth>;
}

type BetterAuthInstance = ReturnType<typeof createInstance>;

@Injectable()
export class AuthService implements OnModuleInit {
  private readonly logger = new Logger(AuthService.name);
  private instance!: BetterAuthInstance;

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: AppConfig,
    @Inject(SMS_PORT) private readonly sms: ISmsService,
    private readonly mailer: MailerService,
  ) {}

  onModuleInit(): void {
    this.instance = createInstance(this.prisma, this.config, this.sms, this.mailer);
    this.logger.log(`Better Auth initialised (mailer provider: ${this.config.mailer.provider})`);
  }

  /**
   * The Better Auth instance itself. Exposed so other modules (realtime) can
   * call `api.getSession(...)` and domain code can use typed helpers.
   */
  get auth(): BetterAuthInstance {
    return this.instance;
  }

  /**
   * Derive the active session (if any) from an Express request. Returns
   * `null` when unauthenticated — callers are expected to throw their own
   * localised errors on null.
   */
  async getSession(
    request: Request,
  ): Promise<Awaited<ReturnType<BetterAuthInstance['api']['getSession']>>> {
    const headers = new Headers();
    for (const [key, value] of Object.entries(request.headers)) {
      if (typeof value === 'string') headers.set(key, value);
      else if (Array.isArray(value)) headers.set(key, value.join(','));
    }
    return this.instance.api.getSession({ headers });
  }

  /**
   * Revoke all active sessions for the given user immediately.
   *
   * Better Auth's `revokeSessions` HTTP endpoint requires an authenticated
   * request header and can only revoke the caller's own sessions. For
   * server-side revocation on behalf of any user (e.g. account deletion), we
   * delete session rows directly via Prisma — safe because both paths write
   * the same `session` table managed by the Prisma adapter.
   *
   * The `Session` FK to `User` is `onDelete: Cascade`, so a future hard-delete
   * of the user row will clean up any remaining sessions automatically.
   */
  async revokeAllSessions(userId: string): Promise<void> {
    await this.prisma.session.deleteMany({ where: { userId } });
  }
}

/**
 * WHY this file exists:
 * IMailer is the domain contract for outbound email. All callers (Better Auth
 * callbacks, future user-facing flows) depend on this interface, not on any
 * concrete adapter. HttpExceptionFilter never touches this layer directly.
 */

export const MAILER_PORT = Symbol('MailerPort');

export interface SendVerificationEmailArgs {
  readonly toEmail: string;
  readonly locale: 'en' | 'ru';
  readonly verificationUrl: string;
  readonly expiresAt: Date;
}

export interface SendPasswordResetEmailArgs {
  readonly toEmail: string;
  readonly locale: 'en' | 'ru';
  readonly resetUrl: string;
  readonly expiresAt: Date;
}

export interface IMailer {
  sendVerificationEmail(args: SendVerificationEmailArgs): Promise<void>;
  sendPasswordResetEmail(args: SendPasswordResetEmailArgs): Promise<void>;
}

/** Minimal record stored by MockMailer for test inspection. */
export interface SentMailRecord {
  readonly type: 'verification' | 'password-reset';
  readonly toEmail: string;
  readonly locale: 'en' | 'ru';
  readonly subject: string;
  readonly sentAt: Date;
}

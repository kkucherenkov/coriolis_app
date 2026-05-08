import { Injectable, Logger } from '@nestjs/common';

import { passwordResetEmailEn } from '../templates/password-reset/en';
import { passwordResetEmailRu } from '../templates/password-reset/ru';
import { verificationEmailEn } from '../templates/verification/en';
import { verificationEmailRu } from '../templates/verification/ru';
import type {
  IMailer,
  SendPasswordResetEmailArgs,
  SendVerificationEmailArgs,
  SentMailRecord,
} from '../mailer.port';

const RING_BUFFER_SIZE = 50;

@Injectable()
export class MockMailer implements IMailer {
  private readonly logger = new Logger(MockMailer.name);
  private readonly buffer: SentMailRecord[] = [];

  async sendVerificationEmail(args: SendVerificationEmailArgs): Promise<void> {
    const tpl =
      args.locale === 'ru'
        ? verificationEmailRu({
            recipient: args.toEmail,
            verificationUrl: args.verificationUrl,
            expiresAt: args.expiresAt,
          })
        : verificationEmailEn({
            recipient: args.toEmail,
            verificationUrl: args.verificationUrl,
            expiresAt: args.expiresAt,
          });

    this.logger.debug(
      `[MOCK MAILER] type=verification to=${args.toEmail} subject="${tpl.subject}" verificationUrl=${args.verificationUrl}`,
    );

    this.push({
      type: 'verification',
      toEmail: args.toEmail,
      locale: args.locale,
      subject: tpl.subject,
      sentAt: new Date(),
    });
  }

  async sendPasswordResetEmail(args: SendPasswordResetEmailArgs): Promise<void> {
    const tpl =
      args.locale === 'ru'
        ? passwordResetEmailRu({
            recipient: args.toEmail,
            resetUrl: args.resetUrl,
            expiresAt: args.expiresAt,
          })
        : passwordResetEmailEn({
            recipient: args.toEmail,
            resetUrl: args.resetUrl,
            expiresAt: args.expiresAt,
          });

    this.logger.debug(
      `[MOCK MAILER] type=password-reset to=${args.toEmail} subject="${tpl.subject}" resetUrl=${args.resetUrl}`,
    );

    this.push({
      type: 'password-reset',
      toEmail: args.toEmail,
      locale: args.locale,
      subject: tpl.subject,
      sentAt: new Date(),
    });
  }

  /** Returns a copy of the ring buffer. Useful for test assertions. */
  getLastSent(): SentMailRecord[] {
    return [...this.buffer];
  }

  /** Clear the ring buffer between tests. */
  clear(): void {
    this.buffer.length = 0;
  }

  private push(record: SentMailRecord): void {
    if (this.buffer.length >= RING_BUFFER_SIZE) {
      this.buffer.shift();
    }
    this.buffer.push(record);
  }
}

import { Injectable, Logger } from '@nestjs/common';

import { AppConfig } from '../../../common/config/app-config';
import { passwordResetEmailEn } from '../templates/password-reset/en';
import { passwordResetEmailRu } from '../templates/password-reset/ru';
import { verificationEmailEn } from '../templates/verification/en';
import { verificationEmailRu } from '../templates/verification/ru';
import type {
  IMailer,
  SendPasswordResetEmailArgs,
  SendVerificationEmailArgs,
} from '../mailer.port';

interface ResendEmailBody {
  from: string;
  to: string[];
  subject: string;
  html: string;
  text: string;
  headers?: Record<string, string>;
}

@Injectable()
export class ResendMailer implements IMailer {
  private readonly logger = new Logger(ResendMailer.name);

  constructor(private readonly config: AppConfig) {}

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

    await this.send({
      from: this.config.mailer.fromAddress,
      to: [args.toEmail],
      subject: tpl.subject,
      html: tpl.html,
      text: tpl.text,
      headers: { 'X-Mailer': 'Coriolis-Companion/1.0' },
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

    await this.send({
      from: this.config.mailer.fromAddress,
      to: [args.toEmail],
      subject: tpl.subject,
      html: tpl.html,
      text: tpl.text,
      headers: { 'X-Mailer': 'Coriolis-Companion/1.0' },
    });
  }

  private async send(body: ResendEmailBody): Promise<void> {
    const apiKey = this.config.mailer.resendApiKey;

    this.logger.log(`Sending email via Resend to=${body.to.join(', ')} subject="${body.subject}"`);

    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const text = await response.text().catch(() => '(no body)');
      this.logger.error(`Resend API error: status=${response.status.toString()} body=${text}`);
      throw new Error(`Resend API returned ${response.status.toString()}: ${text}`);
    }

    this.logger.log(`Email sent successfully via Resend to=${body.to.join(', ')}`);
  }
}

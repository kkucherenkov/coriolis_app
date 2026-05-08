import { Inject, Injectable } from '@nestjs/common';

import { MAILER_PORT } from './mailer.port';
import type { IMailer, SendPasswordResetEmailArgs, SendVerificationEmailArgs } from './mailer.port';

/**
 * Public façade for transactional email. Callers (Better Auth callbacks, future
 * domain events) depend on this service, not on the port token directly, so the
 * injection token stays an implementation detail of the module boundary.
 */
@Injectable()
export class MailerService implements IMailer {
  constructor(@Inject(MAILER_PORT) private readonly mailer: IMailer) {}

  sendVerificationEmail(args: SendVerificationEmailArgs): Promise<void> {
    return this.mailer.sendVerificationEmail(args);
  }

  sendPasswordResetEmail(args: SendPasswordResetEmailArgs): Promise<void> {
    return this.mailer.sendPasswordResetEmail(args);
  }
}

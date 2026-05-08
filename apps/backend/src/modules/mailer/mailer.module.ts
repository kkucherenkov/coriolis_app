/**
 * WHY this file exists:
 * MailerModule owns the outbound transactional email abstraction for Coriolis
 * Companion. It registers either MockMailer (dev/test) or ResendMailer
 * (production) behind the MAILER_PORT token, decided by AppConfig.mailer.provider.
 *
 * AppConfig is available globally (ConfigModule is @Global), so no extra imports.
 * MailerService is exported so callers (AuthModule callback wiring) can inject it.
 */
import { Global, Module } from '@nestjs/common';

import { AppConfig } from '../../common/config/app-config';

import { MockMailer } from './adapters/mock-mailer';
import { ResendMailer } from './adapters/resend-mailer';
import { MAILER_PORT } from './mailer.port';
import { MailerService } from './mailer.service';

@Global()
@Module({
  providers: [
    {
      provide: MAILER_PORT,
      useFactory: (config: AppConfig) => {
        const { provider } = config.mailer;
        if (provider === 'resend') {
          return new ResendMailer(config);
        }
        return new MockMailer();
      },
      inject: [AppConfig],
    },
    MailerService,
  ],
  exports: [MailerService, MAILER_PORT],
})
export class MailerModule {}

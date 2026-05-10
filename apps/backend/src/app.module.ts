import path from 'node:path';

import { Module, type DynamicModule } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { CqrsModule } from '@nestjs/cqrs';
import { ScheduleModule } from '@nestjs/schedule';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import {
  AcceptLanguageResolver,
  HeaderResolver,
  I18nJsonLoader,
  I18nModule,
  QueryResolver,
} from 'nestjs-i18n';

import { AuthModule } from './common/auth/auth.module';
import { CentrifugoModule } from './common/centrifugo/centrifugo.module';
import { DataLoaderModule } from './common/dataloader/dataloader.module';
import { NotificationsModule } from './common/notifications/notifications.module';
import { ConfigModule } from './common/config/config.module';
import { ObservabilityModule } from './common/observability/observability.module';
import { PrismaModule } from './common/prisma/prisma.module';
import { RedisModule } from './common/redis/redis.module';
import { SmsModule } from './common/sms/sms.module';
import { CharactersModule } from './modules/characters/characters.module';
import { DiceModule } from './modules/dice/dice.module';
import { GameSessionsModule } from './modules/game-sessions/game-sessions.module';
import { NpcsModule } from './modules/npcs/npcs.module';
import { ShipsModule } from './modules/ships/ships.module';
import { SharingModule } from './modules/sharing/sharing.module';
import { IntegrationsModule } from './modules/integrations/integrations.module';
import { HealthModule } from './modules/health/health.module';
import { MailerModule } from './modules/mailer/mailer.module';
import { RealtimeModule } from './modules/realtime/realtime.module';
import { UsersModule } from './modules/users/users.module';

type ImportableModule = DynamicModule | (new (...args: unknown[]) => unknown);

const devOnlyModules: ImportableModule[] = [];

@Module({
  imports: [
    ConfigModule,
    CqrsModule.forRoot(),
    ScheduleModule.forRoot(),
    ThrottlerModule.forRoot({
      throttlers: [{ ttl: 60_000, limit: 60 }],
    }),
    I18nModule.forRoot({
      fallbackLanguage: 'en',
      loader: I18nJsonLoader,
      loaderOptions: {
        path: path.resolve(__dirname, 'i18n'),
        watch: false,
      },
      resolvers: [
        new QueryResolver(['lang']),
        new HeaderResolver(['x-lang']),
        AcceptLanguageResolver,
      ],
    }),
    ObservabilityModule,
    DataLoaderModule,
    PrismaModule,
    RedisModule,
    CentrifugoModule,
    SmsModule,
    NotificationsModule,
    IntegrationsModule,
    MailerModule,
    AuthModule,
    HealthModule,
    RealtimeModule,
    UsersModule,
    CharactersModule,
    DiceModule,
    GameSessionsModule,
    ShipsModule,
    NpcsModule,
    SharingModule,
    ...devOnlyModules,
  ],
  providers: [{ provide: APP_GUARD, useClass: ThrottlerGuard }],
})
export class AppModule {}

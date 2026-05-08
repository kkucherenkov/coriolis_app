/**
 * WHY this file exists:
 * Composition root for the users bounded context. Wires handlers, the controller,
 * the daily cascade-delete cron job, and the Prisma-backed adapter behind the
 * USER_REPO port token.
 *
 * AuthModule is @Global(), so SessionGuard is available without importing it here.
 * PrismaModule is also @Global() (via AppModule), so UserRepo can inject PrismaService.
 * ScheduleModule.forRoot() is imported once at the AppModule level.
 */
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { DeleteMeHandler } from './commands/delete-me.handler';
import { UpdateMeHandler } from './commands/update-me.handler';
import { USER_REPO } from './domain/user.ports';
import { UserDeletedHandler } from './events/user-deleted.handler';
import { UserRepo } from './infra/user.repo';
import { CascadeDeletedUsersJob } from './jobs/cascade-deleted-users.job';
import { GetMeHandler } from './queries/get-me.handler';
import { UsersController } from './users.controller';

@Module({
  imports: [CqrsModule],
  controllers: [UsersController],
  providers: [
    // Query handlers
    GetMeHandler,
    // Command handlers
    UpdateMeHandler,
    DeleteMeHandler,
    // Event handlers
    UserDeletedHandler,
    // Jobs
    CascadeDeletedUsersJob,
    // Infra adapters
    { provide: USER_REPO, useClass: UserRepo },
  ],
})
export class UsersModule {}

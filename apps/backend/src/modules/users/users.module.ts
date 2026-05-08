/**
 * WHY this file exists:
 * Composition root for the users bounded context. Wires handlers, the controller,
 * and the Prisma-backed adapter behind the USER_REPO port token.
 *
 * AuthModule is @Global(), so SessionGuard is available without importing it here.
 * PrismaModule is also @Global() (via AppModule), so UserRepo can inject PrismaService.
 */
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { UpdateMeHandler } from './commands/update-me.handler';
import { USER_REPO } from './domain/user.ports';
import { UserRepo } from './infra/user.repo';
import { GetMeHandler } from './queries/get-me.handler';
import { UsersController } from './users.controller';

@Module({
  imports: [CqrsModule],
  controllers: [UsersController],
  providers: [
    GetMeHandler,
    UpdateMeHandler,
    { provide: USER_REPO, useClass: UserRepo },
  ],
})
export class UsersModule {}

/**
 * WHY this file exists:
 * Composition root for the dice bounded context.
 * Wires all CQRS handlers, the Prisma repo, and the controller.
 *
 * PrismaModule is @Global() (via AppModule), so RollRepo can inject
 * PrismaService without importing PrismaModule here.
 * AuthModule is @Global(), so SessionGuard is available without importing here.
 * CharactersModule exports CHARACTER_REPO — imported so dice handlers can
 * verify character ownership without crossing bounded context boundaries.
 */
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { CharactersModule } from '../characters/characters.module';

import { CreateRollHandler } from './commands/create-roll.handler';
import { PushRollHandler } from './commands/push-roll.handler';
import { DiceController } from './dice.controller';
import { ROLL_REPO } from './domain/roll.ports';
import { RollRepo } from './infra/roll.repo';
import { ListRollsHandler } from './queries/list-rolls.handler';

// RollPushedEvent is consumed by RollPushedDpHandler registered in GameSessionsModule.
// The dice module only publishes the event; it does not own a handler for it.

@Module({
  imports: [CqrsModule, CharactersModule],
  controllers: [DiceController],
  providers: [
    // Commands
    CreateRollHandler,
    PushRollHandler,
    // Queries
    ListRollsHandler,
    // Infrastructure
    { provide: ROLL_REPO, useClass: RollRepo },
  ],
})
export class DiceModule {}

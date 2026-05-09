/**
 * WHY this file exists:
 * Composition root for the game-sessions bounded context.
 * Wires all CQRS handlers, the Prisma repo, and the controller.
 *
 * PrismaModule is @Global() (via AppModule), so GameSessionRepo and DpRepo can
 * inject PrismaService without importing PrismaModule here.
 * AuthModule is @Global(), so SessionGuard is available without importing here.
 *
 * The DP sub-context (Feature 7.3) lives under dp/ and is wired here.
 * RollPushedDpHandler subscribes to RollPushedEvent from the dice module.
 * Because NestJS CQRS EventBus is global-scoped, no cross-module import is needed.
 *
 * RealtimeModule is imported to make CENTRIFUGO_CLIENT available to
 * UpdateDpHandler and RollPushedDpHandler (T-7.4.1.b/c).
 */
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { RealtimeModule } from '../realtime/realtime.module';
import { AssignCharacterHandler } from './commands/assign-character.handler';
import { CreateGameSessionHandler } from './commands/create-game-session.handler';
import { DeleteGameSessionHandler } from './commands/delete-game-session.handler';
import { UnassignCharacterHandler } from './commands/unassign-character.handler';
import { UpdateGameSessionHandler } from './commands/update-game-session.handler';
import { UpdateDpHandler } from './dp/commands/update-dp.handler';
import { DP_REPO } from './dp/domain/dp.ports';
import { RollPushedDpHandler } from './dp/events/roll-pushed.handler';
import { DpRepo } from './dp/infra/dp.repo';
import { ListDpEventsHandler } from './dp/queries/list-dp-events.handler';
import { GAME_SESSION_REPO } from './domain/game-session.ports';
import { GameSessionsController } from './game-sessions.controller';
import { GameSessionRepo } from './infra/game-session.repo';
import { GetGameSessionHandler } from './queries/get-game-session.handler';
import { ListGameSessionsHandler } from './queries/list-game-sessions.handler';

@Module({
  imports: [CqrsModule, RealtimeModule],
  controllers: [GameSessionsController],
  providers: [
    // Commands
    CreateGameSessionHandler,
    UpdateGameSessionHandler,
    DeleteGameSessionHandler,
    AssignCharacterHandler,
    UnassignCharacterHandler,
    // DP commands
    UpdateDpHandler,
    // Queries
    GetGameSessionHandler,
    ListGameSessionsHandler,
    // DP queries
    ListDpEventsHandler,
    // Events
    RollPushedDpHandler,
    // Infrastructure
    { provide: GAME_SESSION_REPO, useClass: GameSessionRepo },
    { provide: DP_REPO, useClass: DpRepo },
  ],
})
export class GameSessionsModule {}

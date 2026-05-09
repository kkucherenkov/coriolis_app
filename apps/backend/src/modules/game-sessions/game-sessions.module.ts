/**
 * WHY this file exists:
 * Composition root for the game-sessions bounded context.
 * Wires all CQRS handlers, the Prisma repo, and the controller.
 *
 * PrismaModule is @Global() (via AppModule), so GameSessionRepo can inject
 * PrismaService without importing PrismaModule here.
 * AuthModule is @Global(), so SessionGuard is available without importing here.
 */
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { AssignCharacterHandler } from './commands/assign-character.handler';
import { CreateGameSessionHandler } from './commands/create-game-session.handler';
import { DeleteGameSessionHandler } from './commands/delete-game-session.handler';
import { UnassignCharacterHandler } from './commands/unassign-character.handler';
import { UpdateGameSessionHandler } from './commands/update-game-session.handler';
import { GAME_SESSION_REPO } from './domain/game-session.ports';
import { GameSessionsController } from './game-sessions.controller';
import { GameSessionRepo } from './infra/game-session.repo';
import { GetGameSessionHandler } from './queries/get-game-session.handler';
import { ListGameSessionsHandler } from './queries/list-game-sessions.handler';

@Module({
  imports: [CqrsModule],
  controllers: [GameSessionsController],
  providers: [
    // Commands
    CreateGameSessionHandler,
    UpdateGameSessionHandler,
    DeleteGameSessionHandler,
    AssignCharacterHandler,
    UnassignCharacterHandler,
    // Queries
    GetGameSessionHandler,
    ListGameSessionsHandler,
    // Infrastructure
    { provide: GAME_SESSION_REPO, useClass: GameSessionRepo },
  ],
})
export class GameSessionsModule {}

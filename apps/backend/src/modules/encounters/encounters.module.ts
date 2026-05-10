/**
 * WHY this file exists:
 * Composition root for the encounters bounded context.
 * Wires all CQRS handlers, the Prisma repo adapter, the GameSessionAccess
 * adapter, and both controllers.
 *
 * PrismaModule is @Global() (via AppModule), so EncounterRepo and
 * GameSessionAccessService can inject PrismaService without importing
 * PrismaModule here.
 * AuthModule is @Global(), so SessionGuard is available without importing here.
 */
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { CreateEncounterHandler } from './commands/create-encounter.handler';
import { UpdateEncounterHandler } from './commands/update-encounter.handler';
import { DeleteEncounterHandler } from './commands/delete-encounter.handler';
import { GAME_SESSION_ACCESS } from './domain/game-session-access.ports';
import { ENCOUNTER_REPO } from './domain/encounter.ports';
import { EncounterRepo } from './infra/encounter.repo';
import { GameSessionAccessService } from './infra/game-session-access.adapter';
import { GetEncounterHandler } from './queries/get-encounter.handler';
import { ListEncountersHandler } from './queries/list-encounters.handler';
import { EncountersController } from './encounters.controller';
import { NestedEncountersController } from './nested-encounters.controller';

@Module({
  imports: [CqrsModule],
  controllers: [EncountersController, NestedEncountersController],
  providers: [
    // Commands
    CreateEncounterHandler,
    UpdateEncounterHandler,
    DeleteEncounterHandler,
    // Queries
    GetEncounterHandler,
    ListEncountersHandler,
    // Infrastructure
    { provide: ENCOUNTER_REPO, useClass: EncounterRepo },
    { provide: GAME_SESSION_ACCESS, useClass: GameSessionAccessService },
  ],
  exports: [ENCOUNTER_REPO],
})
export class EncountersModule {}

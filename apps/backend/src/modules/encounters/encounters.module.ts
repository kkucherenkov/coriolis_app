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
 *
 * CombatantsModule is imported to make COMBATANT_COUNT available for
 * UpdateEncounterHandler (setup → active state-machine guard). This is a
 * one-way dependency: encounters → combatants. CombatantsModule does NOT
 * import EncountersModule (it injects ENCOUNTER_REPO and GAME_SESSION_ACCESS
 * tokens which are re-exported here). This pattern avoids a circular module dep.
 */
import { Module, forwardRef } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { CombatantsModule } from '../combatants/combatants.module';

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
  imports: [CqrsModule, forwardRef(() => CombatantsModule)],
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
  exports: [ENCOUNTER_REPO, GAME_SESSION_ACCESS],
})
export class EncountersModule {}

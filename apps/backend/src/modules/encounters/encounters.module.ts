/**
 * WHY this file exists:
 * Composition root for the encounters bounded context.
 * Wires all CQRS handlers, the Prisma repo adapter, the GameSessionAccess
 * adapter, the CentrifugoCombatPublisher, and both controllers.
 *
 * PrismaModule is @Global() (via AppModule), so EncounterRepo and
 * GameSessionAccessService can inject PrismaService without importing
 * PrismaModule here.
 * AuthModule is @Global(), so SessionGuard is available without importing here.
 * RealtimeModule is imported to make CENTRIFUGO_CLIENT available to
 * CentrifugoCombatPublisher (mirrors the wiring in GameSessionsModule).
 *
 * CombatantsModule is imported to make COMBATANT_COUNT and COMBATANT_REPO
 * available. This is a one-way dependency: encounters → combatants.
 * CombatantsModule does NOT import EncountersModule (it injects ENCOUNTER_REPO,
 * GAME_SESSION_ACCESS, and COMBAT_PUBLISHER tokens which are re-exported here).
 * This pattern avoids a circular module dep.
 */
import { Module, forwardRef } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { CombatantsModule } from '../combatants/combatants.module';
import { RealtimeModule } from '../realtime/realtime.module';

import { CreateEncounterHandler } from './commands/create-encounter.handler';
import { UpdateEncounterHandler } from './commands/update-encounter.handler';
import { DeleteEncounterHandler } from './commands/delete-encounter.handler';
import { RollInitiativeHandler } from './commands/roll-initiative.handler';
import { ReorderInitiativeHandler } from './commands/reorder-initiative.handler';
import { AdvanceTurnHandler } from './commands/advance-turn.handler';
import { AdvanceRoundHandler } from './commands/advance-round.handler';
import { GAME_SESSION_ACCESS } from './domain/game-session-access.ports';
import { ENCOUNTER_REPO, INITIATIVE_REPO } from './domain/encounter.ports';
import { EncounterRepo } from './infra/encounter.repo';
import { GameSessionAccessService } from './infra/game-session-access.adapter';
import { InitiativeRepo } from './infra/initiative.repo';
import { COMBAT_PUBLISHER, CentrifugoCombatPublisher } from './infra/combat.publisher';
import { GetEncounterHandler } from './queries/get-encounter.handler';
import { ListEncountersHandler } from './queries/list-encounters.handler';
import { EncountersController } from './encounters.controller';
import { NestedEncountersController } from './nested-encounters.controller';

@Module({
  imports: [CqrsModule, RealtimeModule, forwardRef(() => CombatantsModule)],
  controllers: [EncountersController, NestedEncountersController],
  providers: [
    // Commands
    CreateEncounterHandler,
    UpdateEncounterHandler,
    DeleteEncounterHandler,
    RollInitiativeHandler,
    ReorderInitiativeHandler,
    AdvanceTurnHandler,
    AdvanceRoundHandler,
    // Queries
    GetEncounterHandler,
    ListEncountersHandler,
    // Infrastructure
    { provide: ENCOUNTER_REPO, useClass: EncounterRepo },
    { provide: GAME_SESSION_ACCESS, useClass: GameSessionAccessService },
    { provide: INITIATIVE_REPO, useClass: InitiativeRepo },
    { provide: COMBAT_PUBLISHER, useClass: CentrifugoCombatPublisher },
  ],
  exports: [ENCOUNTER_REPO, GAME_SESSION_ACCESS, COMBAT_PUBLISHER],
})
export class EncountersModule {}

/**
 * WHY this file exists:
 * Composition root for the combatants bounded context.
 * Wires all CQRS handlers, the Prisma repo adapter, the source-lookup adapter,
 * and both controllers.
 *
 * PrismaModule is @Global() (via AppModule), so CombatantRepo and
 * SourceLookupAdapter can inject PrismaService without importing PrismaModule here.
 * AuthModule is @Global(), so SessionGuard is available without importing here.
 *
 * Circular dependency handling:
 * - EncountersModule imports CombatantsModule (to consume COMBATANT_COUNT).
 * - CombatantsModule imports EncountersModule via forwardRef (to consume
 *   ENCOUNTER_REPO, GAME_SESSION_ACCESS, and COMBAT_PUBLISHER needed by
 *   combatant command handlers).
 * NestJS forwardRef() breaks the circular module reference at the DI graph level.
 *
 * COMBATANT_COUNT is exported so EncountersModule can inject it into
 * UpdateEncounterHandler for the setup → active state-machine guard.
 * COMBAT_PUBLISHER is exported from EncountersModule and flows into
 * combatant handlers via the forwardRef import.
 */
import { Module, forwardRef } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { EncountersModule } from '../encounters/encounters.module';

import { AddCombatantHandler } from './commands/add-combatant.handler';
import { UpdateCombatantHandler } from './commands/update-combatant.handler';
import { DeleteCombatantHandler } from './commands/delete-combatant.handler';
import { ListCombatantsHandler } from './queries/list-combatants.handler';
import { CombatantRepo } from './infra/combatant.repo';
import { SourceLookupAdapter } from './infra/source-lookup.adapter';
import { COMBATANT_REPO, COMBATANT_COUNT } from './domain/combatant.ports';
import { SOURCE_LOOKUP } from './domain/source-lookup.ports';
import { CombatantsController } from './combatants.controller';
import { NestedCombatantsController } from './nested-combatants.controller';

@Module({
  imports: [CqrsModule, forwardRef(() => EncountersModule)],
  controllers: [CombatantsController, NestedCombatantsController],
  providers: [
    // Commands
    AddCombatantHandler,
    UpdateCombatantHandler,
    DeleteCombatantHandler,
    // Queries
    ListCombatantsHandler,
    // Infrastructure
    CombatantRepo,
    { provide: COMBATANT_REPO, useExisting: CombatantRepo },
    { provide: COMBATANT_COUNT, useExisting: CombatantRepo },
    { provide: SOURCE_LOOKUP, useClass: SourceLookupAdapter },
  ],
  exports: [COMBATANT_REPO, COMBATANT_COUNT],
})
export class CombatantsModule {}

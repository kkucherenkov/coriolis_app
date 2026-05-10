/**
 * WHY this file exists:
 * Composition root for the ships bounded context.
 * Wires all CQRS handlers, the Prisma repo adapter, and the controller.
 *
 * PrismaModule is @Global() (via AppModule), so ShipRepo can inject
 * PrismaService without importing PrismaModule here.
 * AuthModule is @Global(), so SessionGuard is available without importing here.
 */
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { AddShipModuleHandler } from './commands/add-ship-module.handler';
import { CreateShipHandler } from './commands/create-ship.handler';
import { DeleteShipHandler } from './commands/delete-ship.handler';
import { DeleteShipModuleHandler } from './commands/delete-ship-module.handler';
import { DuplicateShipHandler } from './commands/duplicate-ship.handler';
import { UpdateShipHandler } from './commands/update-ship.handler';
import { UpdateShipModuleHandler } from './commands/update-ship-module.handler';
import { SHIP_REPO } from './domain/ship.ports';
import { ShipRepo } from './infra/ship.repo';
import { GetShipExportHandler } from './queries/get-ship-export.handler';
import { GetShipHandler } from './queries/get-ship.handler';
import { ListShipsHandler } from './queries/list-ships.handler';
import { ShipModulesController } from './ship-modules.controller';
import { ShipsController } from './ships.controller';

@Module({
  imports: [CqrsModule],
  controllers: [ShipsController, ShipModulesController],
  providers: [
    // Commands
    CreateShipHandler,
    UpdateShipHandler,
    DeleteShipHandler,
    DuplicateShipHandler,
    AddShipModuleHandler,
    UpdateShipModuleHandler,
    DeleteShipModuleHandler,
    // Queries
    ListShipsHandler,
    GetShipHandler,
    GetShipExportHandler,
    // Infrastructure
    { provide: SHIP_REPO, useClass: ShipRepo },
  ],
})
export class ShipsModule {}

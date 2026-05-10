/**
 * WHY this file exists:
 * Composition root for the NPCs bounded context.
 * Wires all CQRS handlers, the Prisma repo adapter, and the controller.
 *
 * PrismaModule is @Global() (via AppModule), so NpcRepo can inject
 * PrismaService without importing PrismaModule here.
 * AuthModule is @Global(), so SessionGuard is available without importing here.
 */
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { CreateNpcHandler } from './commands/create-npc.handler';
import { DeleteNpcHandler } from './commands/delete-npc.handler';
import { DuplicateNpcHandler } from './commands/duplicate-npc.handler';
import { UpdateNpcHandler } from './commands/update-npc.handler';
import { NPC_REPO } from './domain/npc.ports';
import { NpcRepo } from './infra/npc.repo';
import { GetNpcHandler } from './queries/get-npc.handler';
import { ListNpcsHandler } from './queries/list-npcs.handler';
import { NpcsController } from './npcs.controller';

@Module({
  imports: [CqrsModule],
  controllers: [NpcsController],
  providers: [
    // Commands
    CreateNpcHandler,
    UpdateNpcHandler,
    DeleteNpcHandler,
    DuplicateNpcHandler,
    // Queries
    ListNpcsHandler,
    GetNpcHandler,
    // Infrastructure
    { provide: NPC_REPO, useClass: NpcRepo },
  ],
  exports: [NPC_REPO],
})
export class NpcsModule {}

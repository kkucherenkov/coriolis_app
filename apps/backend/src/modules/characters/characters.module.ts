/**
 * WHY this file exists:
 * Composition root for the characters bounded context.
 * Wires all CQRS handlers, the Prisma repo, ownership guard, and controller.
 * ItemsModule and TalentsModule are imported as nested feature modules.
 *
 * PrismaModule is @Global() (via AppModule), so CharacterRepo can inject PrismaService.
 * AuthModule is @Global(), so SessionGuard is available without importing here.
 */
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { CharacterOwnershipGuard } from './character-ownership.guard';
import { CharactersController } from './characters.controller';
import { CreateCharacterHandler } from './commands/create-character.handler';
import { DeleteCharacterHandler } from './commands/delete-character.handler';
import { DuplicateCharacterHandler } from './commands/duplicate-character.handler';
import { UpdateCharacterHandler } from './commands/update-character.handler';
import { CHARACTER_REPO } from './domain/character.ports';
import { CharacterUpdatedHandler } from './events/character-updated.event';
import { CharacterRepo } from './infra/character.repo';
import { ItemsModule } from './items/items.module';
import { CleanupAbandonedDraftsJob } from './jobs/cleanup-abandoned-drafts.job';
import { ExportCharacterHandler } from './queries/export-character.handler';
import { GetCharacterHandler } from './queries/get-character.handler';
import { ListCharactersHandler } from './queries/list-characters.handler';
import { TalentsModule } from './talents/talents.module';

@Module({
  imports: [CqrsModule, ItemsModule, TalentsModule],
  controllers: [CharactersController],
  providers: [
    // Commands
    CreateCharacterHandler,
    UpdateCharacterHandler,
    DeleteCharacterHandler,
    DuplicateCharacterHandler,
    // Queries
    GetCharacterHandler,
    ListCharactersHandler,
    ExportCharacterHandler,
    // Events
    CharacterUpdatedHandler,
    // Jobs
    CleanupAbandonedDraftsJob,
    // Infrastructure
    { provide: CHARACTER_REPO, useClass: CharacterRepo },
    // Guards
    CharacterOwnershipGuard,
  ],
  // Exported so SharingModule can verify character ownership without
  // duplicating the CHARACTER_REPO provider.
  exports: [{ provide: CHARACTER_REPO, useClass: CharacterRepo }],
})
export class CharactersModule {}

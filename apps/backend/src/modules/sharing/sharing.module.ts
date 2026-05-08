/**
 * WHY this file exists:
 * Composition root for the sharing bounded context.
 * Wires all CQRS handlers, the Prisma repo, ViewTracker, FlushViewTrackerJob,
 * and both controllers (owner-side + public).
 *
 * PrismaModule is @Global() (via AppModule), so ShareLinkRepo can inject
 * PrismaService without importing PrismaModule here.
 * AuthModule is @Global(), so SessionGuard is available without importing here.
 * CharactersModule exports CHARACTER_REPO — imported to allow sharing handlers
 * to verify character ownership without crossing bounded context boundaries.
 */
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { CharactersModule } from '../characters/characters.module';

import { CreateShareLinkHandler } from './commands/create-share-link.handler';
import { RevokeShareLinkHandler } from './commands/revoke-share-link.handler';
import { SHARE_LINK_REPO } from './domain/share-link.ports';
import { ShareLinkRepo } from './infra/share-link.repo';
import { ViewTracker } from './infra/view-tracker';
import { FlushViewTrackerJob } from './jobs/flush-view-tracker.job';
import { PublicSharingController } from './public-sharing.controller';
import { GetPublicCharacterHandler } from './queries/get-public-character.handler';
import { ListShareLinksHandler } from './queries/list-share-links.handler';
import { SharingController } from './sharing.controller';

@Module({
  imports: [CqrsModule, CharactersModule],
  controllers: [SharingController, PublicSharingController],
  providers: [
    // Commands
    CreateShareLinkHandler,
    RevokeShareLinkHandler,
    // Queries
    ListShareLinksHandler,
    GetPublicCharacterHandler,
    // Infrastructure
    { provide: SHARE_LINK_REPO, useClass: ShareLinkRepo },
    ViewTracker,
    // Jobs
    FlushViewTrackerJob,
  ],
})
export class SharingModule {}

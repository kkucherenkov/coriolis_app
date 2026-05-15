/**
 * WHY this file exists:
 * Composition root for the memberships bounded context. Wires the five
 * commands, two queries, the controller, the Prisma-backed repo, and the
 * character-ownership adapter.
 *
 * PrismaModule is @Global() (via AppModule), so MembershipRepo and
 * CharacterOwnershipAdapter can inject PrismaService without importing
 * PrismaModule here. AuthModule is @Global(), so SessionGuard is available
 * without importing here.
 */
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { PrismaService } from '../../common/prisma/prisma.service';
import { AcceptInviteHandler } from './commands/accept-invite.handler';
import { KickMemberHandler } from './commands/kick-member.handler';
import { LeaveSessionHandler } from './commands/leave-session.handler';
import { CHARACTER_OWNERSHIP, LinkCharacterHandler } from './commands/link-character.handler';
import { RevokeInviteHandler } from './commands/revoke-invite.handler';
import { RotateInviteHandler } from './commands/rotate-invite.handler';
import { GAME_SESSION_INVITE_REPO, MEMBERSHIP_REPO } from './domain/membership.ports';
import { InvitesController } from './http/invites.controller';
import { MeMembershipsController } from './http/me-memberships.controller';
import { CharacterOwnershipAdapter } from './infra/character-ownership.adapter';
import { MembershipRepo } from './infra/membership.repo';
import { MembershipsController } from './memberships.controller';
import { GetInviteMetadataHandler } from './queries/get-invite-metadata.handler';
import {
  DISPLAY_NAME_FETCHER,
  GetInvitePreviewHandler,
} from './queries/get-invite-preview.handler';
import { GetMyMembershipsHandler } from './queries/get-my-memberships.handler';
import { ListMembershipsHandler } from './queries/list-memberships.handler';

@Module({
  imports: [CqrsModule],
  controllers: [MembershipsController, InvitesController, MeMembershipsController],
  providers: [
    RotateInviteHandler,
    RevokeInviteHandler,
    KickMemberHandler,
    LeaveSessionHandler,
    LinkCharacterHandler,
    AcceptInviteHandler,
    ListMembershipsHandler,
    GetInviteMetadataHandler,
    GetInvitePreviewHandler,
    GetMyMembershipsHandler,
    MembershipRepo,
    { provide: MEMBERSHIP_REPO, useExisting: MembershipRepo },
    { provide: GAME_SESSION_INVITE_REPO, useExisting: MembershipRepo },
    { provide: CHARACTER_OWNERSHIP, useClass: CharacterOwnershipAdapter },
    {
      provide: DISPLAY_NAME_FETCHER,
      useFactory:
        (prisma: PrismaService) =>
        async (userId: string): Promise<string> => {
          const user = await prisma.user.findUnique({
            where: { id: userId },
            select: { displayName: true, name: true },
          });
          return user?.displayName ?? user?.name ?? 'Unknown';
        },
      inject: [PrismaService],
    },
  ],
  exports: [MEMBERSHIP_REPO],
})
export class MembershipsModule {}

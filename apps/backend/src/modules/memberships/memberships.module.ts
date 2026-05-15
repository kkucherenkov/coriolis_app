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

import { KickMemberHandler } from './commands/kick-member.handler';
import { LeaveSessionHandler } from './commands/leave-session.handler';
import { CHARACTER_OWNERSHIP, LinkCharacterHandler } from './commands/link-character.handler';
import { RevokeInviteHandler } from './commands/revoke-invite.handler';
import { RotateInviteHandler } from './commands/rotate-invite.handler';
import { GAME_SESSION_INVITE_REPO, MEMBERSHIP_REPO } from './domain/membership.ports';
import { CharacterOwnershipAdapter } from './infra/character-ownership.adapter';
import { MembershipRepo } from './infra/membership.repo';
import { MembershipsController } from './memberships.controller';
import { GetInviteMetadataHandler } from './queries/get-invite-metadata.handler';
import { ListMembershipsHandler } from './queries/list-memberships.handler';

@Module({
  imports: [CqrsModule],
  controllers: [MembershipsController],
  providers: [
    RotateInviteHandler,
    RevokeInviteHandler,
    KickMemberHandler,
    LeaveSessionHandler,
    LinkCharacterHandler,
    ListMembershipsHandler,
    GetInviteMetadataHandler,
    MembershipRepo,
    { provide: MEMBERSHIP_REPO, useExisting: MembershipRepo },
    { provide: GAME_SESSION_INVITE_REPO, useExisting: MembershipRepo },
    { provide: CHARACTER_OWNERSHIP, useClass: CharacterOwnershipAdapter },
  ],
  exports: [MEMBERSHIP_REPO],
})
export class MembershipsModule {}

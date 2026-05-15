/**
 * WHY this file exists:
 * Route for GET /api/v1/me/memberships — the caller's own active memberships.
 * Lives under the /me resource tree, separate from the session-scoped
 * MembershipsController at /game-sessions/:gameSessionId.
 */
import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { QueryBus } from '@nestjs/cqrs';

import { SessionGuard } from '../../../common/auth/auth.guard';
import { GetMyMembershipsQuery } from '../queries/get-my-memberships.query';

import type { AuthenticatedRequest } from '../../../common/auth/auth.guard';
import type { MyMembershipReadModel } from '../domain/membership.ports';

@UseGuards(SessionGuard)
@Controller({ path: 'me', version: '1' })
export class MeMembershipsController {
  constructor(private readonly queryBus: QueryBus) {}

  /** GET /api/v1/me/memberships */
  @Get('memberships')
  async getMyMemberships(
    @Req() req: AuthenticatedRequest,
  ): Promise<{ items: MyMembershipReadModel[] }> {
    const items = await this.queryBus.execute<GetMyMembershipsQuery, MyMembershipReadModel[]>(
      new GetMyMembershipsQuery(req.userId),
    );
    return { items };
  }
}

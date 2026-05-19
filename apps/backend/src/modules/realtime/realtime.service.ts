/**
 * WHY this file exists:
 * Issues short-lived Centrifugo connection JWTs scoped to the channels the
 * authenticated user is allowed to subscribe to.
 *
 * Channel allow list (embedded in the JWT `channels` claim):
 *  - session.<id>         for every GameSession the user has an active membership in
 *    (role = 'gm' OR 'player', leftAt IS NULL).
 *  - session.<id>.chat    broadcast chat channel for the session.
 *  - session.<id>.member.<membershipId>  per-member channel for whispers.
 *  - character.<id> placeholder is reserved for Epic 8/9 player subscriptions;
 *    it is not yet populated here.
 *
 * The JWT also carries a connection-level `info` claim:
 *   { memberships: [{ gameSessionId, membershipId }] }
 * Centrifugo propagates `info` into the `connInfo` field on presence /
 * join / leave events for every channel the connection subscribes to.
 * The chat tab strip (web + mobile) reads this to map presence entries
 * back to membershipId — see the Phase 8.5 follow-up #6 wiring.
 *
 * ISessionAccessRepo is injected via SESSION_ACCESS_REPO to avoid a
 * circular module dependency: GameSessionsModule imports RealtimeModule (for
 * CENTRIFUGO_CLIENT), so RealtimeModule cannot import GameSessionsModule in
 * return. This narrow port keeps the layering clean.
 */
import { Inject, Injectable } from '@nestjs/common';
import * as jwt from 'jsonwebtoken';
import { I18nService } from 'nestjs-i18n';

import { AuthService } from '../../common/auth/auth.service';
import { AppConfig } from '../../common/config/app-config';
import { RealtimeAuthError } from './domain/realtime.errors';
import {
  SESSION_ACCESS_REPO,
  type ISessionAccessRepo,
  type UserMembership,
} from './domain/session-ownership.port';

import type { Request } from 'express';

export interface RealtimeToken {
  token: string;
  expiresAt: string;
}

@Injectable()
export class RealtimeService {
  constructor(
    private readonly config: AppConfig,
    private readonly auth: AuthService,
    private readonly i18n: I18nService,
    @Inject(SESSION_ACCESS_REPO)
    private readonly sessionAccess: ISessionAccessRepo,
  ) {}

  async issueToken(request: Request): Promise<RealtimeToken> {
    const session = await this.auth.getSession(request);
    if (!session?.user) {
      throw new RealtimeAuthError();
    }

    const userId = session.user.id;
    const memberships = await this.sessionAccess.findActiveMembershipsForUser(userId);
    const allowedChannels = buildAllowedChannels(memberships);
    const info = buildConnectInfo(memberships);

    const { tokenHmacSecret, tokenTtlSeconds } = this.config.centrifugo;
    const expSeconds = Math.floor(Date.now() / 1000) + tokenTtlSeconds;
    const token = jwt.sign(
      {
        sub: userId,
        exp: expSeconds,
        channels: allowedChannels,
        info,
      },
      tokenHmacSecret,
      { algorithm: 'HS256' },
    );

    return { token, expiresAt: new Date(expSeconds * 1000).toISOString() };
  }
}

/**
 * Connection-level `info` claim payload embedded in the realtime JWT.
 *
 * Centrifugo propagates this verbatim to other subscribers via the
 * `connInfo` field on presence / join / leave events. Frontend clients
 * (web + mobile) read it to map a presence entry to its membershipId.
 *
 * Schema mirrored in `packages/specs/asyncapi/centrifugo.yaml`
 * (`RealtimeConnectInfo`).
 */
export interface RealtimeConnectInfo {
  memberships: {
    gameSessionId: string;
    membershipId: string;
  }[];
}

/**
 * Builds the list of Centrifugo channel names this user may subscribe to.
 *
 * Per active membership (GM or player, leftAt IS NULL), three channel families
 * are granted:
 *   - session.<id>                     — DP / roll events (existing)
 *   - session.<id>.chat                — broadcast chat channel (Stream C)
 *   - session.<id>.member.<membId>     — per-member channel for whispers (Stream C)
 *
 * Player character channels (`character.<id>`) are deferred to Epic 8/9.
 */
function buildAllowedChannels(memberships: readonly UserMembership[]): string[] {
  const channels: string[] = [];
  for (const m of memberships) {
    channels.push(
      `session.${m.gameSessionId}`,
      `session.${m.gameSessionId}.chat`,
      `session.${m.gameSessionId}.member.${m.membershipId}`,
    );
  }
  return channels;
}

function buildConnectInfo(memberships: readonly UserMembership[]): RealtimeConnectInfo {
  return {
    memberships: memberships.map((m) => ({
      gameSessionId: m.gameSessionId,
      membershipId: m.membershipId,
    })),
  };
}

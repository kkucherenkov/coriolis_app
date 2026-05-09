/**
 * WHY this file exists:
 * Handles the UpdateDpCommand — the single write path for Darkness Points.
 *
 * Validation order:
 *  1. delta != 0 (DP_INVALID_DELTA)
 *  2. Session exists (GAME_SESSION_NOT_FOUND)
 *  3. If delta < 0 and !internal → caller must be the GM owner (GAME_SESSION_NOT_OWNER)
 *  4. dpCount + delta >= 0 (DP_BELOW_ZERO)
 *  5. Delegate to IDpRepo.applyDelta (atomic update + audit insert in a transaction)
 *  6. Re-fetch and return the updated GameSession read model
 *  7. Publish dp.changed to the session Centrifugo channel (non-fatal: publish
 *     failures are caught and logged; they must not roll back the DB write)
 */
import { Inject, Logger } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { CENTRIFUGO_CLIENT, type ICentrifugoClient } from '../../../realtime/centrifugo.client';
import {
  GameSessionNotFoundError,
  GameSessionNotOwnerError,
} from '../../domain/game-session.errors';
import { GAME_SESSION_REPO } from '../../domain/game-session.ports';
import { DpBelowZeroError, DpInvalidDeltaError } from '../domain/dp.errors';
import { DP_REPO } from '../domain/dp.ports';

import { UpdateDpCommand } from './update-dp.command';

import type { GameSessionReadModel, IGameSessionRepo } from '../../domain/game-session.ports';
import type { IDpRepo } from '../domain/dp.ports';

/** Maps the DB/command DpSource enum to the AsyncAPI channel source enum. */
const SOURCE_TO_CHANNEL: Record<string, 'gm-manual' | 'roll-push' | 'system'> = {
  GM_MANUAL: 'gm-manual',
  ROLL_PUSH: 'roll-push',
  SYSTEM: 'system',
};

@CommandHandler(UpdateDpCommand)
export class UpdateDpHandler implements ICommandHandler<UpdateDpCommand, GameSessionReadModel> {
  private readonly logger = new Logger(UpdateDpHandler.name);

  constructor(
    @Inject(GAME_SESSION_REPO) private readonly sessionRepo: IGameSessionRepo,
    @Inject(DP_REPO) private readonly dpRepo: IDpRepo,
    @Inject(CENTRIFUGO_CLIENT) private readonly centrifugo: ICentrifugoClient,
  ) {}

  async execute(command: UpdateDpCommand): Promise<GameSessionReadModel> {
    const { gameSessionId, callerId, delta, source, reason, internal, rollId } = command;

    // 1. delta must be non-zero
    if (delta === 0) throw new DpInvalidDeltaError();

    // 2. Session must exist
    const session = await this.sessionRepo.findById(gameSessionId);
    if (!session) throw new GameSessionNotFoundError(gameSessionId);

    // 3. Negative delta ACL — only the GM owner may remove DP (internal callers bypass)
    if (delta < 0 && !internal && session.ownerId !== callerId) {
      throw new GameSessionNotOwnerError(gameSessionId);
    }

    // 4. Would go below zero?
    if (session.dpCount + delta < 0) {
      throw new DpBelowZeroError(session.dpCount, delta);
    }

    // 5. Apply atomically — dpRepo handles the transaction
    const newDpCount = await this.dpRepo.applyDelta({
      gameSessionId,
      delta,
      reason: reason ?? null,
      source,
      rollId: rollId ?? null,
    });

    // 6. Return the refreshed session
    // Session cannot have disappeared between the two calls in a healthy system;
    // but we guard for the type checker.
    const updated = await this.sessionRepo.findById(gameSessionId);
    if (!updated) throw new GameSessionNotFoundError(gameSessionId);

    // 7. Publish dp.changed — non-fatal; DB write is already committed
    try {
      await this.centrifugo.publish(`session.${gameSessionId}`, {
        gameSessionId,
        dpCount: newDpCount,
        delta,
        source: SOURCE_TO_CHANNEL[source] ?? 'system',
        at: new Date().toISOString(),
      });
    } catch (error) {
      this.logger.error(
        `Failed to publish dp.changed for session ${gameSessionId}: ${String(error)}`,
      );
    }

    return updated;
  }
}

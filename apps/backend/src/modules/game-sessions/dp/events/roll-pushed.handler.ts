/**
 * WHY this file exists:
 * Handles RollPushedEvent from the dice module and wires it to:
 *  1. +1 DP on the linked session (via UpdateDpCommand).
 *  2. Publish roll.pushed to the session Centrifugo channel.
 *
 * If gameSessionId is null the event is skipped — the roll was made outside
 * of any session context.
 *
 * The internal flag on UpdateDpCommand bypasses the GM-owner ACL so the
 * system can add DP without needing to know who the GM is.
 *
 * Both operations (DP increment and Centrifugo publish) are non-fatal: a
 * failure in either is logged but does not propagate to the caller. The roll
 * has already been committed to the database.
 */
import { Inject, Logger } from '@nestjs/common';
import { CommandBus, EventsHandler, IEventHandler } from '@nestjs/cqrs';

import { CENTRIFUGO_CLIENT, type ICentrifugoClient } from '../../../realtime/centrifugo.client';
import { RollPushedEvent } from '../../../dice/events/roll-pushed.event';
import { UpdateDpCommand } from '../commands/update-dp.command';

@EventsHandler(RollPushedEvent)
export class RollPushedDpHandler implements IEventHandler<RollPushedEvent> {
  private readonly logger = new Logger(RollPushedDpHandler.name);

  constructor(
    private readonly commandBus: CommandBus,
    @Inject(CENTRIFUGO_CLIENT) private readonly centrifugo: ICentrifugoClient,
  ) {}

  async handle(event: RollPushedEvent): Promise<void> {
    const { rollId, characterId, gameSessionId, hits } = event;

    if (!gameSessionId) {
      this.logger.debug(
        `Roll ${rollId} (character ${characterId}) has no gameSessionId — skipping DP increment.`,
      );
      return;
    }

    // Publish roll.pushed before the DP increment so subscribers can show
    // the push event in the UI before the counter updates.
    try {
      await this.centrifugo.publish(`session.${gameSessionId}`, {
        rollId,
        characterId,
        gameSessionId,
        hits,
        at: new Date().toISOString(),
      });
    } catch (error) {
      // Non-fatal — the roll.pushed notification is best-effort.
      this.logger.error(
        `Failed to publish roll.pushed for session ${gameSessionId} / roll ${rollId}: ${String(error)}`,
      );
    }

    try {
      await this.commandBus.execute(
        new UpdateDpCommand(
          gameSessionId,
          'system',
          1,
          'ROLL_PUSH',
          'Roll pushed by player',
          true, // internal — bypasses GM-owner ACL
          rollId,
        ),
      );
      this.logger.log(`+1 DP applied to session ${gameSessionId} via roll push ${rollId}.`);
    } catch (error) {
      // Non-fatal — log and move on. The roll has already been committed.
      this.logger.error(
        `Failed to apply +1 DP to session ${gameSessionId} for roll ${rollId}: ${String(error)}`,
      );
    }
  }
}

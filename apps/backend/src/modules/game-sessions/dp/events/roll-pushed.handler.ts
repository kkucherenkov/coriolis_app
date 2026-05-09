/**
 * WHY this file exists:
 * Handles RollPushedEvent from the dice module and wires it to +1 DP on the
 * linked session. This replaces the stub handler that previously lived in the
 * dice module's events/ directory.
 *
 * If gameSessionId is null the event is skipped — the roll was made outside
 * of any session context.
 *
 * The internal flag on UpdateDpCommand bypasses the GM-owner ACL so the
 * system can add DP without needing to know who the GM is.
 *
 * TODO(epic-7-4-realtime): publish to Centrifugo session channel after the
 * DP is applied.
 */
import { Logger } from '@nestjs/common';
import { CommandBus, EventsHandler, IEventHandler } from '@nestjs/cqrs';

import { RollPushedEvent } from '../../../dice/events/roll-pushed.event';
import { UpdateDpCommand } from '../commands/update-dp.command';

@EventsHandler(RollPushedEvent)
export class RollPushedDpHandler implements IEventHandler<RollPushedEvent> {
  private readonly logger = new Logger(RollPushedDpHandler.name);

  constructor(private readonly commandBus: CommandBus) {}

  async handle(event: RollPushedEvent): Promise<void> {
    const { rollId, characterId, gameSessionId } = event;

    if (!gameSessionId) {
      this.logger.debug(
        `Roll ${rollId} (character ${characterId}) has no gameSessionId — skipping DP increment.`,
      );
      return;
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
    // TODO(epic-7-4-realtime): publish updated DP to Centrifugo session channel.
  }
}

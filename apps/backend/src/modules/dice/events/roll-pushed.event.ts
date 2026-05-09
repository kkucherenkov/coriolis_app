import { Logger } from '@nestjs/common';
import { EventsHandler, IEventHandler } from '@nestjs/cqrs';

export class RollPushedEvent {
  constructor(
    public readonly rollId: string,
    public readonly characterId: string,
    public readonly gameSessionId: string | null,
    public readonly hits: number,
  ) {}
}

/**
 * Stub handler — logs the event for now.
 *
 * TODO(epic-7-3-dp): wire to UpdateDpCommand once GameSession exists.
 * TODO(epic-7-4-realtime): publish to Centrifugo session channel.
 */
@EventsHandler(RollPushedEvent)
export class RollPushedHandler implements IEventHandler<RollPushedEvent> {
  private readonly logger = new Logger(RollPushedHandler.name);

  handle(event: RollPushedEvent): void {
    this.logger.log(`Roll pushed: ${JSON.stringify(event)}`);
    // TODO(epic-7-3-dp): wire to UpdateDpCommand once GameSession exists.
    // TODO(epic-7-4-realtime): publish to Centrifugo session channel.
  }
}

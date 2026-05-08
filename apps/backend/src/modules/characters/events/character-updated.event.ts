import { Logger } from '@nestjs/common';
import { EventsHandler, IEventHandler } from '@nestjs/cqrs';

export class CharacterUpdatedEvent {
  constructor(
    public readonly characterId: string,
    public readonly ownerId: string,
  ) {}
}

/**
 * Stub handler — logs the event for now.
 * Epic 7 will publish to Centrifugo channel `character.<id>.private` here.
 */
@EventsHandler(CharacterUpdatedEvent)
export class CharacterUpdatedHandler implements IEventHandler<CharacterUpdatedEvent> {
  private readonly logger = new Logger(CharacterUpdatedHandler.name);

  handle(event: CharacterUpdatedEvent): void {
    this.logger.debug(
      `CharacterUpdatedEvent: characterId=${event.characterId} ownerId=${event.ownerId}`,
    );
    // TODO(Epic 7): publish to Centrifugo channel `character.${event.characterId}.private`
  }
}

/**
 * WHY this file exists:
 * Log-only event handler for `UserDeletedEvent`. Serves as a hook point for
 * future Centrifugo channel cleanup and share-slug cache invalidation (Epic 7+).
 * Event handlers are kept here rather than in infra/ because they contain no
 * adapter logic yet — just a log.
 *
 * TODO (Epic 7): subscribe to Centrifugo and disconnect the user's channels.
 * TODO (Epic 7): invalidate any share-slug cache entries keyed to this userId.
 */
import { Logger } from '@nestjs/common';
import { EventsHandler, IEventHandler } from '@nestjs/cqrs';

import { UserDeletedEvent } from './user-deleted.event';

@EventsHandler(UserDeletedEvent)
export class UserDeletedHandler implements IEventHandler<UserDeletedEvent> {
  private readonly logger = new Logger(UserDeletedHandler.name);

  handle(event: UserDeletedEvent): void {
    this.logger.log(
      `User soft-deleted: id=${event.userId} deletedAt=${event.deletedAt.toISOString()}`,
    );
  }
}

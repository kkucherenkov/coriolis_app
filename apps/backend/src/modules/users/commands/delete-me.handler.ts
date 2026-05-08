/**
 * WHY this file exists:
 * Command handler for `DeleteMeCommand`. Implements the soft-delete flow:
 *  1. Idempotent check — already-deleted user returns early (204 is correct).
 *  2. Stamp `deletedAt` on the user row (30-day grace window starts here).
 *  3. Revoke all Better Auth sessions immediately so the client cannot make
 *     further authenticated requests.
 *  4. Publish `UserDeletedEvent` for downstream hooks (Centrifugo cleanup,
 *     analytics — Epic 7+).
 *
 * The handler intentionally does NOT return a value because the controller
 * responds with 204 No Content. The EventBus call is fire-and-forget for the
 * current log-only handler; if a future handler throws, it will surface as an
 * unhandled rejection in the event loop (acceptable for non-critical side effects).
 */
import { Inject, Logger } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import { AuthService } from '../../../common/auth/auth.service';
import { USER_REPO } from '../domain/user.ports';
import { UserDeletedEvent } from '../events/user-deleted.event';

import { DeleteMeCommand } from './delete-me.command';

import type { IUserRepo } from '../domain/user.ports';

@CommandHandler(DeleteMeCommand)
export class DeleteMeHandler implements ICommandHandler<DeleteMeCommand, void> {
  private readonly logger = new Logger(DeleteMeHandler.name);

  constructor(
    @Inject(USER_REPO) private readonly repo: IUserRepo,
    private readonly auth: AuthService,
    private readonly eventBus: EventBus,
  ) {}

  async execute(command: DeleteMeCommand): Promise<void> {
    const { userId } = command;

    const deletedAt = new Date();

    // `softDelete` returns null when the row is already deleted or does not
    // exist — both cases are treated as 204 (idempotent per spec).
    const stamped = await this.repo.softDelete(userId, deletedAt);

    if (stamped === null) {
      // Already soft-deleted or never existed — nothing more to do.
      this.logger.log(`DELETE /me: userId=${userId} already deleted or not found; returning 204.`);
      return;
    }

    // Revoke all active sessions immediately so the client is signed out.
    await this.auth.revokeAllSessions(userId);

    // Publish event for future hooks (Centrifugo cleanup, analytics).
    this.eventBus.publish(new UserDeletedEvent(userId, stamped));

    this.logger.log(`User soft-deleted: id=${userId} deletedAt=${stamped.toISOString()}`);
  }
}

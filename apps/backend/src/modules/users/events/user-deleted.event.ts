/**
 * WHY this file exists:
 * Domain event published after a user soft-delete. Future Centrifugo channel
 * cleanup, analytics, and email confirmation hooks subscribe to this event
 * (Epic 7+). Keeping it here decouples the hard-delete cron from those
 * concerns at the domain boundary.
 */
export class UserDeletedEvent {
  constructor(
    /** The id of the user who was soft-deleted. */
    public readonly userId: string,
    /** The exact timestamp written to `deletedAt` (anchor for the 30-day window). */
    public readonly deletedAt: Date,
  ) {}
}

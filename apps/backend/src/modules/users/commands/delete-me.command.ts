/**
 * Command dispatched by DELETE /api/v1/me.
 * Carries only the authenticated user's id — nothing from the request body.
 */
export class DeleteMeCommand {
  constructor(public readonly userId: string) {}
}

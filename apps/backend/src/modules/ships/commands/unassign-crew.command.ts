/**
 * WHY this file exists:
 * Command for removing a character from a ship's crew roster
 * (DELETE /api/v1/ships/{id}/crew/{characterId}).
 * Operation is idempotent — clearing an already-empty slot is a no-op.
 */
export class UnassignCrewCommand {
  constructor(
    public readonly shipId: string,
    public readonly ownerId: string,
    public readonly characterId: string,
  ) {}
}

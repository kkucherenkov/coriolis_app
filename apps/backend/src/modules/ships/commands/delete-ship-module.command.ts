/**
 * WHY this file exists:
 * Command for removing a module from a ship (DELETE /api/v1/ship-modules/{id}).
 * Mandatory-slot guard (BRIDGE / REACTOR / DRIVE) lives in the handler.
 */

export class DeleteShipModuleCommand {
  constructor(
    public readonly moduleId: string,
    public readonly ownerId: string,
  ) {}
}

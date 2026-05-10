export class DuplicateShipCommand {
  constructor(
    public readonly id: string,
    public readonly ownerId: string,
  ) {}
}

export class DeleteShipCommand {
  constructor(
    public readonly id: string,
    public readonly ownerId: string,
  ) {}
}

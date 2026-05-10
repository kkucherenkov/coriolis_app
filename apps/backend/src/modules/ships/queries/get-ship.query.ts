export class GetShipQuery {
  constructor(
    public readonly id: string,
    public readonly ownerId: string,
  ) {}
}

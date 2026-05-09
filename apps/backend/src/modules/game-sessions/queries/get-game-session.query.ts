export class GetGameSessionQuery {
  constructor(
    public readonly id: string,
    public readonly ownerId: string,
  ) {}
}

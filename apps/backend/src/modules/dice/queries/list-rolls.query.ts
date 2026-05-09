export class ListRollsQuery {
  constructor(
    public readonly callerId: string,
    public readonly characterId: string,
    public readonly limit: number,
  ) {}
}

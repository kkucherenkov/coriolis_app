export class ListShipsQuery {
  constructor(
    public readonly ownerId: string,
    public readonly limit: number,
    public readonly cursor?: string,
  ) {}
}

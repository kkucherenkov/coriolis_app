export class ListNpcsQuery {
  constructor(
    public readonly ownerId: string,
    public readonly limit: number,
    public readonly cursor?: string,
  ) {}
}

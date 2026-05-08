export class ListCharactersQuery {
  constructor(
    public readonly ownerId: string,
    public readonly limit: number,
    public readonly cursor?: string,
    /** When true, both draft and active characters are returned. Default false. */
    public readonly includeDrafts = false,
  ) {}
}

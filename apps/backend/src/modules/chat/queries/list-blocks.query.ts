export class ListBlocksQuery {
  constructor(
    public readonly gameSessionId: string,
    public readonly callerUserId: string,
  ) {}
}

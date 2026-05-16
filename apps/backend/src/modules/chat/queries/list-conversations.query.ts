export class ListConversationsQuery {
  constructor(
    public readonly gameSessionId: string,
    public readonly callerUserId: string,
  ) {}
}

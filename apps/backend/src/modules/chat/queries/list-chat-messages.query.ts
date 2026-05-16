export class ListChatMessagesQuery {
  constructor(
    public readonly gameSessionId: string,
    public readonly callerUserId: string,
    public readonly conversation: string,
    public readonly cursor: string | null,
    public readonly limit: number,
  ) {}
}

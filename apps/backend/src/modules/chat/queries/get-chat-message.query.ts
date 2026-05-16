export class GetChatMessageQuery {
  constructor(
    public readonly messageId: string,
    public readonly callerUserId: string,
  ) {}
}

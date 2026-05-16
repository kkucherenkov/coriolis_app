export class MarkConversationReadCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly userId: string,
    public readonly conversationKey: string,
    public readonly lastReadAt: Date,
  ) {}
}

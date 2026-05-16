export class EditChatMessageCommand {
  constructor(
    public readonly messageId: string,
    public readonly userId: string,
    public readonly callerMembershipId: string,
    public readonly body: string,
  ) {}
}

export class DeleteChatMessageCommand {
  constructor(
    public readonly messageId: string,
    public readonly userId: string,
    public readonly callerMembershipId: string,
    public readonly isCallerGm: boolean,
  ) {}
}

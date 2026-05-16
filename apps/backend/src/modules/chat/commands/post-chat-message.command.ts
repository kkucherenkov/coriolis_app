export class PostChatMessageCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly userId: string,
    public readonly authorMembershipId: string,
    public readonly targetMembershipId: string | null,
    public readonly body: string,
  ) {}
}

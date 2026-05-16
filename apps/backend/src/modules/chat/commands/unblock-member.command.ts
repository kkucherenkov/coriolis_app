export class UnblockMemberCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly userId: string,
    public readonly targetMembershipId: string,
  ) {}
}

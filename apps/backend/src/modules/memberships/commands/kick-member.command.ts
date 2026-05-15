export class KickMemberCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly callerUserId: string,
    public readonly membershipId: string,
  ) {}
}

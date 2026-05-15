export class RevokeInviteCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly userId: string,
  ) {}
}

export class AcceptInviteCommand {
  constructor(
    public readonly token: string,
    public readonly userId: string,
    public readonly characterId: string | null,
  ) {}
}

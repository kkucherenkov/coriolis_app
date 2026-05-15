export class RotateInviteCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly userId: string,
  ) {}
}

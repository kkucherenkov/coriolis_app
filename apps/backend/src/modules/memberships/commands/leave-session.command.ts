export class LeaveSessionCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly userId: string,
    public readonly membershipId: string,
  ) {}
}

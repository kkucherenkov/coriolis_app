export class MemberJoinedEvent {
  constructor(
    public readonly membershipId: string,
    public readonly gameSessionId: string,
    public readonly userId: string,
  ) {}
}

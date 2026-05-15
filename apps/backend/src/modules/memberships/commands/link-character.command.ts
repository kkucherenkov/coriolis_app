export class LinkCharacterCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly callerUserId: string,
    public readonly membershipId: string,
    public readonly characterId: string | null,
  ) {}
}

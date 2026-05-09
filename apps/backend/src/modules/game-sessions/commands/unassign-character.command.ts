export class UnassignCharacterCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly ownerId: string,
    public readonly characterId: string,
  ) {}
}

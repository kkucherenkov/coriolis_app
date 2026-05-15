export class CharacterLinkedEvent {
  constructor(
    public readonly membershipId: string,
    public readonly gameSessionId: string,
    public readonly userId: string,
    public readonly characterId: string | null,
  ) {}
}

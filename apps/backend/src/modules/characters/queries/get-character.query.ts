export class GetCharacterQuery {
  constructor(
    public readonly characterId: string,
    public readonly ownerId: string,
  ) {}
}

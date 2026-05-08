export class DuplicateCharacterCommand {
  constructor(
    public readonly characterId: string,
    public readonly ownerId: string,
  ) {}
}

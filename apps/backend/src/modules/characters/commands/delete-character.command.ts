export class DeleteCharacterCommand {
  constructor(
    public readonly characterId: string,
    public readonly ownerId: string,
  ) {}
}

export class ExportCharacterQuery {
  constructor(
    public readonly characterId: string,
    public readonly ownerId: string,
  ) {}
}

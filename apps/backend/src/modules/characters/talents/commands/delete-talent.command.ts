export class DeleteTalentCommand {
  constructor(
    public readonly talentId: string,
    public readonly ownerId: string,
  ) {}
}

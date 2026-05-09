export class DeleteGameSessionCommand {
  constructor(
    public readonly id: string,
    public readonly ownerId: string,
  ) {}
}

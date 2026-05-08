export class DeleteItemCommand {
  constructor(
    public readonly itemId: string,
    public readonly ownerId: string,
  ) {}
}

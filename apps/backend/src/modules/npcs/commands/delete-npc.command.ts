export class DeleteNpcCommand {
  constructor(
    public readonly id: string,
    public readonly ownerId: string,
  ) {}
}

export class DeleteEncounterCommand {
  constructor(
    public readonly id: string,
    public readonly callerId: string,
  ) {}
}

export class DeleteCombatantCommand {
  constructor(
    public readonly id: string,
    public readonly callerId: string,
  ) {}
}

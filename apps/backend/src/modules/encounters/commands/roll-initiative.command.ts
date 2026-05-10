export class RollInitiativeCommand {
  constructor(
    public readonly encounterId: string,
    public readonly callerId: string,
  ) {}
}

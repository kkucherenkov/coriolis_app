export class AdvanceRoundCommand {
  constructor(
    public readonly encounterId: string,
    public readonly callerId: string,
  ) {}
}

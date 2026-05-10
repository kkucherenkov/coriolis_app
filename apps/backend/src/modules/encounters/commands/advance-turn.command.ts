export class AdvanceTurnCommand {
  constructor(
    public readonly encounterId: string,
    public readonly callerId: string,
  ) {}
}

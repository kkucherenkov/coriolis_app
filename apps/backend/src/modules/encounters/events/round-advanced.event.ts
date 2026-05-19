export class RoundAdvancedEvent {
  constructor(
    public readonly encounterId: string,
    public readonly gameSessionId: string,
    public readonly round: number,
  ) {}
}

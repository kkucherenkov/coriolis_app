export class EncounterEndedEvent {
  constructor(
    public readonly encounterId: string,
    public readonly gameSessionId: string,
  ) {}
}

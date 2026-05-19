export class EncounterStartedEvent {
  constructor(
    public readonly encounterId: string,
    public readonly gameSessionId: string,
  ) {}
}

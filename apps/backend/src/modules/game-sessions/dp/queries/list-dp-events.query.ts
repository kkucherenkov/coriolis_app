export class ListDpEventsQuery {
  constructor(
    public readonly gameSessionId: string,
    public readonly callerId: string,
    public readonly limit: number,
    public readonly cursor?: string,
  ) {}
}

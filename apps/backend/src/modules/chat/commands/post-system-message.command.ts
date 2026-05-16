export class PostSystemMessageCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly systemKey: string,
    public readonly systemParams: Record<string, unknown> | null,
  ) {}
}

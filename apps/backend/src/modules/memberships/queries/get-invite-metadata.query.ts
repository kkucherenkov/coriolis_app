export class GetInviteMetadataQuery {
  constructor(
    public readonly gameSessionId: string,
    public readonly userId: string,
  ) {}
}

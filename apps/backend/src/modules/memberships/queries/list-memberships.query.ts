export class ListMembershipsQuery {
  constructor(
    public readonly gameSessionId: string,
    public readonly callerUserId: string,
  ) {}
}

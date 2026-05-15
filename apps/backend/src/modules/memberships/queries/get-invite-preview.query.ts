export class GetInvitePreviewQuery {
  constructor(
    public readonly token: string,
    /** null when caller is unauthenticated */
    public readonly callerUserId: string | null,
  ) {}
}

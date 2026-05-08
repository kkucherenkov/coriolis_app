export class RevokeShareLinkCommand {
  constructor(
    /** ID of the authenticated user (caller must own the share link's character). */
    public readonly callerId: string,
    public readonly shareLinkId: string,
  ) {}
}

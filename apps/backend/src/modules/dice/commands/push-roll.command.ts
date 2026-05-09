export class PushRollCommand {
  constructor(
    /** The authenticated caller's userId. */
    public readonly callerId: string,
    /** The roll to push. */
    public readonly rollId: string,
  ) {}
}

/**
 * Emitted by PushRollHandler after a roll has been pushed.
 *
 * Consumers:
 *  - RollPushedDpHandler (game-sessions/dp) — applies +1 DP to the linked session.
 *  - TODO(epic-7-4-realtime): Centrifugo publisher.
 */
export class RollPushedEvent {
  constructor(
    public readonly rollId: string,
    public readonly characterId: string,
    public readonly gameSessionId: string | null,
    public readonly hits: number,
  ) {}
}

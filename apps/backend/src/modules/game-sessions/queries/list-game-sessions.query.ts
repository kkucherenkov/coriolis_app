import type { GameSessionStatus } from '../domain/game-session.ports';

export class ListGameSessionsQuery {
  constructor(
    public readonly ownerId: string,
    public readonly limit: number,
    public readonly cursor?: string,
    public readonly status?: GameSessionStatus,
  ) {}
}

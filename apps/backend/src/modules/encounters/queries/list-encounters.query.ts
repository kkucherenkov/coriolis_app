import type { EncounterStatus } from '../domain/encounter.ports';

export class ListEncountersQuery {
  constructor(
    public readonly gameSessionId: string,
    public readonly callerId: string,
    public readonly limit: number,
    public readonly cursor?: string,
    public readonly status?: EncounterStatus,
  ) {}
}

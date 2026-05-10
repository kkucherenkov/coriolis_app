export class ListCombatantsQuery {
  constructor(
    public readonly encounterId: string,
    public readonly callerId: string,
  ) {}
}

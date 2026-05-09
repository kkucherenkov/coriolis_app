import type { TalentKind, TalentReadModel } from '../../domain/character.ports';

export const TALENT_REPO = Symbol('TALENT_REPO');

export interface ITalentRepo {
  findById(id: string): Promise<(TalentReadModel & { characterId: string }) | null>;

  listByCharacterId(characterId: string): Promise<TalentReadModel[]>;

  create(data: {
    characterId: string;
    kind: TalentKind;
    name: string;
    description: string;
    rank: number;
  }): Promise<TalentReadModel & { characterId: string }>;

  update(
    id: string,
    data: Partial<{ name: string; description: string; rank: number }>,
  ): Promise<TalentReadModel & { characterId: string }>;

  delete(id: string): Promise<void>;
}

import { IsIn, IsInt, IsNotEmpty, IsOptional, IsString, Max, Min } from 'class-validator';

import type { TalentKind } from '../../domain/character.ports';

const VALID_TALENT_KINDS: TalentKind[] = ['personal', 'crew', 'iconGift', 'stigma'];

export class AddTalentDto {
  @IsOptional()
  @IsIn(VALID_TALENT_KINDS)
  kind?: TalentKind;

  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsString()
  @IsNotEmpty()
  description!: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(3)
  rank?: number;
}

export class AddTalentCommand {
  constructor(
    public readonly characterId: string,
    public readonly ownerId: string,
    public readonly dto: AddTalentDto,
  ) {}
}

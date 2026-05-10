import { IsIn, IsInt, IsOptional, IsString, Max, MaxLength, Min, MinLength } from 'class-validator';

import type { RollKind } from '../domain/roll.ports';

export class CreateRollDto {
  @IsString()
  @MinLength(1)
  @MaxLength(80)
  label!: string;

  @IsInt()
  @Min(0)
  @Max(20)
  pool!: number;

  @IsOptional()
  @IsString()
  gameSessionId?: string | null;

  @IsOptional()
  @IsIn(['skill', 'save', 'trauma', 'initiative', 'darkness'])
  kind?: RollKind;
}

export class CreateRollCommand {
  constructor(
    /** The authenticated caller's userId. */
    public readonly callerId: string,
    /** The target character's id. */
    public readonly characterId: string,
    public readonly dto: CreateRollDto,
  ) {}
}

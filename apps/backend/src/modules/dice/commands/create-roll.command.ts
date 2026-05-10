import { Type } from 'class-transformer';
import {
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';

import type { RollKind } from '../domain/roll.ports';

export class RollBreakdownDto {
  @IsInt()
  @Min(0)
  @Max(10)
  attribute!: number;

  @IsInt()
  @Min(0)
  @Max(10)
  skill!: number;

  @IsInt()
  @Min(0)
  @Max(10)
  gear!: number;

  @IsInt()
  @Min(0)
  @Max(10)
  modifier!: number;

  @IsInt()
  @Min(0)
  @Max(10)
  helpers!: number;
}

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

  @IsOptional()
  @ValidateNested()
  @Type(() => RollBreakdownDto)
  breakdown?: RollBreakdownDto;
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

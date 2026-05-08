import {
  IsArray,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsObject,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

import type {
  Attributes,
  CharacterStatus,
  ConditionFlags,
  CriticalInjurySeverity,
  IconId,
  Skills,
} from '../domain/character.ports';
import { AttributesDto, ConditionFlagsDto, SkillsDto } from './create-character.command';

export class CriticalInjuryDto {
  @IsString() @IsNotEmpty() name!: string;
  @IsIn(['LIGHT', 'SEVERE', 'CRITICAL']) severity!: CriticalInjurySeverity;
  @IsString() @IsNotEmpty() effect!: string;
  @IsOptional() @IsString() acquiredAt?: string;
}

const VALID_ICONS: IconId[] = [
  'lady-of-tears',
  'traveler',
  'messenger',
  'merchant',
  'dancer',
  'gambler',
  'judge',
  'faceless-one',
  'deckhand',
];

export class UpdateHpDto {
  @IsOptional() @IsInt() @Min(0) current?: number;
}

export class UpdateMpDto {
  @IsOptional() @IsInt() @Min(0) current?: number;
}

export class UpdateCharacterDto {
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  name?: string;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  concept?: string | null;

  @IsOptional()
  @IsIn(VALID_ICONS)
  iconId?: IconId | null;

  @IsOptional()
  @IsObject()
  @ValidateNested()
  @Type(() => AttributesDto)
  attributes?: Attributes;

  @IsOptional()
  @IsObject()
  @ValidateNested()
  @Type(() => SkillsDto)
  skills?: Skills;

  @IsOptional()
  @IsObject()
  @ValidateNested()
  @Type(() => UpdateHpDto)
  hp?: { current?: number };

  @IsOptional()
  @IsObject()
  @ValidateNested()
  @Type(() => UpdateMpDto)
  mp?: { current?: number };

  @IsOptional()
  @IsInt()
  @Min(0)
  experience?: number;

  @IsOptional()
  @IsObject()
  @ValidateNested()
  @Type(() => ConditionFlagsDto)
  conditions?: ConditionFlags;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CriticalInjuryDto)
  criticalInjuries?: {
    name: string;
    severity: CriticalInjurySeverity;
    effect: string;
    acquiredAt?: string;
  }[];

  @IsOptional()
  @IsString()
  @MaxLength(4096)
  notes?: string | null;

  @IsOptional()
  @IsIn(['draft', 'active'])
  status?: CharacterStatus;
}

export class UpdateCharacterCommand {
  constructor(
    public readonly characterId: string,
    public readonly ownerId: string,
    public readonly dto: UpdateCharacterDto,
  ) {}
}

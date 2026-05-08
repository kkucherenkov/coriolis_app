import {
  IsArray,
  IsBoolean,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsObject,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

import type { Attributes, ConditionFlags, IconId, Skills } from '../domain/character.ports';

export class AttributesDto {
  @IsInt() @Min(1) @Max(5) strength!: number;
  @IsInt() @Min(1) @Max(5) agility!: number;
  @IsInt() @Min(1) @Max(5) wits!: number;
  @IsInt() @Min(1) @Max(5) empathy!: number;
}

export class SkillsDto {
  @IsInt() @Min(0) @Max(5) dexterity!: number;
  @IsInt() @Min(0) @Max(5) force!: number;
  @IsInt() @Min(0) @Max(5) infiltration!: number;
  @IsInt() @Min(0) @Max(5) manipulation!: number;
  @IsInt() @Min(0) @Max(5) meleeCombat!: number;
  @IsInt() @Min(0) @Max(5) observation!: number;
  @IsInt() @Min(0) @Max(5) rangedCombat!: number;
  @IsInt() @Min(0) @Max(5) survival!: number;
  @IsInt() @Min(0) @Max(5) command!: number;
  @IsInt() @Min(0) @Max(5) culture!: number;
  @IsInt() @Min(0) @Max(5) dataDjinn!: number;
  @IsInt() @Min(0) @Max(5) medicurgy!: number;
  @IsInt() @Min(0) @Max(5) mysticPowers!: number;
  @IsInt() @Min(0) @Max(5) pilot!: number;
  @IsInt() @Min(0) @Max(5) science!: number;
  @IsInt() @Min(0) @Max(5) technology!: number;
}

export class ConditionFlagsDto {
  @IsBoolean() exhausted!: boolean;
  @IsBoolean() sleepless!: boolean;
  @IsBoolean() thirsty!: boolean;
  @IsBoolean() hungry!: boolean;
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

export class HpDto {
  @IsOptional() @IsInt() @Min(0) current?: number;
}

export class MpDto {
  @IsOptional() @IsInt() @Min(0) current?: number;
}

export class CreateCharacterDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  name!: string;

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
  @Type(() => HpDto)
  hp?: { current?: number };

  @IsOptional()
  @IsObject()
  @ValidateNested()
  @Type(() => MpDto)
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
  @IsString()
  @MaxLength(4096)
  notes?: string | null;
}

export class CreateCharacterCommand {
  constructor(
    public readonly ownerId: string,
    public readonly dto: CreateCharacterDto,
  ) {}
}

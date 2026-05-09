import {
  IsArray,
  IsBoolean,
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
  Concept,
  CrewConcept,
  CriticalInjurySeverity,
  IconId,
  MutantLineage,
  Skills,
  Upbringing,
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

const VALID_UPBRINGINGS: Upbringing[] = ['plebeian', 'stationary', 'aristocrat'];

const VALID_CONCEPTS: Concept[] = [
  'artist',
  'networker',
  'fugitive',
  'negotiator',
  'operative',
  'pilot',
  'pioneer',
  'preacher',
  'scientist',
  'sailor',
  'soldier',
];

const VALID_CREW_CONCEPTS: CrewConcept[] = [
  'free-trader',
  'mercenary',
  'explorer',
  'agents',
  'pilgrim',
];

const VALID_MUTANT_LINEAGES: MutantLineage[] = ['zirba', 'shingura', 'nerida'];

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
  @IsIn(VALID_CONCEPTS)
  concept?: Concept | null;

  @IsOptional()
  @IsIn(VALID_ICONS)
  iconId?: IconId | null;

  @IsOptional()
  @IsIn(VALID_UPBRINGINGS)
  upbringing?: Upbringing;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  origin?: string | null;

  @IsOptional()
  @IsIn(VALID_CREW_CONCEPTS)
  crewConcept?: CrewConcept | null;

  @IsOptional()
  @IsBoolean()
  mutant?: boolean;

  @IsOptional()
  @IsIn(VALID_MUTANT_LINEAGES)
  mutantLineage?: MutantLineage | null;

  @IsOptional()
  @IsInt()
  @Min(0)
  reputation?: number;

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

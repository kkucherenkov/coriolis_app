import {
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

import type {
  Attributes,
  CharacterStatus,
  ConditionFlags,
  Concept,
  CrewConcept,
  IconId,
  MutantLineage,
  Skills,
  Upbringing,
} from '../domain/character.ports';

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
  @IsIn(VALID_CONCEPTS)
  concept?: Concept | null;

  /**
   * Canonical role within the chosen amplua (ГЛАВА 2 «АМПЛУА И РОЛИ»).
   * Optional at creation — the wizard sets it before flipping to active.
   * Validated against the concept at the handler layer.
   */
  @IsOptional()
  @IsString()
  role?: string | null;

  @IsOptional()
  @IsIn(VALID_ICONS)
  iconId?: IconId | null;

  @IsIn(VALID_UPBRINGINGS)
  upbringing!: Upbringing;

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

  @IsOptional()
  @IsIn(['draft', 'active'])
  status?: CharacterStatus;
}

export class CreateCharacterCommand {
  constructor(
    public readonly ownerId: string,
    public readonly dto: CreateCharacterDto,
  ) {}
}

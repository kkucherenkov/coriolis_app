import {
  IsArray,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

class NpcHpDto {
  @IsOptional()
  @IsInt()
  current?: number;

  @IsOptional()
  @IsInt()
  max?: number;
}

class NpcMpDto {
  @IsOptional()
  @IsInt()
  current?: number;

  @IsOptional()
  @IsInt()
  max?: number;
}

export class CreateNpcDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  name!: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  description?: string | null;

  @IsOptional()
  attributes?: Record<string, number>;

  @IsOptional()
  skills?: Record<string, number>;

  @IsOptional()
  @ValidateNested()
  @Type(() => NpcHpDto)
  hp?: NpcHpDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => NpcMpDto)
  mp?: NpcMpDto;

  @IsOptional()
  @IsInt()
  signature?: number;

  @IsOptional()
  @IsInt()
  keySkillModifier?: number;

  @IsOptional()
  @IsArray()
  armor?: unknown[];

  @IsOptional()
  @IsArray()
  weapons?: unknown[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];
}

export class CreateNpcCommand {
  constructor(
    public readonly ownerId: string,
    public readonly dto: CreateNpcDto,
  ) {}
}

import { IsArray, IsInt, IsOptional, IsString, MaxLength, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

class NpcHpUpdateDto {
  @IsOptional()
  @IsInt()
  current?: number;

  @IsOptional()
  @IsInt()
  max?: number;
}

class NpcMpUpdateDto {
  @IsOptional()
  @IsInt()
  current?: number;

  @IsOptional()
  @IsInt()
  max?: number;
}

export class UpdateNpcDto {
  @IsOptional()
  @IsString()
  @MaxLength(120)
  name?: string;

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
  @Type(() => NpcHpUpdateDto)
  hp?: NpcHpUpdateDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => NpcMpUpdateDto)
  mp?: NpcMpUpdateDto;

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

export class UpdateNpcCommand {
  constructor(
    public readonly id: string,
    public readonly ownerId: string,
    public readonly dto: UpdateNpcDto,
  ) {}
}

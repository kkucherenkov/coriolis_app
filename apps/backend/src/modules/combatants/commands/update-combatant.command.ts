import { IsArray, IsInt, IsOptional, IsString, MaxLength, Min, MinLength } from 'class-validator';

export class UpdateCombatantDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(80)
  displayName?: string;

  @IsOptional()
  @IsInt()
  hpCurrent?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  armor?: number;

  @IsOptional()
  @IsInt()
  signature?: number;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  statusFlags?: string[];

  @IsOptional()
  @IsString()
  @MaxLength(500)
  notes?: string | null;
}

export class UpdateCombatantCommand {
  constructor(
    public readonly id: string,
    public readonly callerId: string,
    public readonly dto: UpdateCombatantDto,
  ) {}
}

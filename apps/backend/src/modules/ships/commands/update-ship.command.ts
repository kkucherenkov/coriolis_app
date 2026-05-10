import {
  IsArray,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

class HullUpdateDto {
  @IsOptional()
  @IsInt()
  @Min(0)
  current?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  max?: number;
}

class EnergyUpdateDto {
  @IsOptional()
  @IsInt()
  @Min(0)
  current?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  max?: number;
}

export class UpdateShipDto {
  @IsOptional()
  @IsString()
  @MaxLength(80)
  name?: string;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  model?: string | null;

  @IsOptional()
  @IsString()
  @MaxLength(40)
  registry?: string | null;

  @IsOptional()
  @ValidateNested()
  @Type(() => HullUpdateDto)
  hull?: HullUpdateDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => EnergyUpdateDto)
  energy?: EnergyUpdateDto;

  @IsOptional()
  @IsInt()
  @Min(0)
  armor?: number;

  @IsOptional()
  @IsInt()
  maneuverability?: number;

  @IsOptional()
  @IsInt()
  signature?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  speed?: number;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  problems?: string[];

  @IsOptional()
  @IsString()
  @MaxLength(4096)
  history?: string | null;

  @IsOptional()
  @IsString()
  @MaxLength(4096)
  notes?: string | null;
}

export class UpdateShipCommand {
  constructor(
    public readonly id: string,
    public readonly ownerId: string,
    public readonly dto: UpdateShipDto,
  ) {}
}

import {
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

import type { ShipClass } from '../domain/ship.ports';

class HullDto {
  @IsOptional()
  @IsInt()
  @Min(0)
  current?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  max?: number;
}

class EnergyDto {
  @IsOptional()
  @IsInt()
  @Min(0)
  current?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  max?: number;
}

const SHIP_CLASS_VALUES: ShipClass[] = [
  'fighter',
  'shuttle',
  'torpedo-boat',
  'light-freighter',
  'light-passenger',
  'courier-yacht',
  'clipper',
  'patrol-boat',
  'gunboat',
  'assault-ship',
  'blockade-runner',
  'pleasure-yacht',
  'flying-circus',
  'prospector',
  'rescue-ship',
  'passenger-liner',
  'heavy-freighter',
  'cruiser',
  'destroyer',
  'heavy-cruiser',
];

export class CreateShipDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  name!: string;

  @IsEnum(SHIP_CLASS_VALUES)
  class!: ShipClass;

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
  @Type(() => HullDto)
  hull?: HullDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => EnergyDto)
  energy?: EnergyDto;

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
  @IsString()
  @MaxLength(4096)
  notes?: string | null;

  @IsOptional()
  @IsString()
  @MaxLength(4096)
  history?: string | null;
}

export class CreateShipCommand {
  constructor(
    public readonly ownerId: string,
    public readonly dto: CreateShipDto,
  ) {}
}

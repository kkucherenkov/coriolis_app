import {
  IsArray,
  IsBoolean,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
  ValidateIf,
} from 'class-validator';

import { VALID_SHIP_MODULE_SLOTS } from '../../../ships/domain/ship-module-validation';

import type { ItemType } from '../../domain/character.ports';

const VALID_RANGES = ['close', 'medium', 'long', 'extreme'];
const VALID_TYPES: ItemType[] = ['WEAPON', 'ARMOR', 'GEAR', 'CYBERNETIC', 'SHIP_MODULE', 'OTHER'];

export class AddItemDto {
  @IsIn(VALID_TYPES)
  type!: ItemType;

  @IsString()
  @IsNotEmpty()
  name!: string;

  // WEAPON
  @ValidateIf((o: AddItemDto) => o.type === 'WEAPON')
  @IsInt()
  @Min(1)
  damage?: number;

  @ValidateIf((o: AddItemDto) => o.type === 'WEAPON')
  @IsIn(VALID_RANGES)
  range?: string;

  @ValidateIf((o: AddItemDto) => o.type === 'WEAPON')
  @IsInt()
  @Min(0)
  bonus?: number;

  @ValidateIf((o: AddItemDto) => o.type === 'WEAPON')
  @IsInt()
  @Min(1)
  crit?: number;

  // WEAPON / ARMOR / GEAR / OTHER
  @ValidateIf((o: AddItemDto) => ['WEAPON', 'ARMOR', 'GEAR', 'OTHER'].includes(o.type))
  @IsNumber()
  @Min(0)
  weight?: number;

  // WEAPON / ARMOR
  @ValidateIf((o: AddItemDto) => ['WEAPON', 'ARMOR'].includes(o.type))
  @IsArray()
  @IsString({ each: true })
  features?: string[];

  @ValidateIf((o: AddItemDto) => ['WEAPON', 'ARMOR'].includes(o.type))
  @IsBoolean()
  equipped?: boolean;

  // ARMOR
  @ValidateIf((o: AddItemDto) => o.type === 'ARMOR')
  @IsInt()
  @Min(0)
  armorRating?: number;

  // GEAR
  @ValidateIf((o: AddItemDto) => o.type === 'GEAR')
  @IsInt()
  @Min(1)
  quantity?: number;

  // GEAR / OTHER
  @ValidateIf((o: AddItemDto) => ['GEAR', 'OTHER'].includes(o.type))
  @IsOptional()
  @IsString()
  notes?: string | null;

  // CYBERNETIC
  @ValidateIf((o: AddItemDto) => o.type === 'CYBERNETIC')
  @IsInt()
  @Min(0)
  @Max(15)
  xpCost?: number;

  // CYBERNETIC / SHIP_MODULE
  @ValidateIf((o: AddItemDto) => ['CYBERNETIC', 'SHIP_MODULE'].includes(o.type))
  @IsString()
  @IsNotEmpty()
  effect?: string;

  // SHIP_MODULE
  @ValidateIf((o: AddItemDto) => o.type === 'SHIP_MODULE')
  @IsIn(VALID_SHIP_MODULE_SLOTS)
  slot?: string;
}

export class AddItemCommand {
  constructor(
    public readonly characterId: string,
    public readonly ownerId: string,
    public readonly dto: AddItemDto,
  ) {}
}

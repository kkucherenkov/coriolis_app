import {
  IsArray,
  IsBoolean,
  IsIn,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

import { VALID_SHIP_MODULE_SLOTS } from '../../../ships/domain/ship-module-validation';

export class UpdateItemDto {
  @IsOptional() @IsString() name?: string;
  @IsOptional() @IsInt() @Min(1) damage?: number;
  @IsOptional() @IsIn(['close', 'medium', 'long', 'extreme']) range?: string;
  @IsOptional() @IsInt() @Min(0) bonus?: number;
  @IsOptional() @IsInt() @Min(1) crit?: number;
  @IsOptional() @IsInt() @Min(0) armorRating?: number;
  @IsOptional() @IsNumber() @Min(0) weight?: number;
  @IsOptional() @IsArray() @IsString({ each: true }) features?: string[];
  @IsOptional() @IsBoolean() equipped?: boolean;
  @IsOptional() @IsInt() @Min(1) quantity?: number;
  @IsOptional() @IsString() notes?: string | null;
  @IsOptional() @IsInt() @Min(0) @Max(15) xpCost?: number;
  @IsOptional() @IsString() effect?: string;
  @IsOptional()
  @IsIn(VALID_SHIP_MODULE_SLOTS)
  slot?: string;
}

export class UpdateItemCommand {
  constructor(
    public readonly itemId: string,
    public readonly ownerId: string,
    public readonly dto: UpdateItemDto,
  ) {}
}

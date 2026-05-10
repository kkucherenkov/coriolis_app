/**
 * WHY this file exists:
 * Command + DTO for updating a ship module (PATCH /api/v1/ship-modules/{id}).
 * All fields are optional (PATCH semantics). Slot immutability enforced in the handler.
 */
import { IsInt, IsOptional, IsString, Min, MinLength } from 'class-validator';

export class UpdateShipModuleDto {
  /** Discriminator — must match installed slot if present */
  @IsOptional()
  @IsString()
  slot?: string;

  @IsOptional()
  @IsString()
  @MinLength(1)
  name?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  energyUse?: number;

  @IsOptional()
  @IsString()
  notes?: string | null;

  // Weapon fields
  @IsOptional()
  @IsInt()
  @Min(0)
  weaponBonus?: number;

  @IsOptional()
  @IsString()
  weaponRange?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  weaponDamage?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  weaponCritThreshold?: number;

  // Torpedo fields
  @IsOptional()
  @IsInt()
  @Min(0)
  torpedoCount?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  mineCount?: number;

  // Hold fields
  @IsOptional()
  @IsInt()
  @Min(0)
  cargoTons?: number;

  @IsOptional()
  concealed?: boolean;

  // Sensor fields
  @IsOptional()
  @IsInt()
  @Min(0)
  detectionBonus?: number;
}

export class UpdateShipModuleCommand {
  constructor(
    public readonly moduleId: string,
    public readonly ownerId: string,
    public readonly dto: UpdateShipModuleDto,
  ) {}
}

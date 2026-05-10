/**
 * WHY this file exists:
 * Command + DTO for adding a new module to a ship (POST /api/v1/ships/{id}/modules).
 * The DTO carries the raw body — discriminator validation is handled in the handler
 * via validateModuleCreate() so the logic stays unit-testable without HTTP context.
 */
import { IsInt, IsNotEmpty, IsOptional, IsString, Min } from 'class-validator';

export class AddShipModuleDto {
  /** Discriminator — presence/validity checked by validateModuleCreate */
  @IsString()
  @IsNotEmpty()
  slot!: string;

  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsInt()
  @Min(0)
  energyUse!: number;

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

export class AddShipModuleCommand {
  constructor(
    public readonly shipId: string,
    public readonly ownerId: string,
    public readonly dto: AddShipModuleDto,
  ) {}
}

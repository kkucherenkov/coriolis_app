import { IsIn, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class AddCombatantDto {
  @IsIn(['pc', 'npc'])
  combatantType!: 'pc' | 'npc';

  @IsString()
  sourceId!: string;

  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(80)
  displayName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  notes?: string | null;
}

export class AddCombatantCommand {
  constructor(
    public readonly encounterId: string,
    public readonly callerId: string,
    public readonly dto: AddCombatantDto,
  ) {}
}

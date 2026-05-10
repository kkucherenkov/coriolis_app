import { IsArray, IsString, ArrayMinSize } from 'class-validator';

export class ReorderInitiativeDto {
  @IsArray()
  @ArrayMinSize(1)
  @IsString({ each: true })
  combatantIds!: string[];
}

export class ReorderInitiativeCommand {
  constructor(
    public readonly encounterId: string,
    public readonly callerId: string,
    public readonly dto: ReorderInitiativeDto,
  ) {}
}

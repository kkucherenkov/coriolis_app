import { IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateEncounterDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  name!: string;

  @IsOptional()
  @IsString()
  @MaxLength(4096)
  notes?: string | null;
}

export class CreateEncounterCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly callerId: string,
    public readonly dto: CreateEncounterDto,
  ) {}
}

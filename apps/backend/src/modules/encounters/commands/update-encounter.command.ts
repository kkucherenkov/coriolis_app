import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateEncounterDto {
  @IsOptional()
  @IsString()
  @MaxLength(80)
  name?: string;

  @IsOptional()
  @IsEnum(['setup', 'active', 'ended'])
  status?: 'setup' | 'active' | 'ended';

  @IsOptional()
  @IsString()
  @MaxLength(4096)
  notes?: string | null;
}

export class UpdateEncounterCommand {
  constructor(
    public readonly id: string,
    public readonly callerId: string,
    public readonly dto: UpdateEncounterDto,
  ) {}
}

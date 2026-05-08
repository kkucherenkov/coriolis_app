import { IsInt, IsNotEmpty, IsOptional, IsString, Max, Min } from 'class-validator';

export class UpdateTalentDto {
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  name?: string;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  description?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(3)
  rank?: number;
}

export class UpdateTalentCommand {
  constructor(
    public readonly talentId: string,
    public readonly ownerId: string,
    public readonly dto: UpdateTalentDto,
  ) {}
}

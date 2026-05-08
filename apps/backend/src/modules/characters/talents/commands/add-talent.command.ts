import { IsInt, IsNotEmpty, IsOptional, IsString, Max, Min } from 'class-validator';

export class AddTalentDto {
  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsString()
  @IsNotEmpty()
  description!: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(3)
  rank?: number;
}

export class AddTalentCommand {
  constructor(
    public readonly characterId: string,
    public readonly ownerId: string,
    public readonly dto: AddTalentDto,
  ) {}
}

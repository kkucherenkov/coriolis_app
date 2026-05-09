import { IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateGameSessionDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  name!: string;

  @IsOptional()
  @IsString()
  @MaxLength(600)
  description?: string | null;

  @IsOptional()
  @IsString()
  shipId?: string | null;
}

export class CreateGameSessionCommand {
  constructor(
    public readonly ownerId: string,
    public readonly dto: CreateGameSessionDto,
  ) {}
}

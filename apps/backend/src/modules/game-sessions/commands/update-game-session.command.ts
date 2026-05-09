import { IsIn, IsOptional, IsString, MaxLength } from 'class-validator';

import type { GameSessionStatus } from '../domain/game-session.ports';

export class UpdateGameSessionDto {
  @IsOptional()
  @IsString()
  @MaxLength(80)
  name?: string;

  @IsOptional()
  @IsString()
  @MaxLength(600)
  description?: string | null;

  @IsOptional()
  @IsIn(['active', 'archived'])
  status?: GameSessionStatus;

  @IsOptional()
  @IsString()
  shipId?: string | null;
}

export class UpdateGameSessionCommand {
  constructor(
    public readonly id: string,
    public readonly ownerId: string,
    public readonly dto: UpdateGameSessionDto,
  ) {}
}

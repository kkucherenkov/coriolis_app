import { IsBoolean, IsISO8601, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class CreateShareLinkDto {
  @IsOptional()
  @IsBoolean()
  includeGmNotes?: boolean;

  @IsOptional()
  @IsISO8601()
  expiresAt?: string | null;

  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(80)
  label?: string | null;
}

export class CreateShareLinkCommand {
  constructor(
    /** ID of the authenticated user (caller must own the character). */
    public readonly callerId: string,
    public readonly characterId: string,
    public readonly dto: CreateShareLinkDto,
  ) {}
}

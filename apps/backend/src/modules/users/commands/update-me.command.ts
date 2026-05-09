/**
 * A Command is a plain data object. Validation (class-validator) runs on the
 * DTO in the controller before dispatch; the handler trusts the values here.
 */
import { IsEnum, IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';

import type { UserTheme } from '../domain/user.ports';

export class UpdateMeCommand {
  constructor(
    public readonly userId: string,
    public readonly displayName: string | null | undefined,
    public readonly theme: UserTheme | undefined,
  ) {}
}

/**
 * DTO for `PATCH /api/v1/me`. The global ValidationPipe with
 * `whitelist: true` + `forbidNonWhitelisted: true` strips and rejects any
 * property not listed here (e.g. `email`, `createdAt`).
 *
 * class-validator note on null:
 *  - `@IsOptional()` allows the property to be absent from the body entirely.
 *  - When `displayName` is present but `null`, class-validator skips all
 *    decorators because the value is null (treated as absent). That is the
 *    correct behaviour — null means "clear the field" and is allowed by spec.
 *  - When `displayName` is an empty string, `@IsNotEmpty()` fires → 400.
 *  - When `displayName` exceeds 80 chars, `@MaxLength(80)` fires → 400.
 */
export class UpdateMeDto {
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  displayName?: string | null;

  @IsOptional()
  @IsEnum(['dark', 'high-contrast'])
  theme?: UserTheme;
}

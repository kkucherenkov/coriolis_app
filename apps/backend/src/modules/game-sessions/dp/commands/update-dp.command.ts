import { IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

import type { DpSource } from '../domain/dp.ports';

export class UpdateDpDto {
  @IsInt()
  @Min(-99)
  @Max(99)
  delta!: number;

  @IsOptional()
  @IsString()
  reason?: string | null;
}

/**
 * Command issued from three sources:
 *  1. HTTP controller (GM manual adjustment) — callerId is the GM's userId,
 *     source is 'GM_MANUAL'.
 *  2. RollPushedEventHandler — callerId is 'system', source is 'ROLL_PUSH'.
 *     In this case the GM-owner ACL check is bypassed.
 *  3. Future automation — callerId is 'system', source is 'SYSTEM'.
 *
 * The `internal` flag signals that the caller is not an end-user and therefore
 * the GM-owner ACL does not apply. Only the two system sources set this flag.
 */
export class UpdateDpCommand {
  constructor(
    public readonly gameSessionId: string,
    /** User ID of the calling user, or 'system' for internal callers. */
    public readonly callerId: string,
    public readonly delta: number,
    public readonly source: DpSource,
    public readonly reason: string | null,
    /** When true the GM-owner check is skipped (internal pipeline calls only). */
    public readonly internal = false,
    public readonly rollId: string | null = null,
  ) {}
}

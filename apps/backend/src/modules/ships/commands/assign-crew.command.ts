/**
 * WHY this file exists:
 * Command + DTO for assigning a character to a crew position on a ship
 * (POST /api/v1/ships/{id}/crew). Ownership guards for both ship and
 * character live in the handler.
 */
import { IsEnum, IsNotEmpty, IsString } from 'class-validator';

import type { CrewPosition } from '../domain/ship.ports';

const CREW_POSITIONS: CrewPosition[] = [
  'captain',
  'pilot',
  'sensorOp',
  'gunner',
  'engineer',
  'serviceCrew',
];

export class AssignCrewDto {
  @IsEnum(CREW_POSITIONS)
  position!: CrewPosition;

  @IsString()
  @IsNotEmpty()
  characterId!: string;
}

export class AssignCrewCommand {
  constructor(
    public readonly shipId: string,
    public readonly ownerId: string,
    public readonly dto: AssignCrewDto,
  ) {}
}

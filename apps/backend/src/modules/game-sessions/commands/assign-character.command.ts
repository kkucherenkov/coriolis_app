import { IsNotEmpty, IsString } from 'class-validator';

export class AssignCharacterDto {
  @IsString()
  @IsNotEmpty()
  characterId!: string;
}

export class AssignCharacterCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly ownerId: string,
    public readonly characterId: string,
  ) {}
}

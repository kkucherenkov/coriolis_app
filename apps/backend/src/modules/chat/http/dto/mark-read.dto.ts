import { IsISO8601 } from 'class-validator';

export class MarkReadDto {
  @IsISO8601()
  lastReadAt!: string;
}

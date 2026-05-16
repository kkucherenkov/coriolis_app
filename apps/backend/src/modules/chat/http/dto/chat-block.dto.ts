import { IsString } from 'class-validator';

export class ChatBlockDto {
  @IsString()
  targetMembershipId!: string;
}

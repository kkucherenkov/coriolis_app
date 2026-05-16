import { IsIn, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class PostChatMessageDto {
  @IsString()
  @IsIn(['text'])
  kind!: 'text';

  @IsString()
  @MinLength(1)
  @MaxLength(4096)
  body!: string;

  @IsOptional()
  @IsString()
  targetMembershipId?: string;
}

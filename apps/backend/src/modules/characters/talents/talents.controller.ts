import {
  Body,
  Controller,
  Delete,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Req,
  UseGuards,
} from '@nestjs/common';
import { CommandBus } from '@nestjs/cqrs';

import { SessionGuard } from '../../../common/auth/auth.guard';

import { DeleteTalentCommand } from './commands/delete-talent.command';
import { UpdateTalentCommand, UpdateTalentDto } from './commands/update-talent.command';

import type { AuthenticatedRequest } from '../../../common/auth/auth.guard';
import type { TalentReadModel } from '../domain/character.ports';

@UseGuards(SessionGuard)
@Controller({ path: 'talents', version: '1' })
export class TalentsController {
  constructor(private readonly commandBus: CommandBus) {}

  /** PATCH /api/v1/talents/:id */
  @Patch(':id')
  @HttpCode(HttpStatus.OK)
  async update(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() body: UpdateTalentDto,
  ): Promise<TalentReadModel> {
    return this.commandBus.execute(new UpdateTalentCommand(id, req.userId, body));
  }

  /** DELETE /api/v1/talents/:id */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Req() req: AuthenticatedRequest, @Param('id') id: string): Promise<void> {
    return this.commandBus.execute(new DeleteTalentCommand(id, req.userId));
  }
}

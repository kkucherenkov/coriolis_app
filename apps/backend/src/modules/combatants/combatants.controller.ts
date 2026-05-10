/**
 * WHY this file exists:
 * Handles the two flat combatant endpoints:
 *   PATCH  /api/v1/combatants/{id}  → updateCombatant
 *   DELETE /api/v1/combatants/{id}  → deleteCombatant
 *
 * The userId comes from the authenticated session.
 * No Prisma, no business logic — dispatch only.
 */
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

import { SessionGuard } from '../../common/auth/auth.guard';

import { UpdateCombatantCommand, UpdateCombatantDto } from './commands/update-combatant.command';
import { DeleteCombatantCommand } from './commands/delete-combatant.command';

import type { AuthenticatedRequest } from '../../common/auth/auth.guard';
import type { CombatantReadModel } from './domain/combatant.ports';

@UseGuards(SessionGuard)
@Controller({ path: 'combatants', version: '1' })
export class CombatantsController {
  constructor(private readonly commandBus: CommandBus) {}

  /** PATCH /api/v1/combatants/:id */
  @Patch(':id')
  @HttpCode(HttpStatus.OK)
  async update(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() body: UpdateCombatantDto,
  ): Promise<CombatantReadModel> {
    return this.commandBus.execute(new UpdateCombatantCommand(id, req.userId, body));
  }

  /** DELETE /api/v1/combatants/:id */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Req() req: AuthenticatedRequest, @Param('id') id: string): Promise<void> {
    return this.commandBus.execute(new DeleteCombatantCommand(id, req.userId));
  }
}

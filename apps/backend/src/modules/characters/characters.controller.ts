/**
 * WHY this file exists:
 * Thin HTTP entry point for the characters bounded context. Jobs:
 *  1. Authenticate via SessionGuard + optionally CharacterOwnershipGuard.
 *  2. Receive validated DTO (ValidationPipe + class-validator).
 *  3. Dispatch the appropriate Query or Command via the bus.
 *  4. Return the result — no mapping, no Prisma, no business logic.
 *
 * The user id is sourced exclusively from the authenticated session via
 * req.userId. It is never taken from the request body or path params.
 */
import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { CommandBus, QueryBus } from '@nestjs/cqrs';

import { SessionGuard } from '../../common/auth/auth.guard';

import { CharacterOwnershipGuard } from './character-ownership.guard';
import { CreateCharacterCommand, CreateCharacterDto } from './commands/create-character.command';
import { DeleteCharacterCommand } from './commands/delete-character.command';
import { DuplicateCharacterCommand } from './commands/duplicate-character.command';
import { UpdateCharacterCommand, UpdateCharacterDto } from './commands/update-character.command';
import { AddItemCommand, AddItemDto } from './items/commands/add-item.command';
import { ExportCharacterQuery } from './queries/export-character.query';
import { GetCharacterQuery } from './queries/get-character.query';
import { ListCharactersQuery } from './queries/list-characters.query';
import { AddTalentCommand, AddTalentDto } from './talents/commands/add-talent.command';

import type { AuthenticatedRequest } from '../../common/auth/auth.guard';
import type {
  CharacterReadModel,
  ItemReadModel,
  TalentReadModel,
} from './domain/character.ports';

interface CharacterListResponse {
  items: CharacterReadModel[];
  nextCursor: string | null;
}

@UseGuards(SessionGuard)
@Controller({ path: 'characters', version: '1' })
export class CharactersController {
  constructor(
    private readonly queryBus: QueryBus,
    private readonly commandBus: CommandBus,
  ) {}

  /** GET /api/v1/characters */
  @Get()
  async list(
    @Req() req: AuthenticatedRequest,
    @Query('limit') limitRaw?: string,
    @Query('cursor') cursor?: string,
    @Query('includeDrafts') includeDraftsRaw?: string,
  ): Promise<CharacterListResponse> {
    const limit = Math.min(Math.max(Number.parseInt(limitRaw ?? '20', 10) || 20, 1), 100);
    const includeDrafts = includeDraftsRaw === 'true' || includeDraftsRaw === '1';
    return this.queryBus.execute(new ListCharactersQuery(req.userId, limit, cursor, includeDrafts));
  }

  /** POST /api/v1/characters */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Req() req: AuthenticatedRequest,
    @Body() body: CreateCharacterDto,
  ): Promise<CharacterReadModel> {
    return this.commandBus.execute(new CreateCharacterCommand(req.userId, body));
  }

  /** GET /api/v1/characters/:id */
  @Get(':id')
  @UseGuards(CharacterOwnershipGuard)
  async getOne(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
  ): Promise<CharacterReadModel> {
    return this.queryBus.execute(new GetCharacterQuery(id, req.userId));
  }

  /** PATCH /api/v1/characters/:id */
  @Patch(':id')
  @UseGuards(CharacterOwnershipGuard)
  @HttpCode(HttpStatus.OK)
  async update(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() body: UpdateCharacterDto,
  ): Promise<CharacterReadModel> {
    return this.commandBus.execute(new UpdateCharacterCommand(id, req.userId, body));
  }

  /** DELETE /api/v1/characters/:id */
  @Delete(':id')
  @UseGuards(CharacterOwnershipGuard)
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Req() req: AuthenticatedRequest, @Param('id') id: string): Promise<void> {
    return this.commandBus.execute(new DeleteCharacterCommand(id, req.userId));
  }

  /** POST /api/v1/characters/:id/duplicate */
  @Post(':id/duplicate')
  @UseGuards(CharacterOwnershipGuard)
  @HttpCode(HttpStatus.CREATED)
  async duplicate(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
  ): Promise<CharacterReadModel> {
    return this.commandBus.execute(new DuplicateCharacterCommand(id, req.userId));
  }

  /** GET /api/v1/characters/:id/export */
  @Get(':id/export')
  @UseGuards(CharacterOwnershipGuard)
  async export(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
  ): Promise<CharacterReadModel> {
    return this.queryBus.execute(new ExportCharacterQuery(id, req.userId));
  }

  /** POST /api/v1/characters/:id/items */
  @Post(':id/items')
  @UseGuards(CharacterOwnershipGuard)
  @HttpCode(HttpStatus.CREATED)
  async addItem(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() body: AddItemDto,
  ): Promise<ItemReadModel> {
    return this.commandBus.execute(new AddItemCommand(id, req.userId, body));
  }

  /** POST /api/v1/characters/:id/talents */
  @Post(':id/talents')
  @UseGuards(CharacterOwnershipGuard)
  @HttpCode(HttpStatus.CREATED)
  async addTalent(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() body: AddTalentDto,
  ): Promise<TalentReadModel> {
    return this.commandBus.execute(new AddTalentCommand(id, req.userId, body));
  }
}

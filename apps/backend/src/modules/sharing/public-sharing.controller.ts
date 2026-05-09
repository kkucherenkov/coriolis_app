/**
 * WHY this file exists:
 * Public (unauthenticated) HTTP entry point for anonymous character reads and
 * the OG image renderer. No SessionGuard — these routes are accessible without auth.
 *
 * The controller declares path: 'public' so routes resolve to:
 *   GET /api/v1/public/character/:slug
 *   GET /api/v1/public/og/character/:slug.png
 */
import { Controller, Get, Param, Res } from '@nestjs/common';
import { QueryBus } from '@nestjs/cqrs';
import type { Response } from 'express';

import { GetPublicCharacterQuery } from './queries/get-public-character.query';
import { OgService } from './og/og.service';

import type { CharacterReadModel } from '../characters/domain/character.ports';

@Controller({ path: 'public', version: '1' })
export class PublicSharingController {
  constructor(
    private readonly queryBus: QueryBus,
    private readonly ogService: OgService,
  ) {}

  /** GET /api/v1/public/character/:slug */
  @Get('character/:slug')
  async getPublicCharacter(@Param('slug') slug: string): Promise<CharacterReadModel> {
    return this.queryBus.execute(new GetPublicCharacterQuery(slug));
  }

  /**
   * GET /api/v1/public/og/character/:slug.png
   *
   * Returns a 1200×630 PNG OG card for the shared character.
   * On render failure, returns a generic fallback PNG (still 200) so crawlers
   * always receive a valid image.
   *
   * Cache-Control: public, max-age=3600 (1 h), stale-while-revalidate=86400 (24 h)
   * The renderer is stateless — no server-side cache layer.
   */
  @Get('og/character/:slug.png')
  async getCharacterOgImage(@Param('slug') slug: string, @Res() res: Response): Promise<void> {
    // GetPublicCharacterQuery already throws DomainError on revoked / expired / 404,
    // which HttpExceptionFilter converts to 404 / 410 problem+json.
    const character = await this.queryBus.execute<GetPublicCharacterQuery, CharacterReadModel>(
      new GetPublicCharacterQuery(slug),
    );

    const png = await this.ogService.renderCharacter(character);

    res.set({
      'Content-Type': 'image/png',
      'Content-Length': String(png.length),
      'Cache-Control': 'public, max-age=3600, stale-while-revalidate=86400',
    });
    res.send(png);
  }
}

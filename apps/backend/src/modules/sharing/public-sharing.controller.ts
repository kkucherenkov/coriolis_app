/**
 * WHY this file exists:
 * Public (unauthenticated) HTTP entry point for anonymous character reads and
 * the OG image stub. No SessionGuard — these routes are accessible without auth.
 *
 * The controller declares path: 'public' so routes resolve to:
 *   GET /api/v1/public/character/:slug
 *   GET /api/v1/public/og/character/:slug.png  (501 stub — Feature 6.3)
 */
import { Controller, Get, HttpException, Param } from '@nestjs/common';
import { QueryBus } from '@nestjs/cqrs';

import { GetPublicCharacterQuery } from './queries/get-public-character.query';

import type { CharacterReadModel } from '../characters/domain/character.ports';

@Controller({ path: 'public', version: '1' })
export class PublicSharingController {
  constructor(private readonly queryBus: QueryBus) {}

  /** GET /api/v1/public/character/:slug */
  @Get('character/:slug')
  async getPublicCharacter(@Param('slug') slug: string): Promise<CharacterReadModel> {
    return this.queryBus.execute(new GetPublicCharacterQuery(slug));
  }

  /**
   * GET /api/v1/public/og/character/:slug.png
   *
   * Stub — always 501 until Feature 6.3 ships the server-side OG renderer.
   * Cache headers planned for the eventual 200:
   *   Cache-Control: public, max-age=3600, stale-while-revalidate=86400
   */
  @Get('og/character/:slug.png')
  getCharacterOgImage(): never {
    throw new HttpException(
      {
        type: 'https://errors.coriolis-companion.app/og-not-implemented',
        title: 'OG image renderer not yet implemented',
        status: 501,
        code: 'OG_NOT_IMPLEMENTED',
        detail: 'The OG image renderer ships in Epic 6 Feature 6.3.',
      },
      501,
    );
  }
}

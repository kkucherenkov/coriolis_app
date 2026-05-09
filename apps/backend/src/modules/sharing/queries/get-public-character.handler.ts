import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import type { CharacterReadModel } from '../../characters/domain/character.ports';
import {
  ShareLinkExpiredError,
  ShareLinkNotFoundError,
  ShareLinkRevokedError,
} from '../domain/share-link.errors';
import { SHARE_LINK_REPO } from '../domain/share-link.ports';
import { ViewTracker } from '../infra/view-tracker';

import { GetPublicCharacterQuery } from './get-public-character.query';

import type { IShareLinkRepo } from '../domain/share-link.ports';

@QueryHandler(GetPublicCharacterQuery)
export class GetPublicCharacterHandler implements IQueryHandler<
  GetPublicCharacterQuery,
  CharacterReadModel
> {
  constructor(
    @Inject(SHARE_LINK_REPO) private readonly repo: IShareLinkRepo,
    private readonly viewTracker: ViewTracker,
  ) {}

  async execute(query: GetPublicCharacterQuery): Promise<CharacterReadModel> {
    const { slug } = query;

    const result = await this.repo.findCharacterBySlug(slug);

    if (!result) {
      throw new ShareLinkNotFoundError(slug);
    }

    const { shareLink, character } = result;

    // Check revocation first (revokedAt takes precedence over expiry)
    if (shareLink.revokedAt) {
      throw new ShareLinkRevokedError(slug);
    }

    // Check expiry
    if (shareLink.expiresAt && new Date(shareLink.expiresAt) < new Date()) {
      throw new ShareLinkExpiredError(slug);
    }

    // Record the view asynchronously — no DB hit on the read path
    this.viewTracker.recordView(slug);

    // Apply notes filter
    if (!shareLink.includeGmNotes) {
      return { ...character, notes: null };
    }

    return character;
  }
}

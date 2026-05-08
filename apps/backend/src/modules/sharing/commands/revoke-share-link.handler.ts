import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { ShareLinkNotFoundError, ShareLinkNotOwnedError } from '../domain/share-link.errors';
import { SHARE_LINK_REPO } from '../domain/share-link.ports';

import { RevokeShareLinkCommand } from './revoke-share-link.command';

import type { IShareLinkRepo } from '../domain/share-link.ports';

@CommandHandler(RevokeShareLinkCommand)
export class RevokeShareLinkHandler implements ICommandHandler<RevokeShareLinkCommand, void> {
  constructor(@Inject(SHARE_LINK_REPO) private readonly repo: IShareLinkRepo) {}

  async execute(command: RevokeShareLinkCommand): Promise<void> {
    const { callerId, shareLinkId } = command;

    const ownership = await this.repo.findOwnerIdByShareLinkId(shareLinkId);
    if (!ownership) {
      throw new ShareLinkNotFoundError(shareLinkId);
    }

    if (ownership.ownerId !== callerId) {
      throw new ShareLinkNotOwnedError(shareLinkId);
    }

    await this.repo.revoke(shareLinkId);
  }
}

/**
 * WHY this file exists:
 * Command handler for `UpdateMeCommand`. Applies the displayName update to the
 * user row via the repo port and returns the refreshed `MeReadModel`.
 *
 * Returning the full model from a command is acceptable here because the
 * PATCH /me endpoint always needs to return the updated resource and there is
 * no separate read path that would diverge. The alternative (command returns
 * void, controller issues a GetMeQuery) would add a redundant round-trip to
 * the same table.
 *
 * Domain validation (empty string, too long) is handled by class-validator on
 * the DTO before the command is dispatched, so the handler can trust the input.
 * The handler re-validates as defence in depth for programmatic callers that
 * bypass the HTTP layer.
 */
import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import {
  DisplayNameEmptyError,
  DisplayNameTooLongError,
  InvalidThemeError,
  UserNotFoundError,
} from '../domain/user.errors';
import { USER_REPO } from '../domain/user.ports';

import { UpdateMeCommand } from './update-me.command';

import type { IUserRepo, MeReadModel, UserTheme } from '../domain/user.ports';

const ALLOWED_THEMES: ReadonlySet<string> = new Set<UserTheme>(['dark', 'high-contrast']);

@CommandHandler(UpdateMeCommand)
export class UpdateMeHandler implements ICommandHandler<UpdateMeCommand, MeReadModel> {
  constructor(@Inject(USER_REPO) private readonly repo: IUserRepo) {}

  async execute(command: UpdateMeCommand): Promise<MeReadModel> {
    const { userId, displayName, theme, chatDockedCollapsed } = command;

    // Defence-in-depth validation (DTO layer already enforces these via
    // class-validator, but programmatic callers may bypass the pipe).
    if (displayName !== undefined && displayName !== null) {
      if (displayName === '') {
        throw new DisplayNameEmptyError();
      }
      if (displayName.length > 80) {
        throw new DisplayNameTooLongError();
      }
    }

    if (theme !== undefined && !ALLOWED_THEMES.has(theme)) {
      throw new InvalidThemeError(theme);
    }

    // Verify user exists before writing (findActiveById respects soft-delete).
    const existing = await this.repo.findActiveById(userId);
    if (!existing) {
      throw new UserNotFoundError(userId);
    }

    // `displayName` undefined means the field was omitted from the PATCH body —
    // preserve the existing value.
    const nextDisplayName = displayName === undefined ? existing.displayName : displayName;
    const nextTheme: UserTheme = theme ?? existing.theme;
    const nextChatDockedCollapsed =
      chatDockedCollapsed === undefined ? existing.chatDockedCollapsed : chatDockedCollapsed;

    return this.repo.updateProfile(userId, {
      displayName: nextDisplayName,
      theme: nextTheme,
      chatDockedCollapsed: nextChatDockedCollapsed,
    });
  }
}

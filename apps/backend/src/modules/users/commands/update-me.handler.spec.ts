/**
 * Unit tests for UpdateMeHandler.
 * The repo port is a vi.fn() mock; no NestJS or Prisma bootstrapping.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  DisplayNameEmptyError,
  DisplayNameTooLongError,
  UserNotFoundError,
} from '../domain/user.errors';

import { UpdateMeCommand } from './update-me.command';
import { UpdateMeHandler } from './update-me.handler';

import type { IUserRepo, MeReadModel } from '../domain/user.ports';

function makeRepo(): IUserRepo {
  return {
    findActiveById: vi.fn(),
    updateDisplayName: vi.fn(),
    softDelete: vi.fn(),
  };
}

function makeMeReadModel(overrides: Partial<MeReadModel> = {}): MeReadModel {
  return {
    id: 'user-1',
    email: 'kalim@example.com',
    displayName: null,
    createdAt: '2026-01-15T09:30:00.000Z',
    ...overrides,
  };
}

describe('UpdateMeHandler', () => {
  let repo: IUserRepo;
  let handler: UpdateMeHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new UpdateMeHandler(repo);
  });

  it('updates displayName and returns refreshed MeReadModel', async () => {
    const existing = makeMeReadModel({ displayName: null });
    const updated = makeMeReadModel({ displayName: 'Kalim al-Rashid' });
    vi.mocked(repo.findActiveById).mockResolvedValue(existing);
    vi.mocked(repo.updateDisplayName).mockResolvedValue(updated);

    const result = await handler.execute(new UpdateMeCommand('user-1', 'Kalim al-Rashid'));

    expect(result).toEqual(updated);
    expect(repo.updateDisplayName).toHaveBeenCalledWith('user-1', 'Kalim al-Rashid');
  });

  it('clears displayName when null is passed', async () => {
    const existing = makeMeReadModel({ displayName: 'Old Name' });
    const updated = makeMeReadModel({ displayName: null });
    vi.mocked(repo.findActiveById).mockResolvedValue(existing);
    vi.mocked(repo.updateDisplayName).mockResolvedValue(updated);

    const result = await handler.execute(new UpdateMeCommand('user-1', null));

    expect(result.displayName).toBeNull();
    expect(repo.updateDisplayName).toHaveBeenCalledWith('user-1', null);
  });

  it('preserves existing displayName when field is omitted (undefined)', async () => {
    const existing = makeMeReadModel({ displayName: 'Existing Name' });
    const updated = makeMeReadModel({ displayName: 'Existing Name' });
    vi.mocked(repo.findActiveById).mockResolvedValue(existing);
    vi.mocked(repo.updateDisplayName).mockResolvedValue(updated);

    await handler.execute(new UpdateMeCommand('user-1', undefined));

    // When displayName is undefined the handler uses the existing value
    expect(repo.updateDisplayName).toHaveBeenCalledWith('user-1', 'Existing Name');
  });

  it('preserves createdAt and email (does not mutate them)', async () => {
    const existing = makeMeReadModel({
      email: 'kalim@example.com',
      createdAt: '2026-01-15T09:30:00.000Z',
    });
    const updated = makeMeReadModel({
      email: 'kalim@example.com',
      createdAt: '2026-01-15T09:30:00.000Z',
      displayName: 'New Name',
    });
    vi.mocked(repo.findActiveById).mockResolvedValue(existing);
    vi.mocked(repo.updateDisplayName).mockResolvedValue(updated);

    const result = await handler.execute(new UpdateMeCommand('user-1', 'New Name'));

    expect(result.email).toBe('kalim@example.com');
    expect(result.createdAt).toBe('2026-01-15T09:30:00.000Z');
  });

  it('throws DisplayNameEmptyError when displayName is an empty string', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeMeReadModel());

    await expect(handler.execute(new UpdateMeCommand('user-1', ''))).rejects.toBeInstanceOf(
      DisplayNameEmptyError,
    );
    // Should not reach the repo write
    expect(repo.updateDisplayName).not.toHaveBeenCalled();
  });

  it('throws DisplayNameEmptyError with 400 status and DISPLAY_NAME_EMPTY code', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeMeReadModel());

    await expect(handler.execute(new UpdateMeCommand('user-1', ''))).rejects.toMatchObject({
      status: 400,
      code: 'DISPLAY_NAME_EMPTY',
    });
  });

  it('throws DisplayNameTooLongError when displayName exceeds 80 characters', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeMeReadModel());
    const tooLong = 'a'.repeat(81);

    await expect(
      handler.execute(new UpdateMeCommand('user-1', tooLong)),
    ).rejects.toBeInstanceOf(DisplayNameTooLongError);
    expect(repo.updateDisplayName).not.toHaveBeenCalled();
  });

  it('throws DisplayNameTooLongError with 400 status and DISPLAY_NAME_TOO_LONG code', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(makeMeReadModel());
    const tooLong = 'a'.repeat(81);

    await expect(
      handler.execute(new UpdateMeCommand('user-1', tooLong)),
    ).rejects.toMatchObject({
      status: 400,
      code: 'DISPLAY_NAME_TOO_LONG',
    });
  });

  it('throws UserNotFoundError when user does not exist', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(null);

    await expect(
      handler.execute(new UpdateMeCommand('missing', 'Name')),
    ).rejects.toBeInstanceOf(UserNotFoundError);
  });

  it('accepts exactly 80 characters as a valid displayName', async () => {
    const maxLength = 'a'.repeat(80);
    const existing = makeMeReadModel();
    const updated = makeMeReadModel({ displayName: maxLength });
    vi.mocked(repo.findActiveById).mockResolvedValue(existing);
    vi.mocked(repo.updateDisplayName).mockResolvedValue(updated);

    const result = await handler.execute(new UpdateMeCommand('user-1', maxLength));

    expect(result.displayName).toBe(maxLength);
  });
});

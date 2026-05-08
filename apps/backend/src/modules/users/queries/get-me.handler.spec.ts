/**
 * Unit tests for GetMeHandler.
 * Pattern from the project template: repo port is a vi.fn() mock, handler
 * is instantiated directly — no NestJS bootstrapping needed.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { UserNotFoundError } from '../domain/user.errors';

import { GetMeQuery } from './get-me.query';
import { GetMeHandler } from './get-me.handler';

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

describe('GetMeHandler', () => {
  let repo: IUserRepo;
  let handler: GetMeHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new GetMeHandler(repo);
  });

  it('returns MeReadModel when user is found', async () => {
    const model = makeMeReadModel({ id: 'user-1', displayName: 'Kalim al-Rashid' });
    vi.mocked(repo.findActiveById).mockResolvedValue(model);

    const result = await handler.execute(new GetMeQuery('user-1'));

    expect(result).toEqual(model);
    expect(repo.findActiveById).toHaveBeenCalledWith('user-1');
  });

  it('returns displayName as null when user has not set one', async () => {
    const model = makeMeReadModel({ displayName: null });
    vi.mocked(repo.findActiveById).mockResolvedValue(model);

    const result = await handler.execute(new GetMeQuery('user-1'));

    expect(result.displayName).toBeNull();
  });

  it('throws UserNotFoundError when repo returns null (user deleted or not found)', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(null);

    await expect(handler.execute(new GetMeQuery('missing'))).rejects.toBeInstanceOf(
      UserNotFoundError,
    );
  });

  it('throws UserNotFoundError with 404 status', async () => {
    vi.mocked(repo.findActiveById).mockResolvedValue(null);

    await expect(handler.execute(new GetMeQuery('soft-deleted'))).rejects.toMatchObject({
      status: 404,
      code: 'USER_NOT_FOUND',
    });
  });
});

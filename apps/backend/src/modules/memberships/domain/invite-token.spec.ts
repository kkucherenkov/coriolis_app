import { describe, expect, it } from 'vitest';

import { generateInviteToken, hashInviteToken } from './invite-token';

describe('invite-token', () => {
  it('generateInviteToken returns a 22-char URL-safe nanoid', () => {
    const token = generateInviteToken();
    expect(token).toHaveLength(22);
    expect(token).toMatch(/^[A-Za-z0-9_-]{22}$/);
  });

  it('generateInviteToken produces unique values', () => {
    const tokens = new Set(Array.from({ length: 1000 }, () => generateInviteToken()));
    expect(tokens.size).toBe(1000);
  });

  it('hashInviteToken returns a 64-char lowercase hex SHA-256', () => {
    const hash = hashInviteToken('Sl9X3kQpZr8mVtNuY7Hb2C');
    expect(hash).toHaveLength(64);
    expect(hash).toMatch(/^[0-9a-f]{64}$/);
  });

  it('hashInviteToken is deterministic', () => {
    const a = hashInviteToken('Sl9X3kQpZr8mVtNuY7Hb2C');
    const b = hashInviteToken('Sl9X3kQpZr8mVtNuY7Hb2C');
    expect(a).toBe(b);
  });

  it('hashInviteToken yields different hashes for different inputs', () => {
    expect(hashInviteToken('a')).not.toBe(hashInviteToken('b'));
  });
});

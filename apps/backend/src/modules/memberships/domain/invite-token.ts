/**
 * WHY this file exists:
 * Pure helpers — no DI, no side effects beyond `crypto`. Isolated here so
 * unit tests can exercise them without a NestJS container.
 *
 * Token length 22 chars over the nanoid default alphabet
 * (URL-safe: A–Z a–z 0–9 _ -) yields ~131 bits of entropy, well above
 * the threshold for an invite that any holder can use. Stored as
 * SHA-256 (hex) at rest; plaintext is returned to the GM exactly once.
 */
import { createHash } from 'node:crypto';

import { nanoid } from 'nanoid';

const INVITE_TOKEN_LENGTH = 22;

export function generateInviteToken(): string {
  return nanoid(INVITE_TOKEN_LENGTH);
}

export function hashInviteToken(plaintext: string): string {
  return createHash('sha256').update(plaintext, 'utf8').digest('hex');
}

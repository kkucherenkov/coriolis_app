/**
 * WHY this file exists:
 * Pure slug generation helper — no side effects, no dependencies.
 * Isolated here so unit tests can exercise it without any DI container.
 *
 * Alphabet decision (ADR 0003):
 * Excludes ambiguous characters (0, O, I, l, 1) so slugs are safe to
 * read from printed material and transcribe by hand. 24 chars from a
 * 56-symbol alphabet yields ~139 bits of entropy — effectively unguessable.
 */
import { customAlphabet } from 'nanoid';

/** Unambiguous alphabet: digits 2–9 + uppercase (no 0OI) + lowercase (no l). */
export const SLUG_ALPHABET = '23456789ABCDEFGHJKMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz';

/** Length chosen for ~139-bit entropy. */
export const SLUG_LENGTH = 24;

const nanoid = customAlphabet(SLUG_ALPHABET, SLUG_LENGTH);

/**
 * Generate a cryptographically random, URL-safe share-link slug.
 * Returns exactly `SLUG_LENGTH` characters from `SLUG_ALPHABET`.
 */
export function generateSlug(): string {
  return nanoid();
}

/**
 * WHY this file exists:
 * Pure helper functions for Coriolis dice mechanics. No I/O, no DI.
 * Uses Node.js crypto.randomInt for a cryptographically secure uniform
 * distribution over [1, 6].
 *
 * PRD §10: Hit = face value of 6. Pool range: 1–10.
 */
import { randomInt } from 'node:crypto';

/**
 * Roll `pool` d6 using a cryptographically secure RNG.
 * Each die is independently drawn from [1, 6] with uniform probability.
 */
export function rollPool(pool: number): number[] {
  const dice: number[] = [];
  for (let i = 0; i < pool; i++) {
    // randomInt(min, max) returns an integer in [min, max)
    dice.push(randomInt(1, 7));
  }
  return dice;
}

/**
 * Count hits (6s) in a dice array.
 */
export function countHits(dice: number[]): number {
  return dice.filter((d) => d === 6).length;
}

/**
 * Reroll all non-6 dice in place (push mechanic, PRD §10).
 * Returns a new array; the 6s are preserved.
 */
export function pushDice(dice: number[]): number[] {
  return dice.map((d) => (d === 6 ? d : randomInt(1, 7)));
}

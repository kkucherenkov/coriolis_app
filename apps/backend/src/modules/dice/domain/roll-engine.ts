/**
 * WHY this file exists:
 * Pure helper functions for Coriolis dice mechanics. No I/O, no DI.
 * Uses Node.js crypto.randomInt for a cryptographically secure uniform
 * distribution over [1, 6].
 *
 * Pool range: 0–20 (canon ST3001 has no hard upper bound; 20 is a
 * payload-size cap). `pool === 0` triggers the «Ноль кубиков» rule
 * (ГЛАВА 3 line 161): roll 2d6, success only on a double six.
 */
import { randomInt } from 'node:crypto';

const ZERO_POOL_DICE_COUNT = 2;

/**
 * Roll `pool` d6 using a cryptographically secure RNG.
 * Each die is independently drawn from [1, 6] with uniform probability.
 * `pool === 0` rolls 2 dice per the Ноль кубиков rule; the caller must
 * pass `pool` to {@link countHits} so the success rule is applied.
 */
export function rollPool(pool: number): number[] {
  const physicalCount = pool === 0 ? ZERO_POOL_DICE_COUNT : pool;
  const dice: number[] = [];
  for (let i = 0; i < physicalCount; i++) {
    // randomInt(min, max) returns an integer in [min, max)
    dice.push(randomInt(1, 7));
  }
  return dice;
}

/**
 * Count successes (6s) in a dice array.
 *
 * For `pool === 0` the Ноль кубиков rule applies: a success is only
 * counted when *every* rolled die is a 6 (i.e. double sixes), and the
 * call returns 1 on success and 0 otherwise — never the raw 6-count.
 */
export function countHits(dice: number[], pool: number): number {
  if (pool === 0) {
    return dice.length > 0 && dice.every((d) => d === 6) ? 1 : 0;
  }
  return dice.filter((d) => d === 6).length;
}

/**
 * Reroll all non-6 dice in place (push mechanic, PRD §10).
 * Returns a new array; the 6s are preserved.
 */
export function pushDice(dice: number[]): number[] {
  return dice.map((d) => (d === 6 ? d : randomInt(1, 7)));
}

/**
 * Barrel export for the rules-engine module.
 * Import from here rather than from the internal file.
 */
export {
  computeHpMax,
  computeMpMax,
  computeEncumbranceMax,
  computeEncumbranceCurrent,
  canPush,
  applyConditions,
} from './rules-engine';
export type { ConditionFlags } from './rules-engine';

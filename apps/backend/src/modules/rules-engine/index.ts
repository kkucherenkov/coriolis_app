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
  UPBRINGING_BUDGETS,
  sumAttributes,
  sumSkills,
} from './rules-engine';
export type { CanPushResult, ConditionFlags, Upbringing, UpbringingBudget } from './rules-engine';

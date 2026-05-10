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
  CONCEPT_KEYS,
  sumAttributes,
  sumSkills,
} from './rules-engine';
export type {
  AttributeKey,
  CanPushResult,
  ConditionFlags,
  Concept,
  ConceptKeys,
  CrewConcept,
  SkillKey,
  TalentKind,
  Upbringing,
  UpbringingBudget,
} from './rules-engine';
export { BASE_STATS_BY_CLASS } from './ship-class-table';
export type { ShipBaseStats } from './ship-class-table';
